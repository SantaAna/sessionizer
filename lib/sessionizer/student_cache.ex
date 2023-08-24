defmodule Sessionizer.StudentCache do
  use GenServer
  alias Sessionizer.Students
  alias Sessionizer.RingBuffer
  alias Sessionizer.PairTracker
  alias Sessionizer.StudentPubSub

  defstruct [:student_buffer, :pair_tracker]

  @type t :: %__MODULE__{
          student_buffer: Sessionizer.RingBuffer.t(),
          pair_tracker: map
        }

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
    {s1, student_buffer} = RingBuffer.advance(state[cohort_number].student_buffer)
    {s2, student_buffer} = RingBuffer.advance(student_buffer)

    if s1 == s2 do
      {:reply, {:error, "not enough students"}, state}
    else
      {pair, pair_tracker} = PairTracker.validate(state[cohort_number].pair_tracker, [s1, s2])

      state =
        Map.update!(
          state,
          cohort_number,
          &%{&1 | student_buffer: RingBuffer.shuffle(student_buffer), pair_tracker: pair_tracker}
        )

      {:reply, {:ok, pair}, state}
    end
  end

  # server side 
  def init(_) do
    init_state =
      Students.all()
      |> Enum.group_by(& &1.cohort.cohort_number)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        pair_tracker = PairTracker.new()
        student_buffer = RingBuffer.new(v) |> RingBuffer.shuffle()
        Map.put(acc, k, %__MODULE__{pair_tracker: pair_tracker, student_buffer: student_buffer})
      end)

    StudentPubSub.subscribe()
    {:ok, init_state}
  end

  def handle_info({:add_student, student}, state) do
    update_fun =  
      fn status ->
        Map.update!(status, :student_buffer, &RingBuffer.add(&1, student, :behind))
      end

    Map.update(
      state,
      student.cohort_number,
      %__MODULE__{student_buffer: RingBuffer.new([student]), pair_tracker: PairTracker.new()},
      update_fun
    )
    |> then(&{:noreply, &1})
  end
end

defmodule Sessionizer.PairTracker do
  def new() do
    MapSet.new()
  end

  def validate(tracker, pair) do
    if MapSet.member?(tracker, pair) do
      {Enum.reverse(pair), MapSet.delete(tracker, pair)}
    else
      {pair, MapSet.put(tracker, pair)}
    end
  end
end
