cmake_minimum_required(VERSION 3.16)

project(AnnetteOS LANGUAGES CXX ASM)

# --------------------------------------------------
# Sistema
# --------------------------------------------------
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR i386)

# --------------------------------------------------
# Toolchain
# --------------------------------------------------
set(CXX i686-elf-g++)
set(ASM i686-elf-as)
set(LD  i686-elf-ld)

# --------------------------------------------------
# Flags
# --------------------------------------------------
set(CXXFLAGS
    -ffreestanding
    -O2
    -Wall
    -Wextra
    -fno-exceptions
    -fno-rtti
    -I${CMAKE_SOURCE_DIR}
    -I${CMAKE_SOURCE_DIR}/../include
)

# --------------------------------------------------
# Sources
# --------------------------------------------------
set(CPP_SOURCES
    ./src/kmain.cpp
    ./src/kprintf.cpp
    ./src/gdt.cpp
)

set(ASM_SOURCES
    ./src/kloader.s
)

# --------------------------------------------------
# Object directory
# --------------------------------------------------
set(OBJDIR ${CMAKE_BINARY_DIR}/obj)
file(MAKE_DIRECTORY ${OBJDIR})

set(OBJECTS)

# --------------------------------------------------
# Compile C++ sources
# --------------------------------------------------
foreach(src ${CPP_SOURCES})
    get_filename_component(name ${src} NAME_WE)
    set(obj ${OBJDIR}/${name}.o)

    add_custom_command(
        OUTPUT ${obj}
        COMMAND ${CXX} ${CXXFLAGS}
                -c ${CMAKE_SOURCE_DIR}/${src}
                -o ${obj}
        DEPENDS ${CMAKE_SOURCE_DIR}/${src}
        COMMENT "Compiling ${src}"
    )

    list(APPEND OBJECTS ${obj})
endforeach()

# --------------------------------------------------
# Compile ASM sources
# --------------------------------------------------
foreach(src ${ASM_SOURCES})
    get_filename_component(name ${src} NAME_WE)
    set(obj ${OBJDIR}/${name}.o)

    add_custom_command(
        OUTPUT ${obj}
        COMMAND ${ASM}
                ${CMAKE_SOURCE_DIR}/${src}
                -o ${obj}
        DEPENDS ${CMAKE_SOURCE_DIR}/${src}
        COMMENT "Assembling ${src}"
    )

    list(APPEND OBJECTS ${obj})
endforeach()

# --------------------------------------------------
# Link kernel.bin (DIRECT ld)
# --------------------------------------------------
set(KERNEL_BIN ${CMAKE_BINARY_DIR}/kernel.bin)

add_custom_command(
    OUTPUT ${KERNEL_BIN}
    COMMAND ${LD}
            -T${CMAKE_SOURCE_DIR}/src/linker.ld
            -m elf_i386
            ${OBJECTS}
            -o ${KERNEL_BIN}
    DEPENDS ${OBJECTS} ${CMAKE_SOURCE_DIR}/src/linker.ld
    COMMENT "Linking kernel.bin"
)

add_custom_target(kernel ALL
    DEPENDS ${KERNEL_BIN}
)

# --------------------------------------------------
# Clean
# --------------------------------------------------
add_custom_target(clean-all
    COMMAND rm -rf ${OBJDIR} ${KERNEL_BIN}
)


add_custom_target(iso
    COMMAND mkdir -p iso/boot/grub
    COMMAND cp kernel.bin iso/boot/kernel.bin
    COMMAND grub-mkrescue -o ./AnnetteOSv1.iso ../iso
    DEPENDS kernel.bin
)