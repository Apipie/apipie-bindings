class CommentsController < ApplicationController
  include Concerns::DummyConcern

  api!
  api :GET, "archive/comments/:id/"
  api :GET, "archive/users/:user_id/comments/:id/"
  param :id, Integer, :required => true
  param :user_id, Integer
  param :post_id, Integer
  def archive
    params[:user_id] ||= 1
    params[:post_id] ||= 1
    render :json => Dummy::Store.show(base_path)
  end

  protected

  def base_path
    "/users/#{params[:user_id]}/posts/#{params[:post_id]}/comments"
  end
end
