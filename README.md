# Firecracker

Implements the UDP/TCP torrent scrape protocol.

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