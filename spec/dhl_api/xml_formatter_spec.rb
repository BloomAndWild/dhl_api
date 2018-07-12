require 'spec_helper'

describe DHLApi::XMLFormatter do
  it "works with nested hashes" do
    expect(subject.format_attrs(recipient: { name: "Bloom & Wild" })).to eq(recipient: { name: "Bloom &amp; Wild" })
  end
end
