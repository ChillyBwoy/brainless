defmodule Brainless.Rag.Generation.Provider do
  @callback generate(String.t()) :: {:error, term()} | {:ok, [String.t()] | nil}

  defmacro __using__(_opts) do
    quote do
      @behaviour Brainless.Rag.Generation.Provider
    end
  end
end
