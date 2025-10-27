NimbleCSV.define(BrainlessSeedParser, separator: ",", escape: "\"")

defmodule Mix.Tasks.Seed do
  @moduledoc "Seed the database"

  use Mix.Task

  alias Brainless.Shop
  alias Brainless.Shop.Book

  @requirements ["app.start"]

  def run(_) do
    "priv/data/books.csv"
    |> File.stream!()
    |> BrainlessSeedParser.parse_stream()
    |> Stream.map(fn [name, description, price, is_available, isbn, author, published_at] ->
      attrs = %{
        name: name,
        description: description,
        price: String.to_integer(price),
        is_available:
          case is_available do
            "true" -> true
            _ -> false
          end,
        isbn: isbn,
        author: author,
        published_at: Date.from_iso8601!(published_at)
      }

      case Shop.create_book(attrs) do
        {:ok, %Book{}} ->
          IO.puts("Imported \"#{name}\"")

        {:error, %Ecto.Changeset{} = changeset} ->
          IO.puts({"Unable to import \"#{name}\"", changeset.errors})
      end
    end)
    |> Stream.run()
  end
end
