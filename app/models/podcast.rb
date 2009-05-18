class Podcast < ActiveRecord::Base
  # Callbacks
  
  # Associations
  has_many :episodes, :class_name => "PodcastEpisode", :order => "podcast_episode.publish_on DESC"
  has_one :image, :class_name => "PodcastImage" 
  
  # Validations
  validates_presence_of :title, :author, :email, :link, :description, :categories, :keywords, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :subtitle, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :author, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :email, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :link, :maximum => 4000, :message => '{{count}}-character limit'
  validates_length_of :description, :maximum => 4000, :message => '{{count}}-character limit'

end
