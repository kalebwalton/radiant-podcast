# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PodcastExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/podcast"
  
  define_routes do |map|
    map.connect 'podcasts/:action', :controller => 'podcasts'
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :podcasts
      admin.resources :podcast_episodes
    end
  end
  
  def activate
    admin.tabs.add "Podcasts", "/admin/podcasts", :after => "Layouts", :visibility => [:all]
  
    # This adds information to the Radiant interface. In this extension, we're dealing with "site" views
    # so :sites is an attr_accessor. If you're creating an extension for tracking moons and stars, you might
    # put attr_accessor :moon, :star
    Radiant::AdminUI.class_eval do
      attr_accessor :podcasts
    end
    # initialize regions for help (which we created above)
    admin.podcasts = load_default_podcast_regions
   
  end

  def load_default_podcast_regions
    returning OpenStruct.new do |podcast|
      podcast.index = Radiant::AdminUI::RegionSet.new do |index|
        index.top.concat %w{help_text}
        index.thead.concat %w{title_header latest_episode_header actions_header}
        index.tbody.concat %w{title_cell latest_episode_cell actions_cell}
        index.bottom.concat %w{new_button}
      end
      podcast.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_title edit_description edit_meta }
        edit.form_bottom.concat %w{edit_buttons}
      end
      podcast.new = podcast.edit
    end
   end
  
  def deactivate
    admin.tabs.remove "Podcasts"
  end
  
end
