require 'spec_helper'
require File.dirname(__FILE__)+'/../../lib/cloak_id/cloak_id_encoder'

describe CloakId::CloakIdEncoder do

  it 'should raise exception when the id to be cloaked is not numeric' do
    expect {CloakId::CloakIdEncoder.cloak(id)}.to raise_error
  end

  it 'should return the base id after cloaking twice' do
    cloaked_v = CloakId::CloakIdEncoder.cloak(10000,0)
    expect(CloakId::CloakIdEncoder.cloak(cloaked_v,0)).to eql 10000

    cloaked_v = CloakId::CloakIdEncoder.cloak(0xffff25,0x1234)
    expect(CloakId::CloakIdEncoder.cloak(cloaked_v,0x1234)).to eql 0xffff25
  end


  it 'should obfuscate provide the obfuscated id on an active model' do
    test_model = make_model()
    cloaked_id = test_model.cloaked_id

    expect(cloaked_id).to start_with 'X'
    decloaked_id = CloakId::CloakIdEncoder.decloak_base36(cloaked_id[1..-1],test_model.cloak_id_key)
    expect(decloaked_id).to eql test_model.id
  end

  it 'should enforce a minimum length when using modified base 35 encoding' do
    cloaked_v = CloakId::CloakIdEncoder.cloak_mod_35(10000,0,40)

    expect(cloaked_v).to include 'ZZZZZZZZZ'
    expect(cloaked_v).to have(40).characters

    decloaked_id = CloakId::CloakIdEncoder.decloak_mod_35(cloaked_v,0)
    expect(decloaked_id).to eql 10000
  end


  it 'should not modify the cloaked id if the cloaked value is already long enough' do
    cloaked_v = CloakId::CloakIdEncoder.cloak_mod_35(10000,0,5)
    expect(cloaked_v).to_not include 'Z'
    expect(cloaked_v).to have_at_least(5).characters
  end
end