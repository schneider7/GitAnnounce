GitAnnounce::Engine.routes.draw do
  post '/', to: "messages#process"
end
