# Aliases a (usually shorter) python version to another
#
# Usage:
#
#     python::alias { '2.7.8': to => '2.7' }

define python::alias(
  $ensure  = 'installed',
  $to      = undef,
  $version = $title,
) {

  require python

  if $to == undef {
    fail('to cannot be undefined')
  }

  if $ensure != 'absent' {
    ensure_resource('python::version', $to)
  }

  $file_ensure = $ensure ? {
    /^(installed|present)$/ => 'symlink',
    default                 => $ensure,
  }

  file { "/opt/pythons/${version}":
    ensure  => $file_ensure,
    force   => true,
    target  => "/opt/pythons/${to}",
    require => Python::Version[$to],
  }
}
