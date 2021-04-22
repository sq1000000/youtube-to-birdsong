#Install dependencies
sudo apt-get install build-essential git libfftw3-dev cmake libusb-1.0-0-dev

#Fetch and build rtl-sdr, skip if already done (subdirectories will be created under the current directory).
git clone git://git.osmocom.org/rtl-sdr.git
cd rtl-sdr/
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
sudo make install
sudo ldconfig
cd ../..

#Disable the DVB-T driver, which would prevent the rtl_sdr tool from accessing the stick
#(if you want to use it for DVB-T reception later, you should undo this change):
sudo bash -c 'echo -e "\n# for RTL-SDR:\nblacklist dvb_usb_rtl28xxu\n" >> /etc/modprobe.d/blacklist.conf'
#The following line is only needed on Ubuntu 16.04 or newer to apply changes made to the blacklist settings.
sudo update-initramfs -u #only on Ubuntu 16.04 or newer
#Disable the problematic kernel module for the current session:
sudo rmmod dvb_usb_rtl28xxu 

#Download OpenWebRX and libcsdr (subdirectories will be created under the current directory).
git clone https://github.com/simonyiszk/openwebrx.git
git clone https://github.com/simonyiszk/csdr.git

#Compile libcsdr (which is a dependency of OpenWebRX)
cd csdr
make
sudo make install

#Edit OpenWebRX config or leave defaults
nano ../openwebrx/config_webrx.py 

#Run OpenWebRX
cd ../openwebrx
./openwebrx.py