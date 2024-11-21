module Api
    module V1
      class RandomImagesController < ApplicationController
        def show
          width = params[:width] || 300
          height = params[:height] || 300
  
          random_image_url = "https://picsum.photos/#{width}/#{height}"
  
          render json: { image_url: random_image_url }, status: :ok
        end
      end
    end
  end
  