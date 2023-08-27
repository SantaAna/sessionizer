defmodule SessionizerWeb.Sessions do
  use SessionizerWeb, :live_view
  alias Sessionizer.CohortCache
  alias Sessionizer.Cohorts

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       cohort_numbers: Cohorts.all() |> Enum.map(& &1.cohort_number),
       driver: nil,
       navigator: nil,
       start_time: nil,
       session_running: false
     )}
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl mb-5">Welcome to Sessions!</h1>
    <div class="flex flex-row gap-10 justify-center">
      <label for="cohort-select">Choose a Cohort</label>
      <select name="cohort-select" phx-hook="CohortSelection" id="cohort-select">
        <option :for={cohort_number <- @cohort_numbers} value={cohort_number}>
          <%= cohort_number %>
        </option>
      </select>
      <.button phx-click="next-pair">
        Next Pair
      </.button>
    </div>
    <div :if={@session_running} class="flex flex-row gap-3">
      <p class="text-lg">Navigator: <%= @navigator.first_name %></p>
      <p class="text-lg">Driver: <%= @driver.first_name %></p>
      <.button phx-click="stop-session">
        Stop Sessoin
      </.button>
    </div>
    """
  end

  def handle_event("stop-session", _unsigned_params, socket) do
    IO.puts("called stop")

    {:noreply,
     assign(socket,
       driver: nil,
       navigator: nil,
       start_time: nil,
       session_running: false
     )}
  end

  def handle_event("next-pair", _unsigned_params, socket) do
    {:ok, [navigator, driver]} = CohortCache.next_pair(socket.assigns.cohort_number)

    IO.inspect([driver, navigator])

    {:noreply,
     assign(socket,
       driver: driver,
       navigator: navigator,
       start_time: NaiveDateTime.utc_now(),
       session_running: true
     )}
  end

  def handle_event("cohort-selected", %{"cohort_number" => cohort_number}, socket) do
    {:noreply, assign(socket, cohort_number: String.to_integer(cohort_number))}
  end
end
