
def mv_files(f)
  Dir.mkdir("#{f}")
  FileUtils.mv('post_id.csv', "#{f}/")
  FileUtils.mv('post_content.csv', "#{f}/")
  FileUtils.mv('post_comment_new.csv', "#{f}/")
  end


