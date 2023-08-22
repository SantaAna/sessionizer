defmodule Sessionizer.StudentFixture do
  def student_fixture(attrs \\ %{}) do
    {:ok, student} = 
    attrs
    |> Enum.into(%{
       first_name: "dirk",
       last_name: "diggler"
    })  
    |> Sessionizer.Students.new()
    student
  end
end
