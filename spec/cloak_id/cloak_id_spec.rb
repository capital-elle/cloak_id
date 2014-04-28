require 'spec_helper'


## helper to make a simple model
def make_model
  test_model = TestModel.new
  test_model.id = 1234
  test_model.test_field='This is a test field'

  test_model
end

describe CloakId do

  it 'should allow the user to used the find_by_cloaked_id method to use the cloaked id to find the resource' do
    model = TestModel.create
    cloaked_id = model.cloaked_id

    found_model = TestModel.find_by_cloaked_id(cloaked_id)
    expect(found_model).to eql model
  end
end