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
    bEndFlag = false

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


    # for debug
    browser.goto 'https://www.fl.ru/projects/?page=378&kind=5'

    begin

      browser.screenshot.save 'app/assets/images/screenshot.png'

      browser.divs(:class, 'b-post').each do |project|
        # check for exists next page
        # browser.goto('https://www.fl.ru/projects/?page=379&kind=5')
        # nn=browser.li(:class, 'b-pager__next').exists?

        @url_html = browser.html.clone

        @link = browser.ul(:class, 'b-combo__list').inner_html
        @link = clear_of_html_tags(@link) #.split(/(?=[A-Z])/)

        @link_title = project.a(:class, 'b-post__link').text
        @link_href = project.a(:class, 'b-post__link').attribute_value 'href'
        @link_price = project.div(:class, 'b-post__price').text
        @link_body = project.div(:class, 'b-post__txt').text

        # '9 ответов 182 Проект 18 января, 16:19 Только для'
        # '11 ответов 1233 Вакансия (Россия, Сочи)    9 апреля 2015, 13:57  ' - берется без обработки
        date = project.div(:class, 'b-post__foot').div(:class, 'b-post__txt').text
        if date.scan('роект').size > 0 && date.scan('Только').size > 0 then
          @link_date = (date[(date.index('роект') + 'роект'.length)..date.index('Только')-1]).strip
        else
          @link_date = date
        end

        write_to_db

        # for debug
        break

      end
      # check for exists next page
      if browser.li(:class, 'b-pager__next').exists? then
        # next_href = browser.li(:class, 'b-pager__next').a(:id, 'PrevLink').attribute_value 'href'
        browser.goto(browser.li(:class, 'b-pager__next').a(:id, 'PrevLink').attribute_value 'href')
        bEndFlag = false
      else
        bEndFlag = true
      end
    end until bEndFlag
    if browser.exists? then
      browser.close
    end
    # rescue Exception => ex
    #   if browser.exists? then
    #     browser.close
    #   end
    #   logger.error ex.message
    # end
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
