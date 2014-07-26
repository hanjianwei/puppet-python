# Class: python
#
# This module installs a full pyenv-driven python stack
#
class python(
  $pyenv_root    = $python::config::pyenv_root,
  $pyenv_user    = $python::config::pyenv_user,
  $pyenv_cache   = $python::config::pyenv_cache,
) inherits python::config {
  include python::pyenv

  if $::osfamily == 'Darwin' {
    include boxen::config

    boxen::env_script { 'python':
      priority => 'higher',
      source   => 'puppet:///modules/python/python.sh',
    }
  }

  file { '/opt/pythons':
    ensure => directory,
    owner  => $pyenv_user,
  }

  file { $pyenv_cache:
    ensure => directory,
    owner  => $pyenv_user,
  }

  Class['python::pyenv'] ->
  Python <| |> ->
  Python_package <| |>
}
