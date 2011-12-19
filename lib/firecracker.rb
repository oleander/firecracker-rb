require "socket"
require "firecracker/udp_scraper"
require "firecracker/tcp_scraper"
require "bencode"
require "digest/sha1"
require "uri"
require "yaml"

module Firecracker
  def self.process(torrent)
    torrent       = BEncode::load_file(torrent)
    hash          = Digest::SHA1.hexdigest(torrent["info"].bencode)
    announce      = torrent["announce"]
    announce_list = torrent["announce-list"]
    
    # UDP related trackers
    trackers = announce_list.flatten.select{|tracker| tracker.match(/^udp:\/\//)}
    if announce.match(/^udp:\/\//)
      trackers << announce
    end
    
    results = trackers.map do |tracker|
      Firecracker::UDPScraper.new.tracker(tracker).hash(hash).process
    end.reject(&:empty?)
    
    # TCP related trackers
    trackers = announce_list.flatten.select{|tracker| tracker.match(/^http:\/\//) and not tracker.match(%r{thepiratebay})}
    
    if announce.match(/^http:\/\//) and not announce.match(%r{thepiratebay})
      trackers << announce
    end
    
    results += trackers.map do |tracker|
      tracker.gsub!(/announce/, "scrape")
      Firecracker::TCPScraper.new.tracker(tracker).hash(hash).process
    end.reject(&:empty?)
    
    # Sum all data
    results.inject({
      seeders: 0, 
      leechers: 0, 
      completed: 0
    }) do |result, key|
      result.keys.each {|k| result[k] += key[k].to_i}; result
    end
  end  
end