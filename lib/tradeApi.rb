# Copyright (C) 2017 andre73.dev@gmail.com
# MIT License
#
require 'zaif'
require 'pp'
require 'json'

module TradeApi
  class API
    def initialize (opt = {})
      @test = true #テストモードかどうか
      
      @exhange = opt[:exhange] 
      #@private = opt[:private] || true 

      if @exhange == 'Zaif'
        #if @private
          @api = Zaif::API.new(
            api_key: Rails.application.secrets.zaif_api_key,
            api_secret: Rails.application.secrets.zaif_secret_key
          )
        #else    
        #  @api = Zaif::API.new
        #end  
      else  
        return 'nothing!'
      end
    end

    #ティッカー情報の取得
    def get_Ticker(opt = {})
      if opt[:timestamps]
        #引数の時刻と分単位で同一のティッカー情報を返す 指定時刻から60秒
        #取引所の条件が必要 <todo>
        return Ticker.where(created_at: (opt[:timestamps])..(opt[:timestamps].since(59))).order('created_at ASC')
      else
        if @exhange == 'Zaif'
          #現在のティッカー情報を返す
          p opt[:currency_code]
          
          _ticker =  @api.get_ticker(opt[:currency_code])

          if _ticker
            p _ticker
            #insertTicker("btc", "jpy", _ticker)
            return _ticker
          end

        else  
          p 'exhange nothing!'
        end
      end
    end

    #ティッカー情報の追加
    def set_Ticker(opt = {})
      _ticker = get_Ticker(opt)
      
      if _ticker
        insertTicker("btc", "jpy", _ticker)
        #return _ticker
      else
        p 'no tickers'
      end
    end  
    
    #資産履歴の確認
    def get_info
      #if opt[:history] && opt[:history] == 'last'
      #  #test用 テーブルから直近の資産履歴を返す

      if @test
        _fund = Fund.order(:created_at).last
        
        if _fund
          return _fund
        else
          #初回テストデータ
          _ret = {}
          _ret['currency_code'] = 'jpy'
          _ret['funds'] = 1000000
          _ret['deposit'] = 1000000
          
          return _ret
        end
      else
        if @exhange == 'Zaif'
          _fund = @api.get_info
          
          p _fund
          _ret = {}
          _ret['currency_code'] = 'jpy'
          _ret['funds'] = _fund['funds']['jpy']
          _ret['deposit'] = _fund['deposit']['jpy']
          
          return _ret
        else  
          p 'exhange nothing!'
        end      
      end
    end
    
    #有効な注文一覧の取得
    
    #シンボルにあとで変更する <todo>
    def get_active_orders(opt = {})
      if !@test
        _orders = Order.order(:created_at).last
        
        if _orders
          return _orders
        else
          return nil
        end
      else
        if @exhange == 'Zaif'
          _orders = @api.get_active_orders(opt)
          
          p _orders
          #_ret = {}
          #_ret['currency_code'] = 'jpy'
          #_ret['funds'] = _fund['funds']['jpy']
          #_ret['deposit'] = _fund['deposit']['jpy']
          
          return _orders
        else  
          p 'exhange nothing!'
        end      
      end
    end    
    
    #買い注文
    def bid(opt = {})
      
      p 'opt[:currency_pair] ' + opt[:currency_pair]
      p 'opt[:price] ' + opt[:price].to_s
      p 'opt[:amount] ' + opt[:amount].to_s

      if !@test
        #本番  
        #@api.bid(currency_pair, price, amount)
        p '本番買い'
      else  
        #注文履歴テーブルへ追加（テスト用）
        insertOrder(opt[:currency_pair], 'bid', opt[:price], opt[:amount])
    
        #資産履歴テーブルへ追加（テスト用）
        insertFund('jpy', opt[:price], opt[:amount])
      end
    end
    #売り注文
    def ask(opt = {})

      p 'opt[:currency_pair] ' + opt[:currency_pair]
      p 'opt[:price] ' + opt[:price].to_s
      p 'opt[:amount] ' + opt[:amount].to_s

      if !@test
        #本番  
        #@api.ask(currency_pair, price, amount)
        p '本番売り'
      else  
        #注文履歴テーブルへ追加（テスト用）
        insertOrder(opt[:currency_pair], 'ask', opt[:price], opt[:amount])
    
        #資産履歴テーブルへ追加（テスト用） 売り用の追加ロジック必要 <todo>
        #insertFund('jpy', opt[:price], opt[:amount])
      end

    end    
    
    private 
    
    #Tickerテーブルに追加
    def insertTicker(code, counter_code, data)
      _ticker = Ticker.new
      
      _ticker.cur_code = code
      _ticker.ctr_cur_code = counter_code
      _ticker.last = data['last']
      _ticker.high = data['high']
      _ticker.low = data['low']
      _ticker.vwap = data['vwap']
      _ticker.volume = data['volume']
      _ticker.bid = data['bid']
      _ticker.ask = data['ask']
      
      if _ticker.save
        p 'success'
      end
      
    end
    
    #Orderテーブルに追加
    def insertOrder(currency_pair, action, price, amount)
      
      _order = Order.new
      _order.order_id = DateTime.now.strftime("%y%m%d%H%M")
      _order.currency_pair = currency_pair
      _order.action = action
      _order.amount = amount
      _order.price = price
      _order.fee = 0 #あとで計算
      _order.your_action = '' # 意味がわかったら追加
      _order.bonus = 0 #あれば計算
      
      if _order.save
        p 'success'
      end
    end

    #fundテーブルに追加
    def insertFund(currency_code, price ,amount)
      
      #１番最後に生成された資産レコードの情報を取得する
      #_nowFund = Fund.order(:created_at).last
      _nowFund = get_info
      
      #fundテーブルへ追加
      _fund = Fund.new
  
      if _nowFund.present?
        _fund.currency_code = currency_code
        _fund.funds = _nowFund['funds'] - (BigDecimal((price * amount).to_s).floor(0))
        _fund.deposit = _nowFund['deposit']
      else
        #テストデータ
        _fund.currency_code = 'jpy'
        _fund.funds = 200000 - (price * amount)
        _fund.deposit = 200000
      end
  
      if _fund.save
        p 'sucdess'
      end
    end
  end


end