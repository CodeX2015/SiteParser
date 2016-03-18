class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # подключаем Watir
  require 'watir-webdriver'

  # noinspection SpellCheckingInspection
  def fl
    # @url = 'public/index.html'
    @url = 'https://www.fl.ru/projects/'

    filter = 'Программирование'

    args = %w{--ignore-ssl-errors=true}
    browser = Watir::Browser.new :phantomjs, :args => args #:firefox #
    browser.window.resize_to(1366, 768)
    #browser.window.maximize
    browser.goto @url
    # begin

    # Set and apply filter form
    browser.div(:class, 'b-combo').double_click
    # browser.link(:href, '/projects/?kind=1').click
    # element = browser.table(:xpath, '//*[@id="frm"]/div[1]/div[1]/div/table')
    browser.span(:text, filter).click
    browser.link(:onclick, 'FilterCatalogAddCategoryType();').click
    browser.button(:onclick, '$(\'frm\').submit();').click

    browser.divs(:class, 'b-post').each do |project|
      # check for exists next page
      # browser.goto('https://www.fl.ru/projects/?page=379&kind=5')
      # nn=browser.li(:class, 'b-pager__next').exists?

      mm = project.html
      browser.screenshot.save 'app/assets/images/screenshot.png'
      @url_html = browser.html.clone

      @link = browser.ul(:class, 'b-combo__list').inner_html
      @link = clear_of_html_tags(@link) #.split(/(?=[A-Z])/)

      @link_title = project.a(:class, 'b-post__link').text
      @link_href = project.a(:class, 'b-post__link').attribute_value 'href'
      @link_price = project.div(:class, 'b-post__price').text
      @link_body = project.div(:class, 'b-post__txt').text

      # string = '9 ответов 182 Проект 18 января, 16:19 Только для'
      # '11 ответов 1233 Вакансия (Россия, Сочи)    9 апреля 2015, 13:57  '
      date = project.div(:class, 'b-post__foot').div(:class, 'b-post__txt').text
      if date.scan('роект').size > 0 && date.scan('Только').size > 0 then
        @link_date = (date[(date.index('роект') + 'роект'.length)..date.index('Только')-1]).strip
      else
        @link_date = date
      end

      write_to_db
      #break
      n=1
    end
    # rescue Exception => ex
    #   if browser.exists? then
    #     browser.close
    #   end
    #   logger.error ex.message
    # end
    if browser.exists? then
      browser.close
    end
  end

  def write_to_db
    begin
      Project.create(create_date: @link_date, title: @link_title, short_body: @link_body, link: @link_href, price: @link_price)
    rescue Exception => ex
      logger.error ex.message
    end
  end

  def clear_of_html_tags(str)
    return ActionView::Base.full_sanitizer.sanitize(str)
  end

end
