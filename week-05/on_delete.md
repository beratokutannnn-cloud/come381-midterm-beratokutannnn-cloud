# Bölüm C: Silme politikası

Bir kayıt silindiğinde ona bağlı kayıtlara ne olacağı bir iş kararıdır. Aşağıdaki tablo `constraints.sql` içindeki `ON DELETE` ayarlarıyla birebir aynıdır.

| Foreign key | Ebeveyn → çocuk | Seçimin | Neden | Diğer seçenek neden olmadı |
|---|---|---|---|---|
| `fk_member_membership_plan` | membership_plan → member | `RESTRICT` | Paketi olan üyeler varken paketin silinmesi, üyelerin hangi fiyat ve süreyle üye olduğu bilgisini yok eder. Önce üyeler başka bir pakete taşınmalı. | `CASCADE` bir paketi silince o paketteki tüm üyeleri de silerdi; üyelik kayıtlarını kaybetmek kabul edilemez. `SET NULL` olmazdı çünkü `member.plan_id` `NOT NULL`; paketsiz üye iş kuralına aykırı. |
| `fk_fitness_class_trainer` | trainer → fitness_class | `RESTRICT` | Dersi olan bir antrenör silinirse derslerin sahibi belirsiz kalır. Önce dersler başka antrenöre devredilmeli ya da iptal edilmeli. | `CASCADE` antrenörle birlikte onun derslerini ve o derslerin rezervasyonlarını da silerdi. `SET NULL` olmazdı çünkü `fitness_class.trainer_id` `NOT NULL`. |
| `fk_class_booking_member` | member → class_booking | `CASCADE` | Üye silinince onun rezervasyonlarının anlamı kalmaz. | `RESTRICT` rezervasyonu olan üyeyi silmeyi imkânsız kılardı. |
| `fk_class_booking_class` | fitness_class → class_booking | `CASCADE` | Bir ders iptal edilip silinince o derse ait rezervasyonların anlamı kalmaz. | `RESTRICT` rezervasyonu olan dersi silmeyi imkânsız kılardı. |

Kullandığım politikalar: `RESTRICT` ve `CASCADE`.

## CASCADE kanıtı

### fk_class_booking_member (member → class_booking)

Komutlar:

```sql
SELECT (SELECT count(*) FROM member        WHERE member_id = 2) AS member_rows,
       (SELECT count(*) FROM class_booking WHERE member_id = 2) AS booking_rows;
DELETE FROM member WHERE member_id = 2;
SELECT (SELECT count(*) FROM member        WHERE member_id = 2) AS member_rows,
       (SELECT count(*) FROM class_booking WHERE member_id = 2) AS booking_rows;
```

Sonuç (psql çıktısını buraya yapıştır):

```
 member_rows | booking_rows
-------------+--------------
           1 |            1
(1 row)

DELETE 1

 member_rows | booking_rows
-------------+--------------
           0 |            0
(1 row)
```

### fk_class_booking_class (fitness_class → class_booking)

Komutlar:

```sql
INSERT INTO class_booking (member_id, class_id, booking_date) VALUES (3, 1, '2026-04-26');
SELECT (SELECT count(*) FROM fitness_class WHERE class_id = 1) AS class_rows,
       (SELECT count(*) FROM class_booking WHERE class_id = 1) AS booking_rows;
DELETE FROM fitness_class WHERE class_id = 1;
SELECT (SELECT count(*) FROM fitness_class WHERE class_id = 1) AS class_rows,
       (SELECT count(*) FROM class_booking WHERE class_id = 1) AS booking_rows;
```

Sonuç (psql çıktısını buraya yapıştır):

```
INSERT 0 1

 class_rows | booking_rows
------------+--------------
          1 |            1
(1 row)

DELETE 1

 class_rows | booking_rows
------------+--------------
          0 |            0
(1 row)
```

## RESTRICT ile NO ACTION farkı

RESTRICT, bağlı satır varsa silmeyi hemen reddeder ve kontrol ertelenemez. NO ACTION ise constraint DEFERRABLE tanımlanmışsa kontrolün işlemin ilerleyen bir noktasına ertelenmesine izin verir; ertelenmemişse ikisi de aynı sonucu verir. Bu şemada RESTRICT kullandım; violations_output.txt'deki T35 ve T36 de silmeyi bu yüzden hemen reddetti.
