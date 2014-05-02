module CloakId
  # The CloakIdEncoder is a support class that helps with the cloaking process.  It provides the base functionality
  # need to do the hashing back and forth from the numeric identifier, as well as the mechanism to turn this into
  # a cloaked id.
  class CloakIdEncoder
    TWIDDLE_PRIME = 0x20C8592B

    cattr_accessor :cloak_id_default_key

    # Basic hashing function to go back and forth between a hashed value.
    def self.twiddle(val,key)
      hashed = (key ^ val) * TWIDDLE_PRIME
      hashed >> (hashed & 0x0f) & 0xffff
    end

    # Take the integer and cloak it as another integer.  This is a reversible function, and cloak(cloak(X)) = X
    def self.cloak(id,key=CloakIdEncoder.cloak_id_default_key)
      raise "Id must be an integer to cloak properly" unless id.is_a? Integer

      low = id & 0xffff
      high = ((id >> 16) & 0xffff) ^ twiddle(low,key)
      ((low ^ twiddle(high,key||0)) << 16) + high
    end


    # This calls the cloak method, but instead of returning the integer value, it will return it as a base 36 string.
    # Unlike the main cloak method, this is not reversible in the same way.  To reverse the action of cloaking, the
    # decloak_base36 method must be used instead.
    def self.cloak_base36(id,key=CloakIdEncoder.cloak_id_default_key)
      self.cloak(id,key||0).to_s(36).upcase
    end

    # This method reverses the cloaking procedure for when the ID has been cloaked using the base36 technique.  It is
    # important to know that this method does not handle the stripping any prefix that might have been added.  It acts
    # only as an inverse function to the cloak_base36 function
    def self.decloak_base36(cloaked_id, key=CloakIdEncoder.cloak_id_default_key)
      id = cloaked_id.downcase.to_i(36)
      cloak(id,key||0)
    end

    # The modified base 35 encoding eliminates Z's from appearing normallty.  This was we can make cloaked id's at least
    # a given length.  This can help make the representation of the cloaked id, a little bit more homogenized.
    def self.cloak_mod_35(id, key=CloakIdEncoder.cloak_id_default_key, min_len=7)
      intermediate_id = self.cloak(id,key||0).to_s(35).upcase
      if intermediate_id.length < min_len
        "#{"Z"*(min_len-intermediate_id.length)}#{intermediate_id}"
      else
        intermediate_id
      end
    end

    # Preform the decloaking operation for the modified base 35 encoding scheme.  This will remove the "Z" characters that
    # only serve to be place holders, then turn it back into a number and decloak it.
    def self.decloak_mod_35(id,key=CloakIdEncoder.cloak_id_default_key)
      intermediate_id = id.slice(/[0-9A-Y]+/).downcase.to_i(35)
      self.cloak(intermediate_id,key)
    end
  end
end