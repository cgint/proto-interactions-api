defmodule InteractionsPlayground.Config do
  @interactions_base "https://generativelanguage.googleapis.com/v1beta/interactions"
  @default_model "gemini-2.5-flash"

  def default_model, do: @default_model

  def interactions_url do
    @interactions_base
  end

  def require_api_key do
    System.get_env("GEMINI_API_KEY") || System.get_env("GOOGLE_API_KEY") ||
      raise(RuntimeError,
        message: "Missing API key: set GEMINI_API_KEY (or GOOGLE_API_KEY) in your environment."
      )
  end
end
