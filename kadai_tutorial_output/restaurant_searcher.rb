# restaurant_sercher.rb

require "net/http"
require "json"
require "csv"

# 初期設定
KEYID = "5b24526ef5b5a744"
COUNT = 100
PREF = "Z011"
FREEWORD = "渋谷駅"
FORMAT = "json"

PARAMS = {"key": KEYID, "count": COUNT, "large_area": PREF, "keyword": FREEWORD, "format": FORMAT }

def write_data_to_csv(params)
    # 取り出すレストラン情報の格納先
    restaurants = [["名称","営業日","住所","アクセス"]]
    
    # uriにHOTPEPPERサイトの接続先を指定する
    uri = URI.parse("https://webservice.recruit.co.jp/hotpepper/gourmet/v1/")
    # uriにパラメータ情報（渋谷駅周りのレストラン１００件）を設定する
    uri.query = URI.encode_www_form(params)
    # HOTPEPPERサイトへリクエストを発行する
    json_res = Net::HTTP.get(uri)

    # HOTPEPPERサイトからの検索結果（Json形式）を取得する
    response = JSON.load(json_res)
    
    # エラーのときはメッセージ出して終了
    if response == nil or response["results"].has_key?("error") then
        puts "エラーが発生しました！"
        return
    end
    # 検索結果からショップ情報ひとつずつ取り出す
    for rest in response["results"]["shop"] do
        # 必要情報をレストラン情報に格納する
        rest_info = [rest["name"], rest["open"], rest["address"], rest["access"]] 
        restaurants.append(rest_info)
    end
    
    # 取得したレストラン情報をCSV形式でファイルに書き出す
    CSV.open("restaurants_list.csv", "w") do |csv|
        restaurants.each do |rest_info|
            csv << rest_info
        end
    end
    
    return puts restaurants
end

write_data_to_csv(PARAMS)
