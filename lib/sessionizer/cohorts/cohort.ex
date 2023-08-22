defmodule Sessionizer.Cohorts.Cohort do
  use Ecto.Schema 
  import Ecto.Changeset

  schema "cohorts" do
    field :cohort_number, :integer
    has_many :students, Sessionizer.Students.Student
    timestamps()
  end

  def changeset(cohort, attrs \\ %{}) do
    cohort
    |> cast(attrs, [:cohort_number])
    |> cast_assoc(:students)
    |> validate_required(:cohort_number)
    |> unique_constraint(:cohort_number)
  end
end
