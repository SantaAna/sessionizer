defmodule Sessioinizer.CohortsTest do
  use Sessionizer.DataCase 
  alias Sessionizer.Cohorts
  alias Sessionizer.CohortFixture


  describe "new/1" do
    test "creates new cohort w/ valid options" do
      assert match?({:ok, _}, Cohorts.new(%{cohort_number: 1}))
    end

    test "fails with invalid options" do
      assert match?({:error, _}, Cohorts.new())
    end
  end

  describe "get" do
    test "will get record with valid id" do
      cohort = CohortFixture.cohort_fixture() 
      assert cohort == Cohorts.get(cohort.id)
    end

    test "will not get record with invalid id" do
      cohort = CohortFixture.cohort_fixture() 
      assert nil == Cohorts.get(cohort.id + 1)
    end
  end

  describe "get_cohort_by_number/1" do
    test "gets existing cohort succesfully" do
      cohort = CohortFixture.cohort_fixture()  
      assert cohort == Cohorts.get_cohort_by_number(cohort.cohort_number) 
    end 

    test "does not get non-existing cohort" do
      cohort = CohortFixture.cohort_fixture()
      assert Cohorts.get_cohort_by_number(cohort.cohort_number + 1) == nil
    end
  end
end
