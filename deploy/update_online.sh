#!/usr/bin/env bash
printf "\033[0;92m[  ..  ]\033[0m Online update\033[0m"
if [[ ! -z ${TMUX} ]]; then
  printf "\r\033[0;93m[ SKIP ]\033[0m Online update\033[0m\n"
  exit 0
fi

if echo -e "GET http://raw.github.com HTTP/1.0\n\n" | nc github.com 80 >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.github.com/BinaryMisfit/dot-files/active/deploy/update_check.sh)"
fi
