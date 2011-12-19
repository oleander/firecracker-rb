require "socket"
require "firecracker/udp_scraper"
require "firecracker/tcp_scraper"
require "bencode"
require "digest/sha1"
require "uri"
require "yaml"

module Firecracker
  def self.torrents(*torrents)
    torrents.map! do |torrent|
      torrent = BEncode::load_file(torrent)
      
      trackers = torrent["announce-list"].flatten.select{|tracker| tracker.match(/^udp:\/\//)}
      hash = Digest::SHA1.hexdigest(torrent["info"].bencode)
      
      results = trackers.map do |tracker|
        Firecracker::UDPScraper.new.tracker(tracker).hash(hash).process
      end
      
      results.inject({
        seeders: 0, 
        leechers: 0, 
        completed: 0
      }){|result, key| result.keys.each{|k| result[k] += key[k]}; result }
    end
  end
  
  def self.torrent(torrent)
    torrents(torrent)
  end
end