# Python Puppet Module for Boxen

[![Build Status](https://travis-ci.org/hanjianwei/puppet-python.png?branch=master)](https://travis-ci.org/hanjianwei/puppet-python)

Requires the following boxen modules:

* `boxen >= 3.2.0`
* `repository >= 2.1`
* `xquartz` (OS X only)
* `autoconf` (some python versions)
* [ripienaar/puppet-module-data](https://github.com/ripienaar/puppet-module-data)

## About

This module supports python version management with pyenv.
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

## Hiera configuration

The following variables may be automatically overridden with Hiera:

``` yaml
---
"python::user": "deploy"
"python::pyenv::ensure": "v20140705"

# Environment variables for building specific versions
# You'll want to enable hiera's "deeper" merge strategy
# See http://docs.puppetlabs.com/hiera/1/configuring.html#mergebehavior
"python::version::env":
  "2.7.8":
    "CC": "llvm"
    "CFLAGS": "-O9 -funroll-loops"
  "3.4.1":
    "CC": "gcc"

It is **required** that you include
[ripienaar/puppet-module-data](https://github.com/ripienaar/puppet-module-data)
in your boxen project, as this module now ships with many pre-defined versions
in the `data/` directory. With this module included, those
definitions will be automatically loaded, but can be overridden easily in your
own hierarchy.

You can also use JSON if your Hiera is configured for that.
