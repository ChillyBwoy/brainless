defmodule Brainless.ShopFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Brainless.Shop` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        author: "some author",
        description: "some description",
        is_available: true,
        isbn: "some isbn",
        name: "some name",
        price: 42,
        published_at: ~D[2025-10-26]
      })
      |> Brainless.Shop.create_book()

    book
  end
end
