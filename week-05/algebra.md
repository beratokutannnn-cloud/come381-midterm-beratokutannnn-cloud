# Bölüm D: İlişkisel cebir ve hesap

Şema: `membership_plan`, `trainer`, `member`, `fitness_class`, `class_booking`.
Veri: `seed.sql`. SQL karşılıkları: `algebra.sql` (soru numarasıyla).

Gösterimde `⋈` doğal birleşimdir (ortak sütun adı üzerinden). `member` ile `trainer` ikisi de `full_name` sütununa sahip olduğu için bu iki tabloyu doğrudan doğal birleşimle birleştirmedim; antrenör her zaman yalnızca `fitness_class` ile birleşiyor.

---

## D1: σ ve π

**Soru:** Kapasitesi 50'den büyük derslerin adları nelerdir?

**Cebir:**

```
π class_name ( σ capacity>50 (fitness_class) )
```

**SQL:** `algebra.sql`, D1.

**Sonuç:**

```
    class_name    
------------------
 Open Gym Session
 Strength Circuit
(2 rows)
```

**DISTINCT:** Gerekli. `class_name` anahtar değil, iki ders aynı adı taşıyabilir. İlişkisel cebir küme olduğu için tekrar olmaz; SQL'de aynı sonucu almak için `DISTINCT` kullandım.

---

## D2: ⋈ (join)

**Soru:** 5 Mayıs 2026 ve sonrasında başlayan derslere rezervasyon yapan üyelerin adı ve ders adı nedir?

**Cebir:**

```
π full_name, class_name (
  σ start_time >= '2026-05-05' ( member ⋈ class_booking ⋈ fitness_class )
)
```

`member ⋈ class_booking` ortak sütun `member_id` üzerinden, ardından `⋈ fitness_class` ortak sütun `class_id` üzerinden birleşir.

**SQL:** `algebra.sql`, D2.

**Sonuç:**

```
  full_name  |    class_name     
-------------+-------------------
 Ali Veli    | Sunrise Yoga
 Ayşe Can    | CrossFit Advanced
 Ayşe Can    | CrossFit Basics
 Can Er      | Sunrise Yoga
 Deniz Aksoy | Strength Circuit
 Elif Kara   | CrossFit Basics
 Furkan Ay   | CrossFit Basics
(7 rows)
```

**DISTINCT:** Gerekli. Yalnızca `full_name` ve `class_name` seçiyoruz, anahtar sütunları seçmiyoruz. Aynı adlı iki üye ya da aynı adlı iki ders aynı çifti tekrar üretebilir. Küme anlamını korumak için `DISTINCT` kullandım.

---

## D3: ∪ (union)

**Soru:** Ya yoga ya da crossfit uzmanı bir antrenörün dersine rezervasyon yapmış üyeler kimlerdir?

**Cebir:**

```
π member_id ( σ specialty='yoga'     ( class_booking ⋈ fitness_class ⋈ trainer ) )
  ∪
π member_id ( σ specialty='crossfit' ( class_booking ⋈ fitness_class ⋈ trainer ) )
```

**SQL:** `algebra.sql`, D3.

**Sonuç:**

```
 member_id 
-----------
         1
         2
         3
         4
         5
         6
(6 rows)
```

**DISTINCT:** Ayrıca gerekmez. SQL'deki `UNION` zaten tekrarları atar (küme birleşimi). `UNION ALL` kullansaydım, hem yoga hem crossfit dersine giden üye 2 iki kez çıkardı.

---

## D4: − (difference)

**Soru:** Hiçbir derse rezervasyon yapmamış üyeler kimlerdir?

**Cebir:**

```
π member_id (member)  −  π member_id (class_booking)
```

**SQL:** `algebra.sql`, D4a (`EXCEPT`) ve D4b (`NOT EXISTS`). İkisi aynı sonucu verir.

**Sonuç (D4a ve D4b aynı):**

```
 member_id 
-----------
         7
         8
(2 rows)
```

**DISTINCT:** Gerekmez. `EXCEPT` zaten küme işlemi yapar, tekrarları atar. `NOT EXISTS` sürümünde `member` tablosundan okuyoruz ve `member_id` birincil anahtar olduğu için tekrar oluşamaz.

### İlişkisel hesap (tuple relational calculus)

```
{ t.member_id | member(t) ∧ ¬∃b ( class_booking(b) ∧ b.member_id = t.member_id ) }
```

Okunuşu: `member` tablosundaki bir `t` satırının `member_id` değeri, öyle ki `class_booking`'te `member_id`'si `t`'ninkine eşit bir satır yok.

---

## D5: ρ (rename) ve tablonun kendisiyle join'i

**Soru:** Aynı üyelik paketindeki farklı üye çiftleri kimlerdir?

**Cebir:**

```
π a.plan_id, a.full_name, b.full_name (
  σ a.plan_id = b.plan_id ∧ a.member_id < b.member_id (
    ρ a (member)  ×  ρ b (member)
  )
)
```

`ρ a (member)` ve `ρ b (member)` aynı tablonun iki kopyasına ad verir. `a.member_id < b.member_id` koşulu iki şeyi eler: bir üyenin kendisiyle eşleşmesini ve aynı çiftin ters sırayla ikinci kez çıkmasını.

**SQL:** `algebra.sql`, D5.

**Sonuç:**

```
 plan_id |    uye1     |    uye2     
---------+-------------+-------------
       1 | Ali Veli    | Ayşe Can
       1 | Ali Veli    | Gül Tan
       1 | Ayşe Can    | Gül Tan
       2 | Can Er      | Deniz Aksoy
       2 | Can Er      | Hakan Işık
       2 | Deniz Aksoy | Hakan Işık
       3 | Elif Kara   | Furkan Ay
(7 rows)
```

**DISTINCT:** Gerekmez. `a.member_id < b.member_id` koşulu sayesinde her çift yalnızca bir kez üretilir.

---

## D6: ÷ (division)

**Soru:** Yoga uzmanı antrenörlerin verdiği **tüm** derslere rezervasyon yapmış üyeler kimlerdir?

**Cebir:**

```
π member_id, class_id (class_booking)
  ÷
π class_id ( σ specialty='yoga' ( fitness_class ⋈ trainer ) )
```

Bölen: yoga derslerinin `class_id` değerleri (1, 2, 3). Bölünen: hangi üyenin hangi derse rezervasyon yaptığı. Sonuç: bölenin tamamıyla eşleşen üyeler.

**SQL:** `algebra.sql`, D6. İç içe iki `NOT EXISTS` kullandım ("kaydı olmadığı yoga dersi bulunmayan üye"). Bu yolu seçtim çünkü "tümü" koşulunu doğrudan ifade ediyor. `COUNT` ile yazılan division sorguları, spor dışı kayıtlar da sayıma girdiğinde ya da bir satır iki kez sayıldığında yanlış sonuç verebilir.

**Sonuç:**

```
 member_id | full_name 
-----------+-----------
         1 | Ali Veli
         3 | Can Er
(2 rows)
```

Üye 2, üç yoga dersinden ikisine kayıtlı (ders 3'e eksik), ama toplam rezervasyonu 4 olduğu için sayıma bakan bir sorgu onu yanlışlıkla seçerdi. `NOT EXISTS` sorgusu onu doğru şekilde eledi.

**DISTINCT:** Gerekmez. `member` tablosundan okuyoruz ve `member_id` birincil anahtar olduğu için tekrar oluşamaz.
