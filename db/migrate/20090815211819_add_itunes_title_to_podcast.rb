class AddItunesTitleToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :itunes_title, :string
  end

  def self.down
    remove_column :podcasts, :itunes_title
  end
end
