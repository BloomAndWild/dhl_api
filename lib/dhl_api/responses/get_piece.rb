module DHLApi
  module Responses
    class GetPiece
      attr_accessor :body

      def initialize(response)
        @body = response.body
      end

      def status_timestamp
        DateTime.parse(tracking_details["@status_timestamp"])
      end

      def status_message
        if tracking_details["@short_status"].blank?
          tracking_details["@piece_status_desc"]
        else
          tracking_details["@short_status"]
        end
      end

      def status_text
        tracking_details["@status"]
      end

      def status_code
        tracking_details["@error_status"]
      end

      def tracking_details
        @tracking_details ||= Nori.new.parse(body)["data"]["data"]
      end
    end
  end
end
