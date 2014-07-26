# Class: python::config
#
# This module include config params for python
#
class python::config {
  case $::osfamily {
    Darwin: {
      include boxen::config

      $pyenv_user  = $::boxen_user
      $pyenv_root  = "${boxen::config::home}/pyenv"
      $pyenv_cache = "${boxen::config::cachedir}/pythons"
    }

    default: {
      $pyenv_user  = 'root'
      $pyenv_root  = '/opt/pyenv'
      $pyenv_cache = '/tmp/pythons'
    }
  }
}
