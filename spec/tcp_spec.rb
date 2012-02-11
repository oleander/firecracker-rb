describe Firecracker::TCPScraper do
  describe "single file" do
    # use_vcr_cassette "example1" Doesn't work for some reason
    
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
        [:downloads, :seeders, :leechers].should include(key)
      end
    end
    
    it "should only contain values greater than zero" do
      values.keys.each do |key|
        values[key].should > 0
      end
    end
  end
  
  describe "multi file" do
    use_vcr_cassette "example2"
    
    let(:hashes) { ["03db8637a8e16f7d5e3e4f7557d5d87b1905dc16"] }
    let(:raw){
      Firecracker::TCPScraper.new({
        tracker: "tracker.pow7.com:80/scrape",
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
        [:seeders, :leechers, :downloads].should include(key)
      end
    end
    
    it "should only contain values greater than zero" do
      values.keys.each do |key|
        values[key].should > 0
      end
    end
  end
end