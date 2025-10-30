defmodule Brainless.Rag.Embedding.Provider do
  @callback to_vector(String.t()) :: {:error, term()} | {:ok, [float()]}
  @callback to_vector_list([String.t()]) :: {:error, map()} | {:ok, [[float()]]}

  defmacro __using__(_opts) do
    quote do
      @behaviour Brainless.Rag.Embedding.Provider
    end
  end
end
