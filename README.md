### AnnetteOS

this is a simply operating system for learning and practice purpose nothing special should be waited from this.


##### Development Environmemt.

Binutils
GCC
Make
Grep
Diffutils
perl or Python
asm nasm or gas
vi, nano, vscode...

#### download SRC to Build a GCC Cross Compiler

- download Binutils from their FTP website https://ftp.gnu.org/gnu/binutils/
- download GCC from their FTP website https://ftp.gnu.org/gnu/gcc/

#### Install dependencies
debian, ubuntu base package manager.
```sh
sudo apt-get install bison flex libgmp3-dev libgmp-dev libmpc-dev libmpfr-dev texinfo libisl-dev
```
#### Create the Build environment for these tools.

these variables are use alongside the compilation, the we can move wherever we want to move it.
```sh
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```

##### Build binutils

```sh
mkdir build-binutils
cd build-binutils
../binutils-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
```


###  Build GCC
for example im build 13.2.0
```sh
configure --prefix=$PREFIX --target=$TARGET --disable-nls --enable-languages=c,c++ --without-headers --enable-interwork            --enable-multilib --with-gmp=/usr --with-mpc=/opt/local --with-mpfr=/opt/local
or 
# this is the one I used to build the cross compiler in this example.
../gcc-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers

```

#### using GCC 
remember to use this always, unless you change the sample setup.
```sh
export TARGET=i686-elf
$HOME/opt/cross/bin/$TARGET-gcc --version
```

##### Cross compile literature.

```url
https://wiki.osdev.org/GCC_Cross-Compiler
https://wiki.osdev.org/Cross-Compiler_Successful_Builds

```


### What next?

there would be a lot of things to do.
- try to run a simple boot loader. 1

##### bootloader type bare bones... 1

