module Concerns
  module DummyConcern
    extend Apipie::DSL::Concern
    include ActiveSupport::Concern

    api!
    def index
      render :json => Dummy::Store.index(base_path)
    end

    api!
    def show
      render :json => Dummy::Store.show("#{base_path}/#{params[:id]}")
    end

    api!
    def create
      render :json => params
    end

    api!
    def update
      render :json => Dummy::Store.show("#{base_path}/#{params[:id]}")
    end

    api!
    def destroy
      render :json => []
    end

    protected

    def base_path
      raise NotImplementedError
    end

  end
end
