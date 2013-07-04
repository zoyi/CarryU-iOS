# 2012-12-30, Di Wu

%w(fileutils csv open-uri).each { |header| require header }

PROJECT_NAME = 'lol'
IOS_GID = 0


dirname = File.basename(Dir.pwd)

puts dirname << " is not under #{PROJECT_NAME} dictionary" and return  if dirname != PROJECT_NAME

puts " => verified folder."

# Retrieve Data from Google docs

def retrieve_data_with_gid(gid)
  CSV.parse(open("https://docs.google.com/spreadsheet/pub?key=0AqkOefRa93cAdG84eGVPZjRjYUptM09jdXgtWlhPTFE&output=csv&gid=#{gid}").read, :encoding => 'utf-8', :headers => true)
end

matrix = retrieve_data_with_gid IOS_GID

tags = []

matrix.by_col!.each do |col|
  # col[0] => header, col[1] => data
  lang = col[0]

  if lang == 'tag'
    tags = col.last
  else
    path = File.join(Dir.pwd, PROJECT_NAME, "#{lang.strip}.lproj".downcase)

    puts "writing to " << path

    FileUtils.mkpath(path) rescue nil

    data = col.last

    # Write to file.
    File.open(File.join(path, "Localizable.strings"), "w") do |file|
      data.each_index do |i|
        key = tags[i].strip  rescue nil
        value = data[i].strip  rescue nil
        file.puts "\"#{key}\" = \"#{value}\";"  if key and value
      end
    end
    puts "done"
  end
end
