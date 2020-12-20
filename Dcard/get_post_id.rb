require "byebug"

def format_error(e)
  puts "==========================================="
  puts "error type=#{e.class}, message=#{e.message}"
  puts "==========================================="
end

def wait_randomly
  sleep(rand(0.5..1.2))
end

def parse_date(day_integer)
  DateTime.now.prev_day(day_integer).strftime("%y-%m-%d")
end

def created_at_string(data)
  data["createdAt"].slice(0, 10)
end

def get_json_from(url_string, params_string = "")
  uri = URI(url_string + params_string)
  JSON.parse(Net::HTTP.get(uri))
end

def post_row(data)
  [data["id"], data["title"], data["forumName"], data["forumAlias"]]
end

# main
def get_post_id(board, batch_size, sleep_time, prev_day)
  table = CSV.parse(File.read("forums.csv"), headers: false)

  board_index = board.to_i

  post_rows = []
  ended_at_string = parse_date(prev_day)

  row = table[board_index]
  items = get_json_from(row[2])

  segmented_post_rows = []
  count = 0
  last_id = 0
  total_cut = 0

  post_created_at = ""
  # print board name
  puts "=============#{board_index + 1}.#{row[0]}============"
  items.each do |item|
    wait_randomly

    post_created_at = created_at_string(item)
    break if post_created_at < ended_at_string
    count += 1
    total_cut += 1
    segmented_post_rows << post_row(item)

    # print board count and title
    puts total_cut, "----------#{item["title"]}"

    if count == 30
      last_id = item["id"]
      count = 0
    end
  rescue => e
    format_error(e)
  end

  while true
    break puts "本版已無符合條件資料" if post_created_at.empty? || post_created_at < ended_at_string || last_id == 0
    items = get_json_from(row[2], "&before=#{last_id}")

    if items.size < 30
      items.each do |item|
        post_created_at = created_at_string(item)
        break puts "本版已無符合條件資料" if post_created_at.empty? || post_created_at < ended_at_string
        total_cut += 1

        wait_randomly

        puts total_cut, "-----------#{item["title"]}"
        segmented_post_rows << post_row(item)
      rescue => e
        format_error(e)
      end
    else
      count = 0
      items.each do |item|
        if total_cut.modulo(batch_size) == 0
          sleep(sleep_time)
        else
          wait_randomly
        end
        post_created_at = created_at_string(item)
        break if post_created_at.empty? || post_created_at < ended_at_string
        count += 1
        total_cut += 1
        segmented_post_rows << post_row(item)
        puts total_cut, "-----------#{item["title"]}"
        if count == 30
          last_id = item["id"]
          count = 0
        end
      rescue => e
        format_error(e)
      end
    end
  end
  post_rows += segmented_post_rows

  File.write("post_id.csv", post_rows.map(&:to_csv).join)
end
