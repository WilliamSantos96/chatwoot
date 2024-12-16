# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdministratorNotifications::ChannelNotificationsMailer do
  let(:class_instance) { described_class.new }
  let!(:account) { create(:account) }
  let!(:administrator) { create(:user, :administrator, email: 'agent1@example.com', account: account) }

  before do
    allow(described_class).to receive(:new).and_return(class_instance)
    allow(class_instance).to receive(:smtp_config_set_or_development?).and_return(true)
  end

  describe 'slack_disconnect' do
    let(:mail) { described_class.with(account: account).slack_disconnect.deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Sua integração com o Slack expirou')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end

  describe 'dialogflow disconnect' do
    let(:mail) { described_class.with(account: account).dialogflow_disconnect.deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Sua integração com o Dialogflow foi desconectada')
    end

    it 'renders the content' do
      expect(mail.body).to include('Sua integração com o Dialogflow foi desconectada devido a problemas de permissão.')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end

  describe 'facebook_disconnect' do
    before do
      stub_request(:post, /graph.facebook.com/)
    end

    let!(:facebook_channel) { create(:channel_facebook_page, account: account) }
    let!(:facebook_inbox) { create(:inbox, channel: facebook_channel, account: account) }
    let(:mail) { described_class.with(account: account).facebook_disconnect(facebook_inbox).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('A conexão da sua página do Facebook expirou')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end

  describe 'whatsapp_disconnect' do
    let!(:whatsapp_channel) { create(:channel_whatsapp, provider: 'whatsapp_cloud', sync_templates: false, validate_provider_config: false) }
    let!(:whatsapp_inbox) { create(:inbox, channel: whatsapp_channel, account: account) }
    let(:mail) { described_class.with(account: account).whatsapp_disconnect(whatsapp_inbox).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Sua conexão com o Whatsapp expirou')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end

  describe 'contact_import_complete' do
    let!(:data_import) { build(:data_import, total_records: 10, processed_records: 10) }
    let(:mail) { described_class.with(account: account).contact_import_complete(data_import).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Importação de contatos concluída')
    end

    it 'renders the processed records' do
      expect(mail.body.encoded).to match('Número de registros importados: 10')
      expect(mail.body.encoded).to match('Número de registros com falha: 0')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end

  describe 'contact_export_complete' do
    let!(:file_url) { 'http://test.com/test' }
    let(:mail) { described_class.with(account: account).contact_export_complete(file_url, administrator.email).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq("O arquivo de exportação do seus contatos está disponível para download.")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([administrator.email])
    end
  end
end
