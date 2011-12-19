require "spec_helper"
require "yaml"

describe Firecracker::TCPScraper do
  let(:f) {
    Firecracker::TCPScraper.new.tracker("tracker.ccc.de/scrape")
  }
  
  it "should return multiply values" do
    f.hashes("2bbf3d63e6b313ecf2655067b51e93f17eeeb135", "3c6a84bc53a91e5ed707091fbd928c91ed0eeacf").process.keys.count.should eq(2)
  end
  
  it "should return a single value" do
    f.hash("2bbf3d63e6b313ecf2655067b51e93f17eeeb135").process[:completed].should_not be_nil
  end
end