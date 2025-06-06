module ComplimentsHelper
  def category_badge_classes(category_slug)
    case category_slug
    when "professional-achievement"
      "bg-blue-100 text-blue-800"
    when "personal-growth"
      "bg-green-100 text-green-800"
    when "kindness-compassion"
      "bg-pink-100 text-pink-800"
    when "creativity-innovation"
      "bg-purple-100 text-purple-800"
    when "leadership"
      "bg-indigo-100 text-indigo-800"
    when "teamwork"
      "bg-teal-100 text-teal-800"
    when "overcoming-challenge"
      "bg-orange-100 text-orange-800"
    when "helpfulness"
      "bg-yellow-100 text-yellow-800"
    when "positive-attitude"
      "bg-lime-100 text-lime-800"
    when "thoughtfulness"
      "bg-cyan-100 text-cyan-800"
    when "character-values"
      "bg-emerald-100 text-emerald-800"
    when "friendship"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  def category_strip_color(category_slug)
    case category_slug
    when "professional-achievement"
      "bg-blue-500"
    when "personal-growth"
      "bg-green-500"
    when "kindness-compassion"
      "bg-pink-500"
    when "creativity-innovation"
      "bg-purple-500"
    when "leadership"
      "bg-indigo-500"
    when "teamwork"
      "bg-teal-500"
    when "overcoming-challenge"
      "bg-orange-500"
    when "helpfulness"
      "bg-yellow-500"
    when "positive-attitude"
      "bg-lime-500"
    when "thoughtfulness"
      "bg-cyan-500"
    when "character-values"
      "bg-emerald-500"
    when "friendship"
      "bg-red-500"
    else
      "bg-gray-500"
    end
  end
end
