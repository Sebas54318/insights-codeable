1
SELECT name, category, city FROM restaurant;

SELECT DISTINCT name, category, city FROM restaurant
WHERE city = 'Reynoldsview';

SELECT DISTINCT name, category, city FROM restaurant
WHERE category = 'Italian';

2
SELECT DISTINCT name FROM dish;


4
SELECT r.name, COUNT(c.name) AS visitors FROM client AS c
JOIN visit AS v ON c.id = v.client_id
JOIN restaurant AS r ON v.restaurant_id = r.id
GROUP BY r.name
ORDER BY visitors DESC;

SELECT * FROM client AS c
JOIN visit AS v ON c.id = v.client_id
JOIN restaurant AS r ON v.restaurant_id = r.id;

5
SELECT r.name, SUM(price) AS sales FROM restaurant AS r
JOIN dish AS d ON r.id = d.restaurant_id
GROUP BY r.name
ORDER BY sales DESC;

6
SELECT r.name, ROUND(AVG(price),1) AS "avg expense" FROM restaurant AS r
JOIN dish AS d ON r.id = d.restaurant_id
GROUP BY r.name
ORDER BY "avg expense" DESC;

7
SELECT c.age, ROUND(AVG(d.price),1) AS avg_expense FROM client AS c
JOIN visit AS v ON v.client_id = c.id
JOIN dish AS d ON d.id = v.dish_id
GROUP BY c.age;

8
SELECT to_char(v.date, 'MONTH') AS month, SUM(price) AS sales FROM visit AS v
JOIN dish AS d ON d.id = v.dish_id
GROUP BY month
ORDER BY sales DESC;


9
SELECT d.name AS dish, MIN(price) FROM restaurant AS r
JOIN dish AS d ON d.restaurant_id = r.id
GROUP BY d.name;