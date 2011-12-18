require "spec_helper"

describe Firecracker do
  use_vcr_cassette "intro"
  it "should work" do
    Firecracker.process("2bbf3d63e6b313ecf2655067b51e93f17eeeb135")
  end
end