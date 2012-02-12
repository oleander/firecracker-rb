describe Firecracker do
  # use_vcr_cassette "example-total"
  
  let(:keys){
    [:seeders, :leechers, :completed]
  }
  
  it "should return valid data" do
    puts Firecracker.load("spec/fixtures/example.torrent")
  end
end