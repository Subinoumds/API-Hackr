class PhishingPageGenerator
    def self.generate_phishing_page(target_email, fake_url, content, input_path, output_path)
      html = File.read(input_path)
  
      html.gsub!(/<\/body>/, <<~HTML + '</body>')
        <div>
          <h2>Cher utilisateur, votre attention est requise !</h2>
          <p>#{content}</p>
          <a href="#{fake_url}" style="color: red;">Vérifiez ici</a>
        </div>
      HTML
  
      File.open(output_path, 'w') { |file| file.write(html) }
      Rails.logger.info "Page phishing générée avec succès dans #{output_path}."
    end
  end
  