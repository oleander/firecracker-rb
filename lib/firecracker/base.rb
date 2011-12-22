require "acts_as_chain"

module Firecracker
  class Base
    acts_as_chain :tracker, :hashes
    
    def hash(hash)
      tap { @hashes = [hash].flatten }
    end  
    
    def hashes(hashes)
      tap { @hashes = [hashes].flatten }
    end
  
    def valid?
      [@tracker, @hashes].all?
    end
    
    def debugger?
      defined?(@debugger) and @debugger
    end
  end
end