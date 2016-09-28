Rails.application.routes.draw do
  get 'info/home'
  post 'messages/register' => 'messages#register'
  # You can have the root of your site routed with "root"
  root 'info#home'
end
