require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastEpisode do
  before(:each) do
    @episode = PodcastEpisode.new
  end

  it "should be valid" do
    @episode.should be_valid
  end
end
