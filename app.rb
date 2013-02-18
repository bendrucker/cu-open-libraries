require './constants.rb'

configure :development do
	conn = Mongo::Connection.new("localhost", 27017)
	set :mongo, conn.db('libs')['libraries']
end

configure :production do
	conn = Mongo::Connection.new(ENV['MONGO_HQ_HOST'], ENV['MONGO_HQ_PORT'])
	conn.authenticate(ENV['MONGO_HQ_USERNAME'], ENV['MONGO_HQ_PASSWORD'])
	set :mongo, conn.db('library_hours')['libraries']
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