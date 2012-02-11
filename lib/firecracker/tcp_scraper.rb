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
      
      keys = ["downloaded", "complete", "incomplete"]
      results = Hash.new { |h,k| h[k] = keys.include?(k.to_s) ? 0 : nil }
      
      raise %q{
        Someting went wrong.
        You've passed multiply hashes, but the 
        tracker only responed with one result.
      } if files.empty? and not @options[:hashes].one?
      
      if files.empty?
        if keys.any? { |t| raw_hash.keys.include?(t) }
          keys.each do |key|
            results[key.to_sym] += raw_hash[key].to_i
          end
        end
        
        return {
          @options[:hashes].first => results
        }
      end
      
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
        @_hash_info ||= @options[:hashes].map! do |hash|
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