require 'rubygems'
require 'bundler/setup'
require 'open-uri'
Bundler.require

require './constants'

task :setup do
	libraries = {}
	Nokogiri::HTML(open(BASE_URL)).css('.hours_toc a').each do |link|
		href = link.get_attribute('href')
		if href.include? QUERY
			libraries[href.gsub(QUERY, '').to_sym] = link.content
		end	
	end
	File.open('libraries.yml', 'w') do |file|
		file.write(Psych.dump(libraries))
	end	
end

task :hours do
	libraries = []
	Psych.load(File.read('libraries.yml')).each do |key, name|
		hours_element = Nokogiri::HTML(open([BASE_URL, QUERY, key].join)).at_css('.today_date').ancestors('table').first.at_css('.today_hours')
		hours = if hours_element
			 		hours_element.content.gsub('Midnight', '12:00am').gsub('Noon', '12:00pm')
				else
					nil
				end

		status = 
			unless hours.nil?
				'Open'
			else
				'Closed'
			end

		library = {
			:slug => key,
			:name => name,
			:status => status
		}	

		if hours
			unless hours.include? '24 Hours'
				library[:open] = Time.parse(hours.split('-').first)
				library[:close] = Time.parse(hours.split('-').last)
			else
				library[:allday] = true
			end		
		end	

		libraries << library

	end

	unless ENV['MONGODB_URI']
		connection = Mongo::MongoClient.new("localhost", 27017)
		mongo = connection.db('libs')['libraries']
	else
		connection = Mongo::MongoClient.new
		mongo = connection.db('library_hours')['libraries']
	end

	mongo.remove

	mongo.insert libraries
end