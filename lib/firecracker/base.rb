module Firecracker
  class Base
    def initialize(args = {})
      args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
      
      @type == :multi
    end
    
    #
    # @hash String A torrent hash
    # @return Firecracker::Base
    # Example:
    #   2bbf3d63e6b313ecf2655067b51e93f17eeeb135
    #
    def hash(hash)
      @type = :single
      tap { @hashes = [hash].flatten }
    end
    
    #
    # @hashes Array<String> A list of torrent hashes
    # @return Firecracker::Base
    # Example:
    #   [2bbf3d63e6b313ecf2655067b51e93f17eeeb135]
    #
    def hashes(*hashes)
      @type = :multi
      tap { @hashes = hashes.flatten }
    end
    
    #
    # @tracker String 
    #  Tracker that should be requested
    #  TCP tracker should always end with /scrape or similar
    #  Se example for more info
    # @return Firecracker::Base
    # Example:
    #  "tracker.ccc.de/scrape" (tcp)
    #   "tracker.ccc.de" (udp)
    #
    def tracker(tracker)
      tap { @tracker = tracker }
    end
    
    #
    # @return Do we have everyting that's needed
    #  to do the request.
    #
    def valid?
      [@tracker, @hashes].all?
    end
    
    #
    # @return Should we print debug ouput?
    #
    def debugger?
      defined?(@debugger) and @debugger
    end
  end
end