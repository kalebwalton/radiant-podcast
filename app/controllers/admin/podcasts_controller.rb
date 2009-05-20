class Admin::PodcastsController < Admin::ResourceController

  [:create, :update].each do |action|
    class_eval %{
      def #{action}
        params[:podcast][:image] = process_podcast_image_upload
        model.update_attributes!(params[:podcast])    
        announce_saved                                    
        response_for :#{action}                           
      end                                                 
    }, __FILE__, __LINE__
  end

  def process_podcast_image_upload
    # If there was a PodcastImage uploaded, process it
    unless params[:podcast].nil? or params[:podcast][:image].nil?
      image_param = {:uploaded_data => params[:podcast][:image]}
      image = PodcastImage.new(image_param)
    end
    image
  end

end
