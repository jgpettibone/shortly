require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'digest/sha1'
require 'pry'
require 'uri'
require 'open-uri'
require 'SecureRandom'
# require 'nokogiri'

###########################################################
# Configuration
###########################################################

set :public_folder, File.dirname(__FILE__) + '/public'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Handle potential connection pool timeout issues
after do
    ActiveRecord::Base.connection.close
end

# turn off root element rendering in JSON
ActiveRecord::Base.include_root_in_json = false

###########################################################
# Models
###########################################################
# Models to Access the database through ActiveRecord.
# Define associations here if need be
# http://guides.rubyonrails.org/association_basics.html

class Link < ActiveRecord::Base
    has_many :clicks

    validates :url, presence: true

    before_save do |record|
        record.code = Digest::SHA1.hexdigest(url)[0,5]
    end
end

class Click < ActiveRecord::Base
    belongs_to :link, counter_cache: :visits
end

class User < ActiveRecord::Base

  # def is_loggedin
  #   return true
  # end

end

###########################################################
# Routes
###########################################################

get '/' do
  # if User then
    erb :index
  # else
  #   redirect "http://www.google.com"
  # end
end

loggedin = false

get '/links' do
  puts 'in get /links'
  if loggedin then
    links = Link.order("created_at DESC")
    links.map { |link|
      link.as_json.merge(base_url: request.base_url)
    }.to_json
  else
    puts 'in get /links else'
    redirect '/login'
    puts 'after redirect'
  end
end

get '/login' do
  erb :index
end

post '/links' do
  data = JSON.parse request.body.read
  uri = URI(data['url'])
  raise Sinatra::NotFound unless uri.absolute?
  link = Link.find_by_url(uri.to_s) ||
    Link.create( url: uri.to_s, title: get_url_title(uri) )
  link.as_json.merge(base_url: request.base_url).to_json
end

post '/loggedin' do
  data = JSON.parse request.body.read
  puts data
  hashedP = hashPassword(data['password'])
  saltedP = saltPassword(data['password'])
  user = User.create({username: data['username'], password_hash: hashedP, password_salt: saltedP})
end

get '/:url' do
  link = Link.find_by_code params[:url]
  raise Sinatra::NotFound if link.nil?
  link.clicks.create!
  redirect link.url
end

###########################################################
# Utility
###########################################################

def hashPassword (password)
  result = Digest::SHA1.hexdigest(password)
  puts "hash: #{result}"
  result
end

def saltPassword (password)
  result = SecureRandom.base64
  puts "salt: #{result}"
  result
end

def read_url_head url
  head = ""
  url.open do |u|
    begin
      line = u.gets
      next  if line.nil?
      head += line
      break if line =~ /<\/head>/
    end until u.eof?
  end
  head + "</html>"
end

def get_url_title url
  # Nokogiri::HTML.parse( read_url_head url ).title
  result = read_url_head(url).match(/<title>(.*)<\/title>/)
  result.nil? ? "" : result[1]
end
