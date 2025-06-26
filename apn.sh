#!/system/bin/sh

# IP tujuan
TARGET_IP="104.22.4.240"

# Daftar APN ID
APN_LIST=(2910 2907)
APN_INDEX=0

# Hitung jumlah ping gagal berturut-turut
FAIL_COUNT=0

# Fungsi untuk ping
check_ping() {
    ping -c 3 -W 2 $TARGET_IP > /dev/null 2>&1
    return $?
}

# Fungsi untuk ganti APN
ganti_apn() {
    APN_ID=${APN_LIST[$APN_INDEX]}
    echo "Mengganti ke APN ID $APN_ID"
    content update --uri content://telephony/carriers/preferapn --bind apn_id:i:$APN_ID
    sleep 5
}

# Mulai loop tanpa henti (tekan CTRL+C untuk berhenti)
while true; do
    echo "Melakukan ping ke $TARGET_IP..."
    check_ping
    if [ $? -eq 0 ]; then
        echo "Ping berhasil."
        FAIL_COUNT=0
    else
        echo "Ping gagal."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # Jika gagal 2 kali, ganti APN
    if [ $FAIL_COUNT -ge 2 ]; then
        # Reset hitungan
        FAIL_COUNT=0
        # Ganti ke APN berikutnya
        APN_INDEX=$(( (APN_INDEX + 1) % ${#APN_LIST[@]} ))
        ganti_apn
    fi

    # Delay antara percobaan ping
    sleep 10
done
