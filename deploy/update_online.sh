#1/usr/bin/env bash
if echo -e "GET http://github.com HTTP/1.0\n\n" | nc github.com 80 >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://github.com/BinaryMisfit/dot-files/raw/active/deploy/update-check.sh)"
fi
