defmodule Brainless.Rag.Embedding.Gemini do
  @moduledoc """
    See https://developers.googleblog.com/en/gemini-embedding-available-gemini-api/
  """
  use Brainless.Rag.Embedding.Provider

  @model_gemini "models/text-embedding-004"

  @impl true
  def to_vector(input) do
    case ExLLM.Providers.Gemini.Embeddings.embed_text(@model_gemini, input) do
      {:ok, %{values: vector}} ->
        {:ok, vector}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def to_vector_list(inputs) do
    case ExLLM.Providers.Gemini.Embeddings.embed_texts(@model_gemini, inputs,
           cache: true,
           cache_ttl: :timer.minutes(10)
         ) do
      {:ok, values} ->
        {:ok, Enum.map(values, fn %{values: embeddings} -> embeddings end)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
