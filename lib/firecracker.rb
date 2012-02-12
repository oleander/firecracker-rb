require "socket"
require "firecracker/udp_scraper"
require "firecracker/tcp_scraper"
# require "bencode"
require "digest/sha1"
require "uri"
require "yaml"

module Firecracker
  #
  # @torrent String A raw torrent file.
  # @protocols Array<Symbol> Protocols that should be used. UDP is the fastest.
  # @return Hash Seeders, leechers and the amounts of downloads
  #
  def self.raw(raw, protocols = [:udp, :tcp])
    Firecracker.torrent(raw.bdecode, protocols)
  end
  
  #
  # @torrent String Path to a torrent file
  # @protocols Array<Symbol> Protocols that should be used. UDP is the fastest.
  # @return Hash Seeders, leechers and the amounts of downloads
  #
  def self.load(torrent, protocols = [:udp, :tcp])
    Firecracker.raw(File.read(torrent))
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
  
  def self.tcp_trackers(torrent)
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
  
  def self.torrent(torrent, protocols = [:udp, :tcp], silent = true)    
    # UDP related trackers
    if protocols.include?(:udp)
      trackers = udp_trackers(torrent)      
      udp_results = trackers.map do |tracker|
        begin
          Firecracker::UDPScraper.new({
            tracker: tracker,
            hashes: [hash(torrent)]
          }).process!
        rescue
          raise $! unless silent
        end
      end.reject(&:nil?).map(&:values).flatten
    end
    
    # TCP related trackers
    if protocols.include?(:tcp)
      trackers = tcp_trackers(torrent)
    
      tcp_results = trackers.map do |tracker|
        begin
          Firecracker::TCPScraper.new({
            tracker: tracker,
            hashes: [hash(torrent)]
          }).process!
        rescue
          raise $! unless silent
        end
      end.reject(&:nil?).map(&:values).flatten
    end

    (tcp_results + udp_results).inject{ |memo, el| memo.merge(el){ |k, old_v, new_v| old_v + new_v } }
  end
end