defmodule Sessioinizer.CohortTrackerTest do
  use ExUnit.Case 
  alias Sessionizer.CohortTracker
  
  describe "add_student/3" do
    test "adds a new cohort number when needed" do
      s = %{cohort_number: 10, name: "dirk"}
      t = CohortTracker.new()
          |> CohortTracker.add_student(s.cohort_number, s)

      assert t[s.cohort_number].student_buffer.waiting == [s]
    end

    test "adds student to existing cohort" do
      cohort_number = 10
      students = [%{cohort_number: cohort_number, name: "dirk"},%{cohort_number: cohort_number, name: "patrick"}]
      tracker = Enum.reduce(students, CohortTracker.new(), fn s, acc -> 
        CohortTracker.add_student(acc, s.cohort_number, s)
      end)

      assert tracker[cohort_number].student_buffer.count == 2 
    end
  end

  describe "next_pair/2" do
    test "returns error tuple if insufficient students" do
      s = %{cohort_number: 10, name: "dirk"}
      t = CohortTracker.new()
          |> CohortTracker.add_student(s.cohort_number, s)

      assert CohortTracker.next_pair(t, 10) == {{:error, "too few students"}, t}
    end 

    test "return error tuple if cohort does not exist" do
      s = %{cohort_number: 10, name: "dirk"}
      t = CohortTracker.new()
          |> CohortTracker.add_student(s.cohort_number, s)

      assert CohortTracker.next_pair(t, 1) == {:error, "cohort does not exist"}
    end

    test "does not return the same pair when called twice" do
      s1 = %{cohort_number: 10, name: "dirk"}
      s2 = %{cohort_number: 10, name: "patrick"}
      t = CohortTracker.new()
          |> CohortTracker.add_student(s1.cohort_number, s1)
          |> CohortTracker.add_student(s2.cohort_number, s2)
      {p1, t} = CohortTracker.next_pair(t, 10)
      {p2, t} = CohortTracker.next_pair(t, 10)

      refute p1 == p2
    end
  end
end
