require 'sinatra'
require 'dalli'



# Do equal number of sets and gets with small values
get '/a/:requests' do
  dc = Dalli::Client.new('localhost:11211')
  @start_time = Time.now
  @queries = params[:requests].to_i / 2 # get and set operation per iteration
  @queries.to_i.times do |key|
    dc.set('foo', 'bar')
    @out = dc.get('foo')
  end
  @end_time = Time.now
  @elapsed = @end_time - @start_time
  @queries = params[:requests]
  erb :index # render views/index.erb
end

