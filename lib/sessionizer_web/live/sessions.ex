defmodule SessionizerWeb.Sessions do
  use SessionizerWeb, :live_view
  alias Sessionizer.CohortCache
  alias Sessionizer.Cohorts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, cohort_numbers: Cohorts.all() |> Enum.map(& &1.cohort_number))}
  end

  def render(assigns) do
  ~H"""
    <h1> Welcome to Sessions! </h1> 
    <div >
      <label for="cohort-select">Choose a Cohort</label>
      <select name="cohort-select" phx-hook="CohortSelection" id="cohort-select">
        <option :for={cohort_number <- @cohort_numbers} value={cohort_number}> <%= cohort_number %> </option> 
      </select>
    </div>
  """ 
  end

  def handle_event("cohort-selected", unsigned_params, socket) do
    IO.puts("fired event")
    IO.inspect(unsigned_params) 
    {:noreply, socket}
  end
end
