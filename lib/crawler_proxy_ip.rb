require "crawler_proxy_ip/version"

module CrawlerProxyIp
  def self.redis
    @redis ||= Redis.new(:url => "redis://127.0.0.1:6379/2")
  end

  def logger(*str)
    File.open("#{CRAWLER_ROOT}/log/crawler.log", 'a') { |f| f.write((str+["\n"]).join('，')) }
  end
end
