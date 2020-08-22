require "sinatra/base"
require "uri"
require "httparty"

OMBI_URL = ENV["OMBI_URL"]
OMBI_API_KEY = ENV["OMBI_API_KEY"]
OMBI_API_USERNAME = ENV["API_USERNAME"]

module OmbiBot
  class Web < Sinatra::Base
    get "/" do
      "Math is good for you."
    end
    post "/" do
      body = JSON.parse(URI.decode(request.body.read)[8..-1])
      type = body["callback_id"]

      if type == 'tv_request'
        begin
          body = {
            "theTvDbId" => body["actions"][0]["value"].to_i,
            "languageCode" => "en",
          }.to_json
          res = HTTParty.post(
            "#{OMBI_URL}/api/v1/Request/tv",
            headers: {"UserName" => OMBI_API_USERNAME, "ApiKey" => OMBI_API_KEY, "Content-Type" => "application/json"},
            body: body,
          )
          return res.parsed_response["message"]
        rescue => exception
          puts "exception: " + exception.to_s
        end
      end

      if type == "movie_request"
        begin
          body = {
            "theMovieDbId" => body["actions"][0]["value"].to_i,
            "languageCode" => "en",
          }.to_json
          res = HTTParty.post(
            "#{OMBI_URL}/api/v1/Request/movie",
            headers: {"UserName" => OMBI_API_USERNAME, "ApiKey" => OMBI_API_KEY, "Content-Type" => "application/json"},
            body: body,
          )
          return res.parsed_response["message"]
        rescue => exception
          puts "exception: " + exception.to_s
        end
      end
    end
  end
end
