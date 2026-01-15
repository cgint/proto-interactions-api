defmodule InteractionsPlayground.Config do
  @interactions_base_url "https://generativelanguage.googleapis.com"
  @interactions_version "v1beta"
  @default_model "gemini-2.5-flash"

  def interactions_url do
    "#{@interactions_base_url}/#{@interactions_version}/interactions"
  end

  def default_model, do: @default_model

  def require_api_key do
    System.get_env("GEMINI_API_KEY") || System.get_env("GOOGLE_API_KEY") ||
      raise("""
      Missing API key: set GEMINI_API_KEY (or GOOGLE_API_KEY) in your environment.
      """)
  end
end

