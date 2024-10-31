# app/controllers/api/v1/random_images_controller.rb

module Api
    module V1
      class RandomImagesController < ApplicationController
        def show
          width = params[:width] || 300
          height = params[:height] || 300
  
          # Génère l'URL de l'image aléatoire
          random_image_url = "https://picsum.photos/#{width}/#{height}"
  
          render json: { image_url: random_image_url }, status: :ok
        end
      end
    end
  end
  