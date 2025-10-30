defmodule Brainless.Rag.Embedding do
  use Brainless.Rag.Embedding.Provider

  @impl true
  def to_vector(input) do
    case Brainless.Rag.Config.provider() do
      :gemini -> Brainless.Rag.Embedding.Gemini.to_vector(input)
      :bumblebee -> Brainless.Rag.Embedding.Bumblebee.to_vector(input)
    end
  end

  @impl true
  def to_vector_list(inputs) do
    case Brainless.Rag.Config.provider() do
      :gemini -> Brainless.Rag.Embedding.Gemini.to_vector_list(inputs)
      :bumblebee -> Brainless.Rag.Embedding.Bumblebee.to_vector_list(inputs)
    end
  end
end
