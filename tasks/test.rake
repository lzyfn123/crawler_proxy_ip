namespace :proxy_ips do
  task :test do
    ## 添加redis
    im = CrawlerProxyIp::IpManage.instance
    im.redis = CrawlerProxyIp.redis

    obj = im.get_random_ip #(true)
    puts '随机取ip', obj

    key = im.get_key_by_obj(obj)
    p '随机取ip-key', key

    im.incr_credit(key)
    obj = im.get_obj_by_key(key)
    p '提升可信度后', obj

    im.decr_credit(key)
    obj = im.get_obj_by_key(key)
    p '降低可信度后', obj

    im.mv_to_black(key)
    p '移动到黑名单', im.get_black_list

    im.mv_to_enable(key)
    p '移动到白名单', im.get_black_list

    im.mv_to_black(key)
    p '移动到黑名单', im.get_black_list

    im.del_ip(key)
    p '从黑名单删除', im.get_black_list
    # obj = {"ip" => "2.2.2.2", "post" => "808", "credit" => "0", "http_type" => "HTTP", "auth_second" => "0", "location" => "青海西宁"}
    puts '验证', obj
    im.redis.del('proxy_ips_black')

    im.auth_proxy_ips([obj]) do |flag, ip|
      unless flag
        key = im.generate_key_by_ip(ip)
        im.mv_to_black(key)
      end
    end
    p '黑名单', im.get_black_list
  end
end
