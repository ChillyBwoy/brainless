defmodule Mix.Tasks.BuildIndex do
  @moduledoc "Build vector index"

  use Mix.Task

  alias Brainless.Shop
  alias Brainless.MediaLibrary
  alias Brainless.Rag.Embedding

  @requirements ["app.start", "app.config"]

  def run(_) do
    case Application.fetch_env!(:brainless, :ai_provider) do
      "gemini" ->
        update_books_embeddings(:gemini)
        update_movies_embeddings(:gemini)

      "bumblebee" ->
        update_books_embeddings(:bumblebee)
        update_movies_embeddings(:bumblebee)
    end
  end

  defp update_embeddings(:gemini, all_items, chunks, get_index_data, get_entity_repr, update) do
    all_items
    |> Enum.chunk_every(chunks)
    |> Enum.map(fn items ->
      texts = Enum.map(items, &get_index_data.(&1))
      {:ok, embeddings} = Embedding.predict_many(:gemini, texts)

      if length(embeddings) != length(items) do
        raise "embeddings size != items size"
      end

      Enum.with_index(items)
      |> Enum.map(fn {entity, idx} ->
        embedding = Enum.at(embeddings, idx)

        case update.(entity, embedding) do
          {:ok, updated_entity} ->
            IO.puts("ok: #{get_entity_repr.(updated_entity)}")
            updated_entity

          {:error, _changeset} ->
            IO.puts("error: #{get_entity_repr.(entity)}")
            entity
        end
      end)
    end)
    |> List.flatten()
  end

  defp update_movies_embeddings(:gemini) do
    movies = MediaLibrary.list_movies()

    update_embeddings(
      :gemini,
      movies,
      50,
      & &1.description,
      &"Movie [#{&1.id}] #{&1.title}",
      &MediaLibrary.update_movie(&1, %{embedding: &2})
    )
  end

  defp update_movies_embeddings(:bumblebee) do
    []
  end

  defp update_books_embeddings(:gemini) do
    books = Shop.list_books()

    update_embeddings(
      :gemini,
      books,
      50,
      & &1.description,
      &"Book: [#{&1.id}] [#{&1.name}]",
      &Shop.update_book(&1, %{embedding: &2})
    )
  end

  defp update_books_embeddings(:bumblebee) do
    Shop.list_books()
    |> Enum.map(fn book ->
      %{embedding: embedding} = Embedding.predict(:bumblebee, book.description)

      case Shop.update_book(book, %{embedding: embedding}) do
        {:ok, updated_book} ->
          dbg({"updated", book.id, book.name})
          updated_book

        {:error, changeset} ->
          dbg({"error", book.id, book.name, changeset.errors})
          book
      end
    end)
  end
end
