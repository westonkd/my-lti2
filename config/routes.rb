Rails.application.routes.draw do
  get 'info/home'
  post 'messages/register' => 'messages#register'

  root 'info#home'
end
