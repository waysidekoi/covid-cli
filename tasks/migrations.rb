require 'active_record'
require 'covid'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ENV['DATABASE'] || Covid.root.join("db", "covid.db")
)

ActiveRecord::Schema.define do
  create_table(:countries, force: true) do |t|
    t.string :name, null: false
    t.float :latitude, { precision: 10, scale: 6 }
    t.float :longitude, { precision: 10, scale: 6 }

    t.timestamps
    t.index :name
  end

  create_table(:states, force: true) do |t|
    t.string :name, null: false
    t.decimal :latitude, { precision: 10, scale: 6 }
    t.decimal :longitude, { precision: 10, scale: 6 }
    t.references :country, foreign_key: true

    t.timestamps
    t.index :name
  end

  create_table(:reports, force: true) do |t|
    t.string  :type
    t.date    :date
    t.integer :count
    t.bigint :location_id
  end

end
