module Admin::PodcastEpisodesHelper
  def human_filesize(bytes)
    a_kilobyte = 1024.to_f
    a_megabyte = a_kilobyte.to_f * 1024.to_f
    if bytes < a_megabyte
      return "#{(bytes.to_f/a_kilobyte).round(2)} KB"
    else
      return "#{(bytes.to_f/a_megabyte).round(2)} MB"
    end
  end

  def human_duration(duration)
    return "-" if duration.nil?
    hours = duration/60/60
    duration -= hours * 60 * 60
    minutes = duration/60
    duration -= minutes * 60
    seconds = duration
    duration = []
    duration << "#{hours} hr" if hours > 0
    duration << "#{minutes} min" if minutes > 0
    duration << "#{seconds} sec" if seconds > 0
    duration.join(" ")
  end
end
