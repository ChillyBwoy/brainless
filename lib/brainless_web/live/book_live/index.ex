defmodule BrainlessWeb.BookLive.Index do
  use BrainlessWeb, :live_view

  import Ecto.Query
  import Pgvector.Ecto.Query

  alias Brainless.Rag.Embedding
  alias Brainless.Repo
  alias Brainless.Shop
  alias Brainless.Shop.Book

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Books")
     |> stream(:books, [])}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Shop.get_book!(id)
    {:ok, _} = Shop.delete_book(book)

    {:noreply, stream_delete(socket, :books, book)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    query = String.trim(query)

    books =
      if String.length(query) == 0 do
        []
      else
        {:ok, vector} = Embedding.predict(:gemini, query)

        Repo.all(
          from book in Book,
            order_by: l2_distance(book.embedding, ^Pgvector.new(vector)),
            limit: 10
        )
      end

    {:noreply, socket |> stream(:books, books, reset: true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Books
        <:actions>
          <.button variant="primary" navigate={~p"/books/new"}>
            <.icon name="hero-plus" /> New Book
          </.button>
        </:actions>
      </.header>

      <form phx-submit="search">
        <.input type="text" name="query" value="" />
        <.button phx-disable-with="..." variant="primary">Search</.button>
      </form>

      <.table
        id="books"
        rows={@streams.books}
        row_click={fn {_id, book} -> JS.navigate(~p"/books/#{book}") end}
      >
        <:col :let={{_id, book}} label="#">
          <.icon :if={book.is_available} name="hero-check" class="size-5 text-green-500" />
          <.icon :if={!book.is_available} name="hero-no-symbol" class="size-5 text-red-500" />
        </:col>
        <:col :let={{_id, book}} label="Name">
          <div class="group hover:ring ring-primary rounded p-1">
            {book.name}
            <div class="invisible rounded-lg p-4 absolute group-hover:visible right-0 z-50 left-1/3 bg-info-content text-info shadow-xl">
              {book.description}
            </div>
          </div>
        </:col>
        <:col :let={{_id, book}} label="Author">{book.author}</:col>
        <:col :let={{_id, book}} label="Published at">{book.published_at}</:col>
        <:col :let={{_id, book}} label="Price">{book.price}</:col>
        <:action :let={{_id, book}}>
          <div class="sr-only">
            <.link navigate={~p"/books/#{book}"}>Show</.link>
          </div>
          <.link navigate={~p"/books/#{book}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, book}}>
          <.link
            phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end
end
