defmodule Sessionizer.CohortTracker do
  alias Sessionizer.Cohort

  @type t :: %{
          integer => Cohort.t()
        }
  
  @doc """
  Creates a new tracker.
  """
  def new do
    %{}
  end

  @doc"""
  Adds a student to the tracker.  If the given cohort number does not exist we create it.
  """
  @spec add_student(t, integer, map) :: t
  def add_student(cohort_list, cohort_number, student)
      when is_map_key(cohort_list, cohort_number) do
    Map.update!(cohort_list, cohort_number, &Cohort.put(&1, student))
  end

  def add_student(cohort_list, cohort_number, student) do
    Map.put(cohort_list, cohort_number, Cohort.new(students: [student]))
  end

  @doc"""
  Gets the next pair from the student buffer from the given cohort.
  If the cohort does not exist, or has less than 2 students an error tuple is returned.
  """
  @spec next_pair(t, integer) :: {list(map), t} | {:error, String.t}
  def next_pair(cohort_list, cohort_number) when is_map_key(cohort_list, cohort_number) do
    case Map.get_and_update!(cohort_list, cohort_number, &Cohort.next_pair/1) do
      {{:ok, pair}, updated} -> {pair, updated}
      {{:error, message}, updated} -> {{:error, message}, updated}
    end
  end

  def next_pair(_cohort_list, _cohort_number), do: {:error, "cohort does not exist"}
end

defmodule Sessionizer.Cohort do
  alias Sessionizer.RingBuffer
  alias Sessionizer.PairTracker
  defstruct [:student_buffer, :pair_tracker]

  @type t :: %__MODULE__{
          student_buffer: Sessionizer.RingBuffer.t(),
          pair_tracker: map
        }

  @doc """
  Creates a new cohort struct using opts.
  """
  @spec new(list) :: t
  def new(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:students, [])
      |> Keyword.put_new(:pairs, [])

    %__MODULE__{
      student_buffer: RingBuffer.new(opts[:students], shuffle: true),
      pair_tracker: PairTracker.new(opts[:pairs])
    }
  end
  
  @doc """
  Gets the next pair from the cohort struct if possible.
  """
  @spec next_pair(t) :: {{:ok, list(map)}, t} | {{:error, String.t}, t}
  def next_pair(%__MODULE__{student_buffer: b, pair_tracker: p} = cohort) do
    {s1, b} = RingBuffer.advance(b)
    {s2, b} = RingBuffer.advance(b)

    if s1 == s2 do
      {{:error, "too few students"}, cohort}
    else
      {pair, p} = PairTracker.validate(p, [s1, s2])
      {{:ok, pair}, %{cohort | student_buffer: b, pair_tracker: p}}
    end
  end
  
  @doc """
  Adds a student to the student buffer
  """
  @spec put(t, map) :: t
  def put(cohort, student) do
    Map.update!(cohort, :student_buffer, &RingBuffer.add(&1, student, :behind))
  end
end

defmodule Sessionizer.PairTracker do
  def new() do
    MapSet.new()
  end

  def new([]) do
    MapSet.new()
  end

  def new(list) do
    MapSet.new(list)
  end

  def validate(tracker, pair) do
    if MapSet.member?(tracker, pair) do
      {Enum.reverse(pair), MapSet.delete(tracker, pair)}
    else
      {pair, MapSet.put(tracker, pair)}
    end
  end
end
