#1/usr/bin/env bash
echo -e "GET http://github.com HTTP/1.0\n\n" | nc github.com 80 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    /bin/bash -c "$(curl -fsSL https://github.com/BinaryMisfit/dot-files/raw/latest/default/scripts/update_env.sh)"
fi
