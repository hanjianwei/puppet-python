Puppet::Type.newtype(:python_package) do
  @doc = ""

  ensurable do
    newvalue :present do
      provider.create
    end

    newvalue :absent do
      provider.destroy
    end

    defaultto :present

    aliasvalue(:installed, :present)
    aliasvalue(:uninstalled, :absent)

    def retrieve
      provider.query[:ensure]
    end

    def insync?(is)
      @should.each { |should|
        case should
        when :present
          return true unless is == :absent
        when :absent
          return true if is == :absent
        when *Array(is)
          return true
        end
      }
      false
    end
  end

  newparam(:name) do
    isnamevar

    validate do |v|
      unless v.is_a? String
        raise Puppet::ParseError,
          "Expected name to be a String, got a #{v.class.name}"
      end
    end
  end

  newparam(:package) do
    validate do |v|
      unless v.is_a? String
        raise Puppet::ParseError,
          "Expected package to be a String, got a #{v.class.name}"
      end
    end
  end

  newparam(:python_version) do
    validate do |v|
      unless v.is_a? String
        raise Puppet::ParseError,
          "Expected python_version to be a String, got a #{v.class.name}"
      end
    end
  end

  newparam(:version) do
    defaultto '>= 0'

    validate do |v|
      unless v.is_a? String
        raise Puppet::ParseError,
          "Expected version to be a String, got a #{v.class.name}"
      end
    end
  end

  newparam(:index_url) do
    defaultto "https://pypi.python.org/simple"

    validate do |v|
      unless v.is_a? String
        raise Puppet::ParseError,
          "Expected source to be a String, got a #{v.class.name}"
      end
    end
  end

  autorequire :python do
    if @parameters.include?(:python_version) && python_version = @parameters[:python_version].to_s
      if python_version == "*"
        catalog.resources.find_all { |resource| resource.type == 'Python' }
      else
        Array.new.tap do |a|
          a << python_version if catalog.resource(:python, python_version)
        end
      end
    end
  end
end
