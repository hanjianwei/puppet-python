# Class: python
#
# This module installs a full pyenv-driven python stack
#
class python(
  $provider = $python::provider,
  $prefix   = $python::prefix,
  $user     = $python::user,
) {
  if $::osfamily == 'Darwin' {
    include boxen::config
  }

  include python::build

  $provider_class = "python::${provider}"
  include $provider_class

  if $::osfamily == 'Darwin' {
    boxen::env_script { 'python':
      content  => template('python/python.sh'),
      priority => 'higher',
    }
  }

  file { '/opt/pythons':
    ensure => directory,
    owner  => $user,
  }

  Class['python::build'] ->
  Class[$provider_class] ->
  Python <| |> ->
  Python_package <| |>
}
