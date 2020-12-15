def get_post_comment
  table = CSV.parse(File.read("new_post_comment.csv"), headers: false)

  post_comments = []
  table.each do |line|
    begin 
      p "=============post_id=#{line[0]}============" 
      count = 0
      last_floor = 0

      while true
        sleep(0.5)
        url = "https://www.dcard.tw/_api/posts/#{line[0]}/comments?after=#{last_floor}"
        p "next_url = #{url}"
        uri = URI(url)
        data = Net::HTTP.get(uri)
        items = JSON.parse(data)

        if items.size < 30 
          sleep(0.2)
          items.each do |item|
            post_comments << [item["id"],item["postId"],item["createdAt"],item["updatedAt"],item["floor"],item["content"],item["likeCount"],item["gender"]]
            count += 1 
            p count,"最後一頁"
          end
          break
        else 
          sleep(0.2)
          items.each do |item|
            post_comments << [item["id"],item["postId"],item["createdAt"],item["updatedAt"],item["floor"],item["content"],item["likeCount"],item["gender"]]
            count += 1
            p count, "後面還有"
            if count == 30 
              last_floor = item["floor"]
              count = 0
            end
          end
        end 
      end 
    rescue => e
      puts "error type=#{e.class}, message=#{e.message}"
    end 
  end 

  savetime = Time.now
  File.write("post_comment_new_#{savetime}.csv", post_comments.map(&:to_csv).join)
end 
