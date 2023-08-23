defmodule Sessionizer.StudentCache do
  use GenServer
  alias Sessionizer.Students

  # client side
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  @doc """
  Returns the next pair in the rotation for the given cohort number.
  If there are less than two members in the cohort an error tuple is returned.
  """
  @spec next_pair(integer) :: {:ok, list} | {:error | String.t}
  def next_pair(cohort_number) do
    GenServer.call(__MODULE__, {:next_pair, cohort_number})
  end

  def handle_call({:next_pair, cohort_number}, _from, state) do
    case state[cohort_number] do
      {waiting, finished} when length(waiting) + length(finished) < 2 ->
        {:reply, {:error, "not enough students"}, state}

      {[s1, s2 | waiting], finished} when length(waiting) > 2 ->
        finished = [s1, s2 | finished]
        {:reply, {:ok, [s1, s2]}, Map.put(state, cohort_number,{waiting, finished})}

      {[s1, s2 | waiting], finished} ->
        waiting = waiting ++ Enum.shuffle([s1, s2 | finished])
        {:reply, {:ok, [s1, s2]}, Map.put(state, cohort_number, {waiting, []})}
    end
  end

  # server side 
  def init(_) do
    init_state =
      Students.all()
      |> Enum.group_by(& &1.cohort.cohort_number)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, {Enum.shuffle(v), []})
      end)

    {:ok, init_state}
  end
end
