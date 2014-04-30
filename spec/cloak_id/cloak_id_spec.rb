require 'spec_helper'


## helper to make a simple model
def make_model
  test_model = TestModel.new
  test_model.id = 1234
  test_model.test_field='This is a test field'

  test_model
end

describe CloakId do

  it 'should provide the obfuscated id on an active record' do
    test_model = make_model()
    cloaked_id = test_model.cloaked_id

    expect(cloaked_id).to start_with 'X'
    decloaked_id = CloakId::CloakIdEncoder.decloak_base36(cloaked_id[1..-1],test_model.cloak_id_key)
    expect(decloaked_id).to eql test_model.id
  end

  it 'should use the specified prefix on the front of the cloaked id' do
    test_model = TestModel.create
    test_association = TestAssociation.create

    expect(test_model.cloaked_id).to start_with 'X'     #default
    expect(test_association.cloaked_id).to start_with 'L'
  end

  it 'should be able to convert a string key into a numeric key for cloaking' do
    expect(TestModel2.cloaking_key).to eql Zlib::crc32('my_key')
  end

  it 'should raise an error when using a prefix that does not start with a letter' do
    sample_model = UncloakedModel.new
    expect do
      class << sample_model
        cloak_id prefix:'123'
      end
    end.to raise_error(CloakId::CloakingError)
  end

  it 'should return null for the cloaked id when there is no id in place' do
    model = TestModel.new

    expect(model.cloaked_id).to be_nil
  end

  it 'should allow the user to used the find_by_cloaked_id method to use the cloaked id to find the resource' do
    model = TestModel.create
    cloaked_id = model.cloaked_id

    found_model = TestModel.find_by_cloaked_id(cloaked_id)
    expect(found_model).to eql model
  end

  it 'should provide the cloaked id when converting the resource into a parameter' do
    model = make_model()
    expect(model.to_param).to eql model.cloaked_id
  end

  it 'should include the cloaked id in the json that is produced for the resource' do
    test_model = make_model()
    model_json = test_model.as_json
    expect(model_json['id']).to eql test_model.cloaked_id
  end


  it 'should handle cloaking ids with the JSON as it bubbles up' do
    model = TestModel.create
    association = TestAssociation.create

    model.test_associations << association
    model.test_associations  << TestAssociation.create
    model_json = model.as_json(include: :test_associations)

    # This is ugly, but since this is a single association on the model, we want the first item in the "has many"
    expect(model_json['test_associations'][0]['id']).to eql association.cloaked_id
    expect(model_json['test_associations'][0]['test_model_id']).to eql model.cloaked_id
  end
end