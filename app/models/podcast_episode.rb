class PodcastEpisode < ActiveRecord::Base
  default_scope :order => 'publish_on DESC'

  # Callbacks
  
  # Associations
  belongs_to :podcast
  has_attachment :storage => :file_system, :max_size => 50.megabytes
  
  # Validations
  validates_attachment :size => "The file you uploaded was larger than the maximum size of 50MB" 
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

  def human_duration
    return "0:00" if self.duration.nil?
    dur = self.duration
    hours = dur/60/60
    dur -= hours * 60 * 60
    minutes = dur/60
    dur -= minutes * 60
    seconds = dur
    hours = hours < 10 ? "0#{hours}" : "#{hours}"
    minutes = minutes < 10 ? "0#{minutes}" : "#{minutes}"
    seconds = seconds < 10 ? "0#{seconds}" : "#{seconds}"
    hours+":"+minutes+":"+seconds
  end

  def human_filesize
    bytes = self.size
    a_kilobyte = 1024.to_f
    a_megabyte = a_kilobyte.to_f * 1024.to_f
    if bytes < a_megabyte
      return "#{(bytes.to_f/a_kilobyte).round(2)} KB"
    else
      return "#{(bytes.to_f/a_megabyte).round(2)} MB"
    end
  end
end
