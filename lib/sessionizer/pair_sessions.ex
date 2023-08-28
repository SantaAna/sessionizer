defmodule Sessionizer.PairSessions do
  import Ecto.Query
  alias Sessionizer.PairSessions.PairSession
  alias Sessionizer.Repo

  def create(attrs \\ %{})

  def create(%{driver: driver, navigator: navigator} = attrs)
      when is_map(driver) and is_map(navigator) do
    attrs =
      attrs
      |> Map.put(:driver_id, driver.id)
      |> Map.put(:navigator_id, navigator.id)

    %PairSession{}
    |> PairSession.changeset(attrs)
    |> Repo.insert()
  end

  def create(attrs) do
    %PairSession{}
    |> PairSession.changeset(attrs)
    |> Repo.insert()
  end

  def load_participants(%PairSession{} = session) do
    Repo.preload(session, [:driver, :navigator])
  end
end

