class PodcastEpisode < ActiveRecord::Base
  default_scope :order => 'publish_on DESC'

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

  validates_format_of :content_type, :message => 'must be in MP3, MP4, M4A, M4V, MOV or PDF format', :with => /.*(mp3|mp4|m4a|m4v|mpg|mpeg|quicktime|pdf).*/
  validates_format_of :filename, :message => 'must end in .mp3, .mp4, .m4a, .m4v, .mov, or .pdf', :with => /.*\.(m4a|mp3|mov|mp4|m4v|pdf)/

  def validate
    unless errors.on(:content_type).nil?
      errors.add(:uploaded_data, errors.on(:content_type))
    end
    unless errors.on(:filename).nil?
      errors.add(:uploaded_data, errors.on(:filename))
    end
  end
end
