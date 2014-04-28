require 'erb'

class CertificateAuthority
  attr_accessor :dir

  def initialize(dir)
    @dir = dir
  end

  def countryName_default
    "US"
  end

  def stateOrProvinceName_default
    "California"
  end

  def default_bits
    2048
  end

  def template
    ERB.new(File.read("openssl.cnf.erb"))
  end

  def config
    template.result(binding)
  end
end
