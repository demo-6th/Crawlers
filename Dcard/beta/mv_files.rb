def mv_files(table_title)
  clean_title = table_title.gsub("/", "-")
  Dir.mkdir("#{clean_title}") unless Dir.exists?("#{clean_title}")
  FileUtils.mv("post_id.csv", "#{clean_title}/")
  FileUtils.mv("post_content.csv", "#{clean_title}/")
  FileUtils.mv("post_comment_new.csv", "#{clean_title}/")
  FileUtils.mv("#{clean_title}", "#{@folder_name}/")
end

def beta_folder_name()
  @folder_name = DateTime.now.strftime("%F %R").gsub(":", "-")
  Dir.mkdir("#{@folder_name}")
end

def finish_time()
  finishtime = DateTime.now.strftime("%F %R").gsub(":", "-")
  File.open("finish_at_#{finishtime}.txt", "w")
  FileUtils.mv("finish_at_#{finishtime}.txt", "#{@folder_name}/")
end
