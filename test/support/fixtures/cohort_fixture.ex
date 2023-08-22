defmodule Sessionizer.CohortFixture do

  def cohort_fixture(attrs \\ %{}) do
    {:ok, cohort} = 
    attrs
    |> Enum.into(%{
          cohort_number: System.unique_integer([:positive])
    })  
    |> Sessionizer.Cohorts.new()
    cohort
  end
end
