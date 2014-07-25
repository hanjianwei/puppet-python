# Installs a python version with python-build..
# Takes ensure, env, and version params.
#
# Usage:
#
#     python::version { '2.7.8': }

define python::version(
  $ensure  = 'installed',
  $env     = {},
  $version = $title,
) {
  require python

  python { $version:
    ensure       => $ensure,
    environment  => $env,
    python_build => "${python::pyenv_root}/plugins/python-build/bin/python-build",
    user         => $python::pyenv_user,
    provider     => pythonbuild,
  }

}
