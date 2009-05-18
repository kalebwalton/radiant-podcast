require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastImage do
  before(:each) do
    @podcast_image = PodcastImage.new
  end

  it "should be valid" do
    @podcast_image.should be_valid
  end
end
