

def get_post_content
  table = CSV.parse(File.read("post_url.csv"), headers: false)

  all_post_content = []
  all_comment_content = []
  
  table.each do |x|
    sleep(rand(0.5..1.2))
    url = x[2]
    p url
    begin 
      doc = Nokogiri::HTML(open(url,'Cookie' => 'over18=1'))
      # board 
      board = doc.xpath('//*[@id="topbar"]/a[2]').text
      # post_url
      post_url = url
      # post author 
      post_author = doc.xpath('//*[@id="main-content"]/div[1]/span[2]').text
      # post title 
      post_title = doc.xpath('//*[@id="main-content"]/div[3]/span[2]').text
      # post time
      post_time = doc.xpath('//*[@id="main-content"]/div[4]/span[2]').text
      # post content
      post_content = doc.xpath('//*[@id="main-content"]/text()').text
      all_post_content << [ board, post_url, post_author, post_title, post_time, post_content]
  
      # all post comment
      comment_content = []
      doc.css("#main-container .bbs-content .push").each do |comment|
        sleep(rand(0.5..1.2))
        # board
        board = doc.xpath('//*[@id="topbar"]/a[2]').text
        # post_url
        post_url = url
        # post comment author 
        post_comment_author = comment.css(".push-userid").text
        # post comment time
        post_comment_time = comment.css(".push-ipdatetime").text
        # comment content 
        post_comment_content = comment.css(".push-content").text
        comment_content << [board, post_url, post_comment_author, post_comment_time, post_comment_content]
    end 
    all_comment_content << comment_content
    rescue OpenURI::HTTPError => ex
      puts "404"
    end 
  end 
  
  File.write("post_content.csv", all_post_content)
  File.write("post_comment_content.csv", all_comment_content)
end 



