defmodule SimpleProyectTest do
  use ExUnit.Case
  doctest SimpleProyect

  test "greets the world" do
    assert SimpleProyect.hello() == :world
  end
end
