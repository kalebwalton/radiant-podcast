class CreatePodcasts < ActiveRecord::Migration
  def self.up
    create_table :podcasts do |t|
      t.string :title
      t.string :subtitle
      t.string :author
      t.string :email
      t.string :link
      t.text :description
      t.text :categories
      t.string :keywords
      t.string :copyright

      t.timestamps
    end
  end

  def self.down
    drop_table :podcasts
  end
end
