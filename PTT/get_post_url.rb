
def get_post_url
  table = CSV.parse(File.read("./hot_boards_url.csv"), headers: false)
  pre_url = "https://www.ptt.cc"
  post_url_all = []

  table.each do |t|
    sleep(rand(0.5..1.2))
    # 下一頁的url
    next_url = t[0]
    p "page   #{next_url}"
    # 測試先設定每個熱門版抓1頁
    post_url = []
    1.times {
      begin 
        sleep(rand(0.5..1.2))
        doc = Nokogiri::HTML(open(next_url,'Cookie' => 'over18=1'))
        num = doc.search("#main-container .r-list-container .r-ent").size
        p num
        (0...num).each { |i|
          post_url << [doc.css("#main-container .r-list-container .r-ent .meta .date")[i].text,doc.css("#main-container .r-list-container .r-ent .meta .author")[i].text, 
          pre_url + doc.css("#main-container .r-list-container .r-ent .title a")[i]["href"]
          ]
        }
        next_url = pre_url + doc.css("#main-container .btn-group .wide:nth-child(2)")[0]["href"]
        p "next   #{next_url}"
      rescue 
        p "error"
      end 
    }
    # 塞進這一個版所抓的資料
    post_url_all << post_url
  end 
  
  File.write("post_url.csv", post_url_all.flatten(1).map(&:to_csv).join)
end 
