# Set a directory's default python version via pyenv.
# Automatically ensures that python version is installed via pyenv.
#
# Usage:
#
#     python::local { '/path/to/a/thing': version => '1.9.3-p194' }

define python::local($version = undef, $ensure = present) {
  include python

  case $version {
    'system': { $_python_local_require = undef }
    undef:    { $_python_local_require = undef }
    default:  {
      ensure_resource('python::version', $version)
      $_python_local_require = Python::Version[$version]
    }
  }

  file {
    "${name}/.python-version":
      ensure  => $ensure,
      content => "${version}\n",
      replace => true,
      require => $_python_local_require ;

    "${name}/.pyenv-version":
      ensure  => absent,
      before  => File["${name}/.python-version"],
      require => $_python_local_require ;
  }
}
