defmodule SessionizerWeb.Sessions do
  use SessionizerWeb, :live_view
  alias Sessionizer.CohortCache
  alias Sessionizer.Cohorts
  alias Sessionizer.PairSessions

  def mount(_params, _session, socket) do
    cohort_numbers = Cohorts.all() |> Enum.map(& &1.cohort_number)
    cohort_number = hd(cohort_numbers)

    {:ok,
     assign(socket,
       cohort_numbers: cohort_numbers,
       cohort_number: cohort_number,
       driver: nil,
       navigator: nil,
       start_time: nil,
       session_running: false,
       session_count: 0
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
      <p><%= @session_count %></p>
      <.button phx-click="next-pair">
        Next Pair
      </.button>
    </div>
    <div :if={@session_running} class="flex flex-row gap-3">
      <p class="text-lg">Navigator: <%= @navigator.first_name %></p>
      <p class="text-lg">Driver: <%= @driver.first_name %></p>
      <p class="text-lg">Timer: <%= @timer %></p>
      <.button phx-click="stop-session">
        Stop Sessoin
      </.button>
    </div>
    """
  end

  def handle_event("stop-session", _unsigned_params, socket) do
    IO.puts("called stop")

    PairSessions.create(%{
      driver: socket.assigns.navigator,
      navigator: socket.assigns.driver,
      start_time: socket.assigns.start_time, end_time: NaiveDateTime.utc_now()
    })

    {:noreply,
     assign(socket,
       driver: nil,
       navigator: nil,
       start_time: nil,
       session_running: false,
       session_count: socket.assigns.session_count + 1,
       timer: 0
     )}
  end

  def handle_event("next-pair", _unsigned_params, socket) do
    {:ok, [navigator, driver]} = CohortCache.next_pair(socket.assigns.cohort_number)

    IO.inspect([driver, navigator])
    Process.send_after(self(), {:tick, socket.assigns.session_count}, 1000)

    {:noreply,
     assign(socket,
       driver: driver,
       navigator: navigator,
       start_time: NaiveDateTime.utc_now(),
       session_running: true,
       timer: 0
     )}
  end

  def handle_event("cohort-selected", %{"cohort_number" => cohort_number}, socket) do
    {:noreply, assign(socket, cohort_number: String.to_integer(cohort_number))}
  end

  def handle_info({:tick, count}, %{assigns: %{session_count: count}} = socket) do
    Process.send_after(self(), {:tick, count}, 1000)
    {:noreply, update(socket, :timer, &(&1 + 1))}
  end

  def handle_info({:tick, _count}, socket) do
    {:noreply, socket}
  end
end
