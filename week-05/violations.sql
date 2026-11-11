\set VERBOSITY verbose

-- Bölüm B: İhlal testleri
-- Çalıştırma sırası: schema.sql -> constraints.sql -> violations.sql
-- Not: PostgreSQL'de başarısız INSERT bile identity sayacını ilerletir.
-- Bu yüzden testlerde yalnızca hazırlık bloğundaki id'lere (1, 2, 3) ya da
-- var olmayan 999'a başvuruyoruz.

-- =========================================================
-- Hazırlık: tabloları boşalt, testlerin ihtiyaç duyduğu satırları ekle
-- =========================================================
TRUNCATE membership_plan, trainer, member, fitness_class, class_booking
  RESTART IDENTITY CASCADE;

INSERT INTO membership_plan (plan_name, monthly_price, duration_months) VALUES
  ('Basic',   300.00, 1),
  ('Premium', 500.00, 12);

INSERT INTO trainer (full_name, specialty) VALUES
  ('Ayşe Demir',  'yoga'),
  ('Mehmet Kaya', 'crossfit');

INSERT INTO member (plan_id, full_name, email, join_date) VALUES
  (1, 'Ali Veli',  'ali@example.com',  '2026-01-10'),
  (1, 'Ayşe Can',  'ayse@example.com', '2026-02-01'),
  (2, 'Can Er',    'can@example.com',  '2026-03-01');

INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time) VALUES
  (1, 'Morning Yoga',     '2026-05-01 09:00', 20, '2026-05-01 10:00'),
  (2, 'CrossFit Basics',  '2026-05-01 18:00', 15, '2026-05-01 19:00');

INSERT INTO class_booking (member_id, class_id, booking_date, attended) VALUES
  (1, 1, '2026-04-20', NULL),
  (2, 1, '2026-04-21', NULL),
  (1, 2, '2026-04-22', NULL);

-- =========================================================
-- NOT NULL (beklenen: 23502)
-- =========================================================

\echo T01
-- T01 | membership_plan.plan_name NOT NULL | Beklenen: 23502
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES (NULL, 100, 1);

\echo T02
-- T02 | membership_plan.monthly_price NOT NULL | Beklenen: 23502
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('NN Plan 2', NULL, 1);

\echo T03
-- T03 | membership_plan.duration_months NOT NULL | Beklenen: 23502
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('NN Plan 3', 100, NULL);

\echo T04
-- T04 | trainer.full_name NOT NULL | Beklenen: 23502
INSERT INTO trainer (full_name, specialty)
VALUES (NULL, 'yoga');

\echo T05
-- T05 | member.plan_id NOT NULL | Beklenen: 23502
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (NULL, 'Test Uye', 't05@example.com', '2026-01-01');

\echo T06
-- T06 | member.full_name NOT NULL | Beklenen: 23502
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (1, NULL, 't06@example.com', '2026-01-01');

\echo T07
-- T07 | member.email NOT NULL | Beklenen: 23502
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (1, 'Test Uye', NULL, '2026-01-01');

\echo T08
-- T08 | member.join_date NOT NULL | Beklenen: 23502
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (1, 'Test Uye', 't08@example.com', NULL);

\echo T09
-- T09 | fitness_class.trainer_id NOT NULL | Beklenen: 23502
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (NULL, 'NN Ders 9', '2026-07-01 09:00', 10, '2026-07-01 10:00');

\echo T10
-- T10 | fitness_class.class_name NOT NULL | Beklenen: 23502
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, NULL, '2026-07-02 09:00', 10, '2026-07-02 10:00');

\echo T11
-- T11 | fitness_class.start_time NOT NULL | Beklenen: 23502
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'NN Ders 11', NULL, 10, '2026-07-03 10:00');

\echo T12
-- T12 | fitness_class.capacity NOT NULL | Beklenen: 23502
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'NN Ders 12', '2026-07-04 09:00', NULL, '2026-07-04 10:00');

\echo T13
-- T13 | fitness_class.end_time NOT NULL | Beklenen: 23502
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'NN Ders 13', '2026-07-05 09:00', 10, NULL);

\echo T14
-- T14 | class_booking.booking_date NOT NULL | Beklenen: 23502
INSERT INTO class_booking (member_id, class_id, booking_date, attended)
VALUES (3, 2, NULL, NULL);

-- =========================================================
-- UNIQUE (beklenen: 23505)
-- =========================================================

\echo T15
-- T15 | uq_member_email | Beklenen: 23505
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (1, 'Kopya Uye', 'ali@example.com', '2026-01-01');

\echo T16
-- T16 | uq_membership_plan_name | Beklenen: 23505
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('Basic', 350, 1);

\echo T17
-- T17 | uq_fitness_class_trainer_start (çok sütunlu) | Beklenen: 23505
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Cakisan Ders', '2026-05-01 09:00', 10, '2026-05-01 10:00');

