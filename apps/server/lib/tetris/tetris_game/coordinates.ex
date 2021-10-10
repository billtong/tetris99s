defmodule TetrisGame.Coordinates do
  use TetrisGame.Tetrimino
  @moduledoc """
  coordinates store in a MapSet; each coordiante as tuple {column, rows}
  column: 0..9; row: 0..23
  """

  @type coordinate :: {1, 1}
  @type coordinates :: MapSet.t(coordinate)

  for {atom, {{{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}}, _, _, _}} <- @tetriminos_states do

    def spawn_tetrimino(unquote(atom)), do: gen_tetrimino_coordinates(unquote(atom), {0, 3})

    defp gen_tetrimino_coordinates(unquote(atom), {x, y}) do
      [
        {unquote(x0)+x, unquote(y0) + y},
        {unquote(x1)+x, unquote(y1) + y},
        {unquote(x2)+x, unquote(y2) + y},
        {unquote(x3)+x, unquote(y3) + y}
      ]
    end
  end

  def spawn_tetrimino(_) do
    #catch all
  end

  defp gen_tetrimino_coordinates(_, _) do
    # catch all
  end

  def init(), do: MapSet.new()

  @spec drop_tetrimino(coordinates, [coordinate]) :: coordinates
  def drop_tetrimino(coordinates, tetrimino_coods) do
    Enum.reduce(tetrimino_coods, coordinates, fn cood, acc -> MapSet.put(acc, cood) end)
    |> Enum.into(%MapSet{})
  end

  @spec clear_line(coordinates, [integer]) :: coordinates
  def clear_line(coordinates, rows) do
    Enum.filter(coordinates, fn {row, _col} -> row not in rows end)
    |> Enum.into(%MapSet{})
  end

  @spec dump_garbage(coordinates, 1, integer) :: coordinates
  def dump_garbage(coordinates, num, hole) do
    Enum.map(coordinates, fn {row, col} -> {row - num, col} end)
    |> Enum.into(%MapSet{})
    |> MapSet.union(gen_garbage(num, hole))
  end

  @spec gen_garbage(1, 1) :: coordinates
  defp gen_garbage(num, hole) do
    for row <- 23..24-num, col <- 0..9, col !== hole, into: %MapSet{}, do: {row, col}
  end
end
