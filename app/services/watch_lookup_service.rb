require "net/http"
require "json"

class WatchLookupService
  MODEL = "gemini-3.6-flash"
  ENDPOINT = URI("https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent")

  ##
  # Initializes a new instance of the WatchLookupService.
  #
  # @param query [String] The watch name to look up.
  def initialize(query)
    @query = query
  end

  ##
  # Calls the Gemini API to look up the watch information.
  #
  # @return [Hash] The parsed JSON response from the API.
  def call
    uri = ENDPOINT.dup
    uri.query = URI.encode_www_form(key: ENV.fetch("GEMINI_API_KEY"))

    response = Net::HTTP.post(
      uri,
      body.to_json,
      { "content-type" => "application/json" }
    )

    parse(response)
  end

private

  ##
  # Constructs the request body for the Gemini API.
  #
  # @return [Hash] The request body as a hash.
  def body
    {
      contents: [{ parts: [{ text: prompt }] }]
    }
  end

  ##
  # Constructs the prompt for the Gemini API.
  #
  # @return [String] The prompt string.
  def prompt
    <<~PROMPT
      You are a horology expert. For the watch "#{@query}", respond with ONLY
      valid JSON (no markdown, no prose, no code fences) matching this shape:
      {
        "brand": "", "model": "", "movement": "", "case_diameter": "",
        "water_resistance": "", "price_range": "", "notable_trivia": ""
      }
      If you don't recognize the watch, do your best educated guess and note
      that in notable_trivia.
    PROMPT
  end

  ##
  # Parses the response from the Gemini API.
  #
  # @param response [Net::HTTPResponse] The HTTP response from the API.
  # @return [Hash] The parsed JSON response or an error message if parsing fails.
  def parse(response)
    data = JSON.parse(response.body)
    text = data.dig("candidates", 0, "content", "parts", 0, "text")
    text = text.gsub(/```json|```/, "").strip
    JSON.parse(text)
  rescue JSON::ParserError, NoMethodError
    { error: "Couldn't parse a result for that one — try a different watch." }
  end
end