require 'resolv'
require 'net/http'
require 'uri'

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

  def crawl_person_info
    name = params[:name]
    surname = params[:surname]
    render json: { message: "Informations pour #{name} #{surname}", name: name, surname: surname }
  end

  def get_person_info
    name = params[:name]
    person_info = fetch_wikipedia_data(name)
  
    if person_info[:error].nil?
      render json: {
        title: person_info[:title],
        snippet: person_info[:snippet],
        url: person_info[:url]
      }, status: :ok
    else
      render json: { error: person_info[:error] }, status: :not_found
    end
  end  

  private

  def fetch_wikipedia_data(name)
    encoded_name = URI.encode_www_form_component(name)
    url = "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=#{encoded_name}&utf8=&formatversion=2"
  
    response = Net::HTTP.get(URI(url))
  
    response.force_encoding('UTF-8') if response.respond_to?(:force_encoding)
  
    puts "Réponse de l'API : #{response}" 
    json_response = JSON.parse(response)
  
    if json_response['query'] && json_response['query']['search'].any?
      page_info = json_response['query']['search'].first
      {
        title: page_info['title'],
        snippet: ActionController::Base.helpers.strip_tags(page_info['snippet']),
        url: "https://en.wikipedia.org/wiki/#{URI.encode_www_form_component(page_info['title'])}"
      }
    else
      { error: 'Aucune information trouvée' }
    end
  rescue StandardError => e
    puts "Erreur : #{e.message}" 
    { error: e.message }
  end  
  
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