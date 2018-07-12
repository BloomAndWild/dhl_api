module DHLApi
  module Responses
    class DoManifest
      attr_accessor :body, :status_code, :status_message, :status_text

      def initialize(response)
        @body = response.body[:do_manifest_response]
        @status_code = body[:status][:status_code]
        @status_message = Array(body[:status][:status_message]).join("\n")
        @status_text = body[:status][:status_text]
      end
    end
  end
end
