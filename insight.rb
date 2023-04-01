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
      option, params = gets.chomp.strip.split(' ', 2)
      case option
      when "1"
        puts search_restaurants(params)
      when "2"

      when "3"

      when "4"

      when "5"

      when "6"

      when "7"

      when "8"

      when "10" 
      
      when "menu"
        print_menu
      when "quit"
        break
      else
        puts "Invalid Option"
      end
    end
  end

  private
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

  def search_restaurants(params)
    # category=country | city=city 
    if params.nil? || params.empty?
      query = "SELECT r.name, r.category, r.city FROM restaurant AS r;"
    else
      field, term = params.split("=")
  
      column_by_field = {
        "name" => "r.name",
        "category" => "r.category",
        "city" => "r.city"
      }
  
      query = "SELECT r.name, r.category, r.city
      FROM restaurant AS r
      WHERE LOWER(#{column_by_field[field]}) = '#{term.downcase.gsub("'", "''")}';"
    end
  p query
    result = @conn.exec(query)
    create_table(result, "Search Restaurants")
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