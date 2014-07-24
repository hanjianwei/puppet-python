# Installs a python version with python-build..
# Takes ensure, env, and version params.
#
# Usage:
#
#     python::version { '1.9.3-p194': }

define python::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $name
) {
  require python
  require python::build

  $alias_hash = hiera_hash('python::version::alias', {})

  if has_key($alias_hash, $version) {
    $to = $alias_hash[$version]

    python::alias { $version:
      ensure => $ensure,
      to     => $to,
    }
  } else {

    case $version {
      /jython/: { require 'java' }
      default: { }
    }

    $default_env = {
      'CC' => '/usr/bin/cc',
    }

    if $::operatingsystem == 'Darwin' {
      require xquartz
      include homebrew::config
      include boxen::config
      ensure_resource('package', 'readline')
      Package['readline'] -> Python <| |>
    }

    $hierdata = hiera_hash('python::version::env', {})

    if has_key($hierdata, $::operatingsystem) {
      $os_env = $hierdata[$::operatingsystem]
    } else {
      $os_env = {}
    }

    if has_key($hierdata, $version) {
      $version_env = $hierdata[$version]
    } else {
      $version_env = {}
    }

    $_env = merge(merge(merge($default_env, $os_env), $version_env), $env)

    if has_key($_env, 'CC') and $_env['CC'] =~ /gcc/ {
      require gcc
    }

    python { $version:
      ensure      => $ensure,
      environment => $_env,
      python_build  => "${python::build::prefix}/bin/python-build",
      user        => $python::user,
      provider    => pythonbuild,
    }

  }

}
