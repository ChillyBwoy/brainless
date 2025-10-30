defmodule Brainless.Rag.Embedding.Bumblebee do
  @moduledoc """
  List of compatible models with 768 dimensions
    - sentence-transformers/gtr-t5-base

  """
  use Brainless.Rag.Embedding.Provider
  require Logger

  @model_repo {:hf, "sentence-transformers/gtr-t5-base"}

  @spec serving() :: Nx.Serving.t()
  def serving do
    {:ok, model_info} = Bumblebee.load_model(@model_repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(@model_repo)

    Logger.info("Starting Bumblebee...")

    Bumblebee.Text.text_embedding(model_info, tokenizer,
      embedding_processor: :l2_norm,
      defn_options: [compiler: EXLA],
      output_attribute: :hidden_state,
      output_pool: :mean_pooling
    )
  end

  @impl true
  @spec to_vector(any()) :: {:error, <<_::40>>} | {:ok, any()}
  def to_vector(input) do
    case Nx.Serving.batched_run(__MODULE__, input) do
      %{embedding: embedding} -> {:ok, embedding}
      _ -> {:error, "error"}
    end
  end

  @impl true
  def to_vector_list(inputs) do
    case Nx.Serving.batched_run(__MODULE__, inputs) do
      values when is_list(values) ->
        {:ok, Enum.map(values, fn %{embedding: embedding} -> embedding end)}

      _ ->
        {:error, "error"}
    end
  end
end
