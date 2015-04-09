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
    param :vip, :bool
    param :address, Hash do
      param :city, String, required: true
      param :street, String
    end
    param :contacts, Array do
      param :contact, String, required: true
      param :kind, String
    end
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
