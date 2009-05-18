class PodcastEpisode < ActiveRecord::Base
  # Callbacks
  
  # Associations
  belongs_to :podcast
  has_attachment :storage => :file_system, :max_size => 25.megabytes
  
  # Validations
  validates_as_attachment
  validates_uniqueness_of :filename

  validates_presence_of :title, :content_type, :filename, :size, :publish_on, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :subtitle, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :description, :maximum => 4000, :message => '{{count}}-character limit'

end
