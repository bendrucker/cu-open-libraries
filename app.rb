require './constants.rb'

configure :development do
	conn = Mongo::MongoClient.new("localhost", 27017)
	set :mongo, conn.db('libs')['libraries']
end

configure :production do
	connection = Mongo::MongoClient.from_uri
	set :mongo, connection.db('library_hours')['libraries']
	require 'newrelic_rpm'
end	



get '/' do
	libraries = settings.mongo.find({'status' => 'Open'}).to_a.select { |library|
		library['status'] == 'Open' && ((library['open']..library['close']).cover?(Time.now.utc) || library['allday'] )
	}
	libraries.each do |library|
		library['url'] = [BASE_URL, QUERY, library['slug']].join
		unless library['allday']
			['open', 'close'].each do |time|
				library[time] =
					if library[time].min.zero?
						library[time].getlocal.strftime("%l %p")
					else
						library[time].getlocal.strftime("%l:%M %p")
					end	
			end
		end		
	end	
	haml :index, :locals => {:libraries => libraries}
end