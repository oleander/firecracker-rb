require "socket"
require "yaml"
require "acts_as_chain"
require "rest-client"
require "bencode"
require "digest/sha1"
require "uri"

class TCPScraper
  acts_as_chain :tracker, :hashes
        
  def process
    hash = URI.encode([@hashes.first].pack('H*'))
    hash2 = URI.encode(["efd0f14d3df80953433fc26a714ae4b94b33f847"].pack('H*'))
    files = BEncode::load(RestClient.get("http://tracker.ccc.de/scrape?info_hash=%s&info_hash=%s" % [hash, hash2]))["files"]
    results = {}
    files.keys.each do |key|
      hash = key.unpack("H*").first
      file = files[key]
      results.merge!({
        hash => {
          completed: file["downloaded"],
          seeders: file["complete"],
          leechers: file["incomplete"],
          hash: hash
        }
      })
    end
  end
  
  def hash(hash)
    tap { @hashes = [hash] }
  end  
end