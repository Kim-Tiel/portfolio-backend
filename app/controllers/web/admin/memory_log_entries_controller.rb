module Web
  module Admin
    class MemoryLogEntriesController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!
      before_action :set_entry, only: %i[show destroy approve]

      def index
        @entries = MemoryLogEntry.all
      end

      def show; end

      def destroy
        @entry.destroy
        redirect_to admin_memory_log_entries_path, notice: 'Entry removed.'
      end

      # approve action to mark as approved for public listing
      def approve
        @entry.update(is_approved: true)
        redirect_to admin_memory_log_entries_path, notice: 'Entry approved.'
      end

      private

      def set_entry
        @entry = MemoryLogEntry.find(params[:id])
      end
    end
  end
end
