GitAnnounce::Engine.routes.draw do
  post '/', to: "messages#receive"
end
