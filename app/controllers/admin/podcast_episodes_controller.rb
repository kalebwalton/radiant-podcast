class Admin::PodcastEpisodesController < Admin::ResourceController
  before_filter :find_podcast
  before_filter :set_duration_properties, :only => [:edit]
  before_filter :set_duration_value, :only => [:update, :create]

  def find_podcast
    @podcast = Podcast.find(params[:podcast_id]) rescue nil unless params[:podcast_id].nil?
  end
  
  def index
    year = params[:year] || Time.now.strftime("%Y")
    @podcast_episodes = PodcastEpisode.find(:all, :conditions => ["podcast_id = ? AND publish_on > ? AND publish_on < ?", @podcast.id, DateTime.parse(year+'-01-01 00:00:00'), DateTime.parse(year+'-12-31 23:59:59')])
    oldest_episode = PodcastEpisode.find(:last, :conditions => ["podcast_id = ?", @podcast.id])
    @oldest_episode_year = oldest_episode.publish_on.strftime("%Y").to_i unless oldest_episode.nil?
    @current_year = Time.now.strftime("%Y").to_i
    @years = (@oldest_episode_year..@current_year).to_a.reverse unless @current_year.nil? || @oldest_episode_year.nil?
  end

  def set_duration_properties
    unless @podcast_episode.nil? || @podcast_episode.duration.nil?
      d = @podcast_episode.duration
      @duration_hours = d/60/60
      d -= @duration_hours * 60 * 60
      @duration_minutes = d/60
      d -= @duration_minutes * 60
      @duration_seconds = d
    end
  end
  
  def set_duration_value
    #FIXME - Implement duration discovery for all media formats. For now we'll use manual entry.
    hours = params[:duration_hours].to_i
    minutes = params[:duration_minutes].to_i
    seconds = params[:duration_seconds].to_i
    duration = (hours*60*60) + (minutes*60) + seconds
    params[:podcast_episode][:duration] = duration;
  end

end
