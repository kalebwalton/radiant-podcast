document.observe('dom:loaded', function() {
  
  Event.observe($('podcast_slug'), 'click', function(event) {
    alert("Changing the Feed URL will require you to resubmit your podcast to iTunes.");
  });
  
});
