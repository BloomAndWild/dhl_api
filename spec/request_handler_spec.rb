require "spec_helper"

describe DHLApi::RequestHandler do
  context "do_manifest" do
    it "fails if shipment was already cancelled" do
      VCR.use_cassette('do_manifest_cancelled') do
        expect {
          described_class.request(:do_manifest, tracking_numbers: ["575007012489"])
        }.to raise_error(/Die Sendungsnummer ist in der aktuellen Nutzergruppe nicht bekannt./)
      end
    end

    it "sends shipment manifest" do
      VCR.use_cassette('do_manifest') do
        response = described_class.request(:do_manifest, tracking_numbers: ["575007012495"])
        expect(response.status_message).to eq("Der Webservice wurde ohne Fehler ausgeführt.")
      end
    end
  end

  context "delete_shipment" do
    it "cancels shipment order" do
      VCR.use_cassette('delete_shipment') do
        response = described_class.request(:delete_shipment, tracking_number: "575007012489")
        expect(response.status_message).to eq("Der Webservice wurde ohne Fehler ausgeführt.")
      end
    end
  end

  context "get_piece" do
    describe "#request" do
      it "gets parcel delivery details" do
        VCR.use_cassette('get_piece') do
          response = described_class.request(:get_piece, tracking_number: "575007184406")
          expect(response.status_message).to eq("Delivery successful")
          expect(response.status_text).to eq("The shipment has been successfully delivered")
        end
      end

      it "handles errors" do
        VCR.use_cassette('get_piece_error') do
          expect{
            described_class.request(:get_piece, tracking_number: "INVALIDNUMBER")
          }.to raise_error(DHLApi::DHLError)
        end
      end
    end
  end

  context "packstation create_shipment" do
    describe "#request" do
      let(:attrs) do
        {
          sequence_number: "01",
          product: "V01PAK",
          customer_reference: "1892475249",
          shipment_date: "2018-05-21",
          weight: 1,
          shipper_address: {
            name1: "Test Shipment",
            street_name: "Odenwaldstrasse",
            street_number: "900",
            zip_code: 63263,
            city: "Neu-Isenburg",
            countryISOCode: "DE",
            email: "dev@bloomandwild.com",
            phone: "2284000000",
          },
          recipient_address: {
            name1: "Test User",
            street_name: "Packstation",
            street_number: "172",
            address_addition: "2626466",
            zip_code: "50969",
            city: "Köln",
            countryISOCode: "DE",
            email: "dev@bloomandwild.com",
            phone: "2284000000",
          },
          label_type: 'B64',
        }
      end

      subject { described_class }

      let(:response) do
        subject.request(:create_shipment, attrs)
      end

      context "with request_name :create_shipment" do
        it "books a shipment with DHL" do
          VCR.use_cassette('create_shipment_packstation') do
            expect(response.body).to be_a Hash
            expect(response.status_code).to eq "0"
            expect(response.base64_pdf_label).to be_a String
            expect(response.shipment_number).to eq "575007190368"
            expect(response.tracking_url).to eq "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=575007190368&rfn=&extendedSearch=true"
          end
        end
      end
    end
  end

  context "create_shipment" do
    describe "#request" do
      let(:shipment_date) { "2018-05-21" }
      let(:attrs) do
        {
          sequence_number: "01",
          product: "V01PAK",
          customer_reference: "800000000000",
          shipment_date: shipment_date,
          weight: 1,
          shipper_address: {
            name1: "Test Shipment",
            street_name: "Herbäcker",
            street_number: "999",
            zip_code: "63179",
            city: "Obertshausen",
            countryISOCode: "DE",
          },
          recipient_address: {
            name1: "Test User",
            name2: "",
            name3: "",
            street_name: "Lutzowplatz",
            street_number: "7",
            address_addition: "",
            dispatching_information: "",
            zip_code: "10785",
            city: "Berlin",
            countryISOCode: "DE",
          },
          label_type: 'B64',
        }
      end

      subject { described_class }

      let(:response) do
        subject.request(:create_shipment, attrs)
      end

      context "with request_name :create_shipment" do
        it "books a shipment with DHL" do
          VCR.use_cassette('create_shipment') do
            expect(response.body).to be_a Hash
            expect(response.status_code).to eq "0"
            expect(response.base64_pdf_label).to be_a String
            expect(response.shipment_number).to eq "222201010017209788"
            expect(response.tracking_url).to eq "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=222201010017209788&rfn=&extendedSearch=true"
          end
        end
      end

      context "with enabled preferred time service" do
        let(:shipment_date) { "2019-04-25" }

        let(:preferred_time_attributes) do
          {
            preferred_time_frame: "18002000",
          }
        end

        let(:response) do
          subject.request(:create_shipment, attrs.merge(preferred_time_attributes))
        end

        it "books a shipment with DHL" do
          VCR.use_cassette('create_preferred_time_shipment_enabled') do
            expect(response.body).to be_a Hash
            expect(response.status_code).to eq "0"
            expect(response.base64_pdf_label).to be_a String
            expect(response.shipment_number).to eq "575007398368"
            expect(response.tracking_url).to eq "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=575007398368&rfn=&extendedSearch=true"
          end
        end
      end

      context "with disabled preferred time service" do
        let(:shipment_date) { "2019-04-25" }

        let(:preferred_time_attributes) do
          {
            preferred_time_frame: nil,
          }
        end

        let(:response) do
          subject.request(:create_shipment, attrs.merge(preferred_time_attributes))
        end

        it "books a shipment with DHL" do
          VCR.use_cassette('create_preferred_time_shipment_disabled') do
            expect(response.body).to be_a Hash
            expect(response.status_code).to eq "0"
            expect(response.base64_pdf_label).to be_a String
            expect(response.shipment_number).to eq "575007398374"
            expect(response.tracking_url).to eq "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc=575007398374&rfn=&extendedSearch=true"
          end
        end
      end

      context "with incorrect booking params" do
        before do
          attrs[:recipient_address] = { zip_code: "not a zip code" }
        end

        it "raises a DHLApi::DHLError" do
          VCR.use_cassette('create_shipment_incorrect_params') do
            expect { response }.to raise_error(
              DHLApi::DHLError,
              [
                "Bitte geben Sie ein Land an.",
                "Bitte geben Sie bei der Empfängeradresse ein Land an.",
                "Bitte geben Sie ein Land an.",
                "Das angegebene Produkt ist für das Land nicht verfügbar.",
              ].join("\n")
            )
          end
        end
      end
    end
  end
end
