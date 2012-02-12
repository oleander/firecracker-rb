describe Firecracker do
  # use_vcr_cassette "example-total" Crashes Ruby for some reason
  before(:all) { @result = Firecracker.load("spec/fixtures/example.torrent") }
  
  let(:keys){
    [:seeders, :leechers, :downloads]
  }
    
  it "should return seeders, leechers and the amount of downloads" do
    (@result.keys & keys).count.should eq(3)
  end
  
  it "should only contain values greater than zero" do
    @result.keys.each do |key|
      @result[key].should > 0
    end
  end
end