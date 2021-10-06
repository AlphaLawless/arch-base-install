#!/bin/bash

createRootPasswordPT() {
  echo "Digite uma senha para a root: "
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
  echo "Por favor, confirme digitando novamente: "
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
    echo -e "[!] Tudo certo! Continuando...\n"
    sleep 2
  else
    echo -e "[!] Errado, por favor faça novamente...\n"
    sleep 2 ; clear ; createRootPasswordPT
  fi
  return $password
}
createRootPasswordPT

echo root:${password} | chpasswd
