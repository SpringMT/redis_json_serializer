# encoding: UTF-8

require 'redis_json_serializer/version'
require 'redis'
require 'redis-namespace'
require 'json'

module RedisJsonSerializer
  class Serializer < Redis::Namespace
    def initialize(options = {})
      @host = options[:host] || '127.0.0.1'
      @port = options[:port] || 6379
      @namespace = options[:namespace] || :mock

      r = ::Redis.new(host: @host, port: @port)
      super(@namespace, redis: r)
    end

    def set(key, value)
      _serialize(value) { |serialized_value| super key, serialized_value }
    end

    def setex(key, ttl = 60, value)
      _serialize(value) { |serialized_value| super key, ttl, serialized_value }
    end

    def get(key)
      _deserialize super(key)
    end

    private
    def _serialize(val)
      if val.nil?
        yield val
      elsif val.class == String
        yield val.to_json_raw
      else
        yield val.to_json
      end
    end
    def _deserialize(val)
      return if val.nil?
      ret = (val.empty? ) ? val : JSON.parse(val, symbolize_names: true)
      if ret.class == Hash && ret[:json_class] == "String"
        ret[:raw].pack("c*").force_encoding('utf-8')
      else
        ret
      end
    end
  end
end
