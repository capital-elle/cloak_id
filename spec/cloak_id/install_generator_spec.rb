# Spec file for the installation generator.
require 'spec_helper'
require 'generator_spec/test_case'
require 'generators/cloak_id/install/install_generator'

describe CloakId::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp',__FILE__)

  before (:all) do
    SecureRandom.stub(:random_number).and_return(12345)
    prepare_destination
    run_generator
  end

  it 'should create an initializer' do
    # We're going to check to make sure that the file has the expected key in it.
    assert_file 'config/initializers/cloak_id.rb',/CloakId::CloakIdEncoder.cloak_id_default_key = 12345/
    end
end