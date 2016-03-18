class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # подключаем Nokogiri
  require 'nokogiri'
  require 'watir-webdriver'

  #url = 'http://www.cy-pr.com/tools/browser/'
  url = 'https://www.fl.ru/projects/'
  args = %w{--ignore-ssl-errors=true}
  browser = Watir::Browser.new :phantomjs, :args => args #:firefox #
  browser.window.resize_to(1366, 768)
  #browser.driver.manage.window.maximize
  browser.goto url
  @m = browser.html
  begin
    browser.div(:class, 'b-combo').when_present.click

    # browser.link(:href, '/projects/?kind=1').click

    # vvv = browser.div(:xpath, '//*[@id="frm"]/div[1]/div[1]/div/table/tbody/tr/td[1]/div')
    # vvv.when_present.click
    vvv = browser.span()
    nE = vvv.exists?
    nV = vvv.visible?
    sleep 1
    browser.screenshot.save 'C:/screenshot.png'
    #element = browser.span(:xpath, '//*[@id="frm"]/div[1]/div[1]/div/table/tbody/tr/td[1]/div/div[2]/div/div/div/div/div/table/tbody/tr/td[1]/ul/li[4]/span')
    #Watir::Wait.until { element.visible? }
    #nn = element.visible?
    #vvv = element.click #.inner_html
    #element(:xpath, "[@text='Программирование']").click()
    #browser.span(:text, 'Программирование').click #.when_present
    # browser.link(:onclick, 'FilterCatalogAddCategoryType();').click
    # browser.button(:onclick, '$(\'frm\').submit();').click
    @m = browser.html
    n = 1
  rescue Exception => ex
    browser.close
    logger.error ex.message
  end

  # noinspection SpellCheckingInspection
  def fl
    source = 'https://www.fl.ru/projects/'
# + page
# получаем содержимое веб-страницы в объект
    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'Opera'))
    @page_class = page.class
# производим поиск по элементам с помощью css-выборки

    page.css('div.b-post').each do |link|

      @link = link.text.to_s.force_encoding('cp1251') #.to_s.force_encoding('cp1251')

      title = link.css('a').text.to_s

      href = 'https://www.fl.ru' + link.css("a").map { |a| a['href'] }[0].to_s

      price = link.css('script')[0].text
      price = clear_of_html_tags(price[price.index('(')+2..price.index(')')-2].to_s)

      body = link.css('script')[1].text
      body = clear_of_html_tags(body[body.index('(')+2..body.index(')')-2].to_s)

      create_date = link.css('script')[2].text
      create_date = clear_of_html_tags(create_date[create_date.index('(')+2..create_date.index(')')-2].to_s)


      begin
        Project.create(create_date: create_date, title: title, short_body: body, link: href, price: price)
      rescue Exception => ex
        logger.error ex.message
      end

      @link_title = title.clone.force_encoding("cp1251")
      @link_href = href.clone.force_encoding("cp1251")
      @link_price = price.clone.force_encoding("cp1251")
      @link_body = body.clone.force_encoding("cp1251")
      @link_date = create_date.clone.force_encoding("cp1251")

      break
    end
  end

  browser.close

  def clear_of_html_tags(str)
    return ActionView::Base.full_sanitizer.sanitize(str)
  end


end
