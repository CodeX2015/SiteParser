class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # подключаем Nokogiri
  require 'nokogiri'

  # noinspection SpellCheckingInspection
  def yandex
    source = 'https://www.fl.ru/projects/'
# + page
    # получаем содержимое веб-страницы в объект
    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'Opera'))
    # производим поиск по элементам с помощью css-выборки
    page.css('a.b-post__link').each do |link|

      data = Hash.new

      data['text'] = link.content

      data['href'] = link['href']
      puts('')
    end

    return data

  end
end
