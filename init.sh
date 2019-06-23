
echo "***********************************Installing core tools***********************************"
sudo apt install git curl python-pip autoconf

echo "***********************************Upgrading pip***********************************"
sudo pip install --upgrade pip>=18.0

echo "***********************************Installing ffmpeg and required tools***********************************"
sudo apt install ffmpeg libavformat-dev libavcodec-dev libavdevice-dev libavutil-dev libswscale-dev libavresample-dev libavfilter-dev libssl-dev

echo "***********************************Installing build tools like build-essential automake clang***********************************"

sudo apt install autoconf automake clang clang-3.8 libtool pkg-config build-essential
sudo apt install -y libarchive-dev clang llvm

echo "***********************************Installing qt***********************************"

sudo apt install python-qt4
sudo apt install pkg-config 
echo "***********************************Installing zmq required for replaying driving data (to default PATH)***********************************"

curl -LO https://github.com/zeromq/libzmq/releases/download/v4.2.3/zeromq-4.2.3.tar.gz
tar xfz zeromq-4.2.3.tar.gz
cd zeromq-4.2.3
./autogen.sh
./configure CPPFLAGS=-DPIC CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS=-fPIC --disable-shared --enable-static
make
sudo make install
cd ..
rm -rf zeromq-4.2.3
rm -rf zeromq-4.2.3.tar.gz

echo "***********************************Installing Cap'n Proto***********************************"

curl -O https://capnproto.org/capnproto-c++-0.6.1.tar.gz
tar xvf capnproto-c++-0.6.1.tar.gz
cd capnproto-c++-0.6.1
./configure --prefix=/usr/local CPPFLAGS=-DPIC CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS=-fPIC --disable-shared --enable-static
make -j4
sudo make install

cd ..
git clone https://github.com/commaai/c-capnproto.git
cd c-capnproto
git submodule update --init --recursive
autoreconf -f -i -s
CFLAGS="-fPIC" ./configure --prefix=/usr/local
make -j4
sudo make install

cd ..
rm -rf capnproto-c++-0.6.1
rm -rf capnproto-c++-0.6.1.tar.gz
rm -rf c-capnproto
rm -rf "=18.0"



echo "***********************************pip installing! If this fails, remove the version constraint in the requirements.txt for which pip failed***********************************"
echo "***********************************most distros have a shitty old version of python OpenSSL, removing it if it exists... (don't worry, we'll reinstall a recent version)***********************************"
sudo rm -rvf /usr/local/lib/python2.7/dist-packages/OpenSSL/
sudo pip install -r requirements.txt
sed -i 's/cryptography==1.4/cryptography/g' requirements_openpilot.txt
sed -i 's/pyOpenSSL==16.0.0/pyOpenSSL/g' requirements_openpilot.txt
sed -i 's/pyopencl==2016.1/pyopencl/g' requirements_openpilot.txt
sed -i 's/pytools==2016.2.1/pytools/g' requirements_openpilot.txt
sed -i 's/simplejson==3.8.2/simplejson/g' requirements_openpilot.txt
sed -i '1s/^/mako /' requirements_openpilot.txt 
sudo pip install -r requirements_openpilot.txt
unset PYTHONPATH
export PYTHONPATH=~/op-dev/
echo "export PYTHONPATH=~/op-dev/" >> ~/.bashrc

echo "export PYTHONPATH=~/op-dev/" >> ~/.bash_profile
bash
env | grep PYTHONPATH

sudo mkdir /data
sudo mkdir /data/params
sudo chown $USER /data/params

echo "Now, try out some tools! If you get a DataUnreadableError(fn)  when running replay.py -- apply this fix manually https://github.com/LHillmann/openpilot-tools/commit/c1dd99a41832becf806c7f2dddde39666a35d498"
