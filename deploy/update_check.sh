#!/usr/bin/env bash
if [[ ! -z ${TMUX} ]]; then
  exit 0
fi

BASE_DIR="${HOME}/.dotfiles"
if [[ -d "${BASE_DIR}" ]]; then
  BRANCH=$(git -C "${BASE_DIR}" name-rev --name-only HEAD)
  VERSION_CURRENT=$(git -C "${BASE_DIR}" rev-parse HEAD)
  VERSION_NEW=$(git ls-remote https://github.com/BinaryMisfit/dot-files HEAD | awk '{ print $1 }')
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]]; then
    bash -c "unset HOME; git -C "${BASE_DIR}" pull --autostash --all --recurse-submodules --rebase --quiet 2>&1 > /dev/null"
    printf "\033[0;31mConfig installed ${VERSION_CURRENT}, online: ${VERSION_NEW}, updating\033[0m\n"
    pushd "${BASE_DIR}" > /dev/null
    . "${BASE_DIR}/install" -Q
    popd > /dev/null
  else
    printf "\033[0;32mConfig installed: ${VERSION_CURRENT}, online: ${VERSION_NEW}, up-to-date\033[0m\n"
  fi
  unset BRANCH
  unset VERSION_CURRENT
  unset VERSION_NEW
fi
unset BASE_DIR
