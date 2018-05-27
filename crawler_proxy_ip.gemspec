# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crawler_proxy_ip/version'

Gem::Specification.new do |spec|
  spec.name          = "crawler_proxy_ip"
  spec.version       = CrawlerProxyIp::VERSION
  spec.authors       = ["lizy"]
  spec.email         = ["lzyfn123@126.com"]

  spec.summary       = %q{网络搜索一些免费的代理IP}
  spec.description   = %q{网络搜索一些免费的代理IP，并验证IP是否有效。}
  spec.homepage      = "https://github.com/lzyfn123/crawler_proxy_ip"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://80sds.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "redis", '~> 3.1'
  spec.add_development_dependency "nokogiri", '~> 1.8.2'
end
