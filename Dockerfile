# Dockerfile

# 1. Temel İmaj: Hangi Python sürümünü kullanacağımızı belirtir.
# 'slim' versiyonları daha küçük boyutludur. Projenizdeki Python sürümüyle uyumlu olsun.
FROM python:3.9-slim

# 2. Çalışma Dizini: Konteyner içindeki ana çalışma klasörünü ayarlar.
# Sonraki komutlar bu klasöre göre çalışır.
WORKDIR /app

# 3. Bağımlılık Dosyasını Kopyala: requirements.txt dosyasını konteynere kopyala.
COPY requirements.txt .

# 4. Bağımlılıkları Yükle: requirements.txt içindeki kütüphaneleri kur.
# --no-cache-dir: İmaj boyutunu küçültmek için pip önbelleğini kullanma.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Gerekli Klasör Yapısını Oluştur: API'nin ihtiyaç duyacağı dosyalar için
# (Özellik isimleri dosyası gibi)
RUN mkdir -p /app/data/processed

# 6. Özellik İsimleri Dosyasını Kopyala: API'nin başlangıçta yüklediği dosya.
# Bu dosyanın lokalde 'data/processed/' altında olduğundan emin olun.
COPY ./data/processed/feature_names.joblib /app/data/processed/feature_names.joblib

# 7. Uygulama Kodunu Kopyala: 'src' klasöründeki tüm kodları (api.py, train.py vs.)
# konteynerdeki '/app/src' klasörüne kopyala.
COPY ./src /app/src

# 8. MLflow Sunucu Adresini Ayarla (Ortam Değişkeni):
# Konteyner içindeki API'nin, ana makinede (host) çalışan MLflow UI'a erişebilmesi için.
# 'host.docker.internal' Docker Desktop (Win/Mac) için özel bir DNS ismidir ve host makineye çözümlenir.
# DİKKAT: Eğer Docker'ı Linux'ta Docker Desktop olmadan kullanıyorsanız veya
# MLflow'u da ayrı bir konteynerde çalıştıracaksanız bu adres değişebilir.
ENV MLFLOW_TRACKING_URI=http://host.docker.internal:5000

# 9. Port Bilgisi: Konteynerin hangi portu dışarıya açacağını belirtir (bilgilendirme amaçlı).
EXPOSE 8000

# 10. Çalıştırma Komutu: Konteyner başlatıldığında çalışacak varsayılan komut.
# Uvicorn sunucusunu başlatır, API'yi 0.0.0.0 adresinde (konteyner içindeki tüm ağ arayüzleri)
# ve 8000 portunda yayınlar.
CMD ["uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]