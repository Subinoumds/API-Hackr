require 'resolv'

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
      UserMailer.welcome_email(@user).deliver_later
      log_action('create', 'User')
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

  def generate_secure_password
    password = SecureRandom.base64(15)
    render json: { password: password }
  end

  def check_email_existence
    email = params[:email]

    if valid_email_format?(email) && domain_exists?(email)
      render json: { exists: true, message: 'Adresse mail potentiellement valide.' }
    else
      render json: { exists: false, message: 'Adresse mail invalide ou domaine inexistant.' }
    end
  end

  def is_common_password
    password = params[:password]

    if common_password?(password)
      render json: { common: true, message: 'Le mot de passe est courant.' }
    else
      render json: { common: false, message: 'Le mot de passe est sécurisé.' }
    end
  end

  private

  def common_password?(password)
    common_passwords = File.readlines(Rails.root.join('lib', 'seclists', '10k-most-common.txt')).map(&:chomp)
    common_passwords.include?(password)
  end

  def valid_email_format?(email)
    /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(email)
  end

  def domain_exists?(email)
    domain = email.split('@').last
    mx_records = Resolv::DNS.open { |dns| dns.getresources(domain, Resolv::DNS::Resource::IN::MX) }
    mx_records.any?
  rescue Resolv::ResolvError
    false
  end

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