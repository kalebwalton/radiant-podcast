class RemoveNumberFromPodcastEpisodes < ActiveRecord::Migration
  def self.up
    remove_column :podcast_episodes, :number
  end

  def self.down
    add_column :podcast_episodes, :number, :integer
  end
end
