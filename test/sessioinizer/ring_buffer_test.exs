defmodule Sessioinizer.RingBufferTest do
  alias Sessionizer.RingBuffer
  use ExUnit.Case

  describe "new/1" do
    test "creates properly with empty list" do
      rb = RingBuffer.new([])
      assert rb.count == 0
    end

    test "creates properly with non-empty list" do
      rb = RingBuffer.new([1, 2, 3])
      assert rb.count == 3
    end
  end

  describe "count/1" do
    test "returns correct count" do
      for x <- 1..Enum.random(2..10) do
        assert List.duplicate(1, x)
               |> RingBuffer.new()
               |> RingBuffer.count() == x
      end
    end
  end

  describe "add/3" do
    test "adds elements to the top by default" do
      b = RingBuffer.new([1,2,3]) |> RingBuffer.add(1)
      {e, _} = RingBuffer.advance(b)
      assert e == 1
      assert RingBuffer.count(b) == 4
    end
  end
end
