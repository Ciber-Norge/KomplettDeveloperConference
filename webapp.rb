require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'securerandom'
require 'chartkick'
require 'rest_client'
require 'sinatra/r18n'

require_relative 'lib/DatabaseHandler.rb'
require_relative 'lib/SessionHandler.rb'
require_relative 'lib/RatingHandler.rb'
require_relative 'lib/StatsHandler.rb'
require_relative 'lib/CommentHandler.rb'
require_relative 'lib/SuggestionHandler.rb'
require_relative 'lib/TrackHandler.rb'

#Global variables
$tracksStorage = nil
$tracksId = "877e3a6c8cdfd454eeb2687a60980dac"
$suggestionsStorage = nil
$suggestionsId = "cdca417b7d0ed043c8c3681f23b3686e"
$dataStorage = nil
$commentsStorage = nil
$dataId = "cdca417b7d0ed043c8c3681f23bc330f"

use Rack::Session::Cookie, :secret => 'super_secret_key_that_should_be_set_in_a_env_variable'

set :bind, '0.0.0.0'
set :server, :thin

unless CLOUDANT_URL = ENV['CLOUDANT_URL']
  raise "You must specify the CLOUDANT_URL env variable"
end

begin
  load_tracks
  load_suggestions
  load_comments
  load_data
end

before do
  session[:init] = true
end

get '/' do
  haml :index
end

# Tracks
get '/track/now' do
  haml :now, :locals => {:params => get_tracks_for_now, :track => 'now'}
end

get '/track/:track' do | track |
  haml :track, :locals => {:params => get_track(track), :track => track}
end

post '/track/:track/:id' do | track, id |
  save_comment(params['id'], params['navn'], params['kommentar'])
  redirect '/track/' + track
end

# Admin
get '/update' do
  load_tracks
  load_suggestions
  load_comments
  load_data
  redirect '/'
end

get '/save' do
  save_all_data
  redirect '/'
end

get '/carousel' do
  haml :carousel
end

# Ajax
post '/ajax/rateit' do
  id = params['id']
  value = params['value']
  sessionId = session[:session_id]
  unless have_rated?(id, sessionId) and is_integer?(value) then
    add_sessionId_to!(id, sessionId)
    inc_rating_with!(value, id)
    JSON.generate({'id' => id, 'value' => get_rating_for!(id)})
  else
    JSON.generate({'id' => id, 'value' => get_rating_for!(id)})
  end
end

# Stats
get '/stats' do
  haml :stats
end

get '/stats/comments' do
  haml :comments
end

get '/stats/comments/delete' do
  delete_comment(params['id'], params['parent'])
  redirect '/stats/comments'
end

get '/stats/presentation' do
  haml :stats
end

get '/stats/suggestions' do
  haml :suggestions
end

get '/stats/suggestions/delete' do
  delete_suggestion(params['id'])
  redirect '/stats/suggestions'
end

# Call for Papers
get '/cfp' do
  haml :cfp
end

post '/cfp' do
  if params['title'] == "" || params['description'] == "" || params['speaker'] == "" then
    redirect '/cfp'
  end

  save_suggestion params['title'], params['description'], params['format'], params['track'], params['speaker']
  haml :thankyou
end

get '/cfp/suggestions' do
  haml :cfpsuggestions
end

# Api
get '/api/talks' do
  content_type :json, 'charset' => 'utf-8'
  $tracksStorage.to_json
end

get '/api/talks/:cdu' do | cdu |
  content_type :json, 'charset' => 'utf-8'
  JSON.parse(RestClient.get("#{CLOUDANT_URL}/#{$EVENT_URL}/#{$tracksId}"))[cdu].to_json
end

get '/api/rating/:cdu/:talk/:key' do | cdu, talk, key |
  content_type :json, 'charset' => 'utf-8'
  JSON.parse(RestClient.get("#{CLOUDANT_URL}/#{$EVENT_URL}/#{$dataId}"))['data'][cdu][talk][key].to_json
end

get '/api/rating/:cdu/:talk' do | cdu, talk |
  content_type :json, 'charset' => 'utf-8'
  JSON.parse(RestClient.get("#{CLOUDANT_URL}/#{$EVENT_URL}/#{$dataId}"))['data'][cdu][talk].to_json
end

get '/api/rating/:cdu' do | cdu |
  content_type :json, 'charset' => 'utf-8'
  JSON.parse(RestClient.get("#{CLOUDANT_URL}/#{$EVENT_URL}/#{$dataId}"))['data'][cdu].to_json
end

get '/api/suggestions/:cdu' do | cdu |
  content_type :json, 'charset' => 'utf-8'
  JSON.parse(RestClient.get("#{CLOUDANT_URL}/#{$EVENT_URL}/#{$suggestionsId}"))['suggestions'][cdu].to_json
end

# Errors
not_found do
  status 404
  haml :oops
end
