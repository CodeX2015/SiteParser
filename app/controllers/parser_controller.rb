class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # подключаем Nokogiri
  require 'nokogiri'

  # подключаем iconv
  # require 'iconv'

  # noinspection SpellCheckingInspection
  def fl
    source = 'https://www.fl.ru/projects/'
# + page
# получаем содержимое веб-страницы в объект
    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'Opera'))
    #@page_class = page.class
# производим поиск по элементам с помощью css-выборки

    page.css('div.b-post').each do |link|

     #@link = link.text.to_s.force_encoding('cp1251') #.to_s.force_encoding('cp1251')
      @link_title = link.css('a').text.to_s.force_encoding("cp1251")
      @link_href = 'https://www.fl.ru' + link.css("a").map { |a| a['href'] }[0].to_s.force_encoding("cp1251")
      price = link.css('script')[0].text
      price = price[price.index('(')+2..price.index(')')-2]
      body = link.css('script')[1].text
      body = body[body.index('(')+2..body.index(')')-2]
      @link_price = ActionView::Base.full_sanitizer.sanitize(price).to_s.force_encoding("cp1251")
      @link_body = ActionView::Base.full_sanitizer.sanitize(body).to_s.force_encoding("cp1251")
      create_date = link.css('script')[2].text
      create_date = create_date[create_date.index('(')+2..create_date.index(')')-2]

      @link_date = ActionView::Base.full_sanitizer.sanitize(create_date).to_s.force_encoding("cp1251")

      Project.create(title: @link_title.force_encoding("cp1251"))


      break


      #data = Hash.new

      #data['title'] = link[0].text

      # data['href'] = link['href']
      #puts(data[0].to_s)
    end

    #return data

  end
end
