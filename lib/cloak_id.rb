require "cloak_id/version"
require "active_record"
require "zlib"
require "cloak_id/cloak_id_encoder"

module CloakId

  # The main entry point for cloak_id  This will cause the Active Record that this is called in to be able to
  # cloak it's ids.
  #
  # options:
  # :prefix : All cloaked ids will begin with this prefix.  If none is provided, then the letter 'X' will be used
  # :key : The key that will be used to do the obfuscation.  If none is provided, then the obfuscation will use
  #        a key based on the model name.  This could result in multiple applications cloaking ids in the same way.
  def cloak_id(options = {})
    cattr_accessor :cloak_id_prefix, :cloak_id_key
    self.cloak_id_prefix = (options[:prefix] || 'X')
    self.cloak_id_key = (options[:key])

    extend ClassMethods
    include InstanceMethods
  end

  module InstanceMethods

    # Return the id for the object in cloaked form.
    def cloaked_id
      "#{self.class.cloak_id_prefix}#{CloakIdEncoder.cloak_base36(self.id, self.class.cloaking_key)}"
    end

  end

  module ClassMethods
    # Return the key that we're going to use in the twiddle function during reversible hashing
    # this value will be based on the CRC check sum of the model name unless one is provided by
    # the user.
    def cloaking_key
      self.cloak_id_key = Zlib::crc32(self.model_name) unless self.cloak_id_key.is_a? Integer
      self.cloak_id_key
    end

    # Perform a find request based on the cloaked id.  This command will verify that the cloaked id is in the
    # correct format to allow it to be found.   If it is not then the requested record cannot be found, and a
    # RecordNotFound error will be raised.
    def find_by_cloaked_id(cloaked_id)
      # make sure this is a valid id
      raise new ActiveRecord::RecordNotFound("Cloaked Id does not have a valid format.") unless cloaked_id.start_with? self.cloak_id_prefix

      decloaked_id = CloakIdEncoder.decloak_base36(cloaked_id[self.cloak_id_prefix.length..-1], self.cloaking_key)
      self.find(decloaked_id)
    end

  end
end

ActiveRecord::Base.extend CloakId