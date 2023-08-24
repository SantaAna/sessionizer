defmodule Sessionizer.StudentPubSub do
  alias Phoenix.PubSub
  @topic "student_update"
  def subscribe do
    PubSub.subscribe(Sessionizer.PubSub, @topic)  
  end 
  
  def broadcast(message) do
    PubSub.broadcast(Sessionizer.PubSub, @topic, message) 
  end

  def broadcast_add(student) do
    broadcast({:add_student, student})
  end
end
