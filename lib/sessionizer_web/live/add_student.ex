defmodule SessionizerWeb.AddStudent do
  use SessionizerWeb, :live_view
  alias Sessionizer.Students
  @html_path "/add_student"

  def mount(_params, _session, socket) do
    socket
    |> assign(:form, to_form(Students.new_form_change()))
    |> then(&{:ok, &1})
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-submit="save-student">
      <.input field={@form[:first_name]} label="First Name" />
      <.input field={@form[:last_name]} label="Last Name" />
      <.input field={@form[:cohort_number]} label="Cohort" />
      <:actions>
        <.button class="mt-3" phx-disable-with="saving">
          Save Student
        </.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("save-student", %{"student" => attrs}, socket) do
    Students.new_from_form(attrs)
    |> then(fn
      {:ok, _} ->
        socket
        |> push_navigate(to: @html_path)
        |> put_flash(:info, "Student successfully added")
        |> then(& {:noreply, &1})
      {:error, error_changeset} ->
        {:noreply, assign(socket, :form, to_form(error_changeset))}
    end)
  end
end
