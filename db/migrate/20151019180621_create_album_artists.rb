class CreateAlbumArtists < ActiveRecord::Migration
  def change
    create_table :album_artists do |t|
      t.integer :artist_id
      t.integer :album_id

      t.timestamps null: false
    end
  end
end
