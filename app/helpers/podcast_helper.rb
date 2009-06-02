require 'time'
module PodcastHelper
  def full_absolute_url(url)
    "http#{'s' if request.ssl? || request.port==443}://#{request.host_with_port}"+url
  end

  def podcast_feed_url(podcast)
    full_absolute_url(url_for(:controller => '/podcast', :slug => podcast.slug))
  end

  #FIXME This is repeated in two helpers - combine in 1 or put it in the model
  def itunes_duration(duration)
    return "0:00" if duration.nil?
    hours = duration/60/60
    duration -= hours * 60 * 60
    minutes = duration/60
    duration -= minutes * 60
    seconds = duration
    hours = hours < 10 ? "0#{hours}" : "#{hours}"
    minutes = minutes < 10 ? "0#{minutes}" : "#{minutes}"
    seconds = seconds < 10 ? "0#{seconds}" : "#{seconds}"
    hours+":"+minutes+":"+seconds
  end

  def rfc2822(date)
    date.to_time.rfc2822 unless date.nil?
  end

end
