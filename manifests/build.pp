# (Internal) Installs python-build

class python::build(
  $user = $python::build::user,
) {
  require python

  $prefix = "${python::prefix}/pyenv/plugins/python-build"

  ensure_resource('file', "${::python::prefix}/cache/pythons", {
    'ensure' => 'directory',
    'owner'  => $user,
  })

}
