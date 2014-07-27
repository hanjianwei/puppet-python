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
    force  => true,
    source => 'yyuu/pyenv',
    user   => $python::pyenv_user
  }
  ->
  repository { "${python::pyenv_root}/plugins/pyenv-virtualenv":
    force  => true,
    source => 'yyuu/pyenv-virtualenv',
    user   => $python::pyenv_user,
  }
  ->
  repository { "${python::pyenv_root}/plugins/pyenv-pip-rehash":
    force  => true,
    source => 'yyuu/pyenv-pip-rehash',
    user   => $python::pyenv_user,
  }

  file { "${python::pyenv_root}/versions":
    ensure  => symlink,
    force   => true,
    backup  => false,
    target  => '/opt/pythons',
    require => Repository[$python::pyenv_root],
  }

}
