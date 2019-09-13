require 'curb'
require 'csv'
require_relative 'parsers'
class Executor
  attr_accessor :page, :filename

  def initialize(uri, filename)
    @page = uri
    @filename = filename
  end

  def execute
    pages_of_catalog = take_catalog
    pages_of_products = []
    products_array = []
    pages_of_catalog.each do |page|
      pages_of_products += (CatalogParser.new(page).parse)
    end
    pages_of_products.each do |page_of_product|
      products_array += ProductParser.new(Curl.get(page_of_product).body).parse
    end
    make_result(products_array)
  end

  def take_catalog
    array_of_pages = []
    tmp = Curl.get(page)
    if tmp.status[0] == '2'
      array_of_pages.append(tmp.body)
      next_page = page + '?p='
    end
    i = 2
    while 1
      tmp = Curl.get(next_page + i.to_s)
      if tmp.status[0] == '2'
        array_of_pages.append(tmp.body)
        i += 1
      else break
      end
    end
    return array_of_pages
  end

  def make_result(array_of_products)
    CSV.open(filename, 'wb', col_sep: "", quote_char: "") do |csv|
      csv << array_of_products
    end
  end
end