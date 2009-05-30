class Podcast < ActiveRecord::Base
  #FIXME - List real iTunes categories
  CATEGORIES = {
    "Arts & Entertainment" => [
      "Architecture",
      "Books"
    ],
    "Technology" => [
      "High Technology"
    ]
  }

  # Callbacks
  
  # Associations
  has_many :episodes, :class_name => "PodcastEpisode", :order => "podcast_episodes.publish_on DESC"
  has_one :image, :class_name => "PodcastImage" 
  
  # Validations
  validates_presence_of :title, :author, :email, :link, :description, :categories, :keywords, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :subtitle, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :author, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :email, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :link, :maximum => 4000, :message => '{{count}}-character limit'
  validates_length_of :description, :maximum => 4000, :message => '{{count}}-character limit'

  validates_uniqueness_of :title, :message => 'title is already in use'

  def validate
    if !self.image.nil? && !self.image.valid?
      self.image.errors.each{|attr, msg|
        errors.add :image, msg
      }
    end
  end

  # Return a slug to use for the URL
  def slug
    self.title.to_slug.gsub(/-{1,}/, '-')
  end

  # Accept an array of categories
  def categories_array=(categories)
    self.categories = categories.join(",")
  end

  # Return an array of categories
  def categories_array
    self.categories.split(",")
  end

  # Return a hash of categories and subcategories
  def categories_hash
    hash = {}
    self.categories_array.each do |category_pair|
      category = category_pair.split('>')[0]
      subcategory = category_pair.split('>')[1]
      hash[category] = [] if hash[category].nil?
      hash[category].push(subcategory) if !subcategory.nil? && !subcategory.empty?
    end
    hash
  end
  
end
