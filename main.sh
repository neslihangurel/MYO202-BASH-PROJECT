#!/bin/bash
# İsim SOYİSİM: Neslihan Gürel
# Öğrenci Numarası: 2320171034
# Sertifika Bağlantıları: 1. https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=GoDfmP699G
# 2. https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=VP1cglWkrE
# 3. https://credsverse.com/credentials/2d2b9b20-be30-49da-ac87-7be671ce22fc

LOG_FILE="report.log"

# ISO biçiminde tarih ve saat yazınız
date -Iseconds > "$LOG_FILE"
echo "-----------------------------------" >> "$LOG_FILE"

OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == *"Darwin"* ]]; then
    # macOS Kullananlar İçin
    echo "[macOS Donanım Bilgileri]" >> "$LOG_FILE"
    system_profiler SPHardwareDataType >> "$LOG_FILE"
    echo -e "\n[Ağ / MAC Bilgisi]" >> "$LOG_FILE"
    ifconfig >> "$LOG_FILE"
else
    # Windows (Git Bash) Kullananlar İçin wmic Özel Kullanımları
    echo "[Windows Donanım Bilgileri]" >> "$LOG_FILE"
    
    echo "--- İşlemci ---" >> "$LOG_FILE"
    wmic cpu get name >> "$LOG_FILE" 2>/dev/null
    
    echo "--- RAM ---" >> "$LOG_FILE"
    wmic memorychip get capacity >> "$LOG_FILE" 2>/dev/null
    
    echo "--- Anakart ---" >> "$LOG_FILE"
    wmic baseboard get product,Manufacturer >> "$LOG_FILE" 2>/dev/null
    
    echo "--- Anakart UUID ---" >> "$LOG_FILE"
    wmic csproduct get uuid >> "$LOG_FILE" 2>/dev/null
    
    echo "--- Disk Bilgileri (Model ve Tur) ---" >> "$LOG_FILE"
    wmic diskdrive get model,mediatype,size >> "$LOG_FILE" 2>/dev/null
    
    echo "--- MAC Adresi ---" >> "$LOG_FILE"
    getmac >> "$LOG_FILE" 2>/dev/null
fi

echo "-----------------------------------" >> "$LOG_FILE"

# Kullanıcıdan parola alma (MYO+202 metni kodda asla yer almaz, kullanıcı klavyeden girer)
read -s -p "Lütfen sifreleme parolasini giriniz: " PAROLA
echo "" 

# GPG ile AES256 arka planda sifreleme
gpg --batch --yes --passphrase "$PAROLA" --symmetric --cipher-algo AES256 -o report.log.gpg "$LOG_FILE"

# Orijinal dosyayi silme
if [ -f "report.log.gpg" ]; then
    rm -f "$LOG_FILE"
    echo "Basarili! report.log dosyasi AES256 ile sifrelendi (report.log.gpg) ve orijinal dosya silindi."
else
    echo "Hata: Sifreleme islemi basarisiz oldu!"
fi
