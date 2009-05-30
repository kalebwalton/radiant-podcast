# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PodcastExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/podcast"
  
  define_routes do |map|

    map.named_route :podcast, 'podcast/:slug', :controller => 'podcast'
    map.named_route :podcast_by_year, 'podcast/:slug/:year', :controller => 'podcast'
    map.named_route :podcast_episodes_by_year, 'admin/podcasts/:podcast_id/episodes/:year', :controller => 'admin/podcast_episodes'
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
