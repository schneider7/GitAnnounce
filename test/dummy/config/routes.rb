Rails.application.routes.draw do
  mount GitAnnounce::Engine => "/git_announce"
end
