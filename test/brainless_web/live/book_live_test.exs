defmodule BrainlessWeb.BookLiveTest do
  use BrainlessWeb.ConnCase

  import Phoenix.LiveViewTest
  import Brainless.ShopFixtures

  @create_attrs %{name: "some name", description: "some description", author: "some author", price: 42, is_available: true, isbn: "some isbn", published_at: "2025-10-26"}
  @update_attrs %{name: "some updated name", description: "some updated description", author: "some updated author", price: 43, is_available: false, isbn: "some updated isbn", published_at: "2025-10-27"}
  @invalid_attrs %{name: nil, description: nil, author: nil, price: nil, is_available: false, isbn: nil, published_at: nil}
  defp create_book(_) do
    book = book_fixture()

    %{book: book}
  end

  describe "Index" do
    setup [:create_book]

    test "lists all books", %{conn: conn, book: book} do
      {:ok, _index_live, html} = live(conn, ~p"/books")

      assert html =~ "Listing Books"
      assert html =~ book.name
    end

    test "saves new book", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Book")
               |> render_click()
               |> follow_redirect(conn, ~p"/books/new")

      assert render(form_live) =~ "New Book"

      assert form_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#book-form", book: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/books")

      html = render(index_live)
      assert html =~ "Book created successfully"
      assert html =~ "some name"
    end

    test "updates book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#books-#{book.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/books/#{book}/edit")

      assert render(form_live) =~ "Edit Book"

      assert form_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#book-form", book: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/books")

      html = render(index_live)
      assert html =~ "Book updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#books-#{book.id}")
    end
  end

  describe "Show" do
    setup [:create_book]

    test "displays book", %{conn: conn, book: book} do
      {:ok, _show_live, html} = live(conn, ~p"/books/#{book}")

      assert html =~ "Show Book"
      assert html =~ book.name
    end

    test "updates book and returns to show", %{conn: conn, book: book} do
      {:ok, show_live, _html} = live(conn, ~p"/books/#{book}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/books/#{book}/edit?return_to=show")

      assert render(form_live) =~ "Edit Book"

      assert form_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#book-form", book: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/books/#{book}")

      html = render(show_live)
      assert html =~ "Book updated successfully"
      assert html =~ "some updated name"
    end
  end
end
