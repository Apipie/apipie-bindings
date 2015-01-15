class CommentsController < ApplicationController
  include Concerns::DummyConcern

  protected

  def base_path
    "/users/#{params[:user_id]}/posts/#{params[:post_id]}/comments"
  end
end
