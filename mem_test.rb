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



def call_memcache(iterations, query)
  # wait until current Time least signifcant digit is either 
  # 5 or 0 sec so that multiple workers all start at the same time
  t = Time.now.sec
  @sleep_for = false
  if (t % 5 == 0) 
    @sleep_for = false
  else 
    @sleep_for = 5 - (t % 5)
  end
  sleep(@sleep_for) unless @sleep_for == false
  @start_time = Time.now
  # run the query pattern
  query.call(iterations)
  @end_time = Time.now
  @elapsed = @end_time - @start_time
  erb :index # render views/index.erb
end


