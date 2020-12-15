
def get_post_content
  table = CSV.parse(File.read("new_update_post_id.csv"), headers: false)
  post_content = []
  table.each do |line|
    sleep(0.5)
    url = "https://www.dcard.tw/_api/posts/#{line[0]}"
    uri = URI(url)
    data = Net::HTTP.get(uri)
    items = JSON.parse(data)
    post_content << [items["id"],items["content"],items["title"],items["createdAt"],items["updatedAt"],items["commentCount"],items["likeCount"],items["gender"]]

  end 
  savetime = Time.now
  File.write("post_content_#{savetime}.csv", post_content.map(&:to_csv).join)
end 

 