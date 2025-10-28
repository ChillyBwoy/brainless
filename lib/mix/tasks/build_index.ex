defmodule Mix.Tasks.BuildIndex do
  @moduledoc "Build vector index"

  use Mix.Task

  alias Brainless.Shop
  alias Brainless.Rag.Embedding

  @requirements ["app.start"]

  def run(_) do
    Shop.list_books()
    |> Enum.each(fn book ->
      %{embedding: embedding} = Embedding.predict(book.name)

      case Shop.update_book(book, %{embedding: embedding}) do
        {:ok, _} ->
          dbg({"updated", book.id, book.name})

        {:error, changeset} ->
          dbg({"error", book.id, book.name, changeset.errors})
      end
    end)
  end
end
