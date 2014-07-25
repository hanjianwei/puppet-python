# Manage python versions with pyenv.
#
# Usage:
#
#     include python::pyenv
#
# Normally internal use only; will be automatically included by the `python` class

class python::pyenv {
  require python

  repository { $python::pyenv_root:
    ensure => $python::pyenv_version,
    force  => true,
    source => 'yyuu/pyenv',
    user   => $python::pyenv_user
  }

  file { "${python::pyenv_root}/versions":
    ensure  => symlink,
    force   => true,
    backup  => false,
    target  => '/opt/pythons',
    require => Repository[$python::pyenv_root],
  }

}
