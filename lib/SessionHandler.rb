def is_active_url?(url)
  "active" if url.kind_of?(String) and\
  request.path_info.eql? url or request.path_info.start_with? url
end

def is_integer?(value)
  Integer(value) rescue false
end

def get_file(filename)
  File.read(filename)
end

def save_all_data
  save_comments
  save_suggestions
  save_data
end

def add_sessionId_to!(id, sessionId)
  get_data[id.to_s]["sessionId"] << sessionId
end

def get_sessionId_for!(id)
  get_item_with!(id)["sessionId"] || get_item_with!(id)["sessionId"] = []
end

def get_item_with!(id)
  get_data[id.to_s] || get_data[id.to_s] = {}
end

def get_data()
  $dataStorage || $dataStorage = {}
end
