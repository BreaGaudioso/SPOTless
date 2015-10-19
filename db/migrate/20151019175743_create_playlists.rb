class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.integer :spotify_playlist_id
      t.string :name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
