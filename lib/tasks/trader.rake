namespace :trader do
  desc 'tdade worker'
  require 'zaif'
  require 'pp'
  
  #test
  task :test => :environment do
    api = Zaif::API.new(:api_key => Rails.application.secrets.zaif_api_key,
    :api_srcret => Rails.application.secrets.zaif_api_srcret)
  
    #puts "BTC/JPY : " + api.get_last_price("btc").to_s
    #puts "BTC/JPY : " + api.get_ticker("btc").to_s
    
    _ticker = api.get_ticker("btc")
    
    if _ticker
      
      puts _ticker
      
      insertTicker("btc", "jpy", _ticker)
    end
  end
  
  
  private
  
  def insertTicker( code, counter_code, data)
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
    
    _ticker.save
    
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
  
  
  
=end
  
  
end