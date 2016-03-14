require 'uri'
require 'net/http'

module CrawlerProxyIp
  module ValidateIp
    # AUTH_URL = 'https://www.baidu.com/'
    AUTH_URL = 'https://ruby.taobao.org/'

    def http_request(http, uri)
      flag = false
      req = Net::HTTP::Get.new(uri.request_uri)
      http.request(req) do |res|
        puts '获取状态', res.code
        flag = res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPRedirection)
      end
      flag
    end

    def auth_proxy_ip(proxy_ip, proxy_port, auth_url=AUTH_URL, &block)
      times = 3
      flag = false
      uri = URI.parse(auth_url)
      http = Net::HTTP.new(uri.host, uri.port, proxy_ip, proxy_port)
      http.open_timeout = 120
      http.read_timeout = 120
      http.use_ssl = true
      http.ssl_timeout = 120
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      begin
        flag = http_request(http, uri)
      rescue Errno::ETIMEDOUT, Net::ReadTimeout, Net::OpenTimeout, Interrupt, SocketError => e
        times -= 1
        retry if times>0
      rescue Exception => ex
        CrawlerProxyIp.logger('验证请求错误:', ex.class.name)
      end

      block.call(flag, proxy_ip)
    end

    def auth_proxy_ips(objs, &block)
      objs.each { |obj| auth_proxy_ip(obj[:ip], obj[:port], &block) }
    end

  end
end