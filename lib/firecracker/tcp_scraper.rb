require "rest-client"
require "timeout"
#require "bencode"
require "digest/sha1"
require "uri"
require "bencode_ext"

require_relative "base"

module Firecracker
  class TCPScraper < Firecracker::Base
    def process 
      raise "both #tracker and #hashes/#hash must be set" unless valid?
      
      results = Hash.new { |h,k| h[k] = 0 }
      keys = ["downloaded", "complete", "incomplete"]
      
      unless files.empty?
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
      else
        if keys.any? { |t| raw_hash.keys.include?(t) }
          keys.each do |key|
            results[key.to_sym] += raw_hash[key].to_i
          end
        end
        
        return results
      end
      

    end
  
  private
    def files
      @_files ||= raw_hash["files"] || {}
    end
    
    def raw_hash
      @_raw_hash ||= (data.nil? or data.empty?) ? {} : data.bdecode || {}
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
      puts "Timeout::Error" if debug?
    rescue SocketError
      puts "SocketError" if debug?
    rescue RestClient::ResourceNotFound
      puts "RestClient::ResourceNotFound" if debug?
    rescue RestClient::BadRequest
      puts "RestClient::BadReques" if debug?
    rescue Errno::ECONNRESET
      puts "Errno::ECONNRESET" if debug?
    end
  end
end