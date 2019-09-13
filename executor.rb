require 'rubygems'
require 'curb'
require 'csv'
require_relative 'parsers'

class Executor
  attr_accessor :uri, :filename

  def initialize(uri, filename)
    @uri = uri
    @filename = filename
  end

  def execute
    puts "getting catalog pages"
    pages_of_catalog = take_catalog
    pages_of_products = []
    products_array = []
    puts "parse catalog to retrieve product pages"
    pages_of_catalog.each do |page|
      pages_of_products += (CatalogParser.new(page).parse)
    end
    puts "parse product pages to retrieve information about each product"
    pages_of_products.each do |page_of_product|
      products_array += ProductParser.new(Curl.get(page_of_product).body).parse
    end
    puts "save result of parsing to file"
    save_result_to_file(products_array)
  end

  def take_catalog
    array_of_pages = []
    begin
      puts "getting first page of catalog"
      page = get_page(uri)
      if page.is_a?(String)
        array_of_pages.append(page)
      end
      i = 1
      next_page = uri + '?p='
      while 1
        i +=1
        page = get_page(next_page + i.to_s)
        if page.is_a?(String)
          array_of_pages.append(page)
          puts "getting #{i} page of catalog"
        else break
        end
      end
    rescue => e
      puts e.message
    end
    return array_of_pages
  end

  def get_page(url)
    page = Curl.get(url)
    case page.status[0]
    when '2'
      return page.body
    when '3'
      return page
    when '4'
      raise "#{page.status} ERROR"
    when '5'
      raise "#{page.status} ERROR"
    end
  end

  def save_result_to_file(array_of_products)
    CSV.open(filename, 'wb', col_sep: "", quote_char: "") do |csv|
      csv << array_of_products
    end
  end
end