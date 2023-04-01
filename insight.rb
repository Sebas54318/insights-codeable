require 'pg'
require 'terminal-table'

class Insight 
  def initialize
    @conn = PG.connect(dbname: "insights")
  end

  def start
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

      when "4"
        puts top_restaurants_by_visitors
      when "5"
        puts top_restaurants_by_sales
      when "6"
        puts top_restaurants_by_avg
      when "7"

      when "8"
        puts sales_by_month(parameters)
      when "9"
        puts best_price_dish
      when "10" 
      
      when "menu"
        print_menu
      when "exit"
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
    query = "SELECT d.name AS dish, MIN(price) FROM restaurant AS r
    JOIN dish AS d ON d.restaurant_id = r.id
    GROUP BY d.name;"
    result = @conn.exec(query)
    create_table(result, "Best price for dish")
  end

  def print_welcome
    puts 'Welcome to the Restaurants Insights!'
    puts "Write 'menu' at any moment to print the menu again and 'quit' to exit."
  end

  def print_menu
    puts "---"
    puts "1. List of restaurants included in the research filter by ['' | category=string | city=string]"
    puts "2. List of unique dishes included in the research"
    puts "3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    puts "4. Top 10 restaurants by the number of visitors."
    puts "5. Top 10 restaurants by the sum of sales."
    puts "6. Top 10 restaurants by the average expense of their clients."
    puts "7. The average consumer expense group by [group=[age | gender | occupation | nationality]]"
    puts "8. The total sales of all the restaurants group by month [order=[asc | desc]]"
    puts "9. The list of dishes and the restaurant where you can find it at a lower price."
    puts "10. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]"
    puts "---"
    puts "Pick a number from the list and an [option] if necessary"
  end

  def create_table(result, title)
    table = Terminal::Table.new
    table.title = title
    table.headings = result.fields
    table.rows = result.values
    table
  end
end

insights = Insight.new
insights.start