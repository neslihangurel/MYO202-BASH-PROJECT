#!/bin/bash
# İsim SOYİSİM: [Neslihan Gürel]
# Öğrenci Numarası: [2320171034]
# Sertifika Bağlantıları: 1. [https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=VP1cglWkrE]
#2. [https://www.btkakademi.gov.tr/portal/certificate/validate?certificateId=GoDfmP699G]
#3. [https://credsverse.com/credentials/2d2b9b20-be30-49da-ac87-7be671ce22fc]

LOG_FILE="report.log"

# 1. ISO biçiminde tarih ve saat yazdırma
# date -Iseconds komutu ISO 8601 standartlarında (Örn: 2026-05-29T15:30:00+03:00) çıktı verir.
date -Iseconds > "$LOG_FILE"
echo "-----------------------------------" >> "$LOG_FILE"

# 2. Donanım Bilgilerini Çekme
# uname -s ile işletim sistemini kontrol edip ona göre komut çalıştırıyoruz.
OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == *"Darwin"* ]]; then
    # macOS Kullananlar İçin
    echo "[macOS Donanım Bilgileri]" >> "$LOG_FILE"
    system_profiler SPHardwareDataType >> "$LOG_FILE"
    echo -e "\n[Ağ / MAC Bilgisi]" >> "$LOG_FILE"
    ifconfig >> "$LOG_FILE"
else
    # Windows (Git Bash, WSL vb.) Kullananlar İçin
    echo "[Windows Donanım Bilgileri]" >> "$LOG_FILE"
    echo "--- İşlemci ---" >> "$LOG_FILE"
    wmic cpu get name >> "$LOG_FILE" 2>/dev/null
    
    echo "--- RAM ---" >> "$LOG_FILE"
    wmic memorychip get capacity >> "$LOG_FILE" 2>/dev/null
    
    echo "--- Anakart ---" >> "$LOG_FILE"
    wmic baseboard get product,Manufacturer >> "$LOG_FILE" 2>/dev/null
    
    echo "--- UUID Disk ---" >> "$LOG_FILE"
    wmic csproduct get uuid >> "$LOG_FILE" 2>/dev/null
    
    echo "--- MAC Adresi ---" >> "$LOG_FILE"
    getmac >> "$LOG_FILE" 2>/dev/null
fi

echo "-----------------------------------" >> "$LOG_FILE"

# 3. Kullanıcıdan parola alma (-s parametresi parolayı ekranda gizler)
read -s -p "Lütfen şifreleme parolasını giriniz (Örn: MYO+202): " PAROLA
echo "" # Alt satıra geçmek için

# 4. GPG ile AES256 arka planda (batch modunda) simetrik şifreleme
gpg --batch --yes --passphrase "$PAROLA" --symmetric --cipher-algo AES256 -o report.log.gpg "$LOG_FILE"

# 5. Orijinal dosyayı silme
# Şifrelenmiş dosyanın başarıyla oluştuğundan emin olduktan sonra siliyoruz.
if [ -f "report.log.gpg" ]; then
    rm -f "$LOG_FILE"
    echo "Başarılı! report.log dosyası AES256 ile şifrelendi (report.log.gpg) ve orijinal dosya silindi."
else
    echo "Hata: Şifreleme işlemi başarısız oldu!"
fi
