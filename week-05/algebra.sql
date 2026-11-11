\pset null '(null)'

-- Bölüm D: SQL karşılıkları. Çalıştırma: seed.sql'den sonra.

-- D1 | σ ve π | Kapasitesi 50'den büyük derslerin adları
\echo D1
SELECT DISTINCT class_name
FROM fitness_class
WHERE capacity > 50
ORDER BY class_name;

-- D2 | ⋈ | 5 Mayıs 2026 ve sonrasında başlayan derslere rezervasyon yapan üyelerin adı ve ders adı
\echo D2
SELECT DISTINCT m.full_name, fc.class_name
FROM member m
JOIN class_booking cb ON cb.member_id = m.member_id
JOIN fitness_class fc ON fc.class_id = cb.class_id
WHERE fc.start_time >= '2026-05-05'
ORDER BY m.full_name, fc.class_name;

-- D3 | ∪ | Ya yoga ya da crossfit uzmanı antrenörün dersine rezervasyon yapmış üyeler
\echo D3
SELECT cb.member_id
FROM class_booking cb
JOIN fitness_class fc ON fc.class_id = cb.class_id
JOIN trainer t ON t.trainer_id = fc.trainer_id
WHERE t.specialty = 'yoga'
UNION
SELECT cb.member_id
FROM class_booking cb
JOIN fitness_class fc ON fc.class_id = cb.class_id
JOIN trainer t ON t.trainer_id = fc.trainer_id
WHERE t.specialty = 'crossfit'
ORDER BY member_id;

-- D4 | − | Hiçbir derse rezervasyon yapmamış üyeler (yol 1: EXCEPT)
\echo D4a
SELECT member_id FROM member
EXCEPT
SELECT member_id FROM class_booking
ORDER BY member_id;

-- D4 | − | Aynı soru (yol 2: NOT EXISTS)
\echo D4b
SELECT m.member_id
FROM member m
WHERE NOT EXISTS (
  SELECT 1 FROM class_booking cb WHERE cb.member_id = m.member_id
)
ORDER BY m.member_id;

-- D5 | ρ ve kendisiyle join | Aynı üyelik paketindeki farklı üye çiftleri
\echo D5
SELECT a.plan_id, a.full_name AS uye1, b.full_name AS uye2
FROM member a
JOIN member b ON a.plan_id = b.plan_id AND a.member_id < b.member_id
ORDER BY a.plan_id, a.member_id, b.member_id;

-- D6 | ÷ | Yoga uzmanı antrenörlerin verdiği TÜM derslere rezervasyon yapmış üyeler
-- (iç içe iki NOT EXISTS: "kaydı olmadığı yoga dersi bulunmayan üye")
\echo D6
SELECT m.member_id, m.full_name
FROM member m
WHERE NOT EXISTS (
  SELECT 1
  FROM fitness_class fc
  JOIN trainer t ON t.trainer_id = fc.trainer_id
  WHERE t.specialty = 'yoga'
    AND NOT EXISTS (
      SELECT 1
      FROM class_booking cb
      WHERE cb.member_id = m.member_id
        AND cb.class_id = fc.class_id
    )
)
ORDER BY m.member_id;
