require 'tmpdir'
class Admin::PodcastEpisodesController < Admin::ResourceController
  before_filter :find_podcast
  before_filter :set_duration_properties, :only => [:edit]
  before_filter :set_duration_value, :only => [:update, :create]
  before_filter :set_upload, :only => [:update, :create]

  def find_podcast
    @podcast = Podcast.find(params[:podcast_id]) rescue nil unless params[:podcast_id].nil?
  end

  #def create
    #model.update_attributes!(params[model_symbol])
    #announce_saved
    #response_for :create
  #end

  #def update
    #model.update_attributes!(params[model_symbol])
    #announce_saved
    #response_for :update
  #end

  
  def index
    year = params[:year] || Time.now.strftime("%Y")
    @podcast_episodes = PodcastEpisode.find(:all, :conditions => ["podcast_id = ? AND publish_on > ? AND publish_on < ?", @podcast.id, DateTime.parse(year+'-01-01 00:00:00'), DateTime.parse(year+'-12-31 23:59:59')])
    oldest_episode = PodcastEpisode.find(:last, :conditions => ["podcast_id = ?", @podcast.id])
    @oldest_episode_year = oldest_episode.publish_on.strftime("%Y").to_i unless oldest_episode.nil?
    @current_year = Time.now.strftime("%Y").to_i
    @years = (@oldest_episode_year..@current_year).to_a.reverse unless @current_year.nil? || @oldest_episode_year.nil?
  end

  def set_upload
    # Read in the temporary upload
    upload_id = params[:upload_id]
    unless upload_id.nil? || upload_id.empty?
      # Set the uploaded_data so the model saving works properly
      params[:podcast_episode][:uploaded_data] = {}
      ud = params[:podcast_episode][:uploaded_data]
      ud['size'] = 1 # 1 to trick attachment_fu
      file_name = upload_id[0, upload_id.rindex('.') || 0]
      ud['filename'] = file_name
      # Grab the data from the temp file
      ud['tempfile'] = File.join(Dir.tmpdir,upload_id)
      ud['content_type'] = "audio/mpeg"
    end
  end

  def upload
    upload = params[:upload] unless params[:upload].nil?
    if !upload.nil?
      # Dump the upload to a temp file
      temp_file = File.new(File.join(Dir.tmpdir, upload.original_filename+"."+(rand*1000000).round.to_s), "w")
      if upload.kind_of? StringIO
        # StringIO's need to be rewound
        upload.rewind
      end
      while not upload.eof?
        temp_file.write upload.read
      end
      temp_file.close

      # Don't begin or rescue, just have it throw up the error
      # to the client.
      # FIXME: Consider putting this in the save/create methods so
      # the user doesn't even have to see it in the submission area
      mp3info = nil
      Mp3Info.open(temp_file.path) do |tmp|
        mp3info = tmp
      end
      
      # Return the upload ID (everything after /tmp/)
      # Also include the mp3 length after a '::' so we can split it
      # in javascript and populate the duration fields
      upload_id = temp_file.path.gsub(/.*\//, '')
      
      render :json => {:upload_id => upload_id, :length => mp3info.length, :mp3info => mp3info.tag1}.to_json
    end
  end

  protected 
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
