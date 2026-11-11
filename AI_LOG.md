```markdown
## Ödev 1

Bu ödevde yapay zeka olarak Claude kullandım.

**Claude'un ürettiği kısımlar:**
- Hafta 2 senaryom olmadığı için FitLife spor salonu senaryosunu Claude önerdi.
- `docs/er.md` (Mermaid ER diyagramı), `sql/schema.sql` ve `README.md` metninin ilk taslakları Claude'a ait. README'yi benim isteğimle biraz yeniden yazdırdım.

**Benim yaptıklarım:**
- GitHub reposunu, `week-05` dalını ve proje klasörlerini kendim oluşturdum.
- PostgreSQL'i kendi bilgisayarıma kurdum ve çalıştırdım. Bu sırada aldığım hataları (PATH, Türkçe locale) Claude'un yardımıyla çözdüm.
- `schema.sql` dosyasını temiz bir veritabanında çalıştırıp beş tablonun hatasız oluştuğunu `\dt` ile kontrol ettim.
- Dosyaları commit'leyip GitHub'a gönderdim.# come381-midterm-beratokutannnn-cloud



## Ödev 2

### D6 (division) denemesi

**Araç:** ChatGPT

**Prompt:

```
PostgreSQL'de şu şema var:

membership_plan(plan_id, plan_name, monthly_price, duration_months)
trainer(trainer_id, full_name, specialty)
member(member_id, plan_id, full_name, email, join_date)
fitness_class(class_id, trainer_id, class_name, start_time, capacity, end_time)
class_booking(member_id, class_id, booking_date, attended)  -- PK (member_id, class_id)

Uzmanlığı 'yoga' olan antrenörlerin verdiği TÜM derslere rezervasyon yapmış üyeleri
bulan bir SQL sorgusu yaz (division).
```

**Gelen sorgu:**

```sql
SELECT m.member_id, m.full_name
FROM member m
WHERE NOT EXISTS (
    SELECT 1
    FROM fitness_class fc
    JOIN trainer t ON fc.trainer_id = t.trainer_id
    WHERE LOWER(t.specialty) = 'yoga'
      AND NOT EXISTS (
          SELECT 1
          FROM class_booking cb
          WHERE cb.member_id = m.member_id
            AND cb.class_id = fc.class_id
      )
);
```

**Kendi verimde sonuç:** Üye 1 (Ali Veli) ve üye 3 (Can Er).

**Beklenen:** Üye 1 ve üye 3. Sonuç aynı çıktı.

**Değerlendirme:** Sorgu doğru. Üye 2 üç yoga dersinden ikisine kayıtlı ve CrossFit'e de kayıtlı (toplam 4 rezervasyon); sayıma bakan bir sorgu onu yanlışlıkla seçerdi, bu sorgu "kaydı olmadığı yoga dersi bulunmayan üye" mantığıyla doğru elemiş.

**Yanıltıcı veri denemesi (boş bölen):** Bir transaction içinde yoga derslerini (class_id 1, 2, 3) sildim, aynı sorguyu çalıştırdım, sonra ROLLBACK yaptım. Sonuç: 8 üyenin hepsi döndü, hiç rezervasyonu olmayan üye 7 ve 8 dahil. Sebep: yoga dersi kalmayınca "kaydı olmadığı yoga dersi" koşulu herkes için boşuna doğru oluyor. İlişkisel cebirdeki bölme ise bu durumda sadece `class_booking`'te görünen üyeleri verirdi (7 ve 8 çıkmazdı). Yani SQL sorgusu bu uç durumda cebir ifadesinden farklı davranıyor. Bu durumu `seed.sql`'e kalıcı eklemedim, çünkü yoga derslerini silmek D6'nın normal sonucunu bozar; deneyi geri alınan bir transaction ile yaptım.

### Diğer yapay zeka kullanımım

- Bölüm A-D için Claude ile birlikte çalıştım: `constraints.sql`, `violations.sql`, `on_delete.md` taslağı, `seed.sql`, `algebra.sql` ve `algebra.md` bu sohbette hazırlandı. Dosyaları kendi bilgisayarımda çalıştırdım ve sonuçları doğruladım.