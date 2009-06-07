function copy_feed_url(feed_url) {
  prompt("Select the feed URL below and press CTRL+C to copy\n\nTIP: To get a feed from a specific year add /[year] to the end of the feed URL (e.g. /2008)", feed_url);
}

document.observe('dom:loaded', function() {
  
  when('podcast_title', function(title) {
    var slug = $('podcast_slug'),
        oldTitle = title.value;

    if (!slug) return;

    new Form.Element.Observer(title, 0.15, function() {
      if (oldTitle.toSlug() == slug.value) slug.value = title.value.toSlug();
      oldTitle = title.value;
    });
  });
  
});
