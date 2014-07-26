# Configure and activate pyenv.

export PYENV_ROOT=$BOXEN_HOME/pyenv

export PATH=$BOXEN_HOME/pyenv/bin:$PATH

# Load pyenv
eval "$(pyenv init -)"

# Load pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# Helper for shell prompts and the like
current-python() {
  echo "$(pyenv version-name)"
}
