module ApplicationHelper
  def compliment_category_color(category)
    # Map category names to tailwind color classes
    colors = {
      "Appreciation" => "bg-blue-100 text-blue-800",
      "Recognition" => "bg-purple-100 text-purple-800",
      "Encouragement" => "bg-green-100 text-green-800",
      "Inspiration" => "bg-yellow-100 text-yellow-800",
      "Kindness" => "bg-pink-100 text-pink-800"
    }

    # Default color for any other category
    colors[category.name] || "bg-gray-100 text-gray-800"
  end

  def mood_color_class(mood_value)
    case mood_value
    when 1 then "bg-red-500 text-white"
    when 2 then "bg-orange-500 text-white"
    when 3 then "bg-yellow-500 text-white"
    when 4 then "bg-green-400 text-white"
    when 5 then "bg-green-600 text-white"
    else "bg-gray-500 text-white"
    end
  end

  def mood_emoji(mood_value)
    case mood_value
    when 1 then "😞"
    when 2 then "😔"
    when 3 then "😐"
    when 4 then "🙂"
    when 5 then "😀"
    else "❓"
    end
  end
end
