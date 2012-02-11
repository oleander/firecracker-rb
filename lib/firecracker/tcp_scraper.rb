require "rest-client"
require "timeout"
require "digest/sha1"
require "uri"
require "bencode_ext"
require_relative "base"

module Firecracker
  class TCPScraper < Firecracker::Base
    #
    # @return Hash
    #   Example: {
    #     c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0: {
    #       downloaded: 123,
    #       complete: 456,
    #       incomplete: 789
    #     }
    #   }
    #
    def process!
      raise "both #tracker and #hashes/#hash must be set" unless valid?
      
      keys    = ["downloaded", "complete", "incomplete"]
      map     = {:complete => :seeders, :incomplete => :leechers, :downloaded => :downloads} 
      results = Hash.new { |h,k| h[k] = 0 }
      
      raise %q{
        Someting went wrong.
        You've passed multiply hashes, but the 
        tracker only responed with one result.
      } if files.empty? and not @options[:hashes].one?
      
      if files.empty?
        keys.each do |key|
          replace = map[key.to_sym] ? map[key.to_sym] : key
          results[replace.to_sym] += raw_hash[key].to_i
        end
        
        return {
          @options[:hashes].first => results
        }
      end
      
      files.keys.each do |key|
        file = files[key]
        results.merge!({
          key => {
            downloads: file["downloaded"],
            seeders: file["complete"],
            leechers: file["incomplete"]
          }
        })
      end
      
      return results
    end
      
    private
      def files
        @_files ||= raw_hash["files"] || {}
      end
      
      def raw_hash
        @_raw_hash ||= if data.nil? or data.empty?
          {}
        else
          data.gsub(/20:(.+?)d8/) do |m| 
            d = m.unpack("H*").first 
            "#{d.length}:#{d}d8"
          end.bdecode || {}
        end
      end
  
      def random_value(max = 20)
        (0...max).map{ ("a".."z").to_a[rand(26)] }.join
      end

      def hash_info
        @_hash_info ||= @options[:hashes].map do |hash|
          "info_hash=%s" % URI.encode([hash].pack("H*"))
        end.join("&")
      end
  
      #
      # Sometime, I'm not sure when, the timeout value
      # passed to RestClient is ignored. That is why
      # the hole method is wrapped inside a Timeout block.
      # Is there a better solution?
      #
      def data
        Timeout::timeout(@options[:timeout]) {
          @_data ||= RestClient.get("#{@options[:tracker]}?%s" % hash_info, timeout: @options[:timeout])
        }
      end
    end
end