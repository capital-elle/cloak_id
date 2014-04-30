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
    key = options[:key]

    if (!key.nil? and key.is_a? String)
      key = Zlib::crc32(key)
    end

    self.cloak_id_key = key

    alias_method :old_serializable_hash, :serializable_hash
    extend ClassMethods
    include InstanceMethods
  end

  module InstanceMethods

    # Return the id for the object in cloaked form.  If the id is nil, then this method will also return nil.
    def cloaked_id
      if self.id.nil?
        nil
      else
        self.class.cloaked_id_for(self.id)
      end
    end

    def to_param
      self.cloaked_id
    end

    def serializable_hash (options = nil)
      attribute_hash = self.old_serializable_hash (options)
      attribute_hash['id'] = self.cloaked_id

      #now we want to cloak any fk ids that have been cloaked
      self.class.reflections.values.each  do |association|
        if association.klass.respond_to? :cloaked_id_for
          # this is a related item that has been cloaked
          if attribute_hash.has_key? association.foreign_key
            attribute_hash[association.foreign_key] = association.klass.cloaked_id_for(attribute_hash[association.foreign_key])
          end
        end
      end
      attribute_hash
    end
  end

  module ClassMethods

    # class method to create the cloaked id.  This will be used when generation a new cloaked id either on demand by the
    # object itself, or when an association wants to hide the id.

    def cloaked_id_for(id)
      "#{self.cloak_id_prefix}#{CloakIdEncoder.cloak_base36(id, self.cloaking_key)}"
    end

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