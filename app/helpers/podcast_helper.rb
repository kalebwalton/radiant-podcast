require 'time'
module PodcastHelper
  def full_absolute_url(url)
    "http#{'s' if request.ssl? || request.port==443}://#{request.host_with_port}"+url
  end

  def podcast_feed_url(podcast)
    full_absolute_url(url_for(:controller => '/podcast', :slug => podcast.slug || ""))
  end

  def rfc2822(date)
    date.to_time.rfc2822 unless date.nil?
  end

end
