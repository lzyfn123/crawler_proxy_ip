# CrawlerProxyIp

## Installation

添加gem包:

```ruby
gem 'crawler_proxy_ip'
```

执行安装gem包:

    $ bundle

或者直接gem安装:

    $ gem install crawler_proxy_ip

## Usage

* 'redis', '~> 3.1'
* 'nokogiri', '~> 1.6.4'
* 'rake', '>= 10.0.0'

## Development

### rake 例子文件 ###

* ./tasks/crawlers.rake
* ./tasks/test.rake

### 获取网上的代理IP ###

```
#!ruby
Crawler.stop_all!

## 添加redis
im = IpMange.instance
im.redis = ProxyIp.redis

## 获取分页地址
totle_pages = 2
base_url = '免费提供代理IP网站的地址'
urls = (1..totle_pages).map { |i| "#{base_url}#{i}" }

```

*创建爬虫并分配url*

* urls 获取代理ip网页url
* list_selector 获取页面的列表的选择器
* ip_manage 用IpManage
* spider_num 线程数

```
#!ruby
spiders = Crawler.new(urls, '#ip_list tr', im, 2) do |item|
  ## 获取解析页面列表
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

```

### 保存数据到redis ###

*Ip_Manage对象是用来对redis的操作*

```
#!ruby
im = IpManage.instance
im.redis = ProxyIp.redis

im.save_ip(obj)      ## 保存代理ip
im.del_ip(key)       ## 从redis中删除当前的代理ip
im.mv_to_black(key)  ## 把当前ip从可用列表移动到不可用
im.get_random_ip     ## 从可用的代理ip中随机获取一个代理ip
im.get_key_by_obj    ## 给定一个ip obj，生成redis中保存的key

```

### 验证数据 ###

*ValidateIp 模块*

```
#!ruby
auth_proxy_ip(...)   ##验证ip是否有效。

```