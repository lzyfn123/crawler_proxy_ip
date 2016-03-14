desc 'xicidaili.com 国内高匿代理'
namespace :crawlers do
  task :get_ips_by_xicidaili do
    ## 停止以前启用的
    CrawlerProxyIp::Crawler.stop_all!

    ## 添加redis
    im = CrawlerProxyIp::IpManage.instance
    im.redis = CrawlerProxyIp.redis

    ## 获取分页地址
    totle_pages = 2
    base_url = 'http://www.xicidaili.com/nn/'
    urls = (1..totle_pages).map { |i| "#{base_url}#{i}" }

    ## 创建爬虫并分配url
    spiders = CrawlerProxyIp::Crawler.new(urls, '#ip_list tr', im, 2) do |item|
      tds = item.css('td')
      unless tds.empty?
        {
            ip: tds[2].text.to_s.strip,
            post: tds[3].text.to_s.strip,
            credit: 0,
            http_type: tds[6].text.to_s.strip,
            auth_second: 0,
            location: tds[4].text.to_s.strip
        }
      end
    end.run_ready

    ## 让小虫子跑起来
    spiders.each(&:join)
  end

  task :get_ips_by_kuaidaili do
    ## 停止以前启用的
    CrawlerProxyIp::Crawler.stop_all!

    ## 添加redis
    im = CrawlerProxyIp::IpManage.instance
    im.redis = CrawlerProxyIp.redis

    ## 获取分页地址
    totle_pages = 2
    base_url = 'http://www.kuaidaili.com/free/inha/'
    urls = (1..totle_pages).map { |i| "#{base_url}#{i}" }

    ## 创建爬虫并分配url
    spiders = CrawlerProxyIp::Crawler.new(urls, 'table.table-bordered tr', im, 2) do |item|
      tds = item.css('td')
      unless tds.blank?
        {
            ip: tds[0].text.to_s.strip,
            post: tds[1].text.to_s.strip,
            http_type: tds[3].text.to_s.strip,
            location: tds[4].text.to_s.strip,
            credit: 0,
            auth_second: 0
        }
      end
    end.run_ready

    ## 让小虫子跑起来
    spiders.each(&:join)
  end

end