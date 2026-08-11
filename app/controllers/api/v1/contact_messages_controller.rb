module Api
  module V1
    class ContactMessagesController < ApplicationController
      def create
        message = ContactMessage.new(contact_message_params)
        message.ip_hash = Digest::SHA256.hexdigest(request.remote_ip.to_s)

        if message.save
          render json: { status: 'sent' }, status: :created
        else
          render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def contact_message_params
        params.require(:contact_message).permit(:name, :email, :subject, :body)
      end
    end
  end
end
