#!/bin/bash

# Exit on error
set -e

# Variables
LIBTORRENT_REPO="https://github.com/arvidn/libtorrent.git"
LIBTORRENT_BRANCH="RC_2_0"
INSTALL_PREFIX="$HOME/.local"
PYTHON_VERSION="python3"  # Replace with python3.12 or python3.13 if needed

# Update and install dependencies
echo "Installing dependencies..."
sudo dnf install -y \
    gcc \
    gcc-c++ \
    make \
    cmake \
    boost-devel \
    boost-python3-devel \
    ${PYTHON_VERSION}-devel \
    openssl-devel \
    zlib-devel \
    bzip2-devel

# Clone the libtorrent repository
echo "Cloning libtorrent repository..."
if [ ! -d "libtorrent" ]; then
    git clone -b $LIBTORRENT_BRANCH $LIBTORRENT_REPO
else
    echo "Libtorrent repository already cloned. Pulling latest changes..."
    cd libtorrent
    git pull
    git submodule update --init --recursive
    cd ..
fi

# Build libtorrent
echo "Building libtorrent..."
cd libtorrent
mkdir -p build
cd build
cmake -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -Dpython-bindings=ON \
    -DPYTHON_EXECUTABLE=$(which $PYTHON_VERSION) \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    ..
make -j$(nproc)
make install

# Update environment variables
echo "Updating environment variables..."
export LD_LIBRARY_PATH=$INSTALL_PREFIX/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=$INSTALL_PREFIX/lib64/$(${PYTHON_VERSION} -c "import sys; print(f'python{sys.version_info.major}.{sys.version_info.minor}')")/site-packages:$PYTHONPATH

# Verify installation
echo "Verifying installation..."
${PYTHON_VERSION} -c "import libtorrent; print('Libtorrent version:', libtorrent.version)"

echo "Libtorrent installation completed successfully!"
