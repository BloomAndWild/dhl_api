require 'erb'
require 'ostruct'

module DHLApi
  class XMLBuilder < OpenStruct
    attr_reader :request

    def initialize(request, attrs = {}, type = :soap)
      @request = request
      @type = type

      formatted_attrs = DHLApi::XMLFormatter.format_attrs(attrs)
      super formatted_attrs
    end

    def build
      case type
      when :soap
        envelope
      when :rest
        body
      end
    end

    private
    attr_reader :type

    def xml_path
      [DHLApi.root_path, 'lib', 'xml']
    end

    def build_xml(file)
      path = File.join(xml_path << file)
      ERB.new(File.read(path)).result(binding)
    end

    def header
      build_xml("security_header.xml.erb")
    end

    def body
      build_xml("#{request}.xml.erb")
    end

    def envelope
      build_xml("shipping_envelope.xml.erb")
    end
  end
end
