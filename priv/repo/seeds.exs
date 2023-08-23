# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sessionizer.Repo.insert!(%Sessionizer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

for first_name <- ~w(bob sally jill), last_name <- ~w(jones smith black), cohort_number <- [1,2,3] do
  %{first_name: first_name, last_name: last_name, cohort_number: cohort_number}
end
|> Enum.each(&Sessionizer.Students.new_from_form/1)
