#!/bin/bash

createRootPasswordEN() {
  echo "Enter a password for root: "
  unset password
  while IFS= read -r -s -n1 pass; do
    if [[ -z $pass ]]; then
      echo
      break
    else
      echo -n '*'
      password+=$pass
    fi
  done
  echo "Please, confirm it typing again: "
  unset confirm
  while IFS= read -r -s -n1 conf; do
    if [[ -z $conf ]]; then
      echo
      break
    else
      echo -n '*'
      confirm+=$conf
    fi
  done
  if [[ $password == $confirm ]]; then
    echo -e "[!] All Right! Continuing...\n"
    sleep 2
  else
    echo -e "[!] Wrong, please do it again...\n"
    sleep 2 ; clear ; createRootPasswordEN
  fi
  return $password
}
createRootPasswordEN

echo root:${password} | chpasswd

