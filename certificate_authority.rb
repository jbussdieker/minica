require 'erb'
require 'fileutils'

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

  def ssl_config
    File.join(dir, "openssl.cnf")
  end

  def ca_key
    File.join(dir, "private", "cakey.pem")
  end

  def ca_crt
    File.join(dir, "cacert.pem")
  end

  def setup_testcert(name = "testcert")
    key_file = File.join(dir, "private", "#{name}.pem")
    crt_file = File.join(dir, "certs", "#{name}.pem")
    csr_file = File.join(dir, "requests", "#{name}.pem")
    puts `openssl req -batch -newkey rsa:2048 -nodes -keyout #{key_file} -config #{ssl_config} -out #{csr_file} -subj "/C=US/ST=California/O=MyCA/CN=#{name}/"`
    puts `openssl ca -batch -config #{ssl_config} -out #{crt_file} -infiles #{csr_file}`
  end

  def setup
    FileUtils.rm_rf(dir)

    serial = File.join(dir, "serial")
    crlnumber = File.join(dir, "crlnumber")
    crl = File.join(dir, "crl.pem")
    index = File.join(dir, "index.txt")

    FileUtils.mkdir_p(File.join(dir, "private"))
    FileUtils.mkdir_p(File.join(dir, "certs"))
    FileUtils.mkdir_p(File.join(dir, "newcerts"))
    FileUtils.mkdir_p(File.join(dir, "requests"))

    File.open(ssl_config, 'w') do |f|
      f.write(config)
    end

    File.open(serial, 'w') do |f|
      f.write("02")
    end

    File.open(crlnumber, 'w') do |f|
      f.write("00")
    end

    File.open(index, 'w')

    puts `openssl genrsa -out #{ca_key} 2048`
    puts `openssl req -batch -config #{ssl_config} -new -x509 -set_serial 1 -days 365 -key #{ca_key} -out #{ca_crt} -subj "/C=US/ST=California/O=MyCA/"`
    puts `openssl ca -batch -config #{ssl_config} -gencrl -out #{crl}`
  end
end
