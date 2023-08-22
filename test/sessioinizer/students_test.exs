defmodule Sessioinizer.StudentsTest do
  use Sessionizer.DataCase 
  alias Sessionizer.Students
  alias Sessionizer.{ StudentFixture,CohortFixture }

  describe "new/1" do
    test "creates with valid options" do
      assert match?({:ok, _}, Students.new(%{first_name: "dirk", last_name: "diggler"})) 
    end 

    test "fails to create new with invalid options" do
      assert match?({:error, _}, Students.new(%{}))
    end
  end

  describe "get/1" do
    test "retrieves existing id" do
      student = StudentFixture.student_fixture() 
      assert student == Students.get(student.id)
    end

    test "fails to retrieve non-existing id" do
      student = StudentFixture.student_fixture() 
      assert nil == Students.get(student.id + 1)
    end
  end

  describe "add_to_cohort/2" do
    test "adds student to cohort with valid cohort and student ids" do
      student = StudentFixture.student_fixture() 
      cohort = CohortFixture.cohort_fixture() 
      Students.add_to_cohort(student.id, cohort.id)
      assert Repo.get(Sessionizer.Students.Student, student.id).cohort_id == cohort.id
      cohort_student_id = Repo.get(Sessionizer.Cohorts.Cohort, cohort.id) 
                       |> Repo.preload(:students)
                       |> then(& hd(&1.students).id)

      assert cohort_student_id == student.id
    end

    test "adds student to cohort and preseves existing students" do
      cohort = CohortFixture.cohort_fixture(%{students: [%{first_name: "dirk", last_name: "digler"}]})
      new_student = StudentFixture.student_fixture(%{first_name: "kim", last_name: "struthers"})

      Students.add_to_cohort(new_student.id, cohort.id)
      
      cohort =  Repo.get(Sessionizer.Cohorts.Cohort, cohort.id) |> Repo.preload(:students)
      assert length(cohort.students) == 2
    end
  end

end
