require "spec_helper"

describe TCPScraper do
  let(:f) {
    TCPScraper.new.tracker("tracker.ccc.de/scrape?")
  }
  
  it "should return multiply values" do
    #f.hashes("2bbf3d63e6b313ecf2655067b51e93f17eeeb135", "2bbf3d62e6b313ecf2655067b51e93f17eeeb135").process.keys.count.should eq(2)
  end
  
  it "should return a single value" do
    f.hash("2bbf3d63e6b313ecf2655067b51e93f17eeeb135").process#[:completed]#.should_not be_nil
  end
end