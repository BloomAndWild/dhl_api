require 'openssl'
require 'base64'
require 'savon'
require 'faraday'
require_relative "dhl_api/version"
require_relative "dhl_api/client"
require_relative "dhl_api/config"
require_relative "dhl_api/request_handler"
require_relative "dhl_api/xml_builder"
require_relative "dhl_api/xml_formatter"
require_relative "dhl_api/dhl_error"
require_relative "dhl_api/responses/create_shipment"
require_relative "dhl_api/responses/delete_shipment"
require_relative "dhl_api/responses/get_piece"
require_relative "dhl_api/responses/do_manifest"

module DHLApi
  def self.root_path
    File.dirname __dir__
  end
end
