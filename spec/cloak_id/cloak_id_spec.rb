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

    expect(cloaked_id).to start_with 'TM'
    decloaked_id = CloakId::CloakIdEncoder.decloak_mod_35(cloaked_id[2..-1],test_model.cloak_id_key)
    expect(decloaked_id).to eql test_model.id
  end

  it 'should use the specified prefix on the front of the cloaked id' do
    test_model = TestModel.create
    test_association = TestAssociation.create

    expect(test_model.cloaked_id).to start_with 'TM'     #default
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

  it 'should use the right find technique when presented with the cloaked vs. the decloaked id.' do
    model = TestModel.create
    model_2 = TestModel.create
    expect(TestModel.find(model.id)).to eql model
    expect(TestModel.find(model.cloaked_id)).to eql model
    expect(TestModel.find([model.id, model_2.id])).to eql [model,model_2]
    expect(TestModel.find([model.cloaked_id, model_2.cloaked_id])).to eql [model,model_2]
  end

  it 'should return true for items that exist and false for those that don\'t when exists? is called' do
     model = TestModel.create

    expect(TestModel.exists?(model.cloaked_id)).to be_true
    expect(TestModel.exists?("#{model.cloaked_id}XX")).to be_false
  end

  it 'should be able to handle the "exists" clause in hash queries as well as alone' do
    model = TestModel.create

    expect(TestModel.exists?(id:model.cloaked_id)).to be_true
    expect(TestModel.exists?(id:"#{model.cloaked_id}XX")).to be_false
  end

  it 'should still handle cases for both hashes and "normal" exists? calls when we use the non cloaked id' do
    model = TestModel.create

    expect(TestModel.exists?(model.id)).to be_true
    expect(TestModel.exists?(model.id+3)).to be_false

    expect(TestModel.exists?(id:model.id)).to be_true
    expect(TestModel.exists?(id:(model.id+3))).to be_false

    end
end