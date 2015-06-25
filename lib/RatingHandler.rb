class Array
  def sum
    self.inject{|sum,x| sum + x }
  end
end

def get_rating_for!(id)
  if get_item_with!(id)["rating"].nil?
    init_rating_for!(id)
  end
  sum = get_item_with!(id)["rating"].sum
  if sum.nil? then return 0 end

  sum / get_item_with!(id)["rating_count"]
end

def inc_rating_with!(rating, id)
  if get_item_with!(id)["rating"].nil? then
    init_rating_for!(id)
  end
  
  get_item_with!(id)["rating_count"] += 1
  get_item_with!(id)["rating"] << rating.to_f
end

def init_rating_for!(id)
  get_item_with!(id)["rating"] = []
  get_item_with!(id)["rating_count"] = 0
end

def have_rated?(id, sessionId)
  get_sessionId_for!(id).include? sessionId
end
def get_number_of_ratings()
  sum = 0
  get_data.each do | key, value |
    sum += value["rating_count"] || 0
  end
  sum
end

def get_number_of_ratings_for(id)
  get_item_with!(id)["rating_count"] || 0
end

def get_average_of_ratings()
  sum = 0
  ratings = get_number_of_ratings
  get_data.each do | key, value |
    sum += value["rating"].sum || 0
  end
  unless sum == 0 or ratings == 0
    return sum / ratings
  end
  0
end

def get_average_of_ratings_for(id)
  sum = get_item_with!(id)["rating"].sum
  ratings = get_number_of_ratings_for(id)
  unless sum == 0 or ratings == 0
    return sum / ratings
  end
  0
end

def get_ratings_for_stats_for(id)
  values = {}
  get_item_with!(id)["rating"].uniq.each do | value |
    values[:"Stemt #{value}"] = get_item_with!(id)["rating"].count(value)
  end
  values
end
