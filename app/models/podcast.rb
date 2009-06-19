require 'yaml'
class Podcast < ActiveRecord::Base
  CATEGORIES = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + '/itunes_categories.yml')).result)

  # Callbacks
  
  # Associations
  has_many :episodes, :class_name => "PodcastEpisode", :order => "podcast_episodes.publish_on DESC"
  has_one :image, :class_name => "PodcastImage" 
  
  # Validations
  validates_presence_of :title, :slug, :author, :email, :link, :description, :categories, :keywords, :message => 'required'
  
  validates_length_of :title, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :subtitle, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :author, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :email, :maximum => 255, :message => '{{count}}-character limit'
  validates_length_of :link, :maximum => 4000, :message => '{{count}}-character limit'
  validates_length_of :description, :maximum => 4000, :message => '{{count}}-character limit'
  validates_length_of :slug, :minimum => 1, :message => '{{count}}-character minimum'

  validates_uniqueness_of :title
  validates_uniqueness_of :slug

  def validate
    if !self.image.nil? && !self.image.valid?
      self.image.errors.each{|attr, msg|
        errors.add :image, msg
      }
    end
  end

  # Accept an array of categories
  def categories_array=(categories)
    self.categories = categories.join(",")
  end

  # Return an array of categories
  def categories_array
    self.categories.split(",") unless self.categories.nil?
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
