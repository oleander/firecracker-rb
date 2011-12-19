require "rest-client"
require "timeout"
require "bencode"
require "digest/sha1"
require "rchardet19"
require "iconv"
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
      
      if @hashes.one? and results.first
        results.first.last
      else
        results
      end
    end
  
  private
    def files
      if data
        cd = CharDet.detect(data)
        ic = Iconv.new("#{cd.encoding}//IGNORE", "UTF-8")
        valid_string = ic.iconv(data)
        valid_string = valid_string.gsub(/d20:(.+)d8/, "d20:#{("a" * 20)}d8")
        if valid_string.empty?
          {}
        else
          BEncode::load(valid_string)["files"]
        end
      else
        {}
      end
    end
  
    def hash_info
      @_hash_info ||= @hashes.map! do |hash|
        "info_hash=%s" % URI.encode([hash].pack("H*"))
      end.join("&")
    end
    
    def data
      Timeout::timeout(1.2) {
        @_data ||= RestClient.get("#{@tracker}?%s" % hash_info, timeout: 2)
      }
    rescue Timeout::Error
      puts "Timeout::Error" if debugger?
    rescue SocketError
      puts "SocketError" if debugger?
    rescue RestClient::ResourceNotFound
      puts "RestClient::ResourceNotFound" if debugger?
    rescue RestClient::BadRequest
      puts "RestClient::BadReques" if debugger?
    rescue Errno::ECONNRESET
      puts "Errno::ECONNRESET" if debugger?
    end
  end
end