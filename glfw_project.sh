while getopts d:n: flag
do
    case "${flag}" in 
        d) dir=${OPTARG};;
        n) name=${OPTARG};;
    esac
done

if [ -d $dir/$name ] 
then
    echo $dir/$name " exists. so we exit"
    exit 9999
fi

echo $dir/$name " DOES NOT exists. So creating one: "
mkdir $dir/$name
cd $dir/$name
echo "we are in " 
pwd

echo "create the build, src, Lib dirs"
mkdir build
mkdir src
mkdir Lib

echo "create CMakeLists.txt file"

cat > CMakeLists.txt << ENDOFFILE
CMAKE_MINIMUM_REQUIRED(VERSION 3.22.1)
PROJECT($name)
add_executable(\${PROJECT_NAME} ./src/main.cpp)

add_subdirectory(Lib/gameLib)
add_subdirectory(Lib/glfw)

target_include_directories(
    \${PROJECT_NAME}  
    PUBLIC \${CMAKE_SOURCE_DIR}/Lib/gameLib/src/
    PUBLIC \${CMAKE_SOURCE_DIR}/Lib/glfw/include/
)

target_link_directories(
    \${PROJECT_NAME}  
    PUBLIC \${CMAKE_BUILD_RPATH}/Lib/gameLib/
    PUBLIC \${CMAKE_BUILD_RPATH}/Lib/glfw/src/
)

target_link_libraries(\${PROJECT_NAME} glfw aligame)
ENDOFFILE

echo "now we are here"
pwd 

cd src

cat > main.cpp << ENDOFFILE
#include <iostream>
#include <GLFW/glfw3.h>
#include "windows.h"

int main() {
    aligame::createWindows(800, 800);
}
ENDOFFILE

cd ..

echo "cd to Lib dir and create src dir"
cd Lib
mkdir gameLib 
cd gameLib
mkdir src
ls

cat > CMakeLists.txt << ENDOFFILE
CMAKE_MINIMUM_REQUIRED(VERSION 3.22.1)
PROJECT(aligame)
add_library(aligame ./src/windows.cpp)

target_include_directories(
    \${PROJECT_NAME}  
    PUBLIC \${CMAKE_SOURCE_DIR}/Lib/glfw/include/
)

target_link_directories(
    \${PROJECT_NAME}  
    PUBLIC \${CMAKE_BUILD_RPATH}/Lib/glfw/src/
)

target_link_libraries(\${PROJECT_NAME} glfw)
ENDOFFILE

cd src

cat > windows.h << ENDOFFILE
namespace aligame {
    void createWindows(int h, int w);
}
ENDOFFILE

cat > windows.cpp << ENDOFFILE
#include "windows.h"
#include <GLFW/glfw3.h>
#include <iostream>

void aligame::createWindows(int h, int w) {
    GLFWwindow* window;

    if( !glfwInit() )
    {
        fprintf( stderr, "Failed to initialize GLFW\n" );
        exit( EXIT_FAILURE );
    }

    window = glfwCreateWindow(h, w, "test", NULL, NULL );
    if (!window)
    {
        fprintf( stderr, "Failed to open GLFW window\n" );
        glfwTerminate();
        exit( EXIT_FAILURE );
    }

    while( !glfwWindowShouldClose(window) )
    {
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Terminate GLFW
    glfwTerminate();
}
ENDOFFILE

echo "we are here"
pwd
echo "cd back to root dir"

cd ../../..
echo "now we are here"
pwd

echo "now init git for in"
pwd
git init

echo "now add thie .gitignore file"
cat > .gitignore << ENDOFFILE
# Prerequisites
*.d

# Compiled Object files
*.slo
*.lo
*.o
*.obj

# Precompiled Headers
*.gch
*.pch

# Compiled Dynamic libraries
*.so
*.dylib
*.dll

# Fortran module files
*.mod
*.smod

# Compiled Static libraries
*.lai
*.la
*.a
*.lib

# Executables
*.exe
*.out
*.app

CMakeLists.txt.user
CMakeCache.txt
CMakeFiles
CMakeScripts
Testing
Makefile
cmake_install.cmake
install_manifest.txt
compile_commands.json
CTestTestfile.cmake
_deps

build

[Bb]
ENDOFFILE

git add .gitignore
git add CMakeLists.txt
git add Lib

echo "now commit the change"
git commit -am  "init git"

echo "now we clone the glfw from git as submodule"
git submodule add https://github.com/glfw/glfw.git Lib/glfw
git commit -am  "add glfw"

cat > confg.sh << ENDOFFILE
#! /bin/sh
cmake -S . -B ./build
ENDOFFILE

cat > build.sh << ENDOFFILE
#! /bin/sh
cd ./build ; make
ENDOFFILE

cat > run.sh << ENDOFFILE
#! /bin/sh
cd ./build ; ./$name
ENDOFFILE

chmod +x ./confg.sh ./build.sh ./run.sh 

./confg.sh
./build.sh
./run.sh