defmodule CoordiantesTest do
  use ExUnit.Case, async: true

  alias TetrisGame.Coordinates

  @cood1 [{23, 1}, {23, 2}, {23, 6}]
  @cood2 [{22, 1}, {22, 2}, {22, 6}]
  @cood3 [{23, 0}, {23, 1}, {23, 2}, {23, 3}, {23, 4}, {23, 5}, {23, 6}, {23, 7}, {23, 8}, {23, 9}, {22, 4}]
  @garbage_cood [
    {23, 0},
    {23, 1},
    {23, 2},
    {23, 3},
    {23, 4},
    {23, 5},
    # hole
    {23, 7},
    {23, 8},
    {23, 9}
  ]
  @l_cood_init [{0, 5}, {1, 3}, {1, 4}, {1, 5}]
  describe "dump one line garbage with a hole at index 6 column " do
    assert Coordinates.dump_garbage(MapSet.new(@cood1), 1, 6) == MapSet.new(@cood2 ++ @garbage_cood)
  end

  describe "clear line at index 23 row (bottom one)" do
    assert Coordinates.clear_line(MapSet.new(@cood3), [23]) == MapSet.new([{22, 4}])
  end

  describe "place tetrimino at {22, 4}" do
    new_cood = [{22, 4}]
    assert Coordinates.drop_tetrimino(MapSet.new(@cood1), new_cood) == MapSet.new(@cood1 ++ new_cood)
  end

  describe "spawn L tetrimino" do
    assert Coordinates.spawn_tetrimino(:L) == @l_cood_init
    assert Coordinates.spawn_tetrimino(:wrong) == nil
  end

end
