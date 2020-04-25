Rails.application.routes.draw do
  telegram_webhook Telegram::Bot::PropusksController
end
