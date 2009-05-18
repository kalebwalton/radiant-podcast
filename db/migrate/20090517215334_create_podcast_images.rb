class CreatePodcastImages < ActiveRecord::Migration
  def self.up
    create_table :podcast_images do |t|
      t.integer :podcast_id
      t.string :content_type
      t.string :filename
      t.integer :size
      t.integer :parent_id
      t.string :thumbnail
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :podcast_images
  end
end
