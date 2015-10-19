class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.string :name
      t.integer :spotify_artist_id

      t.timestamps null: false
    end
  end
end
