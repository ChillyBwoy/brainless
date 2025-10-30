defmodule Mix.Tasks.BuildIndex do
  @moduledoc "Build vector index"

  use Mix.Task

  alias Brainless.MediaLibrary
  alias Brainless.MediaLibrary.Movie
  alias Brainless.Rag
  alias Brainless.Repo

  @requirements ["app.start", "app.config"]

  @chunk_size 100

  def run(_) do
    rebuild_movies_index()
  end

  defp rebuild_movies_index() do
    movies = MediaLibrary.list_movies() |> Repo.preload([:director, :cast, :genres])

    update_embeddings(
      movies,
      &Movie.format_for_embedding(&1),
      &"Movie [#{&1.id}] #{&1.title}",
      &MediaLibrary.update_movie(&1, %{embedding: &2})
    )
  end

  defp update_embeddings(all_items, get_index_data, get_entity_repr, update) do
    all_items
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(fn items ->
      texts = Enum.map(items, &get_index_data.(&1))
      {:ok, embeddings} = Rag.to_vector_list(texts)

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
end
