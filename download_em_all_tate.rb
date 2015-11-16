require 'typhoeus'
require 'json'
require 'csv'

EXPORT_PATH = "./bin/data/downloaded_images/"
CSV_SOURCE = "./bin/data/tate.csv"
CONCURRENT_DOWNLOADS = 30
SLEEP_BETWEEN_DOWNLOADS = 0

## Read ALL THE THINGS
all_things = CSV.foreach(CSV_SOURCE, {headers: true}).collect do |row|
  {id: row[0], image_url: row["thumbnailUrl"] , accession_number: row["accession_number"], title: row["title"]}
end

## FOR ALL THE THINGS, DOWNLOAD!

hydra = Typhoeus::Hydra.new
all_things.each_slice(CONCURRENT_DOWNLOADS) do |things|
  requests = []
  lookup = {}
  things.each do |thing|
    unless thing[:image_url].nil?
      url = thing[:image_url]
      filename = "#{thing[:id]}.jpg"
      unless File.exist? "#{EXPORT_PATH}#{filename}"
        lookup[url] = filename
        request = Typhoeus::Request.new(url, {timeout: 200, followlocation: true})
        hydra.queue(request)
        requests.push request
      else
         #puts "skipping #{filename}"
      end
    end
  end

  ## DOWNLOAD 'EM
  hydra.run

  ## SAVE THEM TO DISK
  responses = requests.map { |r|
    puts "#{r.url}: #{r.response.status_message}"
    if r.response.status_message == 'OK'
      File.open("#{EXPORT_PATH}#{lookup[r.url]}","wb") do |f|
        f.puts r.response.response_body
      end
    else
      puts r.response.inspect
    end
  }
  unless requests.empty?
    puts "Downloaded up to #{things.last[:accession_number]}: #{things.last[:title]}"
    sleep(SLEEP_BETWEEN_DOWNLOADS)
  end
end