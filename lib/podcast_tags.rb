module PodcastTags
  include Radiant::Taggable

  desc %{
    Causes the tags referring to a podcast's attributes to refer to the current podcast.

    *Usage:*

    <pre><code><r:podcast [id="podcast_id"] [name="podcast_name"] [url="podcast_url"]>...</r:podcast></code></pre>
  }
  tag 'podcast' do |tag|
    podcast = nil
    title = tag.attr['title']
    url = tag.attr['url']
    url.gsub!(/.*\//,'') unless url.nil?
    id = tag.attr['id']
    if title.nil? and id.nil? and url.nil?
      raise TagError.new("either a 'title', 'id' or 'url' must be provided to the podcast tag")
    end
    if !title.nil?
      podcast = Podcast.find_by_title(title)
    elsif !id.nil?
      podcast = Podcast.find(id)
    elsif !url.nil?
      podcast = Podcast.find_by_slug(url)
    end
    tag.locals.podcast = podcast unless podcast.nil?
    tag.expand
  end

  [:title, :subtitle, :description, :author].each do |method|
    desc %{
      Displays the @#{method}@ attribute of the current podcast.
      *Usage:*

      <pre><code>
        <r:podcast id="1">
          <r:#{method}/>
        </r:podcast>
      </code></pre>
    }
    tag 'podcast:'+method.to_s do |tag|
      tag.locals.podcast.send(method)
    end
  end

  desc %{
    Gives access to a podcast's episodes.

    *Usage:*

    <pre><code><r:episodes>...</r:episodes></code></pre>
  }
  tag 'podcast:episodes' do |tag|
    tag.expand
  end
  desc %{
    Cycles through each of the episodes. Inside this tag all podcast attribute tags
    are mapped to the current child podcast.

    By default the current year is used.

    *Usage:*

    <pre><code><r:episodes:each [year="number"] [limit="number"]>
     ...
    </r:episodes:each>
    </code></pre>
  }
  tag 'podcast:episodes:each' do |tag|
    year = tag.attr['year'] || Time.now.strftime("%Y")
    limit = tag.attr['limit']
    conditions = []
    values = []
    conditions << "podcast_id = ?"
    values << tag.locals.podcast.id
    conditions << "publish_on > ? AND publish_on < ?" unless tag.attr['year'].nil?
    values.concat [DateTime.parse(year+'-01-01 00:00:00'), DateTime.parse(year+'-12-31 23:59:59')] unless tag.attr['year'].nil?
    conditions = [conditions.join(" AND ")]
    conditions.concat values
    episodes = PodcastEpisode.find(:all, :conditions => conditions, :limit => limit)

    result = []
    episodes.each do |episode|
      tag.locals.episode = episode
      result << tag.expand
    end
    result
  end

  [:title, :subtitle, :description, :duration, :author].each do |method|
    desc %{
      Displays the @#{method}@ attribute of the current episode.

      *Usage:*

      <pre><code>
        <r:podcast url="http://mysite.com/podcast/my-url">
          <r:episodes:each limit="8">
            <r:#{method}/>
          </r:episodes:each>
        </r:podcast>
      </code></pre>
    }
    tag 'podcast:episodes:'+method.to_s do |tag|
      method = :human_duration if method == :duration
      tag.locals.episode.send(method)
    end
  end

  desc %{
    Displays the publish date of a podcast episode.

    *Usage:*

    <pre><code>
      <r:podcast url="http://mysite.com/podcast/my-url">
        <r:episodes:each limit="8">
          <r:publish_on [format="%A, %B %d, %Y"]/>
        </r:episodes:each>
      </r:podcast>
    </code></pre>
  }
  tag 'podcast:episodes:publish_on' do |tag|
    format = tag.attr['format'] || "%A, %B %d, %Y";
    tag.locals.episode.publish_on.strftime(format)
  end


  desc %{
    Displays a link to the podcast episode.

    *Usage:*

    <pre><code><r:link [other attributes...]/></code></pre>
  }
  tag 'podcast:episodes:link' do |tag|
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    %{<a href="#{full_absolute_url(tag.locals.episode.public_filename)}"#{attributes}>#{text}</a>}
  end

  def full_absolute_url(url)
    "http#{'s' if request.ssl? || request.port==443}://#{request.host_with_port}"+url
  end

end
