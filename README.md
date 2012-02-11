# Firecracker

Implements the UDP/TCP torrent scrape protocol.

## Requests

You can request the amounts of seeders and leechers using both TCP and UDP.
It's done by passing a [info_hash](http://wiki.theory.org/BitTorrent_Tracker_Protocol) to the tracker in question.

### TCP

You can pass up to 72 (according to the protocol) hashes to the tracker at the same time.
Keep in mind that most TCP trackers out there doesn't support more than one `info_hash`.
If that's the case you will'll receive a 400 error.

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