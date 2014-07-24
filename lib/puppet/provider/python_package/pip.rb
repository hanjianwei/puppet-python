require 'puppet/util/execution'

Puppet::Type.type(:python_package).provide(:pip) do
  include Puppet::Util::Execution
  desc ""

  def self.python_versions
    Dir["/opt/pythons/*"].map do |python|
      File.basename(python)
    end
  end

  def python_versions
    self.class.python_versions
  end

  def self.packagelist
    return @packagelist if defined?(@packagelist)

    mapping = Hash.new { |h,k| h[k] = {} }

    Dir["/opt/pythons/*"].each do |python|
      v = File.basename(python)
      mapping[v] = Array.new

      Dir["#{python}/lib/python*/site-packages/*.egg-info"].each do |pkg|
        mapping[v] << File.basename(pkg).split('-')[0..-3].join('-')
      end
    end

    @packagelist = mapping
  end

  def self.instances
    return @instances if defined?(@instances)

    all_packages = Array.new

    packagelist.each do |py, packages|

      packages.each do |pkg|

        package_name, _, package_version = pkg.rpartition("-")

        all_packages << new({
          :name           => "#{package_name} for #{py}",
          :package        => package_name,
          :ensure         => :installed,
          :version        => package_version,
          :python_version => py,
          :provider       => :pip,
        })
      end
    end

    @instances = all_packages
  end

  def packagelist
    self.class.packagelist
  end

  def instances
    self.class.instances
  end

  def query
    if @resource[:python_version] == "*"
      installed = python_versions.all? { |py| installed_for? py }
    else
      installed = installed_for? @resource[:python_version]
    end
    {
      :name           => "#{@resource[:package]} for all pythons",
      :ensure         => installed ? :present : :absent,
      :version        => @resource[:version],
      :package        => @resource[:package],
      :python_version => @resource[:python_version],
    }

  rescue => e
    raise Puppet::Error, "#{e.message}: #{e.backtrace.join('\n')}"
  end

  def create
    if Facter.value(:offline) == "true"
      raise Puppet::Error, "Can't install packages because we're offline"
    else
      if @resource[:python_version] == "*"
        target_versions = python_versions
      else
        target_versions = [@resource[:python_version]]
      end
      target_versions.reject { |py| installed_for? py }.each do |python|
        pip "install '#{@resource[:package]}'=='#{@resource[:version]}' --index-url '#{@resource[:index_url]}'", python
      end
    end
  rescue => e
    raise Puppet::Error, "#{e.message}: #{e.backtrace.join("\n")}"
  end

  def destroy
    if @resource[:python_version] == "*"
      target_versions = python_versions
    else
      target_versions = [@resource[:python_version]]
    end
    target_versions.select { |py| installed_for? py }.each do |python|
      pip "uninstall '#{@resource[:package]}'", python
    end
  end

private
  # Override default `execute` to run super method in a clean
  # environment without Bundler, if Bundler is present
  def execute(*args)
    if Puppet.features.bundled_environment?
      Bundler.with_clean_env do
        super
      end
    else
      super
    end
  end

  # Override default `execute` to run super method in a clean
  # environment without Bundler, if Bundler is present
  def self.execute(*args)
    if Puppet.features.bundled_environment?
      Bundler.with_clean_env do
        super
      end
    else
      super
    end
  end

  def pip(command, python_version)
    bindir = "/opt/pythons/#{python_version}/bin"
    execute "#{bindir}/pip #{command} --verbose", {
      :combine            => true,
      :failonfail         => true,
      :uid                => user,
      :custom_environment => {
        "PATH" => env_path(bindir)
      }
    }
  end

  def user
    Facter.value(:boxen_user) || Facter.value(:id)
  end

  def version(v)
    Gem::Version.new(v)
  end

  def requirement
    Gem::Requirement.new(@resource[:version])
  end

  def installed_for?(python_version)
    installed_packages[python_version].any? { |pkg|
      pkg[:package] == @resource[:package] \
        && requirement.satisfied_by?(version(pkg[:version])) \
        && pkg[:python_version] == python_version
    }
  end

  def installed_packages
    @installed_packages ||= Hash.new do |installed_packages, python_version|
      installed_packages[python_version] = packagelist[python_version].map { |pkg|
        package_name, _, package_version = pkg.rpartition("-")
        {
          :package        => package_name,
          :version        => package_version,
          :python_version => python_version,
        }
      }
    end
  end

  def env_path(bindir)
    [bindir,
     "#{Facter.value(:boxen_home)}/bin",
     "/usr/bin", "/bin", "/usr/sbin", "/sbin"].join(':')
  end
end
