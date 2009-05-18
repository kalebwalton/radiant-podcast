class PodcastImage < ActiveRecord::Base
  has_attachment :storage => :file_system, :resize_to => "300>", :max_size => 100.kilobytes
  belongs_to :podcast
  
  validates_as_attachment
  validates_uniqueness_of :filename
end
