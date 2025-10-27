defmodule Brainless.ShopTest do
  use Brainless.DataCase

  alias Brainless.Shop

  describe "books" do
    alias Brainless.Shop.Book

    import Brainless.ShopFixtures

    @invalid_attrs %{name: nil, description: nil, author: nil, price: nil, is_available: nil, isbn: nil, published_at: nil}

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Shop.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Shop.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{name: "some name", description: "some description", author: "some author", price: 42, is_available: true, isbn: "some isbn", published_at: ~D[2025-10-26]}

      assert {:ok, %Book{} = book} = Shop.create_book(valid_attrs)
      assert book.name == "some name"
      assert book.description == "some description"
      assert book.author == "some author"
      assert book.price == 42
      assert book.is_available == true
      assert book.isbn == "some isbn"
      assert book.published_at == ~D[2025-10-26]
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shop.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", author: "some updated author", price: 43, is_available: false, isbn: "some updated isbn", published_at: ~D[2025-10-27]}

      assert {:ok, %Book{} = book} = Shop.update_book(book, update_attrs)
      assert book.name == "some updated name"
      assert book.description == "some updated description"
      assert book.author == "some updated author"
      assert book.price == 43
      assert book.is_available == false
      assert book.isbn == "some updated isbn"
      assert book.published_at == ~D[2025-10-27]
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Shop.update_book(book, @invalid_attrs)
      assert book == Shop.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Shop.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Shop.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Shop.change_book(book)
    end
  end
end
