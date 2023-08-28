defmodule SessionizerWeb.SessionizerComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import SessionizerWeb.Gettext

  attr :sessions, :list, default: []

  def session_list(assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <div
        :for={session <- @sessions}
        class="flex flex-row
         gap-3 p-3 rounded-lg drop-shadow-md bg-slate-50"
      >
        <p><%= "Driver: #{session.driver.first_name} #{session.driver.last_name}" %></p>
        <p><%= "Navigator: #{session.navigator.first_name} #{session.navigator.last_name}" %></p>
        <p><%= "Notes: #{session.notes}" %></p>
      </div>
    </div>
    """
  end
end
