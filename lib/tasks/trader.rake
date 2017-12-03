namespace :trader do
  desc 'tdade worker'
  require 'pp'
  require 'bigdecimal'
  require 'tradeApi'
  #require 'time'
  #require 'date'
  
  #Tickerの取得
  task :getTicker => :environment do
    @api = TradeApi::API.new(exhange:'Zaif')
    @api.get_Ticker(currency_code:"btc")
  end

  #Tickerの取得
  task :setTicker => :environment do
    @api = TradeApi::API.new(exhange:'Zaif')
    @api.set_Ticker(currency_code:"btc")
  end


  task :test => :environment do
    #t = Time.zone.today
    #t1 = Time.local(t.year,t.month,t.day,15,18,0,0)
    #p t1
    @api = TradeApi::API.new(exhange:'Zaif')

    _opt2 = {}
    _opt2[:currency_pair] = 'btc_jpy'
    _opt2[:per] = 1 #％超で

    #売り注文の実行計画
    ask_doPlan(_opt2)

  end  

  task :doPlan => :environment do
    @api = TradeApi::API.new(exhange:'Zaif')

    #基準時間の設定
    t = Time.zone.today
    _basetime = Time.local(t.year,t.month,t.day,11,49,0,0)

    #基準時間のティッカー情報を取得
    _ticker = @api.get_Ticker(timestamps: _basetime)

    if ((_ticker.present?) && (_ticker.length > 0))
      _opt = {}
      _opt[:currency_pair] = 'btc_jpy'
      _opt[:per] = 1 #％以下で
      _opt[:basePrice] =_ticker[0]['bid'].to_f  #基準時間の買値
      _opt[:fund_per] = 20 #資産の投資率 20%

      p _opt 
      #買い注文の実行計画
      bid_doPlan(_opt)

      _opt2 = {}
      _opt2[:currency_pair] = 'btc_jpy'
      _opt2[:per] = 1 #％超で

      #売り注文の実行計画
      ask_doPlan(_opt2)
      
    else
      p 'No Data Ticker'
    end
  end

  private

  # 現在の買値が基準買値金額のxパーセント以上安値なら買い注文
  # priceの最小単位は、5円単位
  def bid_doPlan(opt = {})

    _nowTicker = @api.get_Ticker(currency_code:'btc')

    if _nowTicker
      _nowPrice = _nowTicker['bid']
      
      p '_nowPrice ' + _nowPrice.to_s
      
      p 'xper ' + (_nowPrice * (100 - opt[:per]) / 100).to_s
      p 'baseprice ' + opt[:basePrice].to_s
  
#      if ((_nowPrice * (100 - opt[:per]) / 100) <= opt[:basePrice])
      if true  
        _info_now = @api.get_info
        _amount = getOneOfAsset(_info_now['deposit'], opt[:fund_per])
        #残り資産より注文数量が少ない場合にのみ買い注文
        if _amount < _info_now['funds']  
          #数量は、４万円、注文時はBTCなので４万を換算する必要あり

          #注文量の最小単位は、0.0001BTC単位
          _amount = BigDecimal((_amount/_nowPrice).to_s).floor(4)

          @api.bid(currency_pair: opt[:currency_pair], price: _nowPrice, amount: _amount)
        else
          p "limit over!"
        end  
      end
    else
      p 'No Data Ticker'
    end
  end
  
  # 現在の売値が買値のxパーセント超高値なら売り注文
  # priceの最小単位は、5円単位
  def ask_doPlan(opt = {})

    _nowTicker = @api.get_Ticker(currency_code:'btc')

    if _nowTicker
      _nowPrice = _nowTicker['ask']
      
      p '_nowPrice ' + _nowPrice.to_s
      p 'xper ' + (_nowPrice * (100 - opt[:per]) / 100).to_s

      _active_orders = @api.get_active_orders(opt)
      
      if _active_orders
      
        _active_orders.each do |_order|
          p _order
          p 'bid_price ' + _order[1]['price'].to_s
      
          #現在の売値が買値から指定した％増しの金額より大きいなら売り注文
          if (_order[1]['price'] * (100 + opt[:per]) / 100) < _nowPrice  
            @api.ask(currency_pair:'btc_jpy', price: _nowPrice, amount: _order[1]['amount'])
          else
            p "no ask"
          end  
        end
      else
        p "no orders"
      end  
    else
      p 'No Data Ticker'
    end
  end

  #買い注文の全削除（検証用）
  
  #資産の何%の注文量を取得
  def getOneOfAsset(deposit, per)

      order_amount = deposit * per / 100
      order_amount = BigDecimal(order_amount.to_s).floor(0) #小数点以下切り捨て
      p 'order_amount ' + order_amount.to_s
      return order_amount

    #仮に21万円 実際は資産（資産情報と注文時の通貨・指値・注文量を含む）履歴テーブルから取得
    #_info = @api.get_info
    #p _info_now
    #はじめての注文か
    #注文時の資産残高より現在の残高が多ければ、注文量を再計算する。
    #そうでなければ直近の注文量を返す
    
    #p "_info_last[:deposit]" + _info[:deposit].to_s  
    #p "_info_now['deposit']['jpy']" + _info_now['deposit']['jpy'].to_s  
    
    #if ((_info == nil) || (_info_last[:deposit] < _info_now['deposit']['jpy']))
    #else
    #  return _info_last[:order_amount]
    #end

  end

  #自分の資産（注文）履歴の確認
  #def get_info_last
    #test用
    #return { deposit:190000, order_amount:50000 }

    #データがなければnilを返却 maxの更新時刻データを１行

  #end

  #指値注文

  
  
  
  #現在のBitcoinの買値を取得する（タスクで時間指定仮に１時間ごとなら24回/day）

  #現在のBitcoinの売値を取得する

  #Bitcoinを買い注文する
  #日本円で１回につきどれだけ投資するか設定する

  #Bitcoinを売り注文する
  #可能な限り全額売り注文する

  #いくらで買うかを設定する
  #いくらで売るかを設定する（成行も有り）
  
=begin
　売買ルール１

　１日のある時間の買値から５％下がれば買い
　買った金額を記憶する
　買いのタイミングは１時間間隔

　記憶した金額から５％売値が上昇したら全額成行注文

　１日の初めに記憶した金額から１０％上がったら買わない。

　１日の初めに記憶した金額から２回（はじめから１５％）下がれば、買いを停止

  もっとも初めに記憶した金額から２０％下がれば、買いを停止。
  
  売りは継続（ほぼリアルタイム、５分おき等）
  
  
doPlan
売買ルール2

注文間隔
一時間一回、基準時刻の買値から1%以上
低い場合に注文

決済条件
随時、仮に10分間隔。買値から1%以上なら決済待ち。一時間以内に決済

再投資基準
注文中のオーダを含めて10注文
残金を未注文のオーダ数で割った金額を一回の投資金額とする
計算はオーダ前に行う

  
=end
  
  
end