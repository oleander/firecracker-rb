require "acts_as_chain"

module Firecracker
  class Base
    acts_as_chain :tracker, :hashes
    
    def hash(hash)
      tap { @hashes = [hash] }
    end  
  
    def valid?
      [@tracker, @hashes].all?
    end
  end
end