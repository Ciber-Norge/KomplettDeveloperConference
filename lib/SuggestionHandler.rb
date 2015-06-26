def save_suggestion(title, description, format, track, speaker)
  id = SecureRandom.hex(2)
  get_suggestions[id] = {
    'title' => title,
    'description' => description,
    'format' => format,
    'track' => track,
    'speaker' => speaker
  }
  save_suggestions
end

def delete_suggestion(id)
  get_suggestions.delete(id) && save_all_data
end

def get_suggestion_for(id)
  get_suggestions[id] || get_suggestions[id] = {}
end

def get_suggestion_count
  get_suggestions.length
end

def get_suggestions
  $suggestionsStorage || $suggestionsStorage = {}
end
