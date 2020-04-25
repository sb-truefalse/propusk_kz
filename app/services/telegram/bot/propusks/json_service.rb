# frozen_string_literal: true

# Json parse
class Telegram::Bot::Propusks::JsonService < Service
  attr_reader :iin, :grnz

  def initialize(iin: nil, grnz: nil)
    @iin = iin
    @grnz = grnz
  end

  def check_iin
    return error!('<b>Неверный ИИН</b>') unless iin =~ /^\d+$/

    check_pass
  end

  def check_grnz
    return error!('<b>Неверный ГРНЗ</b>') if grnz.blank?

    check_pass
  end

  protected

  def check_pass
    messages = []
    errors = []
    container = ''

    begin
      if data[:error].present?
        errors << get_data_errors(data)
      elsif data[:results].blank?
        errors << get_results_errors
      else
        messages << get_rule if data[:rule].present?
        messages += get_results
      end
    rescue
      errors << error_find_to_db
    end

    if errors.present?
      errors.each { |error| container += "<b>#{error}</b>\n" }
      error!(container)
    elsif messages.present?
      messages.each { |message| container += "<i>#{message}</i>\n" }
      success!(container)
    end
  end

  def data
    @data ||= if iin
                client.post('/check', iin: iin).body
              else
                client.post('/check', number: grnz).body
              end
  end

  def get_rule
    rule = data[:rule]
    person_info = ''

    if rule[:name].present? && rule[:name] != 'noname'
      person_info += "ФИО: #{rule[:name]} \n"
    end

    if rule[:comment].present?
      person_info += "Комментари: <b> #{rule[:comment]} </b>\n"
    end

    if rule[:business_name].present?
      person_info += "Наименование организации: #{rule[:business_name]} \n"
    end

    if rule[:business_type].present?
      person_info += "Тип организации: #{rule[:business_type]} \n"
    end

    if rule[:business_address].present?
      person_info += "Адрес организации: #{rule[:business_address]} \n"
    end

    if rule[:business_position].present?
      person_info += "Должность: <b> #{rule[:business_position]} </b>\n"
    end

    if rule[:expired_at].present?
      person_info += "Пропуски действительны до: #{rule[:expired_at]} \n"
    end

    if rule[:week_days].present?
      week_days_string = get_week_days_string(rule[:week_days])
      person_info += "По дням недели: #{week_days_string} \n"
    end

    person_info
  end

  def get_results
    messages = []
    rule = data[:rule]
    cities = []
    checkpoints = []
    expired_at = nil
    week_days_string = nil

    if rule.present?
      expired_at = rule[:expired_at]
      week_days_string = if rule[:week_days].present?
        get_week_days_string(data[:rule][:week_days])
      end
    end

    data[:results].each do |pass|
      direction = nil
      if pass[:enterance].present? && pass[:exit].present?
        direction = 'свободное передвижение'
      elsif pass[:enterance].present?
        direction += 'въезд'
      elsif pass[:exit].present?
        direction += 'выезд'
      end

      pass_info = "<b>#{pass[:name]}#{direction ? (' - ' + direction) : ''}</b>"

      if pass[:expired_at].present? && pass[:expired_at] == expired_at
        pass_info += " (до #{pass[:expired_at]})"
      end

      if pass[:week_days].present?
        pass_week_days_string = get_week_days_string(pass[:week_days])
        if pass_week_days_string != week_days_string
          pass_info += " ( #{pass_week_days_string})"
        end
      end

      if pass[:parent_codes]&.include?('checkpoints')
        checkpoints << pass_info
      else
        cities << pass_info
      end

      if cities.present?
        cities_info = "<b>Пропуска в городах:</b>\n"
        cities.each { |city| cities_info += "#{city}\n" }
        messages << cities_info
      end

      if checkpoints.present?
        checkpoints_info = "<b>Пропуска на блок-постах:</b>\n"
        checkpoints.each { |checkpoint| checkpoints_info += "#{checkpoint}\n" }
        messages << checkpoints_info
      end
    end

    messages
  end

  def get_data_errors(data)
    if data[:type].present? && data[:type] == 'too_many_requests'
      iin.nil? ? error_count_check_grnz : error_count_check_iin
    else
      data[:error]
    end
  end

  def get_results_errors
    iin.nil? ?  error_propusk_not_found_grnz : error_propusk_not_found_iin
  end

  def get_week_days_string(week_days)
    return 'все дни недели' if week_days.length == 7

    week_names = [nil, 'пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'вс']
    result = week_days.map { |week_day| week_names[week_day] }
    result.join(', ')
  end

  private

  def client
    @client ||= Telegram::Bot::Propusks::Client.new
  end

  def error_count_check_iin
    'Превышено количество проверок данного ИИН. Попробуйте через 10 минут'
  end

  def error_count_check_grnz
    'Превышено количество проверок данного ГРНЗ. Попробуйте через 10 минут'
  end

  def error_propusk_not_found_iin
    'Пропуска по данному ИИН не найдены'
  end

  def error_propusk_not_found_grnz
    'Пропуска по данному ГРНЗ не найдены'
  end

  def error_find_to_db
    'Произошла ошибка поиска в базе пропусков. Повторите попытку через несколько минут'
  end
end
