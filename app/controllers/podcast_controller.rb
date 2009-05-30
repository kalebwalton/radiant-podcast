class PodcastController < ApplicationController
  session :off
  skip_before_filter :verify_authenticity_token

  no_login_required

  def index
    podcasts = Podcast.find(:all)
    podcasts.each do |podcast|
      if podcast.slug == params[:slug]
        year = params[:year] || Time.now.strftime('%Y')
        @podcast = podcast
        @episodes = PodcastEpisode.find(:all, :conditions => ["podcast_id = ? AND publish_on > ? AND publish_on < ?", @podcast.id, DateTime.parse(year+'-01-01 00:00:00'), DateTime.parse(year+'-12-31 23:59:59')])
        break
      end
    end
    response.content_type = Mime::XML
    render :layout => false
  end
end
