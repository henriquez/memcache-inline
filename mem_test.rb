require 'sinatra'
require 'dalli'

memcache = Dalli::Client.new

# Do equal number of sets and gets with small values
get '/manykeys/:queries' do
  iterations = params[:queries].to_i / 2 # get and set operation per iteration
  @queries = params[:queries]  # get and set operation per iteration

  # define the query pattern to use against memcache
  query_pattern = Proc.new do |iterations|
    iterations.to_i.times do |key|
      memcache.set(key, 'bar')
      @out = memcache.get(key)
    end
  end

  call_memcache(iterations, query_pattern)
end


# simulate a single hot key set then lots of gets with small values
get '/onekey/:queries' do
  iterations = params[:queries].to_i - 1  # get and set operation per iteration
  @queries = params[:queries]  # get and set operation per iteration
  memcache.set('foo', 'bar')

  # define the query pattern to use against memcache
  query_pattern = Proc.new do |iterations|
    iterations.to_i.times do |key|
      @out = memcache.get('foo')
    end
  end

  call_memcache(iterations, query_pattern)
end


# Do equal number of sets and gets with small values
get '/a/:requests' do
  dc = Dalli::Client.new
  @start_time = Time.now
  @queries = params[:requests].to_i / 2 # get and set operation per iteration
  @queries.to_i.times do |key|
    dc.set(key, 'bar')
    @out = dc.get(key)
  end
  @end_time = Time.now
  @elapsed = @end_time - @start_time
  @queries = params[:requests]
  erb :index # render views/index.erb
end


def call_memcache(iterations, query)
  @start_time = Time.now
  # run the query pattern
  query.call(iterations)
  @end_time = Time.now
  @elapsed = @end_time - @start_time
  erb :index # render views/index.erb
end


