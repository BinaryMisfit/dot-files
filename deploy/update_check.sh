#!/usr/bin/env bash
BASE_DIR="${USER}/.dotfiles"
if [[ -d "${BASE_DIR}" ]]; then
  VERSION_CURRENT=$(git -C "${BASE_DIR}" rev-parse HEAD)
  bash -c "unset HOME; git -C \"${BASE_DIR}\" pull --autostash --all --recurse-submodules --rebase --quiet 2>&1 /dev/null"
  VERSION_NEW=$(git -C "${BASE_DIR}" rev-parse HEAD)
  if [[ "${VERSION_CURRENT}" != "${VERSION_NEW}" ]]; then
    exec "${BASE_DIR}/install" -Q
  fi
  unset VERSION_CURRENT
  unset VERSION_NEW
fi
unset BASE_DIR
