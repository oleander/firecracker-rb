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
        file = files[key]
        results.merge!({
          key => {
            completed: file["downloaded"],
            seeders: file["complete"],
            leechers: file["incomplete"],
            hash: key
          }
        })
      end
      
      if @type == :single
        results.first ? results.first.last : nil
      else
        results
      end
    end
  
  private
    def files
      return {} unless data
      @_files ||= lambda {
        cd = CharDet.detect(data)
        ic = Iconv.new("#{cd.encoding}//IGNORE", "UTF-8")
        valid_string = ic.iconv(data)
        valid_string = valid_string.gsub(/20:(.+?)d8/) {|a| "20:#{random_value}d8" }
        valid_string.empty? ? {} : BEncode::load(valid_string)["files"]
      }.call
    end
    
    def random_value(max = 20)
      (0...max).map{ ("a".."z").to_a[rand(26)] }.join
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