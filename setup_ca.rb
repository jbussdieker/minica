#!/usr/bin/env ruby
require_relative 'certificate_authority'

raise "Must specify CA root" unless ARGV.length > 0
dir = ARGV[0]
ca = CertificateAuthority.new(dir)

File.open(File.join(dir, "openssl.cnf"), 'w') do |f|
  f.write(ca.config)
end
