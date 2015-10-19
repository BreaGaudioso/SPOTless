class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :spotify_user_id
      t.string :spotify_auth_token

      t.timestamps null: false
    end
  end
end
