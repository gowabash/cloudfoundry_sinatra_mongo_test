require 'sinatra'
require 'mongo'
require 'yaml'
require 'json'

RAILS_ENV=ENV['RACK_ENV']

def get_connection()
  options = {}
  options['server'] = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['hostname'] rescue 'localhost'
  options['port'] = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['port'] rescue 27017
  options['database'] = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['db'] rescue 'gowabash'
  options['username'] = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['username'] rescue ''
  options['password'] = JSON.parse( ENV['VCAP_SERVICES'] )['mongodb-1.8'].first['credentials']['password'] rescue ''
  return options
end

get '/' do
  vars = ""
  ENV.each_key do |key|
    vars += "#{key} is #{ENV[key]}<br>"
  end
  options = get_connection
  options.each_key do |key|
    vars += "#{key} is #{options[key]}<br>"
  end
  
  return vars
end

get '/add' do
  options = get_connection
  conn= Mongo::Connection.new(options['server'], options['port'], options) 
  db = conn.db(options['database'])
  item = db['counters'].update({'name' => 'test'}, {'$inc' => {'value' => 1}}, {:upsert => true, :safe => true})
  return "added it #{item.inspect}"
end

get '/show' do
  options = get_connection
  conn= Mongo::Connection.new(options['server'], options['port'], options) 
  db = conn.db(options['database'])
  counter = db['counters'].find({'name' => 'test'}).to_a
  return "the counter is #{counter.inspect}"
end
