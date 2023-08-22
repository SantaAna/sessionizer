defmodule Sessionizer.Cohorts do
  alias Sessionizer.Cohorts.Cohort 
  alias Sessionizer.Repo
  alias Ecto.Query

  def get(id) do
    Repo.get(Cohort, id)
  end

  def get!(id) do
    Repo.get!(Cohort,id)
  end

  def get_cohort_by_number(cohort_number, preloads \\ []) do
    Repo.get_by(Cohort, cohort_number: cohort_number)
    |> Repo.preload(preloads)
  end

  def new(attrs \\ %{}) do
    %Cohort{} 
    |> Cohort.changeset(attrs)
    |> Repo.insert()
  end

  def new!(attrs \\ %{}) do
    %Cohort{} 
    |> Cohort.changeset(attrs)
    |> Repo.insert!()
  end
end
