defmodule Sessionizer.Students.Student do
  use Ecto.Schema 
  import Ecto.Changeset

  schema "students" do
    field :first_name, :string
    field :last_name, :string 
    # using this as a virtual field so we can cast 
    # in the new student form changeset, but now 
    # it shows up in all student structs.  Is there
    # a better way to deal with this?
    field :cohort_number, :integer, virtual: true
    belongs_to :cohort, Sessionizer.Cohorts.Cohort 
    has_many :navigator_sessions, Sessionizer.PairSessions.PairSession, foreign_key: :navigator_id
    has_many :driver_sessions, Sessionizer.PairSessions.PairSession, foreign_key: :driver_id
    timestamps()
  end

  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, [:first_name, :last_name, :cohort_id])
    |> validate_required([:first_name, :last_name]) 
    |> foreign_key_constraint(:cohort_id)
  end

  def new_student_form_changeset(student, attrs \\ %{}) do
    student 
    |> cast(attrs, [:first_name, :last_name, :cohort_number])
    |> validate_required([:first_name, :last_name, :cohort_number])
    |> get_cohort_id()
  end

  defp get_cohort_id(%{valid?: false} = cs), do: cs
  defp get_cohort_id(%{changes: %{cohort_number: cohort_number}} = cs) do
    cohort = Sessionizer.Cohorts.get_cohort_by_number(cohort_number) || Sessionizer.Cohorts.new!(%{cohort_number: cohort_number})  
    Map.update!(cs, :changes, & Map.put(&1, :cohort_id, cohort.id))
  end
end
