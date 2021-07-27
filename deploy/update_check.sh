#!/usr/bin/env bash
printf "\033[0;92m[  ..  ]\033[0m Online update\033[0m"
if [[ ! -z ${TMUX} ]]; then
  exit 0
fi

BASE_DIR="${HOME}/.dotfiles"
if [[ -d "${BASE_DIR}" ]]; then
  BRANCH=$(git -C "${BASE_DIR}" name-rev --name-only HEAD)
  VERSION_CURRENT=$(git -C "${BASE_DIR}" rev-parse HEAD)
  VERSION_NEW=$(git ls-remote https://github.com/BinaryMisfit/dot-files HEAD | awk '{ print $1 }')
  printf "\033[3;93mFound\t\033[3;97m${VERSION_CURRENT}\033[0m\n"
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]]; then
    printf "\033[3;93mLatest\t\033[3;91m${VERSION_NEW}, updating\033[0m\n"
    bash -c "unset HOME; git -C "${BASE_DIR}" pull --autostash --all --recurse-submodules --rebase --quiet 2>&1 > /dev/null"
    pushd ${BASE_DIR} > /dev/null
    . "${BASE_DIR}/install" -Qs
    popd > /dev/null
  else
    printf "\033[3;93mLatest\t\033[3;97m${VERSION_NEW}\033[0m\n"
  fi
  unset BRANCH
  unset VERSION_CURRENT
  unset VERSION_NEW
fi
unset BASE_DIR
