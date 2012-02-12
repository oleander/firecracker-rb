module Firecracker
  class Base
    #
    # @args Hash A bunch of options. 
    #  Everyting can be passed using the methods listed below
    # Example:
    #  {
    #    tracker: "tracker.ccc.de",
    #    hashes: ["2bbf3d63e6b313ecf2655067b51e93f17eeeb135"],
    #    debug: false
    #  }
    #
    def initialize(args = {})
      @options = {
        debug: false,
        timeout: 2,
        tracker: nil,
        hashes: []
      }.merge(args)
    end
    
    #
    # @return Do we have everyting that's needed
    #  to do the request.
    #
    def valid?
      [
        @options[:tracker],
        @options[:hashes].any?
      ].all?
    end
    
    #
    # @return Should we print debug ouput?
    #
    def debug?
      @options[:debug]
    end
    
    #
    # @return Array<String> A list of hashes
    #
    def hashes
      @options[:hashes]
    end
    
    #
    # @return Integer Global timeout limit
    #
    def timeout
      @options[:timeout]
    end
  end
end