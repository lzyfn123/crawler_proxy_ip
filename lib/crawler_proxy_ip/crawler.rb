require 'open-uri'
require 'thread'
require 'json'

module CrawlerProxyIp
  class Crawler
    @@spiders = {all: [], finish: []}

    def initialize(urls, list_selector, ip_manage, spider_num=2, &block)
      @urls = urls
      @spider_num = spider_num
      @list_selector = list_selector
      @ip_manage = ip_manage
      @block = block
    end

    class << self
      def get_spiders(type=:all)
        @@spiders.send(:[], type.to_s.to_sym)
      end

      def stop_all!
        @@spiders[:all].each { |spider| @@spiders[:all].delete(spider) && Thread.kill(spider) }
      end

      def distribute_tasks(tasks, num)
        num = tasks.length if tasks.length < num
        average = (tasks.length/num).to_i
        groups = 1.upto(num).map { |page| tasks[((page-1)*average)..(page*average-1)] }
        tasks.length > num*average ? groups << tasks[num*average..tasks.length-1] : groups
      end

      def get_doc_by_url(url)
        doc = Nokogiri::HTML(open(url))
        doc.css("script").remove # encoding bug in older libxml?
        doc
      end
    end

    def run_ready
      groups = self.class.distribute_tasks(@urls, @spider_num)
      @spider_num.times do |index|
        spider_urls = groups[index]

        @@spiders[:all] << Thread.new do
          if @block.nil?
            puts '====== 无法解析doc ======'
          else
            start_time = Time.now
            spider_urls.each do |url|
              proxy_ips = []
              begin ### 添加超时可多次获取
                doc = Crawler.get_doc_by_url(url)
                doc.css(@list_selector).each do |tr|
                  obj = @block.call(tr)
                  proxy_ips.push(obj) if Resolv::IPv4::Regex =~ obj.try(:[], :ip)
                end
                @ip_manage.save_ips(proxy_ips)
              rescue Exception => ex
                CrawlerProxyIp.logger('获取页面错误:', ex.class.name)
                @@spiders[:finish] << Thread.current
              end
            end
            puts "获取到: #{spider_urls.size}个url，花费时间：#{Time.now - start_time}"
          end
          @@spiders[:finish] << Thread.current
        end

      end
      @@spiders[:all]
    end
  end
end