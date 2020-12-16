require "net/http"
require "json"
require "csv"
#
require("./get_forums.rb")
require("./get_post_id.rb")
require("./get_post_content.rb")
require("./get_post_comment.rb")
require("./mv_files.rb")
#
require "fileutils"

def loop_crawler
  all_boards = CSV.parse(File.read("forums.csv"), headers: false)

  # 0.upto = 從第一個版開始
  199.upto(all_boards.count - 1) do |board|
    table_title = all_boards["#{board}".to_i.."#{board}".to_i].first.first

    # n 天前的資料
    prev_day = 30

    # 每 n 筆資料暫停 / 隨機請參考rand(n..m)
    sleep_every = 50

    # 暫停時休息秒數 / 隨機請參考rand(n..m)
    sleep_time = 3

    get_post_id(board, sleep_every, sleep_time, prev_day)
    get_post_content(sleep_every, sleep_time)
    get_post_comment(sleep_every, sleep_time)
    mv_files(table_title)
  end
end

get_forums()
beta_folder_name()
loop_crawler()
finish_time()
