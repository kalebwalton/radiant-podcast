class PodcastEpisode < ActiveRecord::Base
  order_by 'publish_on desc'

  # Callbacks
  
  # Associations
  belongs_to :podcast
  has_attachment :storage => :file_system, :max_size => 25.megabytes
  
  # Validations
  validates_as_attachment
  validates_uniqueness_of :filename

  validates_presence_of :title, :content_type, :filename, :size, :publish_on, :podcast_id, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :subtitle, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :description, :maximum => 4000, :message => '{{count}}-character limit'

  #FIXME - validate the right content_types
  validates_format_of :content_type, :message => 'invalid media format, must be in MP3, MPG or AAC format', :with => /.*(mp3|mpg|mpeg|aac).*/


end
