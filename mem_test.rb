require 'sinatra'
require 'dalli'

# make a bunch of requests to memcached on every get,
get '/' do

  erb :index # render views/index.erb
end