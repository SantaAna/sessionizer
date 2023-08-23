defmodule Sessionizer.Repo.Migrations.StudentsAndSessions do
  use Ecto.Migration

  def change do
    create table("cohorts") do
      add :cohort_number, :integer
      timestamps()
    end

    create table("students") do
      add :first_name, :string
      add :last_name, :string
      add :cohort_id, references(:cohorts) 
      timestamps()
    end 

    create table("pair-sessions") do
      add :duration_seconds, :integer
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :notes, :text
      add :navigator_id, references(:students)
      add :driver_id, references(:students)
      timestamps()
    end

    create unique_index("cohorts", [:cohort_number])
  end
end
