class UsersController < ApplicationController
  def index
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    puts '8888888888888888888888888888888888888888'
    puts hash = spotify_user.to_hash
  end

end
