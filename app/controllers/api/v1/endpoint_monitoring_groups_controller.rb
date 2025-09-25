module Api
  module V1
    class EndpointMonitoringGroupsController < ApplicationController
      before_action :set_group, only: %i[show update destroy]

      def index
        groups = EndpointMonitoringGroup.includes(:endpoint_monitoring_endpoints)
        render json: EndpointMonitoringGroupSerializer.new(groups).serializable_hash, status: :ok
      end

      def show
        render json: EndpointMonitoringGroupSerializer.new(@group).serializable_hash, status: :ok
      end

      def create
        group = EndpointMonitoringGroup.new(group_params)
        if group.save
          render json: EndpointMonitoringGroupSerializer.new(group).serializable_hash, status: :created
        else
          render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @group.update(group_params)
          render json: EndpointMonitoringGroupSerializer.new(@group).serializable_hash, status: :ok
        else
          render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @group.destroy
          render json: { message: "Group deleted successfully" }, status: :ok
        else
          render json: { message: "Failed to delete group" }, status: :unprocessable_entity
        end
      end

      private

      def set_group
        @group = EndpointMonitoringGroup.includes(:endpoint_monitoring_endpoints).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: "Group not found" }, status: :not_found
      end

      def group_params
        params.require(:endpoint_monitoring_group).permit(
          :name,
          :group_type,
          endpoint_monitoring_endpoints_attributes: [
            :id,
            :endpoint_name,
            :host,
            :monitoring_mode,
            :port,
            :latency_critical,
            :latency_warning,
            :packet_loss_critical,
            :packet_loss_warning,
            :response_time,
            :_destroy,
            acceptable_response_codes: []
          ]
        )
      end
    end
  end
end
