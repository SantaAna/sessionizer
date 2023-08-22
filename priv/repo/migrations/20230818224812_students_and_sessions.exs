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

    create table("sessions") do
      add :duration_seconds, :integer
      add :notes, :text
      timestamps()
    end

    create table("session_students") do
      add :student_id, references(:students)
      add :session_id, references(:sessions)
    end

    create unique_index("cohorts", [:cohort_number])
  end
end
