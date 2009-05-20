class PodcastsController < ApplicationController
  session :off
  skip_before_filter :verify_authenticity_token

  no_login_required

  def index
    @podcast = Podcast.find(params[:id])
    response.content_type = Mime::XML
    render :layout => false
  end
end
