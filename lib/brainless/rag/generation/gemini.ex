defmodule Brainless.Rag.Generation.Gemini do
  use Brainless.Rag.Generation.Provider

  @impl true
  def generate(input) do
    msg = %{
      role: "user",
      content: input
    }

    case ExLLM.chat(:gemini, [msg]) do
      {:ok, %ExLLM.Types.LLMResponse{} = response} ->
        dbg({"Brainless.Rag.Generation.Gemini", response})
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
