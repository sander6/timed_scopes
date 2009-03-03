ENV["RAILS_ENV"] = "test"
require 'activerecord' unless defined?(ActiveRecord)
require 'spec'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :dbfile => ":memory:"
  )

  ActiveRecord::Schema.define do
    create_table :things do |table|
      table.datetime  :published_at
      table.boolean   :light_switch_on
      table.timestamps
    end
    
    create_table :thongs do |table|
      table.string :name
    end
  end
end

class Thing < ActiveRecord::Base
end

class Thong < ActiveRecord::Base
end
