require 'csv'
require 'pg'

conn = PG.connect(dbname: "insights")

CSV.foreach('data.csv', headers: true) do |row|
  query = "INSERT INTO client(name, age, gender, occupation, nationality)
  VALUES ($$#{row["client_name"]}$$,#{row["age"]}, '#{row["gender"]}', '#{row["occupation"]}', '#{row["nationality"]}') RETURNING *;"
  client = conn.exec(query)
  # pp client.fields
  query2 = "INSERT INTO restaurant(name, category, city, address)
  VALUES ('#{row["restaurant_name"]}','#{row["category"]}', '#{row["city"]}', '#{row["address"]}') RETURNING *;"
  restaurant = conn.exec(query2)
  
  query3 = "INSERT INTO dish(name, restaurant_id, price)
  VALUES ('#{row["dish"]}','#{restaurant[0]["id"]}', '#{row["price"]}') RETURNING *;"
  dish = conn.exec(query3)

  query4 = "INSERT INTO visit(date, client_id, restaurant_id, dish_id)
  VALUES ('#{row["visit_date"]}','#{client[0]["id"]}','#{restaurant[0]["id"]}', '#{dish[0]["id"]}') RETURNING *;"
  visit = conn.exec(query4)
  # pp visit.values
end
