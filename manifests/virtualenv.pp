# Class: python::virtualenv
#
# This module creates virtualenv from existing python version
#
# Usage:
#
#     python::virtualenv { 'project@2.7.8':
#       version => '2.7.8',
#     }
#
define python::virtualenv(
  $ensure  = 'installed',
  $from    = undef,
  $venv    = $title,
  $options = undef,
) {

  require python

  if $from == undef {
    fail('from cannot be undefined')
  }

  if $ensure != 'absent' {
    ensure_resource('python::version', $from)
  }

  exec { "python_virtualenv_${venv}":
    command  => "env -i bash -c 'source ${boxen::config::home}/env.sh && pyenv virtualenv ${from} ${venv}'",
    provider => 'shell',
    user     => $python::pyenv_user,
    creates  => "${python::pyenv_root}/versions/${venv}",
    require  => Python::Version[$from],
  }

}
