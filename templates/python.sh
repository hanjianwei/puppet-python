# Put python-build on PATH
export PATH=<%= scope.lookupvar("::python::build::prefix") %>/bin:$PATH

<%- if scope.lookupvar("::python::provider") == "pyenv" -%>
# Configure PYENV_ROOT and put PYENV_ROOT/bin on PATH
export PYENV_ROOT=<%= scope.lookupvar("::python::pyenv::prefix") %>
export PATH=$PYENV_ROOT/bin:$PATH

# Load pyenv
eval "$(pyenv init -)"

# Helper for shell prompts and the like
current-python() {
  echo "$(pyenv version-name)"
}
<%- end -%>

# Load global pythons
PYTHONS=(/opt/pythons/*)
export PYTHONS

# Helper for shell prompts and the like
current-python() {
  if [ -z "$PYTHON_ROOT" ]; then
    echo "system"
  else
    echo "${PYTHON_ROOT##*/}"
  fi
}
<%- end -%>
