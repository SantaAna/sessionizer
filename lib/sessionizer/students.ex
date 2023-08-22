defmodule Sessionizer.Students do
  alias Sessionizer.Students.Student 
  alias Sessionizer.Cohorts.Cohort 
  alias Sessionizer.Repo
  alias Ecto.Query

  def get!(id) do
    Repo.get!(Student, id)
  end

  def get(id) do
    Repo.get(Student, id)
  end

  def new(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  
  def new!(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert!()
  end

  def add_to_cohort(student_id, cohort_id) when is_integer(student_id) and is_integer(cohort_id) do 
    Repo.get(Student, student_id)
    |> Ecto.Changeset.change(cohort_id: cohort_id) 
    |> Repo.update()
  end

  def new_form_change(attrs \\ %{}), do: Student.new_student_form_changeset(%Student{}, attrs)

  def new_from_form(attrs \\ %{}) do
    attrs
    |> new_form_change()
    |> Repo.insert()
  end
end
