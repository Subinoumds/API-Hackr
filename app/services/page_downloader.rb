require 'net/http'
require 'uri'

class PageDownloader
  def self.download_page(url, output_path)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      File.open(output_path, 'w') { |file| file.write(response.body) }
      Rails.logger.info "Page téléchargée et enregistrée dans #{output_path}."
    else
      Rails.logger.error "Erreur : Impossible de télécharger la page."
    end
  end
end
