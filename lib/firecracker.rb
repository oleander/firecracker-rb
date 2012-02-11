require "socket"
require "firecracker/udp_scraper"
require "firecracker/tcp_scraper"
# require "bencode"
require "digest/sha1"
require "uri"
require "yaml"

module Firecracker
  def self.raw(raw, protocols = [:udp, :http])
    Firecracker.torrent(BEncode::load(raw), protocols)
  end
  
  def self.file(torrent, protocols = [:udp, :http])
    Firecracker.torrent(BEncode::load_file(torrent), protocols)
  end  
  
  def self.udp_trackers(torrent)
    announce      = torrent["announce"]
    announce_list = torrent["announce-list"]
        
    trackers = announce_list.flatten.select{|tracker| tracker.match(/^udp:\/\//)}
    if announce.match(/^udp:\/\//)
      trackers << announce
    end
    
    return trackers
  end
  
  def self.http_trackers(torrent)
    announce      = torrent["announce"]
    announce_list = torrent["announce-list"]
        
    trackers = announce_list.flatten.select{|tracker| tracker.match(/^http:\/\//)}
    if announce.match(/^http:\/\//)
      trackers << announce
    end
    
    # TPB's tracker is no longer active
    return trackers.map{|t| t.gsub(/announce/, "scrape")}.reject{|t| t.match(%r{thepiratebay})}
  end
  
  def self.hash(torrent)
    Digest::SHA1.hexdigest(torrent["info"].bencode)
  end
  
  def self.torrent(torrent, protocols = [:udp, :http])
    results = []
    
    # UDP related trackers
    if protocols.include?(:udp)
      trackers = udp_trackers(torrent)
    
      results = trackers.map do |tracker|
        Firecracker::UDPScraper.new.tracker(tracker).hash(hash(torrent)).process
      end.reject(&:empty?)
    end
    
    # TCP related trackers
    if protocols.include?(:http)
      trackers = http_trackers(torrent)
    
      results += trackers.map do |tracker|
        Firecracker::TCPScraper.new.tracker(tracker).hash(hash(torrent)).process
      end.reject(&:empty?)
    end
    
    # Sum all data
    return results.inject({
      seeders: 0, 
      leechers: 0, 
      completed: 0
    }) do |result, key|
      result.keys.each {|k| result[k] += key[k].to_i}; result
    end
  end
end