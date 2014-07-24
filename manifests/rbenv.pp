# Manage python versions with pyenv.
#
# Usage:
#
#     include python::pyenv
#
# Normally internal use only; will be automatically included by the `python` class
# if `python::provider` is set to "pyenv"

class python::pyenv(
  $ensure = $python::pyenv::ensure,
  $prefix = $python::pyenv::prefix,
  $user   = $python::pyenv::user,
) {

  require python

  repository { $prefix:
    ensure => $ensure,
    force  => true,
    source => 'yyuu/pyenv',
    user   => $user
  }

  file { "${prefix}/versions":
    ensure  => symlink,
    force   => true,
    backup  => false,
    target  => '/opt/pythons',
    require => Repository[$prefix],
  }

}
