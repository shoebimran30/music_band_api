# frozen_string_literal: true

module Api
  module V1
    # app/controllers/api/v1/bands_controller.rb
    class BandsController < ApplicationController
      BASE_URL = 'https://musicbrainz.org/ws/2/artist'
      GEOLOCATION_URL = 'https://get.geojs.io/v1/ip/geo.json'

      def search
        city = params[:city] || fetch_fallback_city
        return render json: { error: 'City is required' }, status: :bad_request unless city.present?

        bands = fetch_bands(city)
        render json: bands
      end

      def location
        location_data = fetch_location_from_ip
        if location_data
          render json: { city: location_data['city'], region: location_data['region'] }
        else
          render json: { error: 'Unable to retrieve location' }, status: :service_unavailable
        end
      end

      private

      def fetch_bands(city)
        response = make_musicbrainz_request(city)
        response.success? ? parse_bands(response, city) : []
      end

      def make_musicbrainz_request(city)
        HTTParty.get(BASE_URL, {
                       query: musicbrainz_query(city),
                       headers: {
                         'User-Agent' => 'MusicBandsAPI/1.0 (your-email@example.com)'
                       }
                     })
      end

      def musicbrainz_query(city)
        {
          query: "area:\"#{city}\" AND begin:[#{10.years.ago.year} TO *]",
          fmt: 'json'
        }
      end

      def parse_bands(response, city)
        parsed_response = JSON.parse(response.body)
        parsed_response['artists'].map do |artist|
          {
            name: artist['name'],
            city: city,
            founded: artist['begin-area'],
            type: artist['type']
          }
        end.take(50)
      end

      def fetch_fallback_city
        location_data = fetch_location_from_ip
        location_data ? location_data['city'] : nil
      end

      def fetch_location_from_ip
        response = HTTParty.get(GEOLOCATION_URL)
        response.success? ? JSON.parse(response.body) : nil
      end
    end
  end
end
