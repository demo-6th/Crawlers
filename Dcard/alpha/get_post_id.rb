# 二、每個forum的post_id_url一次只能顯示30筆post_id，所以要抓三十筆裡面最後一個id再往url加上before繼續往下抓，抓到沒有下一頁才停

def get_post_id
  # 抓文章的id,標題,看板名稱,英文版名,更新時間,回文數量

  all_forums = CSV.parse(File.read("forums.csv"), headers: false)

  #比對用post資料
  cp_id = []
  cp_updatedAt = []
  cp_commentCount = []
 if File.exist?("cp_post_id.csv")
   cp_post_id = CSV.parse(File.read("cp_post_id.csv"), headers: false)
   cp_post_id.each do |id|
     cp_id << id.first 
   end
   cp_post_id.each do |time|
     cp_updatedAt << time[4][0..9]+" "+time[4][11..18]
   end
   cp_post_id.each do |count|
     cp_commentCount << [count[0], count[5]] 
   end
 end
 
  #比對用post資料

  # 先試1個版而已～
  forums = all_forums[458...459]
  forums.each do |forum| 
    p "=============#{forum[0]}============" 
    post_url = forum[2]
    post_uri = URI(post_url)
    post_data = Net::HTTP.get(post_uri)
    post_items = JSON.parse(post_data)
    forum_post_id = [] #本文需爬蟲的文章
    forum_post_comment = [] #回文需爬蟲的文章
    cp_post = []
    all_cp_post = []
    count = 0
    last_id = 0

    post_items.each do |post_item| #開始比對文章id
    count += 1 #post計數
    p new_post_id = post_item["id"] #取出文章id
    p new_post_updatedAt = post_item["updatedAt"][0..9] + " " + post_item["updatedAt"][11..18]#取出文章更新時間
    p new_post_commentCount = [post_item["id"].to_s,post_item["commentCount"].to_s]#取出文章id和回文數
      if cp_id.include?(new_post_id.to_s) #比對文章id是否有在資料庫中
          if cp_updatedAt.include?(new_post_updatedAt)#資料庫有id再比對更新時間
            if cp_commentCount.include?(new_post_commentCount)#比對id與回文數
              puts "此文已爬，無修改，沒新回文"
              cp_post << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            else
              puts "此文已爬，無修改，有新回文"
              forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            end
          else 
            if cp_commentCount.include?(new_post_commentCount)
              puts "此文已爬，有修改，沒新回文"
              forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            else
              puts "此文已爬，有修改，有新回文"        
              forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
              forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            end
          end
      else     
        puts "全新未爬文章"
        forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
        forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
      end
      p count, "第一頁"
      if count == 30 
        last_id = post_item["id"]
        count = 0
      end
    end
     while true
       post_url = "#{forum[2]}&before=#{last_id}" 
       post_uri = URI(post_url)
       post_data = Net::HTTP.get(post_uri)
       post_items = JSON.parse(post_data)

      if post_items.size < 30 
         post_items.each do |post_item|
         new_post_id = post_item["id"] 
         new_post_updatedAt = post_item["updatedAt"][0..9] + " " + post_item["updatedAt"][11..18]
         new_post_commentCount = [post_item["id"].to_s,post_item["commentCount"].to_s]
          sleep(0.5)
          p "最後一頁"
          if cp_id.include?(new_post_id.to_s) 
              if cp_updatedAt.include?(new_post_updatedAt)
                   if cp_commentCount.include?(new_post_commentCount)
                     puts "此文已爬，無修改，沒新回文"
                     cp_post << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                   else
                     puts "此文已爬，無修改，有新回文"
                     forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                   end
              else 
                if cp_commentCount.include?(new_post_commentCount)
                  puts "此文已爬，有修改，沒新回文"
                  forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                else
                  puts "此文已爬，有修改，有新回文"        
                  forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                  forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                end
              end
          else     
            puts "全新未爬文章"
            forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
          end
         end 
         break
      else 
        count = 0
        post_items.each do |post_item|
        new_post_id = post_item["id"] 
        new_post_updatedAt = post_item["updatedAt"][0..9] + " " + post_item["updatedAt"][11..18]
        new_post_commentCount = [post_item["id"].to_s,post_item["commentCount"].to_s]
        sleep(0.4)
        if cp_id.include?(new_post_id.to_s)
              if cp_updatedAt.include?(new_post_updatedAt)
                   if cp_commentCount.include?(new_post_commentCount)
                     puts "此文已爬，無修改，沒新回文"
                     cp_post << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                   else
                     puts "此文已爬，無修改，有新回文"
                     forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                   end
              else 
                if cp_commentCount.include?(new_post_commentCount)
                  puts "此文已爬，有修改，沒新回文"
                  forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                else
                  puts "此文已爬，有修改，有新回文"        
                  forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                  forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
                end
              end
          else     
            puts "全新未爬文章"
            forum_post_id << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
            forum_post_comment << [post_item["id"],post_item["title"],post_item["forumName"], post_item["forumAlias"],post_item["updatedAt"],post_item["commentCount"]]
          end
        count += 1
        p count, "後面還有"
        if count == 30 
          last_id = post_item["id"]
          count = 0
        end
      end
      end 
    end 
    all_cp_post = cp_post + forum_post_id + forum_post_comment
    File.write("new_update_post_id.csv", forum_post_id.map(&:to_csv).join) 
    #需爬蟲文章包含新增的文章和編輯過的文章，提供給test_get_post_content的爬蟲目標
    File.write("new_post_comment.csv", forum_post_comment.map(&:to_csv).join) 
    #需爬蟲回文包含新增文章的回文和舊文章的新回文，提拱給test_get_post_comment的爬蟲目標
    File.write("post_id.csv", all_cp_post.map(&:to_csv).join) 
    #完整post_id檔，上傳資料庫用or用new_update_post_id.csv只上傳更新部分
    File.write("cp_post_id.csv", all_cp_post.map(&:to_csv).join) 
    #內容同上，下次爬蟲比對用
  end
  f = forums[0.1][0]
end 