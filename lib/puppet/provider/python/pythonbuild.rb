require "fileutils"

require 'puppet/util/execution'

Puppet::Type.type(:python).provide(:pythonbuild) do
  include Puppet::Util::Execution

  def self.pythonlist
    @pythonlist ||= Dir["/opt/pythons/*"].map do |python|
      if File.directory?(python) && File.executable?("#{python}/bin/python")
        File.basename(python)
      end
    end.compact
  end

  def self.instances
    pythonlist.map do |python|
      new({
        :name     => python,
        :version  => python,
        :ensure   => :present,
        :provider => "pythonbuild",
      })
    end
  end

  def query
    if self.class.pythonlist.member?(version)
      { :ensure => :present, :name => version, :version => version}
    else
      { :ensure => :absent,  :name => version, :version => version}
    end
  end

  def create
    destroy if File.directory?(prefix)

    if Facter.value(:offline) == "true"
      if File.exist?("#{cache_path}/python-#{version}.tar.gz")
        build_python
      else
        raise Puppet::Error, "Can't install python because we're offline and the tarball isn't cached"
      end
    else
      try_to_download_precompiled_python || build_python
    end
  rescue => e
    raise Puppet::Error, "install failed with a crazy error: #{e.message} #{e.backtrace}"
  end

  def destroy
    FileUtils.rm_rf prefix
  end

private
  def try_to_download_precompiled_python
    Puppet.debug("Trying to download precompiled python for #{version}")
    output = execute "curl --silent --fail #{precompiled_url} >#{tmp} && tar xjf #{tmp} -C /opt/pythons", command_options.merge(:failonfail => false)

    output.exitstatus == 0
  ensure
    FileUtils.rm_f tmp
  end

  def build_python
    execute "#{python_build} --keep #{version} #{prefix}", command_options.merge(:failonfail => true)
  end

  def tmp
    "/tmp/python-#{version}.tar.bz2"
  end

  def precompiled_url
    %W(
      http://
      #{Facter.value(:boxen_s3_host)}
      /
      #{Facter.value(:boxen_s3_bucket)}
      /
      pythons
      /
      #{Facter.value(:operatingsystem)}
      /
      #{os_release}
      /
      #{CGI.escape(version)}.tar.bz2
    ).join("")
  end

  def os_release
    case Facter.value(:operatingsystem)
    when "Darwin"
      Facter.value(:macosx_productversion_major)
    when "Debian", "Ubuntu"
      Facter.value(:lsbdistcodename)
    else
      Facter.value(:operatingsystem)
    end
  end

  def python_build
    @resource[:python_build]
  end

  def command_options
    {
      :combine            => true,
      :custom_environment => environment,
      :uid                => @resource[:user],
      :failonfail         => true,
    }
  end

  def environment
    return @environment if defined?(@environment)

    @environment = Hash.new

    @environment["PYTHON_BUILD_CACHE_PATH"] = cache_path

    @environment.merge!(@resource[:environment])
  end

  def cache_path
    @cache_path ||= if Facter.value(:boxen_home)
      "#{Facter.value(:boxen_home)}/cache/pythons"
    else
      "/tmp/pythons"
    end
  end

  def version
    @resource[:version]
  end

  def prefix
    "/opt/pythons/#{version}"
  end
end
