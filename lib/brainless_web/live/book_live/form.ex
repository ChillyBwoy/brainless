defmodule BrainlessWeb.BookLive.Form do
  use BrainlessWeb, :live_view

  alias Brainless.Shop
  alias Brainless.Shop.Book

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="book-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:price]} type="number" label="Price" />
        <.input field={@form[:is_available]} type="checkbox" label="Is available" />
        <.input field={@form[:isbn]} type="text" label="Isbn" />
        <.input field={@form[:author]} type="text" label="Author" />
        <.input field={@form[:published_at]} type="date" label="Published at" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Book</.button>
          <.button navigate={return_path(@return_to, @book)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    book = Shop.get_book!(id)

    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Shop.change_book(book)))
  end

  defp apply_action(socket, :new, _params) do
    book = %Book{}

    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Shop.change_book(book)))
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset = Shop.change_book(socket.assigns.book, book_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    save_book(socket, socket.assigns.live_action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Shop.update_book(socket.assigns.book, book_params) do
      {:ok, book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, book))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Shop.create_book(book_params) do
      {:ok, book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, book))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _book), do: ~p"/books"
  defp return_path("show", book), do: ~p"/books/#{book}"
end
