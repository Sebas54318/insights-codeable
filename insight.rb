require 'pg'
require 'terminal-table'
require 'colorize'

class Insight 
  def initialize
    @conn = PG.connect(dbname: "insights")
  end

  def start
    puts print_insight.colorize(:blue).bold
    puts ""
    print_welcome
    print_menu

    loop do
      print "> "
      option, parameters = gets.chomp.split(" ",2)
      case option
      when "1"
        puts restaurant_list(parameters)
      when "2"
        puts dishes
      when "3"
        puts group_by(parameters)
      when "4"
        puts top_restaurants_by_visitors
      when "5"
        puts top_restaurants_by_sales
      when "6"
        puts top_restaurants_by_avg
      when "7"
        puts avg_consumer_expense(parameters)
      when "8"
        puts sales_by_month(parameters)
      when "9"
        puts best_price_dish
      when "10" 
        puts favorite_dish_by_group(parameters)
      when "menu"
        print_menu
      when "exit"
        puts "Made with \u2764  by Victor V. , Sebastian M. , Kevin Q.".colorize(:yellow).bold
        break
      else
        puts "Invalid Option"
      end
    end
  end

  private

  def restaurant_list(parameters = nil)
    if parameters == nil
      query = "SELECT DISTINCT name, category, city FROM restaurant;"
    else
      field, term = parameters.split('=')
      query = "SELECT DISTINCT name, category, city FROM restaurant
      WHERE #{field} = '#{term}';"
    end
    
    result = @conn.exec(query)
    create_table(result, "List of restaurants")
  end

  def dishes
    query = "SELECT DISTINCT name FROM dish;"
    result = @conn.exec(query)
    create_table(result, "List of Dishes")
  end

  def top_restaurants_by_visitors
    query = "SELECT r.name, COUNT(c.name) AS visitors FROM client AS c
    JOIN visit AS v ON c.id = v.client_id
    JOIN restaurant AS r ON v.restaurant_id = r.id
    GROUP BY r.name
    ORDER BY visitors DESC;"
    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by visitors")
  end

  def group_by(parameters)
    # 3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    if parameters.nil? || parameters.empty?
      return "invalid parameters"
    else
      field, term = parameters.split("=")

    query = "SELECT #{term}, COUNT(*) AS count, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM visit), 2) AS percentage
    FROM visit
    JOIN client ON visit.client_id = client.id
    GROUP BY #{term}
    ORDER BY #{term};"

    result = @conn.exec(query)
    create_table(result, "Group by #{term.downcase.gsub("'", "''")}")
  end
  end

  def top_restaurants_by_sales
    query = "SELECT r.name, SUM(price) AS sales FROM restaurant AS r
    JOIN dish AS d ON r.id = d.restaurant_id
    GROUP BY r.name
    ORDER BY sales DESC;"
    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by Sales")
  end

  def top_restaurants_by_avg
    query = "SELECT r.name, ROUND(AVG(price),1) AS avg_expense FROM restaurant AS r
    JOIN dish AS d ON r.id = d.restaurant_id
    GROUP BY r.name
    ORDER BY avg_expense DESC;"
    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by average expense per user")
  end

  def avg_consumer_expense(parameters)
    field, term = parameters.split("=")
    termino = term.downcase
    if termino == "age" || termino == "gender" || termino == "occupation" || termino == "nationality"
      query = "SELECT c.#{termino}, ROUND(AVG(d.price),1) AS avg_expense FROM client AS c
      JOIN visit AS v ON v.client_id = c.id
      JOIN dish AS d ON d.id = v.dish_id
      GROUP BY c.#{termino};"
    else
      puts "No ingreso un campo valido"
    end
    result = @conn.exec(query)
    create_table(result, "Average consumer expenses")
  end

  def sales_by_month(parameters = nil)
    if parameters == nil
      query = "SELECT to_char(v.date, 'MONTH') AS month, SUM(price) AS sales FROM visit AS v
      JOIN dish AS d ON d.id = v.dish_id
      GROUP BY month;"
    else
      field, term = parameters.split('=')
      query = "SELECT to_char(v.date, 'MONTH') AS month, SUM(price) AS sales FROM visit AS v
      JOIN dish AS d ON d.id = v.dish_id
      GROUP BY month
      ORDER BY sales #{term.upcase};"
    end
    result = @conn.exec(query)
    create_table(result, "Total sales by month")
  end

  def best_price_dish
    # query = "SELECT d.name AS dish, MIN(price) FROM restaurant AS r
    # JOIN dish AS d ON d.restaurant_id = r.id
    # GROUP BY d.name;"
    # result = @conn.exec(query)
    # create_table(result, "Best price for dish")
    query ="SELECT DISTINCT ON (d.name) d.name AS Dish, r.name AS Restaurant, d.price
    FROM dish d
    JOIN restaurant r ON r.id = d.restaurant_id
    ORDER BY d.name, d.price;"
    result = @conn.exec(query)
    create_table(result, "Dish low price by restaurant")
  end

  def favorite_dish_by_group(parameters)
    field, term = parameters.split('=')
    data = {
      "age" => "c.age",
      "gender" => "c.gender",
      "occupation" => "c.occupation",
      "nationality" => "c.nationality"
    }
    query = "SELECT #{data[field]}, d.name, COUNT(d.name) AS count FROM client AS c
    JOIN visit AS v ON c.id = v.client_id
    JOIN dish AS d ON v.dish_id = d.id WHERE #{data[field]} = '#{term.capitalize}'
    GROUP BY #{data[field]}, d.name
    ORDER BY count DESC
    LIMIT 1;"
    result = @conn.exec(query)
    create_table(result, "Favorite Dish")
  end

  def print_insight
    insight = <<~DELIMETER
    #$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#
    #$#$#$#$#$#$#$                               $#$#$#$#$#$#$#
    #$##$##$##$ ---         Insights            --- #$##$##$#$#
    #$#$#$#$#$#$#$                               $#$#$#$#$#$#$#
    #$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#
    DELIMETER
  end

  def print_welcome
    puts 'Welcome to the Restaurants Insights!'.colorize(:white).bold
    puts "Write 'menu' at any moment to print the menu again and 'quit' to exit.".colorize(:white).bold
  end

  def print_menu
    puts "---".colorize(:yellow).bold
    puts "1. List of restaurants included in the research filter by ['' | category=string | city=string]".colorize(:cyan).italic
    puts "2. List of unique dishes included in the research".colorize(:cyan).italic
    puts "3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]".colorize(:cyan).italic
    puts "4. Top 10 restaurants by the number of visitors.".colorize(:cyan).italic
    puts "5. Top 10 restaurants by the sum of sales.".colorize(:cyan).italic
    puts "6. Top 10 restaurants by the average expense of their clients.".colorize(:cyan).italic
    puts "7. The average consumer expense group by [group=[age | gender | occupation | nationality]]".colorize(:cyan).italic
    puts "8. The total sales of all the restaurants group by month [order=[asc | desc]]".colorize(:cyan).italic
    puts "9. The list of dishes and the restaurant where you can find it at a lower price.".colorize(:cyan).italic
    puts "10. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]".colorize(:cyan).italic
    puts "---".colorize(:yellow).bold
    puts "Pick a number from the list and an [option] if necessary".colorize(:white).bold
  end

  def create_table(result, title)
    table = Terminal::Table.new
    table.title = title.bold
    res = result.fields.map do |row| row.bold end
    table.headings = res
    table.rows = result.values
    table.to_s.colorize(:cyan)
  end
end

insights = Insight.new
insights.start