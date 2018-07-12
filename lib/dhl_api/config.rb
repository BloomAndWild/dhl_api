module DHLApi
  class Config
    attr_writer :soap_endpoint, :service_wsdl, :rest_endpoint, :logger
    attr_accessor :username, :password, :account_number,
      :basic_auth_username, :basic_auth_password, :zt_id, :zt_password, :sandbox

    def service_wsdl
      @service_wsdl ||= File.join(DHLApi.root_path, 'lib', 'wsdl', 'dhl.wsdl')
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def soap_endpoint
      @soap_endpoint ||= if sandbox
        "https://cig.dhl.de/services/sandbox/soap"
      else
        "https://cig.dhl.de/services/production/soap"
      end
    end

    def rest_endpoint
      @rest_endpoint ||= if sandbox
        "https://cig.dhl.de/services/sandbox/rest"
      else
        "https://cig.dhl.de/services/production/rest"
      end
    end
  end
end

