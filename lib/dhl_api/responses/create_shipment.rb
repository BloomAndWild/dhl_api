module DHLApi
  module Responses
    class CreateShipment
      attr_accessor :body, :status_code, :base64_pdf_label, :shipment_number,
        :status_message, :status_text

      def initialize(response)
        @body = response.body[:create_shipment_order_response]
        @status_code = body[:creation_state][:label_data][:status][:status_code]
        @status_message = Array(body[:creation_state][:label_data][:status][:status_message]).join("\n")
        @status_text = body[:creation_state][:label_data][:status][:status_text]
        @base64_pdf_label = body[:creation_state][:label_data][:label_data]
        @shipment_number = body[:creation_state][:label_data][:shipment_number]
      end

      def tracking_url
        "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=#{shipment_number}&rfn=&extendedSearch=true"
      end
    end
  end
end
