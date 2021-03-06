# This script is used to install python3 from source on Ubuntu
# Support python3 version: 3.6, 3.7 and 3.8
# Author: Junting Chen
# Last update: 2021/02/01

if [ ! -d ${HOME}/tmp ]; then
    mkdir ${HOME}/tmp
fi

read -p "What python version do you want? [Default: 3.6.4] " pyversion
# moduleversion=${moduleversion:-'[file tail $ModulesCurrentModulefile]'}
PYVERSION=${pyversion:-'3.6.4'}

# Function to whether a package installed
get_package () {
    local pkg_name="$1"
    dpkg -s $pkg_name &> /dev/null

    if [ $? -ne 0 ];
    then
        echo "${pkg_name} is not installed.";
        return 1
    else
        return 0
    fi
}

# Check curl tool is installed
if ! get_package "curl";
then
    exit 1
fi

# Make sure the following tools are installed before compiling
if [[ $PYVERSION == 3.6* ]];
then
    pkg_list="make build-essential libssl-dev
        zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
        libncurses5-dev libncursesw5-dev xz-utils"
    # pkg_list="${pkg_list} tk-dev"
elif [[ $PYVERSION == 3.7* ]];
then
    pkg_list="make build-essential libssl-dev
        zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
        libncurses5-dev libncursesw5-dev
        libexpat1-dev liblzma-dev libffi-dev"
    # pkg_list="${pkg_list} libgdbm-dev libdb5.3-dev tk-dev"
elif [[ $PYVERSION == 3.8* ]];
then
    pkg_list="make build-essential
        libreadline-dev libncursesw5-dev libssl-dev
        zlib1g-dev libbz2-dev libsqlite3-dev
        libgdbm-dev libc6-dev libffi-dev"
    # pkg_list="${pkg_list} uuid-dev libdb5.3-dev tk-dev"
else
    echo "Unsupport python version `$PYVERSION`"
    exit 1
fi

check_all=0
for pkg in $pkg_list
do
    if ! get_package $pkg;
    then
        check_all=1
    fi
done

if [ $check_all -ne 0 ];
then
    exit 1
fi


#==================== Download tgz file ===========================#
cd ${HOME}/tmp
if [ ! -f Python-${PYVERSION}.tgz ]; then
    curl -OL https://www.python.org/ftp/python/${PYVERSION}/Python-${PYVERSION}.tgz
fi
if [ ! -d Python-${PYVERSION} ]; then
    tar -zxvf Python-${PYVERSION}.tgz
fi

PREFIX=${HOME}/local/modules/Cellar/python3/${PYVERSION}/

# If you have compiled some library yourself, you might need to specify the path to header files (eg. $HOME/.local/include)
cd Python-${PYVERSION}/
./configure --prefix=$PREFIX \
    --enable-optimizations \
    --enable-shared \
    LDFLAGS="-Wl,--rpath=${PREFIX}lib" \
    CPPFLAGS="-I ${HOME}/.local/include" \
    --disable-option-checking \
    --with-ssl \
    --with-ensurepip

make -j8
make -j8 install

#PYTHON=${HOME}/local/modules/Cellar/python3/${PYVERSION}/bin/python3
#$PYTHON -m ensurepip

cd ${HOME}

