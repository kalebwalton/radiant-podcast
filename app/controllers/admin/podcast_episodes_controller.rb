class Admin::PodcastEpisodesController < Admin::ResourceController
  before_filter :find_podcast
  before_filter :add_number_value, :only => [:create]
  after_filter :update_duration, :only => [:create, :update]

  def find_podcast
    @podcast = Podcast.find(params[:podcast_id]) rescue nil unless params[:podcast_id].nil?
  end
  
  def add_number_value
    if !params[:podcast_episode].nil? && params[:podcast_episode][:number].nil?
      params[:podcast_episode][:number] = PodcastEpisode.count(:all, :conditions => ["podcast_id = ?", params[:podcast_id]])+1
    end
  end

  def index
    year = params[:year] || Time.now.strftime("%Y")
    @podcast_episodes = PodcastEpisode.find(:all, :conditions => ["podcast_id = ? AND publish_on > ? AND publish_on < ?", @podcast.id, DateTime.parse(year+'-01-01 00:00:00'), DateTime.parse(year+'-12-31 23:59:59')])
    oldest_episode = PodcastEpisode.find(:last, :conditions => ["podcast_id = ?", @podcast.id])
    @oldest_episode_year = oldest_episode.publish_on.strftime("%Y").to_i unless oldest_episode.nil?
    @current_year = Time.now.strftime("%Y").to_i
    @years = (@oldest_episode_year..@current_year).to_a.reverse unless @current_year.nil? || @oldest_episode_year.nil?
  end
  
  def update_duration
    #FIXME - Implement duration discovery for all media formats
    if !@podcast_episode.nil? && @podcast_episode.valid?
      @podcast_episode.update_attributes!(:duration => 3661) #1 hour, 1 minutes, 1 seconds
    end
  end

end
