require 'csv'
require 'pg'

conn = PG.connect(dbname: "insights")

CSV.foreach('new_data.csv', headers: true) do |row|
  query = "INSERT INTO client(name, age, gender, occupation, nationality)
  VALUES ('#{row["client_name"]}',#{row["age"]}, '#{row["gender"]}', '#{row["occupation"]}', '#{row["nationality"]}')"
  result = conn.exec(query)

  query2 = "INSERT INTO restaurant(name, category, city, address)
  VALUES ('#{row["restaurant_name"]}','#{row["category"]}', '#{row["city"]}', '#{row["address"]}')"
  result2 = conn.exec(query2)
  pp result2.values
  query3 = "INSERT INTO dish(name, restaurant_id, price)
  VALUES ('#{row["dish"]}','#{result2['id']}', '#{row["price"]}')"
  result3 = conn.exec(query3)

end