describe Firecracker do
  use_vcr_cassette "example"
  
  let(:keys){
    [:seeders, :leechers, :completed]
  }
  
  it "should return valid data" do
    Firecracker.process("spec/fixtures/example.torrent").each_pair do |key, value|
      keys.should include(key)
      value.should > 0
    end
  end
end