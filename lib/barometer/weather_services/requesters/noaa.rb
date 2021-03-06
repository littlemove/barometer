require 'httparty'

module Barometer
  module Requester
    class Noaa
      include HTTParty

      def initialize(metric=true)
        @metric = metric
      end

      def get_current(station_id)
        puts "fetch NOAA current weather: #{station_id}" if Barometer::debug?

        response = _get("http://w1.weather.gov/xml/current_obs/#{station_id}.xml")

        output = Barometer::XmlReader.parse(response, "current_observation")
        Barometer::Payload.new(output)
      end

      def get_forecast(query)
        puts "fetch NOAA forecast: #{query.q}" if Barometer::debug?

        response = _get("http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php", query)

        output = Barometer::XmlReader.parse(response, "dwml", "data")
        Barometer::Payload.new(output)
      end

      private

      attr_reader :metric

      def _get(path, query=nil)
        self.class.get(
          path,
          :query => _format_request(query).merge(_format_query(query)),
          :format => :plain,
          :timeout => Barometer.timeout
        )
      end

      def _format_request(query)
        return {} unless query

        { :format => "24 hourly", :numDays => "7" }
      end

      def _format_query(query)
        return {} unless query

        case query.format.to_sym
        when :short_zipcode
          { :zipCodeList => query.q }
        when :zipcode
          { :zipCodeList => query.q }
        when :coordinates
          { :lat => query.q.split(',')[0], :lon => query.q.split(',')[1] }
        else
          {}
        end
      end
    end
  end
end
