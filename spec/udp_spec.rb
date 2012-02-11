require "spec_helper"

describe Firecracker::UDPScraper do
  let(:hashes) { ["0ef176d06f3053375d93eebe43608dfbec053e3c"] }

  let(:raw){
    Firecracker::UDPScraper.new({
      tracker: "tracker.ccc.de:80",
       hashes: hashes
    }).process!
  }
  
  it "should return multiply values" do
    #f.hashes("2bbf3d63e6b313ecf2655067b51e93f17eeeb135", "2bbf3d62e6b313ecf2655067b51e93f17eeeb135").process.keys.count.should eq(2)
  end
  
  it "should return a single value" do
    #f.hash("2bbf3d63e6b313ecf2655067b51e93f17eeeb135").process[:completed].should_not be_nil
  end
end