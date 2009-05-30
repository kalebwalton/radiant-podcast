module Admin::PodcastsHelper
  include PodcastHelper
  def itunes_categories_options_for_select
    all_categories = []
    Podcast::CATEGORIES.each_pair do |category, subcategories|
      all_categories.push([category, category])
      subcategories.each do |subcategory|
        all_categories.push([" - #{subcategory}", "#{category}>#{subcategory}"])
      end
    end
    all_categories
  end
end
