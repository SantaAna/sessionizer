defmodule Sessionizer.Students do
  alias Sessionizer.Students.Student 
  alias Sessionizer.Cohorts.Cohort 
  alias Sessionizer.Repo
  import Ecto.Query

  def get!(id) do
    Repo.get!(Student, id)
  end

  def get(id) do
    Repo.get(Student, id)
  end

  def get(id, preloads) when is_list(preloads) do
    Repo.get(Student, id)
    |> Repo.preload(preloads)
  end

  def all, do: Repo.all(Student) |> Repo.preload(:cohort)     

  def get_by_cohort(cohort_number) when is_integer(cohort_number) do
    q = from s in Student,
        join: c in Cohort,
        on: c.id == s.cohort_id,
        where: c.cohort_number == ^cohort_number

    Repo.all(q)
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

  def student_full_name(%Student{} = student) do
    "#{student.first_name} #{student.last_name}"
  end
end
