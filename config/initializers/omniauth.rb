require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
<<<<<<< HEAD
  provider :spotify,  '41e2045a63d64ce8b8d058653dba2180', '59a2785d2b854f34aa13a352a8f714da', scope: 'playlist-modify-public playlist-read-private user-library-read playlist-modify-private user-library-modify user-read-private playlist-read-collaborative'
=======
  provider :spotify, ENV["CLIENT_KEY"], ENV["CLIENT_SECRET"], scope: 'playlist-modify-public playlist-read-private user-library-read playlist-modify-private user-library-modify user-read-private playlist-read-collaborative'
>>>>>>> b5f1a1f10e4da104259710c3b888ed2348c0b39e
end
