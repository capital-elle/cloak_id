module CloakId
  module Generators
    class InstallGenerator  < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_install
        template 'cloak_id.rb.erb', 'config/initializers/cloak_id.rb'
      end
    end
  end
end