# Here lie model classes that help with the unit tests.  We'll use these to create certain sub-categories of
# models that have cloaked ids.
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

class TestModel2 < ActiveRecord::Base
  self.table_name = 'test_models'

  cloak_id key:'my_key'
end
