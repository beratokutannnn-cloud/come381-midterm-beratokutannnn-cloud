-- Bölüm A: Constraint'ler
-- schema.sql'den SONRA çalışır. Çalıştırma: psql -d come381 -f week-05/constraints.sql

-- =========================================================
-- 0. Şema eki: ders bitiş zamanı
-- İki sütunu karşılaştıran CHECK için fitness_class'a end_time ekliyoruz.
-- (Tablo boşken çalıştığı için NOT NULL hemen eklenebilir.)
-- =========================================================
ALTER TABLE fitness_class ADD COLUMN end_time timestamp;

-- =========================================================
-- 1. NOT NULL
-- Bilerek nullable bıraktıklarım: trainer.specialty (uzmanlığı belirsiz
-- antrenör olabilir) ve class_booking.attended (NULL = ders henüz yapılmadı).
-- =========================================================
ALTER TABLE membership_plan ALTER COLUMN plan_name       SET NOT NULL;
ALTER TABLE membership_plan ALTER COLUMN monthly_price   SET NOT NULL;
ALTER TABLE membership_plan ALTER COLUMN duration_months SET NOT NULL;

ALTER TABLE trainer ALTER COLUMN full_name SET NOT NULL;

ALTER TABLE member ALTER COLUMN plan_id   SET NOT NULL;
ALTER TABLE member ALTER COLUMN full_name SET NOT NULL;
ALTER TABLE member ALTER COLUMN email     SET NOT NULL;
ALTER TABLE member ALTER COLUMN join_date SET NOT NULL;

ALTER TABLE fitness_class ALTER COLUMN trainer_id SET NOT NULL;
ALTER TABLE fitness_class ALTER COLUMN class_name SET NOT NULL;
ALTER TABLE fitness_class ALTER COLUMN start_time SET NOT NULL;
ALTER TABLE fitness_class ALTER COLUMN end_time   SET NOT NULL;
ALTER TABLE fitness_class ALTER COLUMN capacity   SET NOT NULL;

ALTER TABLE class_booking ALTER COLUMN booking_date SET NOT NULL;

-- =========================================================
-- 2. UNIQUE
-- =========================================================

-- İki üye aynı e-posta ile kayıt olamaz.
ALTER TABLE member
  ADD CONSTRAINT uq_member_email UNIQUE (email);

-- Aynı isimde iki üyelik paketi olamaz.
ALTER TABLE membership_plan
  ADD CONSTRAINT uq_membership_plan_name UNIQUE (plan_name);

-- Bir antrenör aynı anda iki farklı derse giremez (çok sütunlu).
ALTER TABLE fitness_class
  ADD CONSTRAINT uq_fitness_class_trainer_start UNIQUE (trainer_id, start_time);

-- Not: "bir üye aynı derse iki kez rezervasyon yapamaz" kuralını
-- class_booking'in (member_id, class_id) PRIMARY KEY'i zaten sağlıyor.

-- =========================================================
-- 3. CHECK
-- =========================================================

-- Paketin aylık fiyatı negatif olamaz.
ALTER TABLE membership_plan
  ADD CONSTRAINT chk_membership_plan_price CHECK (monthly_price >= 0);

-- Paket süresi en az 1 ay olmalı.
ALTER TABLE membership_plan
  ADD CONSTRAINT chk_membership_plan_duration CHECK (duration_months > 0);

-- Bir dersin kontenjanı en az 1 kişi olmalı. (tek sütunda aralık)
ALTER TABLE fitness_class
  ADD CONSTRAINT chk_fitness_class_capacity CHECK (capacity > 0);

-- Antrenörün uzmanlığı tanımlı alanlardan biri olmalı. (izin verilen değerler)
-- specialty NOT NULL değil: NULL değer bu CHECK'ten geçer.
ALTER TABLE trainer
  ADD CONSTRAINT chk_trainer_specialty
  CHECK (specialty IN ('yoga', 'pilates', 'crossfit', 'cardio', 'strength'));

-- Bir ders başladığı andan önce bitemez. (iki sütunu karşılaştıran)
ALTER TABLE fitness_class
  ADD CONSTRAINT chk_fitness_class_time_order CHECK (end_time > start_time);

-- E-posta en azından '@' içermeli.
ALTER TABLE member
  ADD CONSTRAINT chk_member_email_format CHECK (email LIKE '%@%');

-- =========================================================
-- 4. FOREIGN KEY: isimli olarak yeniden kur
-- Eski isimsiz FK'lerin PostgreSQL'in verdiği varsayılan adları aşağıdaki gibidir.
-- (Emin olmak için önce \d member gibi komutlarla kontrol et.)
-- ON DELETE politikaları Bölüm C'deki kararlarla aynı olmalı.
-- =========================================================
ALTER TABLE member         DROP CONSTRAINT member_plan_id_fkey;
ALTER TABLE fitness_class  DROP CONSTRAINT fitness_class_trainer_id_fkey;
ALTER TABLE class_booking  DROP CONSTRAINT class_booking_member_id_fkey;
ALTER TABLE class_booking  DROP CONSTRAINT class_booking_class_id_fkey;

-- Üyesi olan bir paket silinemez.
ALTER TABLE member
  ADD CONSTRAINT fk_member_membership_plan
  FOREIGN KEY (plan_id) REFERENCES membership_plan(plan_id)
  ON DELETE RESTRICT;

-- Dersi olan bir antrenör silinemez.
ALTER TABLE fitness_class
  ADD CONSTRAINT fk_fitness_class_trainer
  FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id)
  ON DELETE RESTRICT;

-- Üye silinince rezervasyonlarının anlamı kalmaz.
ALTER TABLE class_booking
  ADD CONSTRAINT fk_class_booking_member
  FOREIGN KEY (member_id) REFERENCES member(member_id)
  ON DELETE CASCADE;

-- Ders silinince (iptal) o derse ait rezervasyonlar da silinir.
ALTER TABLE class_booking
  ADD CONSTRAINT fk_class_booking_class
  FOREIGN KEY (class_id) REFERENCES fitness_class(class_id)
  ON DELETE CASCADE;
