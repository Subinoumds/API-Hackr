class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    authorize model, :index?
    @users = params[:q].blank? ? scope : scope.search(params[:q])
    @users = @users.page(params[:page])

    render json: @users
  end

  def show
    authorize model, :show?
    render json: @user
  end

  def new
    @user = scope.new
    @roles = User::ROLES
    authorize @user, :create?
  end

  def create
    @user = User.new(user_params)
    authorize @user, :create?

    if @user.save
      UserMailer.welcome_email(user).deliver_later
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user, :update?
  end

  def update
    authorize @user, :update?

    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user, :destroy?
    @user.destroy!
    render json: { message: 'User deleted successfully' }, status: :ok
  end

  def check_email
    email = params[:email]
    user_exists = User.exists?(email: email)
    
    render json: { exists: user_exists }
  end

  def generate_fake_identity
    fake_name = Faker::Name.name
    fake_email = Faker::Internet.email

    render json: { name: fake_name, email: fake_email }
  end

  private

  def model
    User
  end

  def set_user
    @user = User.find(params[:id]) if params[:id]
  end

  def user_params
    params.require(:user).permit(:email, :password, :role)
  end
end