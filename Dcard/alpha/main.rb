require "net/http"
require "json"
require 'csv'
require 'fileutils'

require("./get_forums.rb")
require("./get_post_id.rb")
require("./get_post_content.rb")
require("./get_post_comment.rb")
# require("./mv_files.rb")





get_forums() 
f = get_post_id()
get_post_content()
get_post_comment()
# mv_files(f)
