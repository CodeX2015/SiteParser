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
    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'Opera', 'Accept-Charset' => 'Windows-1251'))
    @page_class = page.class
# производим поиск по элементам с помощью css-выборки

    page.css('div.b-post').each do |link|

      @link = link.to_s.force_encoding('cp1251') #.to_s.force_encoding('cp1251')
      @link_title = link.css('a').text.to_s.force_encoding("cp1251")
      @link_href = 'https://www.fl.ru' + link.css("a").map { |a| a['href'] }[0].to_s.force_encoding("cp1251")
      #@link_price = link.css('div').text.to_s.force_encoding('cp1251')

      @ssss = link.css('script')[0].text.to_s.force_encoding("cp1251") #.split(';')
      @link_price = @ssss[@ssss.index('">')+2..@ssss.index('</')-2]

      #@ssss.index('">')

      #@ssss[@ssss.index('(') + 2.. @ssss.index(')')-2]
      break


      #data = Hash.new

      #data['title'] = link[0].text

      # data['href'] = link['href']
      #puts(data[0].to_s)
    end

    #return data

  end
end
