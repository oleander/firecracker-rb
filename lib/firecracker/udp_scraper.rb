require "socket"
require_relative "base"

module Firecracker
  class UDPScraper < Firecracker::Base      
    #
    # @return Hash
    #   Example: {
    #     c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0: {
    #       downloads: 123,
    #       complete: 456,
    #       incomplete: 789
    #     }
    #   }
    #
    def process!
      raise "both #tracker and #hashes/#hash must be set" unless valid?
      
      # Handshake
      data = send(to_hex(4497486125440, 8) + to_hex(0, 4) + transaction_id)
      request_error! unless data
      
      # Main request
      data = send(data[16..31] + to_hex(2, 4) + transaction_id + hashes.join)
      request_error! unless data
    
      index = 16
      results = {}
      
      loop do
        break unless data[index + 23]

        completed = data[(index + 8)..index + 15].to_i(16)
        leechers  = data[(index + 16)..index + 23].to_i(16)
        seeders   = data[index..index + 7].to_i(16)
        hash      = hashes[(index - 16)/24]

        results.merge!({
          hash => {
            downloads: completed,
            seeders: seeders,
            leechers: leechers
          }
        })

        index += 24
      end

      return results
    end
    
  private
    def socket
      @_socket ||= UDPSocket.open
    end
    
    def request_error!
      raise "Request error. UDP server did not respond"
    end
    
    def to_hex(value, max)
      value.to_s(16).rjust(max * 2, "0")
    end
  
    def tracker
      if @options[:tracker] =~ /^udp:\/\//
        @options[:tracker]
      else
        "udp://#{@options[:tracker]}"
      end
    end

    def send(data)
      Timeout::timeout(timeout) {
        uri = URI.parse(tracker)

        socket.send([data].pack("H*"), 0, uri.host, uri.port || 80)
        resp = if select([socket], nil, nil, 3)
          socket.recvfrom_nonblock(65536)
        end
        
        resp ? resp.first.unpack("H*").first : nil
      }
    end
  
    def transaction_id
      @_transaction_id ||= to_hex(rand(65535), 4)
    end
  end
end