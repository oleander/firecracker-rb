require "socket"
require "yaml"

class Firecracker
  def initialize(hashes)
    @hashes = hashes
  end
  
  def self.process(*hashes)
    Firecracker.new(hashes).process!
  end
  
  def to_hex(value, max)
    "%0#{2 * max}s" % value.to_s(16)
  end
  
  def send(data)
    puts "IN: '#{data}'"
    sock = UDPSocket.open  
    sock.send(data, 0, "tracker.ccc.de", 80)
    resp = if select([sock], nil, nil, 3)
      sock.recvfrom(65536)
    end

    return resp
  end
  
  def process!
    hashes = ""
    @hashes.each do |hash|
      hashes += [hash].pack("H*")
    end

    transaction_id = [to_hex(rand(65535), 4)].pack("H*")
    resp           = send([to_hex(4497486125440, 8)].pack("H*") + [to_hex(0, 4)].pack("H*") + transaction_id)
    connection_id  = resp.first.unpack("H*").first[16..31]

    data = send([connection_id].pack("H*") + [to_hex(2, 4)].pack("H*") + transaction_id + hashes)
    data = data.first.unpack("H*").first
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

    puts results.to_yaml # =>
    # --- 
    # 2bbf3d63e6b313ecf2655067b51e93f17eeeb135: 
    #   :completed: 77470
    #   :seeders: 3389
    #   :leechers: 244
    #   :hash: 2bbf3d63e6b313ecf2655067b51e93f17eeeb135
  end
end