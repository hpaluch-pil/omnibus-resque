require 'resque'
require 'open-uri'
require 'nokogiri'
require 'redis'

module PIL
    module Jobs
        module UrlTitle
            @queue = :url_title

            def self.strip_or_self!(str)
                str.strip! || str if str
            end

            def self.perform(url)
                #url='http://www.downloads.pickeringtest.info/downloads/drivers/PXI_Drivers/'
                puts "Fetching '#{url}'..."
                doc = Nokogiri::HTML(open(url))
                title = strip_or_self!(doc.title)
                puts "Title of url '#{url}' is: '#{title}'"
            end # /perform
        end # /UrlTitle
    end # /Jobs
end # /PIL
Resque.redis = Redis.new( path: '/var/opt/resque/redis/redis.socket')

# vim: set ts=4 sw=4 expandtab:
