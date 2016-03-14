class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # подключаем Nokogiri
  require 'nokogiri'

  # noinspection SpellCheckingInspection
  def fl
    source = 'https://www.fl.ru/projects/'
# + page
    # получаем содержимое веб-страницы в объект
    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'Opera'))
    @page_class = page.class
    # производим поиск по элементам с помощью css-выборки
    page.css('div.b-post').each do |link|

      #@link = link
      @link_title = link.css('h2 a').text
      @link_price = link.css('script').text #.scan(/document.write\('\)/)

      #data = Hash.new

      #data['title'] = link[0].text

      # data['href'] = link['href']
      #puts(data[0].to_s)
    end

    #return data

  end
end
