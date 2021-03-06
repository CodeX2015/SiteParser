class ParserController < ApplicationController
  # для получения контента через http
  require 'open-uri'

  # для управления headless браузером phantomjs
  require 'watir-webdriver'

  # для работы с русским названиями месяцев
  require 'russian'

  # для многопоточной работы
  require 'parallel'

  @@semaphore = Mutex.new

  # noinspection SpellCheckingInspection
  def fl
    # test_func
    # Thread.new { parallel_work }
    @test_day = Russian::strftime(Time.now, "%d %B")

    # Thread.new { parse_freelance_ru }
    # Thread.new { parse_weblancer_net }
    return
    parse_freelance_ru
    parse_freelansim_ru
    parse_weblancer_net
    parse_fl_ru
    @test_day = Russian::strftime(Time.now, "%d %B")
    t.join
    # redirect_to :back
  end

  def get_json_data
    user = 'parse-robot'
    password = 'qazQAZqwe123'
    # initiate config
    # config = Upwork::Api::Config.new({
    consumer_key =	'9440740657a1a068f012f4f0c5e5231b'
    consumer_secret =	'3ecbba180b78770e'

    # https://github.com/upwork/ruby-upwork/blob/master/example/myapp.rb

    # 'access_token'    => 'xxxxxxxx',# assign if known
    # 'access_secret'   => 'xxxxxxxx',# assign if known
    # 'debug'           => false
    # })
    url = "https://api.github.com"
    JSON.load(open(url))
  end

  def test_func
    # '11 ответов 1233 Конскурс (Россия, Сочи)    9 апреля 2015, 13:57  ' - берется без обработки
    # Проект   Только что   Только для
    date = '11 ответов 1233 Конскурс (Россия, Сочи)   Только что   Только для'
    @link_date = (date[(date.index(')') + 1)..date.rindex('Только')-1]).strip
    nnnm = 1
  end

  def parallel_work
    start_time = Time.now

    # 3 Processes -> finished after 1 run
    #     results = Parallel.map(['a','b','c'], in_processes: 3) { |one_letter| ... }
    # 3 Threads -> finished after 1 run
    #     results = Parallel.map(['a','b','c'], in_threads: 3) { |one_letter| ... }

    Parallel.each([1, 2], in_threads: 2) { |method|
      case method
        when 1
          logger.info 'start parse_freelance_ru'
          parse_freelance_ru
        when 2
          logger.info 'start parse_weblancer_net'
          parse_weblancer_net
        else
          logger.info 'case else'
      end

    }

    # old school
    # t1 = Thread.new { parse_freelance_ru }
    # t2 = Thread.new { parse_weblancer_net }
    # t1.join
    # t2.join

    end_time = Time.now
    delta = end_time - start_time
    logger.info 'Time: ' + delta.to_s + ' s'
  end

  def parse_freelance_ru
    Thread.current[:name] = 'parse_freelance_ru'
    url = 'https://freelance.ru/projects/'
    filter = '?spec=4'
    parse_results = []
    args = %w{--ignore-ssl-errors=true}
    browser = Watir::Browser.new :phantomjs, :args => args #:firefox #
    browser.window.resize_to(1366, 768)
    browser.goto url + filter

    browser.screenshot.save 'app/assets/images/screenshot_freelance.png'
    i = 0
    browser.div(:class, 'projects').divs(:class, 'proj').each do |project|
      @link = project.inner_html
      @next_page = browser.a(:title, 'на следующую страницу').attribute_value 'href'
      @link_date = project.li(:class, 'proj-inf pdata pull-left').text
      @link_title = project.a(:class, 'ptitle').text
      @link_body = project.a(:class, 'descr').spans[1].text
      @link_href = project.a(:class, 'ptitle').attribute_value 'href'
      @link_price = project.span(:class, 'cost').text

      logger.info Thread.current[:name].to_s + ' - ' + i.to_s
      parse_results << ParseResult.new(@link_date, @link_title, @link_body, @link_href, @link_price)


      i+=1
      if i == 10
        break
      end
    end

    if browser.exists? then
      browser.close
    end
    write_to_db(parse_results)
  end

  def parse_freelansim_ru
    url = 'http://freelansim.ru/tasks'
    filter = '?categories=web_all_inclusive,web_design,web_html,web_programming,web_prototyping,web_test,web_other,mobile_ios,mobile_android,mobile_wp,mobile_bada,mobile_blackberry,mobile_design,mobile_programming,mobile_prototyping,mobile_test,mobile_other,app_all_inclusive,app_scripts,app_bots,app_plugins,app_utilites,app_design,app_programming,app_prototyping,app_1c_dev,app_test,app_other'
    args = %w{--ignore-ssl-errors=true}
    browser = Watir::Browser.new :phantomjs, :args => args #:firefox #
    browser.window.resize_to(1366, 768)
    browser.goto url + filter

    browser.screenshot.save 'app/assets/images/screenshot_freelansim.png'
    browser.lis(:class, 'content-list__item').each do |project|
      @link = project.inner_html
      @next_page = browser.a(:class, 'next_page').attribute_value 'href'
      @link_date = project.span(:class, 'params__published-at icon_task_publish_at').text
      @link_title = project.div(:class, 'task__title').text
      # @link_body = project.a(:class, 'text-muted').text
      @link_href = project.div(:class, 'task__title').a.attribute_value 'href'
      @link_price = project.div(:class, 'task__price').text

      break
    end

    if browser.exists? then
      browser.close
    end
  end

  def parse_weblancer_net
    Thread.current[:name] = 'parse_weblancer_net'
    url = 'https://www.weblancer.net/projects/'
    filter = '?category_id=2'
    bEndFlag = false
    fail_date_count = 0

    args = %w{--ignore-ssl-errors=true}
    browser = Watir::Browser.new :phantomjs, :args => args #:firefox #
    browser.window.resize_to(1366, 768)
    browser.goto url + filter

    browser.screenshot.save 'app/assets/images/screenshot_weblancer.png'
    parse_results = []
    i = 0
    browser.div(:class, 'cols_table').divs(:class, 'row').each do |project|

      @link = project.inner_html
      @next_page = browser.a(:text, 'Следующая').attribute_value 'href'
      @link_date = project.span(:class, 'time_ago').text
      @link_title = project.a(:class, 'title').text
      @link_body = project.a(:class, 'text-muted').text
      @link_body_href = project.a(:class, 'text-muted').attribute_value 'href'
      @link_href = project.a(:class, 'title').attribute_value 'href'
      if project.div(:class, 'col-sm-2').text == ''
        @link_price = 'по договоренности'
      else
        @link_price = project.div(:class, 'col-sm-2').text
      end

      logger.info Thread.current[:name].to_s + ' - ' + i.to_s


      parse_results << ParseResult.new(@link_date, @link_title, @link_body, @link_href, @link_price)

      i+=1
      if i == 10
        break
      end
    end

    if browser.exists? then
      browser.close
    end
    write_to_db(parse_results)
  end


  def parse_fl_ru
    # @url = 'public/index.html'
    @url = 'https://www.fl.ru/projects/'

    filter = 'Программирование'
    bEndFlag = false
    fail_date_count = 0

    #@test_day = Date.today.strftime('%B')
    #@test_day = Russian::strftime(Time.now, "%d %B")
    # str_test = '24 марта, 20:18'
    # @test_day = (str_test.split(' ')[0]).to_s + ' ' + (str_test.split(' ')[1]).to_s +
    #     ' = ' + Date.today.strftime('%d').to_s + ' ' + Russian::strftime(Time.now, "%B").mb_chars.downcase.to_s
    # return

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
    #browser.goto 'https://www.fl.ru/projects/?page=378&kind=5'

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
        # '11 ответов 1233 Конскурс (Россия, Сочи)    9 апреля 2015, 13:57  ' - берется без обработки
        # Проект   Только что   Только для
        date = project.div(:class, 'b-post__foot').div(:class, 'b-post__txt').text
        if date.scan('роект').size > 0
          if date.scan('Только').size > 0 then
            @link_date = (date[(date.index('роект') + 'роект'.length)..date.rindex('Только')-1]).strip
          else
            @link_date = (date[(date.index('роект') + 'роект'.length)..0]).strip
          end
        elsif date.scan('акансия').size > 0
          if date.scan('Только').size > 0 then
            @link_date = (date[(date.index('акансия') + 'акансия'.length)..date.rindex('Только')-1]).strip
          else
            @link_date = (date[(date.index('акансия') + 'акансия'.length)..0]).strip
          end
        elsif date.scan('онкурс').size > 0
          if date.scan('Только').size > 0 then
            @link_date = (date[(date.index('онкурс') + 'онкурс'.length)..date.rindex('Только')-1]).strip
          else
            @link_date = (date[(date.index('онкурс') + 'онкурс'.length)..0]).strip
          end
        else
          @link_date = date
          write_to_db
        end

        if check_date_of_project(@link_date) or project.h2(:class, 'b-post__pin').exists?
          write_to_db
          fail_date_count = 0
        else
          fail_date_count += 1
        end

        # for debug
        # break

      end

      # check for exists next page
      next_page = browser.li(:class, 'b-pager__next')
      if next_page.exists? and fail_date_count < 3
        next_href = browser.li(:class, 'b-pager__next').a(:id, 'PrevLink').attribute_value 'href'
        browser.goto(next_href)
        # bEndFlag = true
        bEndFlag = false
      else
        bEndFlag = true
      end
    end until bEndFlag
    if browser.exists? then
      browser.close
    end
    # redirect_to :back
    # rescue Exception => ex
    #   if browser.exists? then
    #     browser.close
    #   end
    #   logger.error ex.message
    # end
  end

  def check_date_of_project(project_date)
    # code here
    current_day = Date.today.strftime('%d').to_i
    current_month_name_ru = Russian::strftime(Time.now, '%B').mb_chars.downcase.to_s

    if project_date.scan('минут').size > 0
      return true
    elsif project_date.scan(current_month_name_ru).size > 0
      if project_date.split(' ')[0].to_i >= current_day - 1 and project_date.split(' ')[0].to_i <= current_day
        return true
      else
        return false
      end
    else
      return false
    end
  end

  private
  def write_to_db(parse_results)
    logger.debug 'Current thread before is: ' + Thread.current[:name]
    @@semaphore.synchronize {
      begin
        logger.debug 'Current thread after is: ' + Thread.current[:name]
        parse_results.each do |project|
          Project.create(create_date: project.create_date, title: project.title,
                         short_body: project.short_body, link: project.link, price: project.price)
        end
      rescue Exception => ex
        logger.error ex.message
      end
    }
  end

  def clear_of_html_tags(str)
    return ActionView::Base.full_sanitizer.sanitize(str)
  end

  class ParseResult
    def initialize(create_date, title, short_body, link, price)
      # Instance variables
      @create_date = create_date
      @title = title
      @short_body = short_body
      @link = link
      @price = price
    end

    attr_accessor :create_date
    attr_accessor :title
    attr_accessor :short_body
    attr_accessor :link
    attr_accessor :price

  end

end
