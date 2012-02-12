# Firecracker

An implementation of the [UDP](http://bittorrent.org/beps/bep_0015.html)/[TCP](http://wiki.theory.org/BitTorrentSpecification#Tracker_.27scrape.27_Convention) torrent scrape protocol.

## Get started

All methods below returns a hash similar to this one.

``` ruby
{
  seeders: 123,
  leechers: 456,
  downloads: 789
}
```

### Specify a protocol

A second argument may be passed to `load`, `raw` and `calculate` to specify which protocol to use.
An example argument would look like this: `[:tcp, :udp]`, both tcp and udp are defaults.

### A local torrent file

``` ruby
Firecracker.load("path/to/file.torrent")
```

### A raw torrent string

``` ruby
torrent = RestClient.get("http://mysite.com/file.torrent")
Firecracker.raw(torrent)
```

### A String#bdecode hash

``` ruby
torrent = RestClient.get("http://mysite.com/file.torrent")
Firecracker.calculate(torrent.bdecode)
```

## Helper methods

Ingoing argument (`torrent`) is from now on a [String#bdecode](https://github.com/naquad/bencode_ext) hash.

``` ruby
require "bencode_ext"
torrent = File.read("path/to/file.torrent").bdecode
```

### Generate a info_hash string

``` ruby
Firecracker.hash(torrent)
# => "03db8637a8e16f7d5e3e4f7557d5d87b1905dc16"
```

### A list of TCP/UDP trackers

``` ruby
Firecracker.udp_trackers(torrent)
# => ["udp://tracker.openbittorrent.com:80", "..."]

Firecracker.tcp_trackers(torrent)
# => ["http://torrent.ubuntu.com:6969/scrape", "..."]
```

## UDP/TCP requests

If you want to define your own server or/and protocol you can do this using the [TCPScraper](https://github.com/oleander/firecracker/blob/master/lib/firecracker/tcp_scraper.rb) and [UDPScraper](https://github.com/oleander/firecracker/blob/master/lib/firecracker/udp_scraper.rb) classes.

The hash being passed is a [info_hash](http://wiki.theory.org/BitTorrent_Tracker_Protocol) string.

You can in theory pass up to 72 hashes in one request.

Keep in mind that if one of the passed hashes is invalid or doesn't exist, the requested server might return 404 or 400.  
It's therefore recommended to make one request for each hash. 

### TCP

``` ruby
Firecracker::TCPScraper.new({
  tracker: "exodus.desync.com:6969/announce",
  hashes: ["c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0"]
}).process!

# {
#   c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0: {
#     seeders: 123,
#     leechers, 456
#     downloads: 789
#   }
# }
```

### UDP

``` ruby
Firecracker::UDPScraper.new({
  tracker: "tracker.openbittorrent.com",
  hashes: ["523d83e8aee1a979e66584b5304d2e8fdc9a1675"]
}).process!

# {
#   523d83e8aee1a979e66584b5304d2e8fdc9a1675: {
#     seeders: 123,
#     leechers, 456
#     downloads: 789
#   }
# }
```

## How to install

    [sudo] gem install firecracker

## Requirements

Ruby *1.9.2*.

## License

*Firecracker* is released under the *MIT license*.