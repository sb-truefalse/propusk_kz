Telegram.bots_config = {
  default: ENV['DEFAULT_BOT_TOKEN'],
  username: ENV['DEFAULT_BOT_USERNAME']
}

Telegram::Bot::UpdatesController.session_store =
  :file_store, { expires_in: 1.month }
