GitAnnounce::Engine.routes.draw do
  post '/', to: "messages#receive"
  post '/zulip', to: "messages#zulip"
end
