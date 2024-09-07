defmodule LvBug.User do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  embedded_schema do
    field :first, :string
    field :last, :string
  end

  def changeset(attrs \\ %{}) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:first, :last])
  end

  def validate(changeset) do
    changeset
    |> validate_required([:first])
    |> validate_required([:last])
    |> apply_action(:validate)
  end
end

defmodule LvbugWeb.UserLive do
  use LvbugWeb, :live_view
  alias LvBug.User
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, user: "world", form: to_form(User.changeset(%User{}, %{})))}
  end

  def handle_event(
        "validate",
        %{
          "user" => user_params
        },
        socket
      ) do
    chst =
      User.changeset(%User{}, user_params)
      |> Ecto.Changeset.validate_required([:first])
      |> Ecto.Changeset.validate_required([:last])

    socket =
      socket
      |> assign(:form, to_form(chst, action: :validate))

    IO.puts(" done w/ handle_event validate")
    {:noreply, socket}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    chst =
      User.changeset(%User{}, user_params)
      |> Ecto.Changeset.validate_required([:first])
      |> Ecto.Changeset.validate_required([:last])

    if chst.valid? do
      Logger.info("User saved")
      {:noreply, socket}
    else
      Logger.error("User not saved errs: #{inspect(chst |> to_form())}")

      socket =
        socket
        |> assign(:form, to_form(chst, action: :validate))

      ##### ^^^ if you change the action to something different will cause errors to show
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Both fields are required. To exercise the bug, fill out the first name field and click on the Save button without filling out the last name field. </h1>

    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input3 field={@form[:first]} label="first" phx-debounce="blur" />
      <.input3 field={@form[:last]} label="last" phx-debounce="blur" />
      <:actions>
        <.button>Save</.button>
      </:actions>
    </.simple_form>
    """
  end
end
