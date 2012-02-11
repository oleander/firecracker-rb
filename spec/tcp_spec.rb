require "spec_helper"
require "yaml"

describe Firecracker::TCPScraper do
  describe "initialize" do
    let(:hashes) { ["c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0"] }
    let(:raw){
      Firecracker::TCPScraper.new({
        tracker: "exodus.desync.com:6969/announce",
        hashes: hashes,
        debug: true
      }).process!
    }
    
    let(:values) { raw[raw.keys.first] }
    
    it "should match the number of hashes" do
      raw.should have(1).keys
    end
    
    it "should have 3 categories" do
      values.keys.each do |key|
        [:downloaded, :complete, :incomplete].should include(key)
      end
    end
    
    it "should only contain values greater than zero" do
      values.keys.each do |key|
        values[key].should > 0
      end
    end
  end
end