\echo T18
-- T18 | uq_fitness_class_trainer_start | Beklenen: OK (aynı antrenör, farklı saat)
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Evening Yoga', '2026-05-01 17:00', 10, '2026-05-01 18:00');

\echo T19
-- T19 | class_booking_pkey (aynı üye aynı derse iki kez) | Beklenen: 23505
INSERT INTO class_booking (member_id, class_id, booking_date, attended)
VALUES (1, 1, '2026-04-25', NULL);

-- =========================================================
-- CHECK (beklenen: 23514 ya da OK)
-- =========================================================

\echo T20
-- T20 | chk_membership_plan_price | Beklenen: 23514
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('Eksi Fiyat', -1, 1);

\echo T21
-- T21 | chk_membership_plan_price | Beklenen: OK (sınır: fiyat 0)
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('Free Trial', 0, 1);

\echo T22
-- T22 | chk_membership_plan_duration | Beklenen: 23514
INSERT INTO membership_plan (plan_name, monthly_price, duration_months)
VALUES ('Sifir Sure', 100, 0);

\echo T23
-- T23 | chk_fitness_class_capacity | Beklenen: 23514
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Sifir Kontenjan', '2026-06-01 09:00', 0, '2026-06-01 10:00');

\echo T24
-- T24 | chk_fitness_class_capacity | Beklenen: OK (sınır: kontenjan 1)
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Single Seat', '2026-06-02 09:00', 1, '2026-06-02 10:00');

\echo T25
-- T25 | chk_trainer_specialty | Beklenen: 23514
INSERT INTO trainer (full_name, specialty)
VALUES ('Gecersiz Uzman', 'ballet');

\echo T26
-- T26 | chk_trainer_specialty NULL testi | Beklenen: OK
-- (specialty NOT NULL değil; CHECK sonucu NULL olunca satır kabul edilir)
INSERT INTO trainer (full_name, specialty)
VALUES ('Genel Antrenör', NULL);

\echo T27
-- T27 | chk_fitness_class_time_order | Beklenen: 23514 (bitiş başlangıçtan önce)
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Ters Ders', '2026-06-03 10:00', 10, '2026-06-03 09:00');

\echo T28
-- T28 | chk_fitness_class_time_order | Beklenen: 23514 (sınır: bitiş = başlangıç, kural kesin '>')
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Sifir Sureli Ders', '2026-06-04 09:00', 10, '2026-06-04 09:00');

\echo T29
-- T29 | chk_fitness_class_time_order | Beklenen: OK (sınır: bitiş = başlangıç + 1 dakika)
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (1, 'Bir Dakikalik Ders', '2026-06-05 09:00', 10, '2026-06-05 09:01');

\echo T30
-- T30 | chk_member_email_format | Beklenen: 23514
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (1, 'Hatali Eposta', 'ornek-eposta.com', '2026-01-01');

-- =========================================================
-- FOREIGN KEY: ekleme yönü (beklenen: 23503)
-- =========================================================

\echo T31
-- T31 | fk_member_membership_plan (olmayan paket) | Beklenen: 23503
INSERT INTO member (plan_id, full_name, email, join_date)
VALUES (999, 'Paketsiz Uye', 't31@example.com', '2026-01-01');

\echo T32
-- T32 | fk_fitness_class_trainer (olmayan antrenör) | Beklenen: 23503
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time)
VALUES (999, 'Hayalet Antrenor Dersi', '2026-08-01 09:00', 10, '2026-08-01 10:00');

\echo T33
-- T33 | fk_class_booking_member (olmayan üye) | Beklenen: 23503
INSERT INTO class_booking (member_id, class_id, booking_date, attended)
VALUES (999, 1, '2026-04-25', NULL);

\echo T34
-- T34 | fk_class_booking_class (olmayan ders) | Beklenen: 23503
INSERT INTO class_booking (member_id, class_id, booking_date, attended)
VALUES (3, 999, '2026-04-25', NULL);

-- =========================================================
-- FOREIGN KEY: silme yönü
-- =========================================================

\echo T35
-- T35 | fk_member_membership_plan (RESTRICT) | Beklenen: 23001
-- Üyesi olan paket silinemez. (RESTRICT, 23503 değil 23001 restrict_violation verir.)
DELETE FROM membership_plan WHERE plan_id = 1;

\echo T36
-- T36 | fk_fitness_class_trainer (RESTRICT) | Beklenen: 23001
-- Dersi olan antrenör silinemez. (RESTRICT, 23503 değil 23001 restrict_violation verir.)
DELETE FROM trainer WHERE trainer_id = 1;

\echo T37
-- T37 | fk_class_booking_member (CASCADE) | Beklenen: OK
-- Kaydı olan üye silinir, rezervasyonları da onunla gider.
-- (Bu test veriyi değiştirdiği için en sonda.)
SELECT count(*) AS member1_bookings_before FROM class_booking WHERE member_id = 1;
DELETE FROM member WHERE member_id = 1;
SELECT count(*) AS member1_bookings_after FROM class_booking WHERE member_id = 1;
