module Api
  module V1
    class EndpointConfigurationsController < ApplicationController
      before_action :set_config, only: [ :show, :update, :destroy ]

      def index
        configs = EndpointConfiguration.all
        render json: EndpointConfigurationSerializer.new(configs).serializable_hash, status: :ok
      end

      def show
        render json: EndpointConfigurationSerializer.new(@config).serializable_hash, status: :ok
      end

      def create
        config = EndpointConfiguration.new(config_params)
        if config.save
          render json: EndpointConfigurationSerializer.new(config).serializable_hash, status: :created
        else
          render json: { errors: config.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @config.update(config_params)
          render json: EndpointConfigurationSerializer.new(@config).serializable_hash, status: :ok
        else
          render json: { errors: @config.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @config.destroy
          render json: { message: "Configuration deleted successfully" }, status: :ok
        else
          render json: { message: "Failed to delete configuration" }, status: :unprocessable_entity
        end
      end

      private

      def set_config
        @config = EndpointConfiguration.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { message: "Configuration not found" }, status: :not_found
      end

      def config_params
        params.require(:endpoint_configuration).permit(
          :tenant_id,
          :endpoint_monitoring_group_id,
          :router_id
        )
      end
    end
  end
end
