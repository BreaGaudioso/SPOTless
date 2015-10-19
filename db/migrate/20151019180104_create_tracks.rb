class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :spotify_track_id
      t.integer :album_id
      t.string :name

      t.timestamps null: false
    end
  end
end
