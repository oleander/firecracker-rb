require "acts_as_chain"

module Firecracker
  class Base
    acts_as_chain :tracker, :hashes
    
    def hash(hash)
      @type = :single
      tap { @hashes = [hash].flatten }
    end
    
    def hashes(*hashes)
      @type = :multi
      tap { @hashes = hashes.flatten }
    end
  
    def valid?
      [@tracker, @hashes].all?
    end
    
    def debugger?
      defined?(@debugger) and @debugger
    end
  end
end