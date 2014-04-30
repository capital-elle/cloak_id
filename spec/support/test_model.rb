
class TestModel < ActiveRecord::Base
  cloak_id
  has_many :test_associations
end

class TestAssociation < ActiveRecord::Base
  cloak_id prefix:'L'
  belongs_to :test_model
end

class UncloakedModel < ActiveRecord::Base
end
