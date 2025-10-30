defmodule Brainless.Rag.Config do
  def provider do
    case get_key(:provider) do
      "bumblebee" -> :bumblebee
      "gemini" -> :gemini
      _ -> nil
    end
  end

  def hf_token, do: get_key(:hf_token)

  defp get_key(key), do: Application.fetch_env!(:brainless, Brainless.Rag) |> Keyword.fetch!(key)
end
