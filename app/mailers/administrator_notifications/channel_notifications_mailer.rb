class AdministratorNotifications::ChannelNotificationsMailer < ApplicationMailer
  def slack_disconnect
    return unless smtp_config_set_or_development?

    subject = 'Sua integração com o Slack expirou'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/integrations/slack"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def dialogflow_disconnect
    return unless smtp_config_set_or_development?

    subject = 'Sua integração com o Dialogflow foi desconectada'
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def facebook_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'A conexão da sua página do Facebook expirou'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def whatsapp_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'Sua conexão com o Whatsapp expirou'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def email_disconnect(inbox)
    return unless smtp_config_set_or_development?

    subject = 'Sua caixa de entrada de e-mail foi desconectada. Atualize as credenciais para SMTP/IMAP'
    @action_url = "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/inboxes/#{inbox.id}"
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def contact_import_complete(resource)
    return unless smtp_config_set_or_development?

    subject = 'Importação de contato concluída'

    @action_url = Rails.application.routes.url_helpers.rails_blob_url(resource.failed_records) if resource.failed_records.attached?
    @action_url ||= "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{resource.account.id}/contacts"
    @meta = {}
    @meta['failed_contacts'] = resource.total_records - resource.processed_records
    @meta['imported_contacts'] = resource.processed_records
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def contact_import_failed
    return unless smtp_config_set_or_development?

    subject = 'Falha na importação de contatos'

    @meta = {}
    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  def contact_export_complete(file_url, email_to)
    return unless smtp_config_set_or_development?

    @action_url = file_url
    subject = "O arquivo de exportação do seu contato está disponível para download."

    send_mail_with_liquid(to: email_to, subject: subject) and return
  end

  def automation_rule_disabled(rule)
    return unless smtp_config_set_or_development?

    @action_url ||= "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/settings/automation/list"

    subject = 'Regra de automação desativada devido a erros de validação.'.freeze
    @meta = {}
    @meta['rule_name'] = rule.name

    send_mail_with_liquid(to: admin_emails, subject: subject) and return
  end

  private

  def admin_emails
    Current.account.administrators.pluck(:email)
  end

  def liquid_locals
    super.merge({ meta: @meta })
  end
end
