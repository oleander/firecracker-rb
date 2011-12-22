require "socket"
require "io/wait"
require_relative "base"

module Firecracker
  class UDPScraper < Firecracker::Base
    def initialize
      @socket = UDPSocket.open
    end
      
    def process
      raise "both #tracker and #hashes/#hash must be set" unless valid?

      hashes = @hashes.join
      data = send(to_hex(4497486125440, 8) + to_hex(0, 4) + transaction_id)
      
      raise "request error" unless data
      data = send(data[16..31] + to_hex(2, 4) + transaction_id + hashes)
      raise "request error" unless data
    
      index = 16
      results = {}
      
      loop do
        break unless data[index + 23]

        completed = data[(index + 8)..index + 15].to_i(16)
        leechers  = data[(index + 16)..index + 23].to_i(16)
        seeders   = data[index..index + 7].to_i(16)
        hash      = @hashes[(index - 16)/24]

        results.merge!({
          hash => {
            completed: completed,
            seeders: seeders,
            leechers: leechers,
            hash: hash
          }
        })

        index += 24
      end

      return @hashes.one? ? results.first.last : results
    rescue RuntimeError
      if $!.message == "request error" and debugger?
        puts URI.parse(@tracker).host
      end
      
      return {}
    end
    
  private
    def to_hex(value, max)
      value.to_s(16).rjust(max * 2, "0")
    end
  
    def send(data)
      Timeout::timeout(1.2) {
        unless @tracker =~ /^udp:\/\//
          @tracker = "udp://#{@tracker}"
        end
        
        uri = URI.parse(@tracker)
                
        @socket.send([data].pack("H*"), 0, uri.host, uri.port || 80)
        # if io = IO.wait(3)
        #     if resp = @socket.recvfrom_nonblock(65536)
        #       resp.first.unpack("H*").first
        #     end
        #   end
        #   
        #   return nil
        
        resp = if select([@socket])
          @socket.recvfrom_nonblock(65536)
        end
        # 
        # #@socket.close
        # 
        resp ? resp.first.unpack("H*").first : nil
      }
    rescue SocketError
      puts "SocketError"
    rescue Timeout::Error
      puts "Timeout::Error" if debugger?
    end
  
    def transaction_id
      @_transaction_id ||= to_hex(rand(65535), 4)
    end
  end
end