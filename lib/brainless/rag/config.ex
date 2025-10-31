defmodule Brainless.Rag.Config do
  defp get_provider(name) do
    case name do
      "bumblebee" -> :bumblebee
      "gemini" -> :gemini
      _ -> nil
    end
  end

  defp get_key(key), do: Application.fetch_env!(:brainless, Brainless.Rag) |> Keyword.fetch!(key)

  def embedding_provider, do: get_key(:embedding_provider) |> get_provider()
  def generation_provider, do: get_key(:generation_provider) |> get_provider()
  def hf_token, do: get_key(:hf_token)
end
