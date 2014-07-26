# Python Puppet Module for Boxen

[![Build Status](https://travis-ci.org/hanjianwei/puppet-python.png?branch=master)](https://travis-ci.org/hanjianwei/puppet-python)

Requires the following boxen modules:

* `boxen >= 3.2.0`
* `repository >= 2.1`

## About

This module supports python version management with [pyenv](https://github.com/yyuu/pyenv) and [pyenv-virtualenv](https://github.com/yyuu/pyenv-virtualenv).
All python versions are installed into `/opt/pythons`.


## Usage

```puppet
# Set the global default python (auto-installs it if it can)
class { 'python::global':
  version => '2.7.8'
}

# ensure a certain python version is used in a dir
python::local { '/path/to/some/project':
  version => '2.7.8'
}

# ensure a package is installed for a certain python version
# note, you can't have duplicate resource names so you have to name like so
$version = "2.7.8"
python_package { "httpie for ${version}":
  package        => 'httpie',
  version        => '~> 0.8.0',
  python_version => $version,
}

# ensure a package is installed for all python versions
python_package { 'httpie for all pythons':
  package        => 'httpie',
  version        => '~> 0.8.0',
  python_version => '*',
}

# install a python version
python::version { '2.7.8': }

# Run an installed package
exec { '/opt/pythons/2.7.8/bin/http get https://api.github.com':
  cwd     => "~/src/project",
  require => python_package['httpie for 2.7.8']
}
```
