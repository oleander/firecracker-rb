# Firecracker

Implements the UDP/TCP torrent scrape protocol.

## Fetch data

All methods below returns a hash that looks like this.

``` ruby
{
  seeders: 123,
  leechers, 456
  downloads: 789
}
```

You can also specify which protocol to use by passing a second argument.
Something like this: `[:udp, :tcp]`.
Both udp and tcp are being used if noting is specified.

### Pass a torrent file

``` ruby
Firecracker.load("path/to/file.torrent")
```

### A raw torrent

``` ruby
torrent = RestClient.get("http://mysite.com/file.torrent")
Firecracker.raw(torrent)
```

### A String#bdecode Hash

The two methods above are just wrappers for this one.
You can always pass a bdecoded hash if you by any chans has access to the raw stuff.

``` ruby
torrent = RestClient.get("http://mysite.com/file.torrent")
Firecracker.calculate(torrent.bdecode)
```

## Helper methods

Ingoing argument (`torrent`) is from now on a [String#bdecode](https://github.com/naquad/bencode_ext) Hash.

### Generate a info_hash string

``` ruby
Firecracker.hash(torrent)
# => "03db8637a8e16f7d5e3e4f7557d5d87b1905dc16"
```

### A list of TCP/UDP trackers

``` ruby
Firecracker.udp_trackers(torrent)
# => ["udp://tracker.openbittorrent.com:80"]

Firecracker.tcp_trackers(torrent)
# => ["http://torrent.ubuntu.com:6969/scrape"]
```

## UDP/TCP requests

If you for want to define your own server or/and protocol you can do it using the [TCPScraper](https://github.com/oleander/firecracker/blob/master/lib/firecracker/tcp_scraper.rb) and [UDPScraper](https://github.com/oleander/firecracker/blob/master/lib/firecracker/udp_scraper.rb) classes.

The hash being passed is a [info_hash](http://wiki.theory.org/BitTorrent_Tracker_Protocol) string.

You can in theory pass upto 72 hashes in one request.

Keep in mind that if one of the passed hashes is invalid or doesn't exist, the requested server might return 404 or a 400 error.
It's therefore always recommended to make one request for each hash. 

### TCP

``` ruby
Firecracker::TCPScraper.new({
  tracker: "exodus.desync.com:6969/announce",
  hashes: ["c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0"]
}).process!

# => {
#  c2cff4acc8f5b49fd6b93b88fc0423467fbb08b0: {
#    seeders: 123,
#    leechers, 456
#    downloads: 789
#  }
# }
```

### UDP

You can pass up to 72 hashes, just as for the TCP version.

``` ruby
Firecracker::UDPScraper.new({
  tracker: "tracker.openbittorrent.com",
  hashes: ["523d83e8aee1a979e66584b5304d2e8fdc9a1675"]
}).process!

# => {
#  523d83e8aee1a979e66584b5304d2e8fdc9a1675: {
#    seeders: 123,
#    leechers, 456
#    downloads: 789
#  }
# }
```