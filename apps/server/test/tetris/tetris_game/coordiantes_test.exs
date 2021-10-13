defmodule CoordiantesTest do
  use ExUnit.Case, async: true

  alias TetrisGame.Coordinates

  @cood1 [{23, 1}, {23, 2}, {23, 6}]
  @cood2 [{22, 1}, {22, 2}, {22, 6}]
  @cood3 [{23, 0}, {23, 1}, {23, 2}, {23, 3}, {23, 4}, {23, 5}, {23, 6}, {23, 7}, {23, 8}, {23, 9}, {22, 4}]
  @cood4 [{0, 0}, {0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}, {0, 7}, {0, 8}, {0, 9}]
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

  describe "add tetrimino at {22, 4}" do
    tetris_coord = [{22, 4}]
    new_coord = MapSet.new(@cood1 ++ tetris_coord)
    assert Coordinates.add_tetrimino(MapSet.new(@cood1), MapSet.new(tetris_coord)) == {:ok, new_coord}
    assert Coordinates.add_tetrimino(new_coord, MapSet.new(tetris_coord)) == {:error, :coordinates_conflicted}
  end

  describe "spawn L tetrimino" do
    assert Coordinates.spawn_tetrimino(MapSet.new(), :L) == {:ok, MapSet.new(@l_cood_init)}
    assert Coordinates.spawn_tetrimino(MapSet.new(), :wrong) == {:error, :invalid_tetrimino_type}
    assert Coordinates.spawn_tetrimino(MapSet.new(@cood4), :L) == {:error, :coordinates_conflicted}
  end

  describe "rotate L" do
    {:ok, start_pos} = Coordinates.spawn_tetrimino(MapSet.new(), :L)
    coords = MapSet.new([{2,4}, {2,5}, {-1,4}])
    assert Coordinates.rotate_tetrimino(coords, start_pos, :L, 0, 3) == {:error, :rotate_failed}
  end

end
