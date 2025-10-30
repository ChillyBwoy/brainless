defmodule Brainless.Rag do
  alias Brainless.Rag.Embedding
  alias Brainless.Rag.Generation
  alias Brainless.Rag.Retrieval

  def generate(query) when is_binary(query) do
    Embedding.to_vector(query)
    |> Retrieval.retrieve()
    |> format_prompt(query)
    |> Generation.generate()
  end

  defp format_prompt(_context, query) do
    # TODO: add formatted query
    # """
    # Use the following context to respond to the following query.
    # Context:
    # #{Enum.map_join(context, "\n", & &1)}
    # Query: #{query}
    # """

    query
  end

  def to_vector(text) when is_binary(text), do: Embedding.to_vector(text)

  def to_vector_list(texts) when is_list(texts), do: Embedding.to_vector_list(texts)
end
