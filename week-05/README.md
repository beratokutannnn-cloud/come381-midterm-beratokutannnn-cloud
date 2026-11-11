# Hafta 5: Constraint'ler, ihlal testleri ve ilişkisel cebir

## 1. Çalıştırma sırası

```bash
psql -d come381 -f sql/schema.sql
psql -d come381 -f week-05/constraints.sql
psql -d come381 -f week-05/violations.sql
psql -d come381 -f week-05/seed.sql
psql -d come381 -f week-05/algebra.sql
```

Sıra önemli: `violations.sql` tabloları boşaltarak başladığı için `seed.sql` ondan sonra gelir. Windows'ta komutlara `-U postgres` ekledim. Türkçe karakterler için önce `$env:PGCLIENTENCODING = "UTF8"` ayarını yaptım.

`constraints.sql`, `fitness_class` tablosuna `end_time` sütununu ekler (iki sütunu karşılaştıran CHECK için).

## 2. NULL testi (T26)

`trainer.specialty` sütununda `CHECK (specialty IN (...))` var ama `NOT NULL` yok. Bu sütuna `NULL` eklediğimde hata çıkmadı, satır kabul edildi (`INSERT 0 1`). Çünkü `NULL IN (...)` sonucu `false` değil `NULL` (bilinmiyor) olur ve CHECK yalnızca `false` sonucunu reddeder. Bir sütunun boş kalmasını da engellemek istiyorsam `NOT NULL` ayrıca gerekir.

## 3. Beklediğimden farklı çıkan

T35 ve T36'da (üyesi olan paketi, dersi olan antrenörü silmek) `RESTRICT` kullanan foreign key'lerin ihlalini `23503` bekliyordum. PostgreSQL `23001` (`restrict_violation`) verdi. Testlerdeki beklenen kodu düzeltip yeniden çalıştırdım. Bundan `RESTRICT` ile `NO ACTION` arasındaki farkı öğrendim: `RESTRICT` kontrolü hemen yapar ve kendine ait bir hata kodu verir, `NO ACTION` kontrolü ertelenebilir.

## 4. CHECK ile yazamadığım kural

"Bir rezervasyonun tarihi, dersin başlangıç gününden sonra olamaz" kuralı `class_booking.booking_date` ile `fitness_class.start_time` sütunlarına aynı anda bakmayı gerektirir. Bu iki sütun farklı tablolarda olduğu için `CHECK` ile yazılamaz (`CHECK` yalnızca kendi satırına bakar). Bu kuralı Hafta 8'de trigger ile yazacağım.

Benzer bir kural: bir dersin rezervasyon sayısı `capacity` değerini aşamaz. Bu da birden çok satıra bakmayı gerektirdiği için `CHECK` ile yazılamaz.
