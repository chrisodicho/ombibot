require "httparty"
require "uri"

OMBI_API_KEY = ENV["OMBI_API_KEY"]
OMBI_URL = ENV["OMBI_URL"]

module OmbiBot
  module Commands
    class Request < SlackRubyBot::Commands::Base
      command /(m|mov|movi|movie)/ do |client, data, match|
        query = URI.escape(match["expression"])
        body = JSON.parse(HTTParty.get(
          "#{OMBI_URL}/api/v1/Search/movie/#{query}",
          {
            headers: {
              "ApiKey" => OMBI_API_KEY,
            },
          }
        ).body)

        build_message = -> {
          {
            channel: data.channel,
            text: "Showing first #{[3, body.size].min} of #{body.size} results for \"#{match["expression"]}\":",
            fallback: "use a full-featured slack client to use OmbiBot",
            attachments: body.first(3).map do |movie|
              already_exists = !!movie["available"]
              request_action = {
                name: "request",
                text: "Request #{movie["title"]}",
                type: "button",
                value: movie["id"],
              }
              {
                author_name: already_exists ? 'Already available on Plex' : nil,
                author_link: movie['plexUrl'],
                title: "#{movie["title"]} (#{movie["releaseDate"][0..3]})",
                title_link: "https://www.themoviedb.org/movie/#{movie["theMovieDbId"]}",
                thumb_url: "https://image.tmdb.org/t/p/w300/#{movie["posterPath"]}",
                text: movie["overview"][0..200] + "...",
                callback_id: "movie_request",
                actions: already_exists ? [] : [request_action],
              }
            end,
          }
        }

        client.web_client.chat_postMessage(build_message.call)
      end

      command /(t|tv|show|tvshow|series)/ do |client, data, match|
        query = URI.escape(match["expression"])
        body = JSON.parse(HTTParty.get(
          "#{OMBI_URL}/api/v1/Search/tv/#{query}",
          {
            headers: {
              "ApiKey" => OMBI_API_KEY,
            },
          }
        ).body)

        build_message = -> {
          {
            channel: data.channel,
            text: "Showing first #{[3, body.size].min} of #{body.size} results for \"#{match["expression"]}\":",
            fallback: "use a full-featured slack client to use OmbiBot",
            attachments: body.first(3).map do |tv|
              already_exists = !!tv["plexUrl"]
              request_action = {
                name: "request",
                text: "Request #{tv["title"]}",
                type: "button",
                value: tv["id"],
              }
              {
                author_name: already_exists ? 'Already available on Plex' : nil,
                author_link: tv['plexUrl'],
                title: "#{tv["title"]} (#{tv["firstAired"][0..3]})",
                title_link: "https://www.thetvdb.com/?id=#{tv["theTvDbId"]}&tab=series",
                thumb_url: tv["banner"],
                text: tv["overview"][0..200] + "...",
                callback_id: "tv_request",
                actions: already_exists ? [] : [request_action],
              }
            end,
          }
        }

        client.web_client.chat_postMessage(build_message.call)
      end
    end
  end
end
