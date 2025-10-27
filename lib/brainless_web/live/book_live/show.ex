defmodule BrainlessWeb.BookLive.Show do
  use BrainlessWeb, :live_view

  alias Brainless.Shop

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Book {@book.id}
        <:subtitle>This is a book record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/books"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/books/#{@book}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit book
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@book.name}</:item>
        <:item title="Description">{@book.description}</:item>
        <:item title="Price">{@book.price}</:item>
        <:item title="Is available">{@book.is_available}</:item>
        <:item title="Isbn">{@book.isbn}</:item>
        <:item title="Author">{@book.author}</:item>
        <:item title="Published at">{@book.published_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Book")
     |> assign(:book, Shop.get_book!(id))}
  end
end
