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
    begin
      browser.div(:class, 'b-combo').double_click
      # browser.link(:href, '/projects/?kind=1').click
      # element = browser.table(:xpath, '//*[@id="frm"]/div[1]/div[1]/div/table')
      browser.span(:text, filter).click #.when_present
      browser.link(:onclick, 'FilterCatalogAddCategoryType();').click
      browser.button(:onclick, '$(\'frm\').submit();').click
      browser.screenshot.save 'app/assets/images/screenshot.png'
      @url_html = browser.html.clone
      @link = browser.ul(:class, 'b-combo__list').inner_html
      @link = clear_of_html_tags(@link)#.split(/(?=[A-Z])/)

      @link_title = browser.a(:class, 'b-post__link').text
      @link_href = browser.a(:class, 'b-post__link').attribute_value 'href'
      @link_price = browser.div(:class, 'b-post__price').text
      @link_body = browser.div(:class, 'b-post__txt').text
      @link_date = browser.div(:class, 'b-post__foot').div(:class, 'b-post__txt').text

      n=1
    rescue Exception => ex
      if browser.exists? then browser.close end
      logger.error ex.message
    end
    if browser.exists? then browser.close end
  end

  def clear_of_html_tags(str)
    return ActionView::Base.full_sanitizer.sanitize(str)
  end

end
