class UsersController < ApplicationController
  include Concerns::DummyConcern

  api!
  example <<-EXAMPLE
GET /users
200
[ {"user":{"name":"John Doe" }} ]
EXAMPLE
  def index
    super
  end

  api!
  param :user, Hash do
    param :name, String, required: true
  end
  def create
    super
  end

  api!
  param :name, String, required: true
  def create_unnested
  end

  protected

  def base_path
    '/users'
  end
end
