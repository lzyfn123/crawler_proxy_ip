require "json"
require File.join(__FILE__, '../validate_ip')

###
# 用到容器key
# proxy_ip_8_8_8_8   所有ips
# proxy_ips_enable   能用的ips
# proxy_ips_black    黑名单ips
###
module CrawlerProxyIp
  class IpManage
    include Singleton
    include ValidateIp

    ENABLE_LIST_KEY = 'proxy_ips_enable'
    BLACK_LIST_KEY = 'proxy_ips_black'
    ### 数据结构 obj
    FIELD_TYPE = %w[ip post http_type credit auth_second location]

    attr_accessor :redis

    ### 验证IP，验证obj字段
    def save_ip(obj)
      return if Resolv::IPv4::Regex !~ obj.try(:[], :ip)
      key = generate_key_by_ip(obj.try(:[], :ip))
      unless redis.exists(key)
        redis.mapped_hmset(key, obj)
        redis.sadd(ENABLE_LIST_KEY, key)
      end
      obj
    end

    def save_ips(objs)
      objs.map { |obj| save_ip(obj) }
    end

    ## key, obj
    ## 删除ip
    def del_ip(key, container=BLACK_LIST_KEY)
      redis.del(key)
      redis.srem(BLACK_LIST_KEY, key)
    end

    ##  删除多个ip
    def del_ips(keys)
      keys.map { |obj| del_ip(obj) }
    end

    ## 移动ip到black list中
    # 事物, 返回移动结果
    def mv_to_black(key)
      count = redis.srem(ENABLE_LIST_KEY, key) && redis.sadd(BLACK_LIST_KEY, key)
    end

    ## 移动ip到credit list中
    def mv_to_enable(key)
      redis.srem(BLACK_LIST_KEY, key) && redis.sadd(ENABLE_LIST_KEY, key)
    end

    ### 升信用
    def incr_credit(key, obj_key='credit')
      redis.hincrby(key, obj_key, 1)
    end

    ### 降信用
    def decr_credit(key, obj_key='credit')
      credit = redis.hget(key, obj_key)
      redis.hset(key, 'credit', credit.to_i-1)
    end

    def get_enable_list
      redis.smembers(ENABLE_LIST_KEY)
    end

    def get_black_list
      redis.smembers(BLACK_LIST_KEY)
    end

    ## 获取一个随机ip
    def get_random_ip(count=1, is_https=false)
      obj = nil
      if get_enable_list.any?
        loop do
          key = redis.srandmember(ENABLE_LIST_KEY, count)
          obj = get_obj_by_key(key)
          break if is_https && (obj['http_type']).to_s.downcase.include?('https') || !is_https
        end
      end
      obj
    end

    def get_obj_by_key(key)
      redis.hgetall(key)
    end

    def get_key_by_obj(obj)
      if obj.is_a?(String)
        generate_key_by_ip(obj)
      elsif obj.is_a?(Hash)
        generate_key_by_ip(obj[:ip] || obj['ip'])
      else
        nil
      end
    end

    def generate_key_by_ip(ip)
      "proxy_ip_#{ip.to_s.gsub('.', '_')}"
    end

  end
end

