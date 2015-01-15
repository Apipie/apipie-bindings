class PostsController < ApplicationController
  include Concerns::DummyConcern

  protected

  def base_path
    "/users/#{params[:user_id]}/posts"
  end
end
