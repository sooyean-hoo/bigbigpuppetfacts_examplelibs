#!/opt/puppetlabs/puppet/bin/ruby  -I vendor/bundle/ruby/2.6.0/gems/ruby-xz-1.0.0/lib
require 'xz'
require "base64"
require 'benchmark'

enc   = Base64.encode64('Send reinforcements')
                    # -> "U2VuZCByZWluZm9yY2VtZW50cw==\n"
plain = Base64.decode64(enc)
                    # -> "Send reinforcements"
# puts enc
# puts plain

data = "I love Ruby"

comp = XZ.compress(data) #=> binary blob
dcomp = XZ.decompress(comp) #=> binary blob
# puts comp
# puts dcomp

puts Benchmark.measure {       XZ.decompress( Base64.decode64(  Base64.encode64(XZ.compress(data) )   ) )   }

puts "=====================================================\n"
puts "#{               XZ.decompress( Base64.decode64(  Base64.encode64(XZ.compress(data) )   ) )                               }\n"
puts "=====================================================\n"
