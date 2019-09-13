require 'nokogiri'

class BaseParser
  attr_accessor :str

  def initialize(input_str)
    @str = input_str
  end

  def parse
    return str
  end
end

class CatalogParser < BaseParser
  def initialize(input_str)
    super(input_str)
  end

  def parse
    page = Nokogiri::HTML(str)
    list_of_products = []
    page.xpath('//a[@class="product_img_link product-list-category-img"]').each do |tmp|
      list_of_products.append(tmp.attribute('href'))
    end
    return list_of_products
  end
end

class ProductParser < BaseParser
  def initialize(input_str)
    super(input_str)
  end

  def parse
    page = Nokogiri::HTML(str)
    name_of_product = page.xpath('//h1').text
    image = page.xpath('//img[@id="bigpic"]').attribute('src').text
    count = 0
    result_array = []
    page.xpath('//span[@class="radio_label"]').each do |unit|
      price = page.xpath('//span[@class="price_comb"]')[count]
      final_name = name_of_product + ' - ' + unit.text
      result_array.append([final_name, price.text, image].to_csv)
      count += 1
    end
    return result_array
  end
end