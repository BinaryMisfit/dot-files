#!/usr/bin/env bash
BASE_DIR="${HOME}/.dotfiles"
if [[ -d "${BASE_DIR}" ]]; then
  pushd "${BASE_DIR}" > /dev/null
  VERSION_CURRENT=$(git rev-parse HEAD)
  bash -c "unset HOME; git pull --autostash --all --recurse-submodules --rebase --quiet 2>&1 > /dev/null"
  VERSION_NEW=$(git rev-parse HEAD)
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]]; then
    printf "\033[0;31mConfig installed ${VERSION_CURRENT}, online: ${VERSION_NEW}, updating\033[0m\n"
    install -Q
  else
    printf "\033[0;32mConfig installed: ${VERSION_CURRENT}, online: ${VERSION_NEW}, up-to-date\033[0m\n"
  fi
  popd > /dev/null
  unset VERSION_CURRENT
  unset VERSION_NEW
fi
unset BASE_DIR
