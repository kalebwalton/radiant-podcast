class PodcastImage < ActiveRecord::Base
  has_attachment :storage => :file_system, :resize_to => "300>", :max_size => 100.kilobytes
  belongs_to :podcast
  
  validates_as_attachment

  validates_format_of :content_type, :message => 'invalid image format, must be in PNG or JPG format', :with => /.*(png|jpg|jpeg).*/
end
