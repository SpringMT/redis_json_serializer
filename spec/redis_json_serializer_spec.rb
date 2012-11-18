#!/usr/bin/env ruby
# encoding: UTF-8

require File.dirname(__FILE__) + '/spec_helper'

require 'redis'
require 'redis-namespace'
require 'json'

options = {
  host: "192.168.100.1",
  port: 1234,
  namespace: :test,
}
test_options = {
  namespace: :test,
}

test_nil = nil
test_blank = ''
test_space = 'test test'
test_tab = "test		test"
test_carriage_return = "test\n\rtest"
test_string = 'testてすと'
test_array = %w('test1てすと' 'test2 test2' 'test3\ntest3' 'test4\rtest4' 'test5\n\rtest5' 'test6		test6' '' nil)
test_hash = { test1: 'test1てすと', test2: 'test2 test2', test3: 'test3\ntest3', test4: 'test4\rtest4', test5: 'test5\n\rtest5', test6: 'test6		test6', test7: '', nil_test: nil }

r = Redis.new(host: "127.0.0.1", port: 6379)
test_redis = Redis::Namespace.new(:test, redis: r)

describe RedisJsonSerializer::Serializer do
  describe :new do
    context 'no params' do
      subject { RedisJsonSerializer::Serializer.new }
      it { subject.client.host.should be_eql("127.0.0.1") }
      it { subject.client.port.should be_eql(6379) }
      it { subject.namespace.should be_eql(:mock) }
    end
    context 'exixsts params' do
      subject { RedisJsonSerializer::Serializer.new(options) }
      it { subject.client.host.should be_eql("192.168.100.1") }
      it { subject.client.port.should be_eql(1234) }
      it { subject.namespace.should be_eql(:test) }
    end
  end

  describe :setex do
    before { @set_test_redis = RedisJsonSerializer::Serializer.new(test_options) }
    context 'with a valid key' do
      context 'nil' do
        before { @set_test_redis.setex(:test_setex_nil, 1, test_nil) }
        it { test_redis.get(:test_setex_nil).should be_eql("") }
      end
      context 'blank' do
        before { @set_test_redis.setex(:test_setex_blank, 1, test_blank) }
        it { test_redis.get(:test_setex_blank).should be_eql(test_blank.to_json_raw) }
      end
      context 'space' do
        before { @set_test_redis.setex(:test_setex_space, 1, test_space) }
        it { test_redis.get(:test_setex_space).should be_eql(test_space.to_json_raw) }
      end
      context 'tab' do
        before { @set_test_redis.setex(:test_setex_tab, 1, test_tab) }
        it { test_redis.get(:test_setex_tab).should be_eql(test_tab.to_json_raw) }
        #it { test_redis.get(:test_set_tab).should be_eql("{\"json_class\":\"String\",\"raw\":[116,101,115,116,9,9,116,101,115,116]}") }
      end
      context 'carriage return' do
        before { @set_test_redis.setex(:test_setex_carriage_return, 1, test_carriage_return) }
        it { test_redis.get(:test_setex_carriage_return).should be_eql(test_carriage_return.to_json_raw) }
      end
      context 'String' do
        before { @set_test_redis.setex(:test_setex_string, 1, test_string) }
        it { test_redis.get(:test_setex_string).should be_eql(test_string.to_json_raw) }
      end
      context 'Array' do
        before { @set_test_redis.setex(:test_setex_array, 1, test_array) }
        it { test_redis.get(:test_setex_array).should be_eql(test_array.to_json) }
      end
      context 'Hash' do
        before { @set_test_redis.setex(:test_setex_hash, 1, test_hash) }
        it { test_redis.get(:test_setex_hash).should be_eql(test_hash.to_json) }
      end
    end
    context 'ttl check' do
      before { @set_test_redis.setex(:test_setex_check_ttl, 1, test_hash) }
      it do
        sleep 2
        test_redis.get(:test_setex_hash).should be_nil
      end
    end
  end

  describe :set do
    before { @set_test_redis = RedisJsonSerializer::Serializer.new(test_options) }
    context 'with a valid key' do
      context 'nil' do
        before { @set_test_redis.set(:test_set_nil, test_nil) }
        it { test_redis.get(:test_set_nil).should be_eql("") }
      end
      context 'blank' do
        before { @set_test_redis.set(:test_set_blank, test_blank) }
        it { test_redis.get(:test_set_blank).should be_eql(test_blank.to_json_raw) }
      end
      context 'space' do
        before { @set_test_redis.set(:test_set_space, test_space) }
        it { test_redis.get(:test_set_space).should be_eql(test_space.to_json_raw) }
      end
      context 'tab' do
        before { @set_test_redis.set(:test_set_tab, test_tab) }
        it { test_redis.get(:test_set_tab).should be_eql(test_tab.to_json_raw) }
        #it { test_redis.get(:test_set_tab).should be_eql("{\"json_class\":\"String\",\"raw\":[116,101,115,116,9,9,116,101,115,116]}") }
      end
      context 'carriage return' do
        before { @set_test_redis.set(:test_set_carriage_return, test_carriage_return) }
        it { test_redis.get(:test_set_carriage_return).should be_eql(test_carriage_return.to_json_raw) }
      end
      context 'String' do
        before { @set_test_redis.set(:test_set_string, test_string) }
        it { test_redis.get(:test_set_string).should be_eql(test_string.to_json_raw) }
      end
      context 'Array' do
        before { @set_test_redis.set(:test_set_array, test_array) }
        it { test_redis.get(:test_set_array).should be_eql(test_array.to_json) }
      end
      context 'Hash' do
        before { @set_test_redis.set(:test_set_hash, test_hash) }
        it { test_redis.get(:test_set_hash).should be_eql(test_hash.to_json) }
      end
    end
  end

  describe :get do
    before do
      test_redis.set :test_get_nil, test_nil
      test_redis.set :test_get_blank, test_blank.to_json_raw
      test_redis.set :test_get_space, test_space.to_json_raw
      test_redis.set :test_get_tab, test_tab.to_json_raw
      test_redis.set :test_get_carriage_return, test_carriage_return.to_json_raw
      test_redis.set :test_get_string, test_string.to_json_raw
      test_redis.set :test_get_array, test_array.to_json
      test_redis.set :test_get_hash, test_hash.to_json
    end
    context 'with a valid key' do
      subject { RedisJsonSerializer::Serializer.new(test_options) }
      context 'nil' do
        # nil converts "" so retrun value check not nil but ''. However nil in Hash converts nil.
        it { subject.get(:test_get_nil).should be_eql('') }
      end
      context 'blank' do
        it { subject.get(:test_get_blank).should be_eql(test_blank) }
      end
      context 'space' do
        it { subject.get(:test_get_space).should be_eql(test_space) }
      end
      context 'tab' do
        it { subject.get(:test_get_tab).should be_eql(test_tab) }
      end
      context 'carriage return' do
        it { subject.get(:test_get_carriage_return).should be_eql(test_carriage_return) }
      end
      context 'String' do
        it { subject.get(:test_get_string).should be_eql(test_string) }
      end
      context 'Array' do
        it { subject.get(:test_get_array).should be_eql(test_array) }
      end
      context 'Hash' do
        it { subject.get(:test_get_hash).should be_eql(test_hash) }
      end
    end
    context 'with an invalid key' do
      subject { RedisJsonSerializer::Serializer.new(test_options) }
      it { subject.get(:no_key).should be_nil }
    end
  end

end


