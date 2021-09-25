# Guia de Instalação dos Scripts
* [en-US](../INSTALL.md)

## Scripts de base

Com tudo instalado e montado. Vamos passar para os scripts!

1. Clone o repositório do arch-base-install:
```
git clone https://github.com/alphalawless/arch-base-install
```
2. Entre na pasta arch-base-install:
```
cd arch-base-install
```
3. Mude o que precisar entrando com o vim no `base-mbr.sh` ou `base-uefi.sh`:
```sh
vim base-mbr.sh
#vim base-uefi.sh
```
4. Agora dê as permissões para executar no shell com o comando `chmod`:
```sh
chmod +x base-mbr.sh
#chmod +x base-uefi.sh
```
5. Agora rode o script no shell e pegue um café até terminar:
```sh
./base-mbr.sh
#./base-uefi.sh
```

Com tudo feito, você pode sair do `arch-chroot` digitando `exit`, ou usando o comando Ctrl + D. E com isso desmonte as partições usando `umount -a` e reinicie o sistema.

## DE ou WM

...
Essa parte ainda está em construção. Logo mais vai ter!