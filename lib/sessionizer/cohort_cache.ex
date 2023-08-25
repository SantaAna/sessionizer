defmodule Sessionizer.CohortCache do
  use GenServer
  alias Sessionizer.Students
  alias Sessionizer.StudentPubSub
  alias Sessionizer.CohortTracker

  # client side
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Returns the next pair in the rotation for the given cohort number.
  If there are less than two members in the cohort or the cohort number is invalid 
  an error tuple is returned.
  """
  @spec next_pair(integer) :: {:ok, list} | {:error | String.t()}
  def next_pair(cohort_number) do
    GenServer.call(__MODULE__, {:next_pair, cohort_number})
  end

  def handle_call({:next_pair, cohort_number}, _from, state)
      when not is_map_key(state, cohort_number),
      do: {:reply, {:error, "invalid cohort number"}, state}

  def handle_call({:next_pair, cohort_number}, _from, state) do
    {pair, state} = CohortTracker.next_pair(state, cohort_number)
    {:reply, pair, state}
  end

  # server side 
  def init(_) do
    init_state =
      Students.all()
      |> Enum.reduce(CohortTracker.new(), fn s, acc ->
        CohortTracker.add_student(acc, s.cohort.cohort_number, s)
      end)

    StudentPubSub.subscribe()
    {:ok, init_state}
  end

  def handle_info({:add_student, student}, state) do
    {:noreply, CohortTracker.add_student(state, student.cohort_number, student)}
  end
end
