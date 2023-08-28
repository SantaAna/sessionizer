defmodule Sessionizer.PairSessions.PairSession do
  use Ecto.Schema 
  import Ecto.Changeset

  schema "pair-sessions" do
    field :notes, :string
    field :start_time, :naive_datetime
    field :end_time, :naive_datetime
    belongs_to :driver, Sessionizer.Students.Student   
    belongs_to :navigator, Sessionizer.Students.Student   
    
    timestamps()
  end

  def changeset(pairsession, attrs \\ %{}) do
    pairsession
    |> cast(attrs, [:notes, :start_time, :end_time, :driver_id, :navigator_id])
    |> validate_required(~w(start_time end_time driver_id navigator_id)a)
    |> validate_unique_participants()
    |> validate_positive_duration()
  end

  # checks that driver_id is not equal to navigator_id
  defp validate_unique_participants(changeset) do
    validate_change(changeset, :driver_id, fn :driver_id, driver_id -> 
      if get_field(changeset, :navigator_id) != driver_id do
        []
        else
        [driver_id: "cannot be the same as navigator_id"]
      end
    end) 
  end

  # checks that the end time is after the start time 
  defp validate_positive_duration(changeset) do
    validate_change(changeset, :start_time, fn :start_time, start_time -> 
      if NaiveDateTime.compare(start_time, get_field(changeset, :end_time)) in [:lt, :eq] do
        []
        else
        [start_time: "must be before end_time"]
      end
    end) 
  end
end

