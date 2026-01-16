#### Dependecies
Copied from https://wiki.osdev.org/GCC_Cross-Compiler
```
↓ Dependency / OS →	Source Code	Debian (Ubuntu, Mint, WSL, ...)	Gentoo	Fedora	Cygwin	OpenBSD	Arch
How to install	Normally	sudo apt install foo	sudo emerge --ask foo	sudo dnf install foo	Cygwin GUI setup	doas pkg_add foo	pacman -Syu foo
Compiler	N/A	build-essential	sys-devel/gcc	gcc gcc-c++	mingw64-x86_64-gcc-g++ / mingw64-i686-gcc-g++	Preinstalled	base-devel
Make	N/A	build-essential	dev-build/make	make	make	Preinstalled	base-devel
Bison	[1]	bison	sys-devel/bison	bison	bison	?	base-devel
Flex	[2]	flex	sys-devel/flex	flex	flex	?	base-devel
GMP	[3]	libgmp3-dev	dev-libs/gmp	gmp-devel	libgmp-devel	gmp	gmp
MPC	[4]	libmpc-dev	dev-libs/mpc	libmpc-devel	libmpc-devel	libmpc	libmpc
MPFR	[5]	libmpfr-dev	dev-libs/mpfr	mpfr-devel	libmpfr-devel	mpfr	mpfr
Texinfo	[6]	texinfo	sys-apps/texinfo	texinfo	texinfo	texinfo	base-devel
ISL (Optional)	[7]	libisl-dev	dev-libs/isl	isl-devel	libisl-devel	N/A	N/A
```


#### Set Prefix:

```sh
export PREFIX="$PWD/crossCompiler/opt/cross"
export TARGET=i686-elf
export PATH="/home/neonland/Documents/AnnetteOS/crosscompiler/opt/cross/bin:$PREFIX/bin:$PATH"
```

### Install run deps
```
   xorriso
   mtools
   qemu-system-i386
```