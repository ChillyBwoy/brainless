defmodule Brainless.Rag.Generation.Bumblebee do
  use Brainless.Rag.Generation.Provider
  require Logger

  @model_repo {:hf, "mistralai/Mistral-7B-Instruct-v0.2"}

  def serving do
    # model_repo = {:hf, "google/gemma-1.1-2b-it", [auth_token: Brainless.Rag.Config.hf_token()]}
    {:ok, model_info} = Bumblebee.load_model(@model_repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(@model_repo)
    {:ok, generation_config} = Bumblebee.load_generation_config(@model_repo)

    Logger.info("Starting Bumblebee generator...")

    Bumblebee.Text.generation(model_info, tokenizer, generation_config,
      compile: [batch_size: 1, sequence_length: 1028],
      defn_options: [compiler: EXLA],
      stream: true
    )
  end

  @impl true
  def generate(input) do
    case Nx.Serving.batched_run(__MODULE__, input) do
      %{results: results} when is_list(results) ->
        dbg({"Brainless.Rag.Generation.Bumblebee", results})
        {:ok, Enum.map(results, fn %{text: text} -> text end)}

      _ ->
        {:error, "error"}
    end
  end
end
