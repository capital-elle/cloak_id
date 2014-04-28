ActiveRecord::Schema.define do
  self.verbose = false

  create_table :test_models, :force => true do |t|
    t.string :test_field
  end

end