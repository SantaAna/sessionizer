defmodule Sessionizer.RingBuffer do
  defstruct [:waiting, :finished, :count]

  @type t :: %__MODULE__{
          waiting: list,
          finished: list,
          count: integer
        }

  def new(starting_queue) when is_list(starting_queue) do
    %__MODULE__{
      waiting: starting_queue,
      finished: [],
      count: length(starting_queue)
    }
  end

  @doc """
  Return the total number of elements in the buffer.
  """
  @spec count(t) :: integer
  def count(%__MODULE__{count: count}), do: count

  @doc """
  advances the buffer returning the next element and the updated buffer in a tuple
  """
  @spec advance(t) :: {term, t}
  def advance(%__MODULE__{waiting: [next | []], finished: finished} = buff) do
    waiting = [next | finished] |> Enum.reverse()

    buff
    |> Map.put(:waiting, waiting)
    |> Map.put(:finished, [])
    |> then(&{next, &1})
  end

  def advance(%__MODULE__{waiting: [next | rest], finished: finished} = buff) do
    buff
    |> Map.put(:waiting, rest)
    |> Map.put(:finished, [next | finished])
    |> then(&{next, &1})
  end

  @doc """
  Shuffles the elements in the buffer randomly.
  """
  @spec shuffle(t) :: t
  def shuffle(%__MODULE__{} = buff) do
    buff
    |> Map.update!(:waiting, &Enum.shuffle/1)
    |> Map.update!(:finished, &Enum.shuffle/1)
  end

  @doc """
  Adds an element to the buffer at position specified by the where option.
  If where is set to ahead the element is placed next in line, if the behind 
  option is chosen the element is placed on top of the finished list as if it
  was advanced through an advance call.
  """
  @spec add(t, term, atom) :: t
  def add(%__MODULE__{} = buff, element, where \\ :ahead) do
    case where do
      :ahead ->
        buff
        |> Map.update!(:waiting, &[element | &1])
        |> Map.update!(:count, &(&1 + 1))

      :behind ->
        buff
        |> Map.update!(:finished, &[element | &1])
        |> Map.update!(:count, &(&1 + 1))
    end
  end
end
