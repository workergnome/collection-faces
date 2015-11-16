require 'typhoeus'
require 'json'

EXPORT_PATH = "./bin/data/downloaded_images/"
JSON_SOURCE = "./bin/data/cmoa.json"
CONCURRENT_DOWNLOADS = 10
SLEEP_BETWEEN_DOWNLOADS = 5

## Read ALL THE THINGS
all_things = JSON.parse(File.read(JSON_SOURCE))["things"]

## FOR ALL THE THINGS, DOWNLOAD!
hydra = Typhoeus::Hydra.new
all_things.each_slice(CONCURRENT_DOWNLOADS) do |things|
  requests = []
  lookup = {}
  things.each do |thing|
    unless thing["images"].nil?
      thing["images"].each do |image|
        unless image["image_url"].empty?
          image["image_url"].each_with_index do |url, i|
            filename = "#{thing["id"]}_#{i}.jpg"
            unless File.exist? "#{EXPORT_PATH}#{filename}"
              lookup[url] = filename
              request = Typhoeus::Request.new(url, {followlocation: true, timeout: 300})
              hydra.queue(request)
              requests.push request
            else
               #puts "skipping #{filename}"
            end
          end
        end
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
    end
  }
  unless requests.empty?
    puts "Downloaded up to #{things.last["accession_number"]}: #{things.last["title"]}"
    sleep(SLEEP_BETWEEN_DOWNLOADS)
  end
end