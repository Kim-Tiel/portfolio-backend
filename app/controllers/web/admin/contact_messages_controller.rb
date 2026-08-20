module Web
  module Admin
    class ContactMessagesController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_message, only: %i[show destroy]

      def index
        @messages = ContactMessage.all
      end

      def show; end

      def destroy
        @message.destroy
        redirect_to admin_contact_messages_path, notice: 'Message removed.'
      end

      private

      def set_message
        @message = ContactMessage.find(params[:id])
      end
    end
  end
end
