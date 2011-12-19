require "socket"
require_relative "base"

class UDPScraper < BaseScraper
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
  end
    
private
  def to_hex(value, max)
    value.to_s(16).rjust(max * 2, "0")
  end
  
  def send(data)
    @socket.send([data].pack("H*"), 0, @tracker, 80)
    resp = if select([@socket], nil, nil, 3)
      @socket.recvfrom(65536)
    end

    resp ? resp.first.unpack("H*").first : nil
  end
  
  def transaction_id
    @_transaction_id ||= to_hex(rand(65535), 4)
  end
end