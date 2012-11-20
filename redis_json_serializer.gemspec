# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_json_serializer/version"

Gem::Specification.new do |s|
  s.name        = "redis_json_serializer"
  s.version     = RedisJsonSerializer::VERSION
  s.authors     = ["Spring_MT"]
  s.email       = ["today.is.sky.blue.sky@gmail.com"]
  s.homepage    = "https://github.com/SpringMT/redis_json_serializer"
  s.summary     = %q{json serializer for redis}

  s.rubyforge_project = "redis_json_serializer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis', '~> 3.0'
  s.add_dependency 'redis-namespace', '~> 1.2'

  s.description = <<description
description
end
