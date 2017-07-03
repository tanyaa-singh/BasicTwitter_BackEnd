require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')
set :public_folder, File.dirname(__FILE__)+'/assets' 
set :bind, '0.0.0.0'
 
class User
    include DataMapper::Resource
    property :id, Serial
    property :email, String
    property :password, String

    def followed follower_id
    	Follow.all(follower_id: follower_id, following_id: id).length>0
    end

    def following 
    	Follow.all(follower_id: id).length
    end

    def followers 
    	Follow.all(following_id: id ).length
    end
end
 
 
class Tweet
    include DataMapper::Resource
    property :id, Serial
    property :user_id, Numeric
    property :content, Text
 
 
    def like_count
        Like.all(tweet_id: id).length
    end
 
    def liked_by user_id
        Like.all(tweet_id: id, user_id: user_id).length > 0
    end
end
 
class Like
    include DataMapper::Resource
    property :id, Serial
    property :user_id, Numeric
    property :tweet_id, Numeric
end

class Follow 
	include  DataMapper::Resource
	property :id, Serial
	property :follower_id, Numeric
	property :following_id, Numeric
	
end
 
DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

get '/' do
    if session[:user_id].nil?
        return redirect '/signin'
    end
    tweets = Tweet.all
	erb :index, locals: {tweets: tweets, user_id: session[:user_id]}
end

 
get '/signout' do
    session[:user_id] = nil
    return redirect '/'
end
 
 
 
get '/signin' do
    erb :signin
end
 
post '/signin' do
    email = params["email"]
    password = params["Password"]
 
    # users = User.all(email: email)
 
    # if users.length > 0 
    #   user = users[0]
    # else
    #   user = nil
    # end
 
    user = User.all(email: email).first
 
    #puts user.class
 
    if user.nil?
        return redirect '/signup'
    else
        if user.password == password
            session[:user_id] = user.id
            return redirect '/'
        else
            return redirect '/signup'
        end
 
    end

end
 
 
 
get '/signup' do
    erb :signup
end
 
post '/signup' do
    email = params["email"]
    password = params["Password"]
 
    user = User.all(email: email).first
 
    if user
        return redirect '/signup'
    else
        user = User.new
        user.email = email
        user.password = password
        user.save
        session[:user_id] = user.id
        return redirect '/'
    end
end

post '/create_tweet' do
    content = params[:content]
    tweet = Tweet.new
    tweet.content = content
    tweet.user_id = session[:user_id]
    tweet.save
    return redirect '/'
end
 
post '/like' do
    tweet_id = params[:tweet_id]
    like = Like.all(tweet_id: tweet_id, user_id: session[:user_id]).first
 
    unless like
        like = Like.new
        like.tweet_id = tweet_id
        like.user_id = session[:user_id]
        like.save
    else
        like.destroy
    end
 
    return redirect '/'
 
end

post '/follow' do

	following_id=params["following_id"]
	follow=Follow.all(follower_id: session[:user_id], following_id: following_id).first

	unless follow
		follow=Follow.new
		follow.follower_id=session[:user_id]
		follow.following_id=following_id
		follow.save
	end

	return redirect '/'

end

post '/unfollow' do

	unfollow_id=params["unfollow_id"]
	unfollow=Follow.all(follower_id: session[:user_id], following_id: unfollow_id).first

	unfollow.destroy
	return redirect '/'
end

get '/followers' do

	
end