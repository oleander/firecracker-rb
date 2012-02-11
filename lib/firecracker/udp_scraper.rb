require "socket"
require_relative "base"

module Firecracker
  class UDPScraper < Firecracker::Base      
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

      return @type == :single ? results.first.last : results
    rescue RuntimeError
      if $!.message == "request error" and debug?
        puts URI.parse(@tracker).host
      end
      
      return {}
    end
    
  private
    def socket
      @_socket ||= UDPSocket.open
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
      Timeout::timeout(@options[:timeout]) {        
        uri = URI.parse(tracker)
                
        socket.send([data].pack("H*"), 0, uri.host, uri.port || 80)
        resp = if select([socket], nil, nil, 3)
          socket.recvfrom_nonblock(65536)
        end
        
        resp ? resp.first.unpack("H*").first : nil
      }
    rescue SocketError
      puts "SocketError"
    rescue Timeout::Error
      puts "Timeout::Error" if debug?
    end
  
    def transaction_id
      @_transaction_id ||= to_hex(rand(65535), 4)
    end
  end
end