#!/bin/bash

# We don't need return codes for "$(command)", only stdout is needed.
# Allow `[[ -n "$(command)" ]]`, `func "$(command)"`, pipes, etc.
# shellcheck disable=SC2312

set -u

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

MR_CHECKOUT=/opt/nixpkgs
MR_REPO=https://github.com/ErikMikkelson/mac-runner.git
CHMOD=("/bin/chmod")
MKDIR=("/bin/mkdir" "-p")
STAT_PRINTF=("stat" "-f")
PERMISSION_FORMAT="%A"
CHOWN=("/usr/sbin/chown")
CHGRP=("/usr/bin/chgrp")
USER="$(chomp "$(id -un)")"
export USER
CONFIG="/Users/$USER/.config/mrnixpkgs"
GROUP="admin"
TOUCH=("/usr/bin/touch")

unset HAVE_SUDO_ACCESS # unset this from the environment

mkdir -p "/Users/$USER/.config"

have_sudo_access() {
  if [[ ! -x "/usr/bin/sudo" ]]
  then
    return 1
  fi

  local -a SUDO=("/usr/bin/sudo")
  if [[ -n "${SUDO_ASKPASS-}" ]]
  then
    SUDO+=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]
  then
    SUDO+=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]
  then
    if [[ -n "${NONINTERACTIVE-}" ]]
    then
      "${SUDO[@]}" -l mkdir &>/dev/null
    else
      "${SUDO[@]}" -v && "${SUDO[@]}" -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -z "${HOMEBREW_ON_LINUX-}" ]] && [[ "${HAVE_SUDO_ACCESS}" -ne 0 ]]
  then
    abort "Need sudo access on macOS (e.g. the user ${USER} needs to be an Administrator)!"
  fi

  return "${HAVE_SUDO_ACCESS}"
}

execute() {
  if ! "$@"
  then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
# shellcheck disable=SC2292
if [ -z "${BASH_VERSION:-}" ]
then
  abort "Bash is required to interpret this script."
fi

# Check if script is run with force-interactive mode in CI
if [[ -n "${CI-}" && -n "${INTERACTIVE-}" ]]
then
  abort "Cannot run force-interactive mode in CI."
fi

# Check if both `INTERACTIVE` and `NONINTERACTIVE` are set
# Always use single-quoted strings with `exp` expressions
# shellcheck disable=SC2016
if [[ -n "${INTERACTIVE-}" && -n "${NONINTERACTIVE-}" ]]
then
  abort 'Both `$INTERACTIVE` and `$NONINTERACTIVE` are set. Please unset at least one variable and try again.'
fi

# string formatters
if [[ -t 1 ]]
then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"
  do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

getc() {
  local save_state
  save_state="$(/bin/stty -g)"
  /bin/stty raw -echo
  IFS='' read -r -n 1 -d '' "$@"
  /bin/stty "${save_state}"
}

execute_sudo() {
  local -a args=("$@")
  if have_sudo_access
  then
    if [[ -n "${SUDO_ASKPASS-}" ]]
    then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

should_install_command_line_tools() {
  ! [[ -e "/Library/Developer/CommandLineTools/usr/bin/git" ]]
}

if should_install_command_line_tools && test -t 0
then
  ohai "Installing the Command Line Tools (expect a GUI popup):"
  execute_sudo "/usr/bin/xcode-select" "--install"
  echo "Press any key when the installation has completed."
  getc
  execute_sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
fi

if [ -d "$MR_CHECKOUT" ]
then
    ohai "Checkout dir $MR_CHECKOUT already exists. Updating."
    cd $MR_CHECKOUT && git checkout -- . && git pull
else
  ohai "Checkout dir $MR_CHECKOUT does not exist. Creating."
  execute_sudo "${MKDIR[@]}" "${MR_CHECKOUT}"
  execute_sudo "${CHOWN[@]}" "-R" "${USER}:${GROUP}" "${MR_CHECKOUT}"
  ohai "Cloning repository ${MR_REPO} into ${MR_CHECKOUT}:"
  git clone ${MR_REPO} ${MR_CHECKOUT}
fi

cd $MR_CHECKOUT

if ! [[ -x "$(command -v nix-env)" ]]
then
    ohai "Installing nix. Answer always y."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    export PATH="${PATH}:/nix/var/nix/profiles/default/bin"
fi
if ! [[ -x "$(command -v nix-env)" ]]
then
    ohai "Please restart terminal to finish Nix installation"
    exit 1
fi
