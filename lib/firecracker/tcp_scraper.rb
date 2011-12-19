require "rest-client"
require "bencode"
require "digest/sha1"
require "uri"
require_relative "base"

module Firecracker
  class TCPScraper < Firecracker::Base
    def process 
      raise "both #tracker and #hashes/#hash must be set" unless valid?
    
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
    
      return @hashes.one? ? results.first.last : results
    end
  
  private
    def files
      @files ||= BEncode::load(RestClient.get("http://#{@tracker}?%s" % hash_info))["files"]
    end
  
    def hash_info
      @_hash_info ||= @hashes.map! do |hash|
        "info_hash=%s" % URI.encode([hash].pack("H*"))
      end.join("&")
    end
  end
end