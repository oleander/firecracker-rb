require "spec_helper"

describe Firecracker do
  it "should return multiply values" do
    Firecracker.new.tracker("tracker.ccc.de").hashes("2bbf3d63e6b313ecf2655067b51e93f17eeeb135", "2bbf3d62e6b313ecf2655067b51e93f17eeeb135").process.keys.count.should eq(2)
  end
  
  it "should return a single value" do
    #Firecracker.new("2bbf3d63e6b313ecf2655067b51e93f17eeeb135").process[:completed].should_not be_nil
  end
end