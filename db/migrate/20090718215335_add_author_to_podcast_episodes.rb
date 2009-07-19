class AddAuthorToPodcastEpisodes < ActiveRecord::Migration
  def self.up
    add_column :podcast_episodes, :author, :string
  end

  def self.down
    remove_column :podcast_episodes, :author
  end
end
