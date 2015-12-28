require 'helper'
require 'sshkit'

module SSHKit
  class TestCommandMap < UnitTest

    def test_defaults
      map = CommandMap.new
      assert_equal map[:rake], "/usr/bin/env rake"
      assert_equal map[:test], "test"
    end

    def test_setter
      map = CommandMap.new
      map[:rake] = "/usr/local/rbenv/shims/rake"
      assert_equal map[:rake], "/usr/local/rbenv/shims/rake"
    end

    def test_setter_procs
      map = CommandMap.new
      i = 0
      map[:rake] = -> { i += 1; "/usr/local/rbenv/shims/rake#{i}" }

      assert_equal map[:rake], "/usr/local/rbenv/shims/rake1"
      assert_equal map[:rake], "/usr/local/rbenv/shims/rake2"
    end

    def test_prefix
      map = CommandMap.new
      map.prefix[:rake].push("/home/vagrant/.rbenv/bin/rbenv exec")
      map.prefix[:rake].push("bundle exec")

      assert_equal map[:rake], "/home/vagrant/.rbenv/bin/rbenv exec bundle exec rake"
    end

    def test_prefix_procs
      map = CommandMap.new
      map.prefix[:rake].push("/home/vagrant/.rbenv/bin/rbenv exec")
      map.prefix[:rake].push(proc{ "bundle exec" })

      assert_equal map[:rake], "/home/vagrant/.rbenv/bin/rbenv exec bundle exec rake"
    end

    def test_prefix_unshift
      map = CommandMap.new
      map.prefix[:rake].push("bundle exec")
      map.prefix[:rake].unshift("/home/vagrant/.rbenv/bin/rbenv exec")

      assert_equal map[:rake], "/home/vagrant/.rbenv/bin/rbenv exec bundle exec rake"
    end

    def test_indifferent_setter
      map = CommandMap.new
      map[:rake] = "/usr/local/rbenv/shims/rake"
      map["rake"] = "/usr/local/rbenv/shims/rake2"

      assert_equal "/usr/local/rbenv/shims/rake2", map[:rake]
    end

    def test_indifferent_prefix
      map = CommandMap.new
      map.prefix[:rake].push("/home/vagrant/.rbenv/bin/rbenv exec")
      map.prefix["rake"].push("bundle exec")

      assert_equal map[:rake], "/home/vagrant/.rbenv/bin/rbenv exec bundle exec rake"
    end

    def test_prefix_setter
      map = CommandMap.new({})
      map[:rake] = 'rake2.2'
      map.prefix[:rake].push('bundle exec')

      assert_equal map[:rake], 'bundle exec rake2.2'
    end
  end
end
