require "sinatra/base"

module OmbiBot
  class Web < Sinatra::Base
    get "/" do
      "Math is good for you."
    end
  end
end
