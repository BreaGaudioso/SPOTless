class CreateFuzzy < ActiveRecord::Migration
  def change
    create_table :fuzzies do |t|
      t.integer :track_id
      t.float :match  
      t.integer :match_id
    end
  end
end
