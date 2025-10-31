defmodule Brainless.Rag.Generation do
  use Brainless.Rag.Generation.Provider

  @impl true
  def generate(input) do
    case Brainless.Rag.Config.generation_provider() do
      :gemini -> Brainless.Rag.Generation.Gemini.generate(input)
      :bumblebee -> Brainless.Rag.Generation.Bumblebee.generate(input)
    end
  end
end
