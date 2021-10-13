defmodule TetrisGame.Coordinates do
  use TetrisGame.Tetrimino
  @moduledoc """
  coordinates store in a MapSet; each coordiante as tuple {column, rows}
  column: 0..9; row: 0..23
  """

  @index_min 0
  @row_index_max 23
  @col_index_max 9

  @type coordinate :: {integer(), integer()}
  @type coordinates :: MapSet.t(coordinate)

  for {atom, {{{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}}, _, _, _}} <- @tetriminos_states do

    def spawn_tetrimino(coordinates, unquote(atom)) do
      with {:ok, tetrimino_coordinates} <- gen_tetrimino_coordinates(unquote(atom), {0, 3}),
        {:ok, ^tetrimino_coordinates} <- check_conflict(coordinates, tetrimino_coordinates)
      do
        {:ok, tetrimino_coordinates}
      else
        error -> error
      end
    end

    defp gen_tetrimino_coordinates(unquote(atom), {x, y}) do
      [{unquote(x0)+x, unquote(y0) + y}, {unquote(x1)+x, unquote(y1) + y}, {unquote(x2)+x, unquote(y2) + y}, {unquote(x3)+x, unquote(y3) + y}]
        |> MapSet.new
        |> check_bound
    end
  end

  def spawn_tetrimino(_, _) do
    {:error, :invalid_tetrimino_type}
  end

  defp gen_tetrimino_coordinates(_, _) do
    {:error, :invalid_tetrimino_type}
  end

  for {atom, states_tuple} <- @tetriminos_states, atom !== :O do
    def rotate_tetrimino(coordinates, tetrimino_coordinates, unquote(atom), from_state, to_state) do
      [{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}] = MapSet.to_list(tetrimino_coordinates)
      {{x0_f, y0_f}, {x1_f, y1_f}, {x2_f, y2_f}, {x3_f, y3_f}} = elem(unquote(Macro.escape(states_tuple)), from_state)
      {{x0_t, y0_t}, {x1_t, y1_t}, {x2_t, y2_t}, {x3_t, y3_t}} = elem(unquote(Macro.escape(states_tuple)), to_state)
      new_tetrimino = [{x0-x0_f+x0_t, y0-y0_f+y0_t}, {x1-x1_f+x1_t, y1-y1_f+y1_t}, {x2-x2_f+x2_t, y2-y2_f+y2_t}, {x3-x3_f+x3_t, y3-y3_f+y3_t}] |> MapSet.new

      if check_valid?(coordinates, new_tetrimino) do
        {:ok, new_tetrimino}
      else
        wall_kick_rotate(coordinates, new_tetrimino, unquote(atom), from_state, to_state)
      end
    end
  end

  def rotate_tetrimino(_,_ ,:O ,_ ,_) do
    {:ok, :no_rotate_for_o}
  end

  def rotate_tetrimino(_, _ ,_ ,_ ,_) do
    {:error, :invalid_tetrimino_type_basic_rotate}
  end

  for {from_state, to_state, tests} <- @wall_kick_rotation_jltsz, atom <- [:J, :L, :T, :S, :Z] do
    def wall_kick_rotate(coordinates, tetrimino_coordinates, unquote(atom), unquote(from_state), unquote(to_state)) do
      wall_kick_rotate(coordinates, tetrimino_coordinates, unquote(atom), unquote(from_state), unquote(to_state), unquote(tests))
    end
  end

  for {from_state, to_state, tests} <- @wall_kick_rotation_i do
    def wall_kick_rotate(coordinates, tetrimino_coordinates, :I, unquote(from_state), unquote(to_state)) do
      wall_kick_rotate(coordinates, tetrimino_coordinates, :I, unquote(from_state), unquote(to_state), unquote(tests))
    end
  end

  defp wall_kick_rotate(_coordinates, _tetrimino_coordinates, _atom, _from, _to, []), do: {:error, :rotate_failed}

  defp wall_kick_rotate(coordinates, tetrimino_coordinates, atom, from, to, [{x, y} | tail]) do
    [{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}] = MapSet.to_list(tetrimino_coordinates)
    test_coordinates = MapSet.new([{x0+x, y0+y}, {x1+x, y1+y}, {x2+x, y2+y}, {x3+x, y3+y}])

    if check_valid?(coordinates, test_coordinates) do
      {:ok, test_coordinates}
    else
      wall_kick_rotate(coordinates, tetrimino_coordinates, atom, from, to, tail)
    end
  end

  def wall_kick_rotate(_, _, :O, _, _) do
    {:ok, :no_rotate_for_o}
  end

  def init(), do: MapSet.new()

  @spec add_tetrimino(coordinates(), coordinates()) :: {:ok, coordinates} | {:error, coordinates}
  def add_tetrimino(coordinates, tetrimino_coordinates) do
    with {:ok, ^tetrimino_coordinates} <- check_bound(tetrimino_coordinates),
      {:ok, ^tetrimino_coordinates} <- check_conflict(coordinates, tetrimino_coordinates)
    do
      new_coordiantes = tetrimino_coordinates
      |> Enum.reduce(coordinates, fn cood, acc -> MapSet.put(acc, cood) end)
      |> Enum.into(%MapSet{})
      {:ok, new_coordiantes}
    else
      error -> error
    end
  end

  @spec clear_line(coordinates(), [integer()]) :: coordinates
  def clear_line(coordinates, rows) do
    Enum.filter(coordinates, fn {row, _col} -> row not in rows end)
    |> Enum.into(%MapSet{})
  end

  @spec dump_garbage(coordinates(), integer(), integer()) :: coordinates()
  def dump_garbage(coordinates, num, hole)  do
    Enum.map(coordinates, fn {row, col} -> {row - num, col} end)
    |> Enum.into(%MapSet{})
    |> MapSet.union(gen_garbage(num, hole))
  end

  @spec gen_garbage(integer(), integer()) :: coordinates()
  defp gen_garbage(num, hole) do
    for row <- @row_index_max..@row_index_max+1-num, col <- @index_min..@col_index_max, col !== hole, into: %MapSet{}, do: {row, col}
  end

  def check_bound(tetrimino_coordinates) do
    if Enum.all?(tetrimino_coordinates, fn {row, col} -> row <= @row_index_max and col >= @index_min and col <= @col_index_max end), do: {:ok, tetrimino_coordinates}, else: {:error, :out_of_bound}
  end

  def check_conflict(coordinates, tetrimino_coordinates) do
    if MapSet.disjoint?(coordinates, tetrimino_coordinates), do: {:ok, tetrimino_coordinates}, else: {:error, :coordinates_conflicted}
  end

  def check_valid?(coordinates, tetrimino_coordinates) do
    Enum.all?(tetrimino_coordinates, fn {row, col} -> row <= @row_index_max and col >= @index_min and col <= @col_index_max end) and MapSet.disjoint?(coordinates, tetrimino_coordinates)
  end

end
