class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.integer :spotify_album_id
      t.string :image_url
      t.string :name

      t.timestamps null: false
    end
  end
end
