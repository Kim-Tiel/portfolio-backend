module Api
  module V1
    class MemoryLogEntriesController < ApplicationController
      PAGE_SIZE = 50
      MAX_BODY_BYTES = 8_000

      before_action :reject_oversized_body, only: :create

      def index
        entries = MemoryLogEntry.approved.limit(PAGE_SIZE)
        render json: entries.map { |entry| entry_json(entry) }
      end

      def create
        if honeypot_tripped?
          render json: { status: 'ok' }, status: :created
          return
        end

        entry = MemoryLogEntry.new(memory_log_entry_params.except(:nickname))
        entry.ip_hash = MemoryLogEntry.hash_ip(request.remote_ip)

        if entry.save
          render json: entry_json(entry), status: :created
        else
          render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def reject_oversized_body
        return if request.content_length.to_i <= MAX_BODY_BYTES

        render json: { errors: ['Request too large'] }, status: :payload_too_large
      end

      def honeypot_tripped?
        memory_log_entry_params[:nickname].present?
      end

      # Only these keys are ever accepted; is_approved / ip_hash are not
      # assignable from params.
      def memory_log_entry_params
        params.require(:memory_log_entry).permit(:display_name, :message, :nickname)
      end

      # The ONLY shape any Memory Log response takes.
      def entry_json(entry)
        {
          id: entry.id,
          display_name: entry.display_name,
          message: entry.message,
          created_at: entry.created_at
        }
      end
    end
  end
end
