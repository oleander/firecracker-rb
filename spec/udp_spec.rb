require "spec_helper"

describe Firecracker::UDPScraper do
  let(:hashes) { ["523d83e8aee1a979e66584b5304d2e8fdc9a1675"] }

  let(:raw){
    Firecracker::UDPScraper.new({
      tracker: "tracker.openbittorrent.com",
       hashes: hashes
    }).process!
  }
  
  let(:values) { raw[raw.keys.first] }
  
  it "should match the number of hashes" do
    raw.should have(1).keys
    raw.keys.first.should eq(hashes.first)
  end
  
  it "should have 3 categories" do
    values.keys.each do |key|
      [:downloads, :seeders, :leechers].should include(key)
    end
  end
  
  it "should only contain values greater than zero" do
    values.keys.each do |key|
      values[key].should > 0
    end
  end
end