# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PodcastExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/podcast"
  
  define_routes do |map|

    map.named_route :podcast, 'podcast/:slug', :controller => 'podcast'
    map.named_route :podcast_by_year, 'podcast/:slug/:year', :controller => 'podcast'
    map.named_route :podcast_episodes_by_year, 'admin/podcasts/:podcast_id/episodes/year/:year', :controller => 'admin/podcast_episodes'
    map.named_route :submit_to_itunes, 'admin/podcasts/:podcast_id/itunes', :controller => 'admin/podcasts', :action => 'itunes'
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :podcasts, :member => { :remove => :get, :itunes => :get } do |podcasts|
        podcasts.resources :podcast_episodes, :as => :episodes, :member => { :remove => :get }
      end 
    end

  end
  
  def activate
    #FIXME - Need to somehow prevent a slug with the name 'podcasts' from being created
    admin.tabs.add "Podcasts", "/admin/podcasts", :after => "Layouts", :visibility => [:all]
    
    Page.send :include, PodcastTags

    # This adds information to the Radiant interface. In this extension, we're dealing with "site" views
    # so :sites is an attr_accessor. If you're creating an extension for tracking moons and stars, you might
    # put attr_accessor :moon, :star
    Radiant::AdminUI.class_eval do
      attr_accessor :podcasts
    end
   
  end

  def deactivate
    admin.tabs.remove "Podcasts"
  end
  
end

Technoweenie::AttachmentFu::InstanceMethods.module_eval do
  protected
    def attachment_valid?
      if self.filename.nil?
        errors.add_to_base attachment_validation_options[:empty]
        return
      end
      [:content_type, :size].each do |option|
        if attachment_validation_options[option] && attachment_options[option] && !attachment_options[option].include?(self.send(option))
          errors.add_to_base attachment_validation_options[option]
        end
      end
    end
end

Technoweenie::AttachmentFu::ClassMethods.module_eval do
  # Options: 
  # *  <tt>:empty</tt> - Base error message when no file is uploaded. Default is "No file uploaded" 
  # *  <tt>:content_type</tt> - Base error message when the uploaded file is not a valid content type.
  # *  <tt>:size</tt> - Base error message when the uploaded file is not a valid size.
  #
  # Example:
  #   validates_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
  #                        :size         => "The image you uploaded was larger than the maximum size of 10MB" 
  def validates_attachment(options={})
    options[:empty] ||= "No file uploaded" 
    class_inheritable_accessor :attachment_validation_options
    self.attachment_validation_options = options
    validate :attachment_valid?
  end
end
