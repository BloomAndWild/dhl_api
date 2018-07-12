module DHLApi
  class RequestHandler
    class << self
      def request(request_name, attrs)
        new(request_name, attrs).request
      end
    end

    def initialize(request_name, attrs)
      @request_name = request_name.to_sym
      @attrs = attrs
    end

    def request
      raw_response = get_response
      parse_response(raw_response)
    end

    def xml_builder(attrs={})
      @xml_builder ||= DHLApi::XMLBuilder.new(request_name, attrs, request_type)
    end

    def client
      if request_type == :soap
        Savon.client(
          adapter: :httpclient,
          basic_auth: [
            config.basic_auth_username,
            config.basic_auth_password,
          ],
          wsdl: config.service_wsdl,
          endpoint: config.soap_endpoint,
          namespace: config.soap_endpoint,
          open_timeout: 600,
          read_timeout: 600,
          logger: config.logger,
          log_level: config.logger.level.zero? ? :debug : :info,
          log: config.logger.level.zero?,
          pretty_print_xml: true,
        )
      else
        Faraday.new(url: config.rest_endpoint) do |conn|
          conn.response :raise_error
          conn.adapter :httpclient
          conn.basic_auth(config.basic_auth_username, config.basic_auth_password)
          conn.options.timeout = 60
          conn.options.open_timeout = 60
          # conn.response :logger, ::Logger.new(STDOUT), bodies: true
        end
      end
    end

    private
    attr_accessor :request_name, :attrs

    def get_response
      xml = xml_builder(attrs.merge(security_attrs)).build

      if request_type == :soap
        client.call(request_endpoint, xml: xml)
      elsif request_type == :rest
        client.get(request_endpoint, xml: xml)
      end
    end

    def parse_response raw_response
      response = begin
        case request_name
        when :do_manifest
          DHLApi::Responses::DoManifest.new(raw_response)
        when :create_shipment
          DHLApi::Responses::CreateShipment.new(raw_response)
        when :get_piece
          DHLApi::Responses::GetPiece.new(raw_response)
        when :delete_shipment
          DHLApi::Responses::DeleteShipment.new(raw_response)
        end
      rescue => ex
        raise DHLApi::DHLError.new(ex.message, body: raw_response.body)
      end

      if response.status_code != "0"
        raise DHLApi::DHLError.new(
          response.status_message,
          body: raw_response.body,
          attrs: xml_builder.to_h.reject { |k,v| security_attrs.keys.include? k },
          status_code: response.status_code,
          status_text: response.status_text,
        )
      end

      response
    end

    def request_type
      case request_name
      when :get_piece
        :rest
      when :create_shipment, :do_manifest, :delete_shipment
        :soap
      end
    end

    def request_endpoint
      case request_name
      when :delete_shipment
        :delete_shipment_order
      when :create_shipment
        :create_shipment_order
      when :get_piece
        "sendungsverfolgung"
      else
        request_name
      end
    end

    def security_attrs
      {
        username: config.username,
        password: config.password,
        account_number: config.account_number,
        zt_id: config.zt_id,
        zt_password: config.zt_password,
      }
    end

    def config
      @config ||= Client.config
    end
  end
end
