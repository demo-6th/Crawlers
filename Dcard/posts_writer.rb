require "net/http"
require "json"
require "csv"
require "fileutils"

class PostsWriter
  def initialize(**options)
    @board_index = options[:board].to_i
    @post_rows = []
    @segmented_post_rows = []
    @ended_at_string = parse_date(options[:prev_day])
    @count = 0
    @last_id = 0
    @total_cut = 0
    @post_created_at = ""

    @batch_size = options[:sleep_time]
    @sleep_time = options[:sleep_time]
    @post_created_at = ""
  end

  def perform!
    posts = get_row

    puts "=============#{@board_index + 1}.#{@row[0]}============"
    posts.each do |post|
      parse_post(post)
      if @post_created_at < @ended_at_string
        @last_id = post["id"]
        break
      end
    end

    return if @post_created_at < @ended_at_string || @post_created_at.empty?

    while true
      break puts "本版已無符合條件資料" if @post_created_at.empty? || @post_created_at < @ended_at_string || @last_id == 0
      if posts.size > 30
        filterd_posts = posts.filter { |post| post["id"] == @last_id }
        posts.each do |post|
          break if @post_created_at < @ended_at_string || @post_created_at.empty?
          parse_post(post)
        end
        break puts "本版已無符合條件資料"
      else
        filterd_posts = posts.filter { |post| post["id"] == @last_id }
        posts.each do |post|
          break if @post_created_at < @ended_at_string || @post_created_at.empty?
          parse_post(post)
        end
        break puts "本版已無符合條件資料"
      end
    end

    @post_rows += @segmented_post_rows

    File.write("post_id.csv", @post_rows.map(&:to_csv).join)
  end

  private

  def parse_post(post)
    wait_randomly

    @post_created_at = created_at_string(post)

    @segmented_post_rows << post_row(post)
    @count += 1
    @total_cut += 1

    # print board count and title
    puts @total_cut, "----------#{post["title"]}"

    reset_count_with(post["id"]) if @count == 30
  end

  def reset_count_with(id)
    @last_id = id
    @count = 0
  end

  def get_row
    table = CSV.parse(File.read("forums.csv"), headers: false)

    @row = table[@board_index]

    get_json_from(@row[2])
  end

  def wait_randomly
    return sleep(rand(0.5..1.2)) unless @total_cut.%(@batch_size).zero?

    sleep(@sleep_time)
  end

  def parse_date(day_integer)
    ::DateTime.now.prev_day(day_integer).strftime("%y-%m-%d")
  end

  def created_at_string(data)
    data["createdAt"].slice(0, 10)
  end

  def get_json_from(url_string, params_string = "")
    uri = URI(url_string + params_string)
    ::JSON.parse(::Net::HTTP.get(uri))
  end

  def post_row(data)
    [data["id"], data["title"], data["forumName"], data["forumAlias"]]
  end
end
