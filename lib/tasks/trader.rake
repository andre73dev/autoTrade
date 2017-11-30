namespace :trader do
  desc 'tdade worker'
  require 'zaif'
  require 'pp'
  
  #Tickerの取得
  task :getTicker => :environment do
    @api = Zaif::API.new(:api_key => Rails.application.secrets.zaif_api_key,
    :api_srcret => Rails.application.secrets.zaif_api_srcret)

    _ticker = @api.get_ticker("btc")
    
    if _ticker
      puts _ticker
      insertTicker("btc", "jpy", _ticker)
    end
  end

  task :doPlan => :environment do
    @api = Zaif::API.new(:api_key => Rails.application.secrets.zaif_api_key,
    :api_srcret => Rails.application.secrets.zaif_api_srcret)

#    _opt[:per] = 1
#    _opt[:basePrice] = 1100000 
#    _opt[:deno] = 5
    
    #買い注文の実行計画
    buyless_xPer({per: 1, basePrice: 1100000, deno: 5})
    
    #基準時刻(12:00)の買値
    
    
    #決済注文の実行計画

  end

  private
  
  # 現在の買値が基準買値金額のxパーセント以上安値なら買い注文
  # priceの最小単位は、5円単位
  def buyless_xPer(opt = {})

    _nowPrice = getTicker['bid']
    
    if (_nowPrice * (100 - opt[:per]) / 100 <= opt[:basePrice])
      
      _amount = getOneOfAsset(opt[:deno])
    
      #@api.bid("btc", price, _amount)
      #買い注文をしたつもりで資産履歴（注文）テーブルへ追加
      
      #現在の資産・デポジット・注文情報を追加
      
    end
  end
  
  #現在のTickerを取得する
  def getTicker
    return @api.get_ticker("btc")
  end
  
  #資産の何分の１かの注文量を取得
  #残高が増えない限り、指定した分母、全て注文するまで直近と同じ注文量を返す
  #注文量の最小単位は、0.0001BTC単位
  def getOneOfAsset(deno)
     #仮に21万円 実際は資産（資産情報と注文時の通貨・指値・注文量を含む）履歴テーブルから取得
    _info_last = get_info_last
    _info_now = @api.get_info
    
    if _info_now['success'] == 1
      _asset = _info_now['return']

      #はじめての注文か
      #注文時の資産残高より現在の残高が多ければ、注文量を再計算する。
      #そうでなければ直近の注文量を返す
      if _info_last == nil || (_info_last[:deposit] < _asset['deposit'])
        return _asset['deposit'] / deno #あとで切り捨てしておく　0.0001BTC単位に変換？
      else
        return _info_last[:order_amount]
      end
    end  
  end

  #自分の資産（注文）履歴の確認
  def get_info_last
    #test用
    return { deposit:210000, order_amount:40000 }

    #データがなければnilを返却 maxの更新時刻データを１行

  end

  #指値注文

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
      put 'sucdess'
    end
    
  end
  
  
  
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