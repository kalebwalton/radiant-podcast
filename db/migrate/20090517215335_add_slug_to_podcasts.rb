class AddSlugToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :slug, :string
  end

  def self.down
    remove_column :podcasts, :slug
  end
end
