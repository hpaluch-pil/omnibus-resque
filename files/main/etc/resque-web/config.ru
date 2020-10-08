# config.ru for resque-web

require 'logger'
require 'resque/server'
require 'redis'

use Rack::ShowExceptions

# use this to bind resque-web under some URI path
#rq = Rack::URLMap.new "/resque" => Resque::Server.new

rq = Resque::Server.new
Resque.redis = Redis.new( path: '/var/opt/resque/redis/redis.socket')
run rq

