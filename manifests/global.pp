# Public: specify the global python version (only for pyenv)
#
# Usage:
#
#   class { 'python::global': version => '2.7.8' }

class python::global($version = '2.7.8') {
  require python

  if $version != 'system' {
    ensure_resource('python::version', $version)
    $require = Python::Version[$version]
  } else {
    $require = undef
  }

  file { "${python::pyenv_root}/version":
    ensure  => present,
    owner   => $python::user,
    mode    => '0644',
    content => "${version}\n",
    require => $require,
  }
}
