clear
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;37m                 H A N N X 7   I N S T A L L E R            \e[0m"
echo -e "\e[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n"

echo -e "  \e[1;33m[>]\e[0m Meminta Izin Penyimpanan..."
termux-setup-storage
sleep 2

echo -e "\n  \e[1;36m[1/4]\e[0m Menginstal Paket Sistem & Compiler..."
pkg update -y
pkg install nodejs python git libusb android-tools libimobiledevice usbmuxd clang make libxml2 libxslt pkg-config rust libffi openssl binutils -y

echo -e "\n  \e[1;36m[2/4]\e[0m Menginstal Modul Inti Node.js..."
if [ -f "package.json" ]; then
    npm install
else
    echo -e "  \e[1;33m[!] package.json tidak ditemukan. Pastikan Anda berada di folder hannx7-unlock\e[0m"
fi

echo -e "\n  \e[1;36m[3/4]\e[0m Menginstal Mesin Qualcomm (EDL)..."
pip install --break-system-packages edlclient

echo -e "\n  \e[1;36m[4/4]\e[0m Menginstal Mesin MediaTek & Unisoc..."

rm -rf mtkclient_tmp
git clone --depth 1 https://github.com/bkerler/mtkclient.git mtkclient_tmp
if [ -d "mtkclient_tmp" ]; then
    pushd mtkclient_tmp > /dev/null
    sed -i -E '/pyside6|shiboken6|PySide6/Id' pyproject.toml setup.py requirements.txt 2>/dev/null || true
    pip install --break-system-packages .
    popd > /dev/null
    rm -rf mtkclient_tmp
fi

echo -e "\n  \e[1;36m[+]\e[0m Membangun Mesin Unisoc SPD dari Source yang Benar..."
rm -rf spd_dump_tmp
git clone --depth 1 https://github.com/ilyakurdyukov/spreadtrum_flash.git spd_dump_tmp
if [ -d "spd_dump_tmp" ]; then
    pushd spd_dump_tmp > /dev/null
    export CFLAGS="-I$PREFIX/include"
    export LDFLAGS="-L$PREFIX/lib"
    make clean 2>/dev/null
    make
    if [ -f "spd_dump" ]; then
        cp spd_dump $PREFIX/bin/
        chmod +x $PREFIX/bin/spd_dump
    fi
    popd > /dev/null
    rm -rf spd_dump_tmp
fi

echo -e "\n  \e[1;36m[+]\e[0m Verifikasi Komponen Akhir..."

ERROR=0
if ! command -v mtk &> /dev/null && ! pip show mtkclient &> /dev/null; then
    echo -e "  \e[1;31m[✖] Mesin MTK gagal diinstal\e[0m"; ERROR=1;
fi
if ! command -v edl &> /dev/null; then
    echo -e "  \e[1;31m[✖] Mesin Qualcomm EDL gagal diinstal\e[0m"; ERROR=1;
fi
if ! command -v spd_dump &> /dev/null; then
    echo -e "  \e[1;31m[✖] Mesin Unisoc SPD gagal diinstal\e[0m"; ERROR=1;
fi
if [ ! -d "node_modules" ]; then
    echo -e "  \e[1;31m[✖] Modul Node.js gagal diinstal\e[0m"; ERROR=1;
fi

if [ $ERROR -eq 0 ]; then
    echo -e "\n  \e[1;32m[✔] SEMUA MESIN & MODUL BERHASIL DIINSTAL!\e[0m"
    echo -e "  \e[1;37mJalankan tool dengan perintah: \e[1;32m./hannx7\e[0m\n"
    chmod +x hannx7 2>/dev/null
else
    echo -e "\n  \e[1;31m[✖] INSTALASI BELUM SEMPURNA!\e[0m"
    echo -e "  \e[1;33mBeberapa komponen mungkin butuh instalasi manual.\e[0m\n"
fi
