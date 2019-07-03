GitAnnounce::Engine.routes.draw do
  post '/', to: "controller#create"
end
