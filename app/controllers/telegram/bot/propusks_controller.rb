# Propusks
class Telegram::Bot::PropusksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  around_action :chat_exist?, only: [:start!]

  def start!(*params)
    respond_mess_text t('.title')
  end

  def help!(*params)
    respond_mess_text t('.title')
  end

  def iin!(*params)
    save_context :iin_number
    respond_mess_text t('.title')
  end

  def iin_number(*params)
    result = iin_service.call(params)

    if result.success?
      respond_mess_html t('.success_data', data: result.data)
    else
      respond_mess_html t('.error_data', error: result.data)
    end
  end

  def grnz!(*params)
    save_context :grnz_number
    respond_mess_text t('.title')
  end

  def grnz_number(*params)
    result = grnz_service.call(params)
    if result.success?
      respond_mess_html t('.success_data', data: result.data)
    else
      respond_mess_html t('.error_data', error: result.data)
    end
  end

  # processing non-existent commands
  def action_missing(action, *_args)
    case action_type
    when :command
      respond_mess_text t('.error.command', command: action_options[:command])
    else
      respond_mess_text t('.error.action', command: action)
    end
  end

  protected

  def chat_exist?
    return yield if find_chat.present?

    create_chat
    yield
  end

  def create_chat
    Chat.create(
      tg_chat_id: chat['id'].to_i,
      tg_type: "tg_#{chat['type']}",
      data: payload
    )
  end

  def respond_mess_text(text)
    respond_with :message, text: text
  end

  def respond_mess_html(text)
    respond_with :message, text: text, parse_mode: 'HTML'
  end

  private

  def find_chat
    Chat.find_by(tg_chat_id: chat['id'].to_i)
  end

  def iin_service
    Telegram::Bot::Propusks::IinService.new(payload)
  end

  def grnz_service
    Telegram::Bot::Propusks::GrnzService.new(payload)
  end
end
