module Api
  module V1
    class MemoryLogEntriesController < ApplicationController
      PAGE_SIZE = 50

      def index
        entries = MemoryLogEntry.approved.limit(PAGE_SIZE)
        render json: entries.map { |e|
          { id: e.id, display_name: e.display_name, message: e.message, created_at: e.created_at }
        }
      end

      def create
        entry = MemoryLogEntry.new(memory_log_entry_params)
        entry.ip_hash = Digest::SHA256.hexdigest(request.remote_ip.to_s)

        if entry.save
          render json: { id: entry.id, display_name: entry.display_name, message: entry.message, created_at: entry.created_at },
                 status: :created
        else
          render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def memory_log_entry_params
        params.require(:memory_log_entry).permit(:display_name, :message)
      end
    end
  end
end
