defmodule SessionizerWeb.StudentProfile do
  use SessionizerWeb, :live_view
  alias Sessionizer.Students

  def mount(params, _session, socket) do
    %{"student_id" => student_id} = params
    student_with_sessions = Students.get(student_id, [navigator_sessions: [:driver, :navigator], driver_sessions: [:driver, :navigator]])

    {:ok,
     assign(socket,
       student: student_with_sessions,
       navigator_sessions: student_with_sessions.navigator_sessions,
       driver_sessions: student_with_sessions.driver_sessions,
       all_sessions: student_with_sessions.navigator_sessions ++ student_with_sessions.driver_sessions
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Profile for <%= Students.student_full_name(@student) %></h1>
    <div class="flex flex-row gap-3">
      <p>Navigator Sessions: <%= length(@navigator_sessions) %></p>
      <p>Driver Sessions: <%= length(@driver_sessions) %></p>
    </div>
    <h2> Session History </h2> 
    <.session_list sessions={@all_sessions} />
    """
  end
end
