class UsersController < ApplicationController 
  def spotify
    spotify_user = RSpotify::User.new(request.env['onmiauth.auth'])
    hash = spotify_user.to_hash
     puts '*******************************'
    puts "hash is" + hash
  end

  def index
  end
  
end