# NULL deneyi

## Deney 1

```sql
SELECT COUNT(*), COUNT(phone) FROM customer;
```

- Tahminim: 3
- Sonuç: COUNT(*) = 8, COUNT(phone) = 5
- Yorum: COUNT(*) boş olsa da her satırı sayar fakat COUNT(phone) boş satırları saymaz.

## Deney 2

```sql
SELECT AVG(age), SUM(age) / COUNT(*) FROM customer;
```

- Tahminim: 2
- Sonuç: AVG(age) = 20.83, SUM(age) / COUNT(*) = 15
- Yorum: AVG(age) yaşı olmayanları hesaplamadığı için toplamı 6'ya böler. SUM(age) / COUNT(*) ise toplamı 8'e böler ve yuvarlayarak sonucu yazar.


