#!/usr/bin/env bash
GIT=
GREEN="\033[0;32m"
INSTALL_DIR="$1"
NC="\033[0m"
RED="\033[0;31m"
REPLACE="\e[1A\e[K"
REPLACE2="\e[2A\e[K"
YELLOW="\033[0;33m"

STAGE=":: Verifying script"
printf "${NC}%s${NC}\n" "$STAGE"
if [[ -z "$INSTALL_DIR" ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "Missing install directory"
  exit 255
fi
GIT=$(which git)
if [[ -z "$GIT" ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git not installed"
  exit 255
fi

printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "OK"

STAGE=":: Verifying sabnzbd"
printf "${NC}%s${NC}\n" "$STAGE"
PYTHON3=$(which python3)
PIP3=$(which pip3)
if [[ -z "$PYTHON3" ]] || [[ -z "$PIP3" ]]; then
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\t%s${NC}\n" "SKIPPING" "python3 not installed"
else
  APP_DIR="$INSTALL_DIR/sabnzbd"
  if [[ ! -d "$APP_DIR" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\n" "INSTALL"
    eval $GIT clone -qq https://github.com/sabnzbd/sabnzbd.git "$APP_DIR"
    if [[ $? != 0 ]]; then
      printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git clone failed"
      exit 255
    fi
  else
    printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\n" "UPDATE"
    pushd "$APP_DIR" &>/dev/null
    eval $GIT pull -qq
    if [[ $? != 0 ]]; then
      printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "git pull failed"
      exit 255
    fi
    popd &>/dev/null
  fi

  if [[ -d "$APP_DIR" ]]; then
    printf "${REPLACE}${NC}${STAGE}\t${YELLOW}%s${NC}\n" "CONFIGURE"
    pushd "$APP_DIR" &>/dev/null
    eval $PIP3 install -q -r requirements.txt
    if [[ $? != 0 ]]; then
      printf "${REPLACE2}${NC}${STAGE}\t${RED}%s${NC}\t%s${NC}\n" "ERROR" "pip3 install failed"
      exit 255
    fi
    popd &>/dev/null
  fi

  unset APP_DIR
  printf "${REPLACE}${NC}${STAGE}\t${GREEN}%s${NC}\n" "OK"
fi

unset GIT
unset GREEN
unset INSTALL_DIR
unset NC
unset RED
unset REPLACE
unset REPLACE2
unset STAGE
unset YELLOW
