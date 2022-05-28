defmodule Coordinates do
  @moduledoc """

  Coordinates of tetrimino blocks and garbage blocks

  ### Custom Attributes

  `@tetrimino_relative_coordinates`
  - spawn state -> clockwise#1 -> clockwise#2 -> clockwise#3

  `@wall_kick_rotation_jltsz` `@wall_kick_rotation_i`

  - [Spawn Orientation and Location Source](https://tetris.fandom.com/wiki/SRS#Spawn_Orientation_and_Location)
  - :O can't rotate
  """

  @x_max 9
  @spawn_coordinate {3, 20}
  @tetrimino_relative_coordinates [
    {:I,
     {[{0, 2}, {1, 2}, {2, 2}, {3, 2}], [{2, 0}, {2, 1}, {2, 2}, {2, 3}],
      [{0, 1}, {1, 1}, {2, 1}, {3, 1}], [{1, 0}, {1, 1}, {1, 2}, {1, 3}]}},
    {:J,
     {[{0, 2}, {0, 3}, {1, 2}, {2, 2}], [{1, 1}, {1, 2}, {1, 3}, {2, 3}],
      [{0, 2}, {1, 2}, {2, 2}, {2, 1}], [{0, 1}, {1, 1}, {1, 2}, {1, 3}]}},
    {:L,
     {[{0, 2}, {1, 2}, {2, 2}, {2, 3}], [{1, 1}, {1, 2}, {1, 3}, {2, 1}],
      [{0, 1}, {0, 2}, {1, 2}, {2, 2}], [{0, 3}, {1, 1}, {1, 2}, {1, 3}]}},
    {:O,
     {[{1, 1}, {1, 2}, {2, 1}, {2, 2}], [{1, 1}, {1, 2}, {2, 1}, {2, 2}],
      [{1, 1}, {1, 2}, {2, 1}, {2, 2}], [{1, 1}, {1, 2}, {2, 1}, {2, 2}]}},
    {:S,
     {[{0, 2}, {1, 2}, {1, 3}, {2, 3}], [{1, 2}, {1, 3}, {2, 1}, {2, 2}],
      [{0, 1}, {1, 1}, {1, 2}, {2, 2}], [{0, 2}, {0, 3}, {1, 1}, {1, 2}]}},
    {:T,
     {[{0, 2}, {1, 2}, {2, 2}, {1, 3}], [{1, 1}, {1, 2}, {1, 3}, {2, 2}],
      [{0, 2}, {1, 2}, {2, 2}, {1, 1}], [{0, 2}, {1, 1}, {1, 2}, {1, 3}]}},
    {:Z,
     {[{0, 3}, {1, 3}, {1, 2}, {2, 2}], [{1, 1}, {1, 2}, {2, 2}, {2, 3}],
      [{0, 2}, {1, 2}, {1, 1}, {2, 1}], [{0, 1}, {0, 2}, {1, 2}, {1, 3}]}}
  ]

  @wall_kick_rotation_jltsz [
    {0, 1, [{-1, 0}, {-1, 1}, {0, -2}, {-1, -2}]},
    {1, 0, [{1, 0}, {1, -1}, {0, 2}, {1, 2}]},
    {1, 2, [{1, 0}, {1, -1}, {0, 2}, {1, 2}]},
    {2, 1, [{-1, 0}, {-1, 1}, {0, -2}, {-1, -2}]},
    {2, 3, [{1, 0}, {1, 1}, {0, -2}, {1, -2}]},
    {3, 2, [{-1, 0}, {-1, -1}, {0, 2}, {-1, 2}]},
    {3, 0, [{-1, 0}, {-1, -1}, {0, 2}, {-1, 2}]},
    {0, 3, [{1, 0}, {1, 1}, {0, -2}, {1, -2}]}
  ]
  @wall_kick_rotation_i [
    {0, 1, [{-2, 0}, {1, 0}, {-2, -1}, {1, 2}]},
    {1, 0, [{2, 0}, {-1, 0}, {2, 1}, {-1, -2}]},
    {1, 2, [{-1, 0}, {2, 0}, {-1, 2}, {2, -1}]},
    {2, 1, [{1, 0}, {-2, 0}, {1, -2}, {-2, 1}]},
    {2, 3, [{2, 0}, {-1, 0}, {2, 1}, {-1, -2}]},
    {3, 2, [{-2, 0}, {1, 0}, {-2, -1}, {1, 2}]},
    {3, 0, [{1, 0}, {-2, 0}, {1, -2}, {-2, 1}]},
    {0, 3, [{-1, 0}, {2, 0}, {-1, 2}, {2, -1}]}
  ]

  @clear_line_checker_list 0..23
                           |> Enum.map(fn y ->
                             {y, Enum.map(0..9, &{&1, y}) |> Enum.into(MapSet.new())}
                           end)

  @type tetrimino_leter :: :I | :J | :L | :O | :S | :T | :Z

  @typedoc """
  Each coordinate is a tuple `{x, y}` where x postive axis is right and y positve axis is up.

  ### range of x and y

  - 0 <= x <= 9
  - 0 <= y, as long as the spawn tetrimino didn't blocked by current tetrimino blocks
  """
  @type coordinate :: {integer(), integer()}

  @typedoc """
  A MapSet that contains all coordinates of current tetrimino blocks
  """
  @type coordinate_mapset :: MapSet.t(coordinate())

  for {block_type, {spawn_state, _, _, _}} <-
        @tetrimino_relative_coordinates do
    def spawn_tetrimino(coordinates, unquote(block_type)) do
      with {:ok, tetrimino_coordinates} <-
             get_real_coordinates(unquote(spawn_state), @spawn_coordinate),
           {:ok, ^tetrimino_coordinates} <- check_bound(tetrimino_coordinates),
           {:ok, ^tetrimino_coordinates} <- check_conflict(coordinates, tetrimino_coordinates) do
        {:ok, tetrimino_coordinates}
      else
        error -> error
      end
    end
  end

  @spec spawn_tetrimino(coordinate_mapset(), tetrimino_leter()) ::
          {:ok, MapSet.t(any)}
          | {:error, :coordinates_conflicted | :invalid_tetrimino_type | :out_of_bound}
  def spawn_tetrimino(_, _) do
    {:error, :invalid_tetrimino_type}
  end

  for {block_type, states_tuple} <- @tetrimino_relative_coordinates, block_type !== :O do
    def rotate_tetrimino(coordinates, {x, y}, unquote(block_type), from_state, to_state) do
      relative_coordiantes = elem(unquote(Macro.escape(states_tuple)), to_state)

      case get_real_coordinates(relative_coordiantes, {x, y}) do
        {:ok, new_tetrimino} ->
          {
            if check_valid?(coordinates, new_tetrimino) do
              {:ok, new_tetrimino}
            else
              wall_kick_rotate(
                coordinates,
                new_tetrimino,
                unquote(block_type),
                from_state,
                to_state
              )
            end
          }

        error ->
          error
      end
    end
  end

  def rotate_tetrimino(_, _, :O, _, _) do
    {:error, :no_rotate_for_o}
  end

  @spec rotate_tetrimino(any, any, any, any, any) ::
          {:error, :invalid_tetrimino_type | :no_rotate_for_o | :rotate_failed}
          | {:ok, MapSet.t(any) | MapSet.t({integer, integer})}
  def rotate_tetrimino(_, _, _, _, _) do
    {:error, :invalid_tetrimino_type}
  end

  for {from_state, to_state, tests} <- @wall_kick_rotation_jltsz do
    def wall_kick_rotate(
          coordinates,
          tetrimino_coordinates,
          block_type,
          unquote(from_state),
          unquote(to_state)
        )
        when block_type in [:J, :L, :T, :S, :Z] do
      wall_kick_rotate(
        coordinates,
        tetrimino_coordinates,
        block_type,
        unquote(from_state),
        unquote(to_state),
        unquote(tests)
      )
    end
  end

  for {from_state, to_state, tests} <- @wall_kick_rotation_i do
    def wall_kick_rotate(
          coordinates,
          tetrimino_coordinates,
          :I,
          unquote(from_state),
          unquote(to_state)
        ) do
      wall_kick_rotate(
        coordinates,
        tetrimino_coordinates,
        :I,
        unquote(from_state),
        unquote(to_state),
        unquote(tests)
      )
    end
  end

  def wall_kick_rotate(_, _, :O, _, _) do
    {:error, :no_rotate_for_o}
  end

  def wall_kick_rotate(_coordinates, _tetrimino_coordinates, _block_type, _from, _to),
    do: {:error, :invalid_tetrimino_type}

  defp wall_kick_rotate(_coordinates, _tetrimino_coordinates, _block_type, _from, _to, []),
    do: {:error, :rotate_failed}

  defp wall_kick_rotate(coordinates, tetrimino_coordinates, block_type, from, to, [{x, y} | tail]) do
    [{x0, y0}, {x1, y1}, {x2, y2}, {x3, y3}] = MapSet.to_list(tetrimino_coordinates)

    test_coordinates =
      MapSet.new([{x0 + x, y0 + y}, {x1 + x, y1 + y}, {x2 + x, y2 + y}, {x3 + x, y3 + y}])

    if check_valid?(coordinates, test_coordinates) do
      {:ok, test_coordinates}
    else
      wall_kick_rotate(coordinates, tetrimino_coordinates, block_type, from, to, tail)
    end
  end

  @doc """
  Transform from relative coordinates to real coordinates
  """
  @spec get_real_coordinates([coordinate()], coordinate()) ::
          {:error, :invalid_tetrimino_type} | {:ok, coordinate_mapset()}
  def get_real_coordinates(relative_coordinates, {x, y}) do
    real_coordinates =
      relative_coordinates |> Enum.map(fn {x1, y1} -> {x1 + x, y1 + y} end) |> MapSet.new()

    {:ok, real_coordinates}
  end

  def get_real_coordinates(_, _) do
    {:error, :invalid_tetrimino_type}
  end

  @spec init :: coordinate_mapset()
  defdelegate init(), to: MapSet, as: :new

  @spec add_tetrimino_into_coordinates(coordinate_mapset(), coordinate_mapset()) ::
          coordinate_mapset()
  defdelegate add_tetrimino_into_coordinates(coordinates, tetrimino_coordinates),
    to: MapSet,
    as: :union

  @doc """
  Check which row is clearable and clear coordinates in rows, and drop others according to their coordinates
  """
  def check_and_clear_line(coordinates) do
    Enum.flat_map(@clear_line_checker_list, fn {y, line_mapset} ->
      if MapSet.subset?(line_mapset, coordinates), do: [y], else: []
    end) |> IO.inspect()
    |> case do
      [] ->
        coordinates

      rows ->
        Enum.flat_map(coordinates, fn {x, y} ->
          if y not in rows, do: [{x, y - Enum.count(rows, &(&1 < y))}], else: []
        end)
        |> Enum.into(%MapSet{})
    end
  end

  @doc """
  Add coordinates of garbage blocks, and raise all coordiantes
  """
  @spec dump_garbage(coordinate_mapset(), integer(), integer()) :: coordinate_mapset()
  def dump_garbage(coordinates, num, hole) when num in 1..4 and hole in 0..9 do
    Enum.map(coordinates, fn {x, y} -> {x, y + num} end)
    |> Enum.into(%MapSet{})
    |> MapSet.union(gen_garbage(num, hole))
  end

  def dump_garbage(coordinates, _num, _hole), do: coordinates

  @spec gen_garbage(integer(), integer()) :: coordinate_mapset()
  defp gen_garbage(num, hole) do
    for y <- 0..(num - 1), x <- 0..@x_max, x !== hole, into: %MapSet{}, do: {x, y}
  end

  @doc """
  Check if all coordinates is within the boundary
  """
  @spec check_bound(coordinate_mapset()) :: {:error, :out_of_bound} | {:ok, coordinate_mapset()}
  def check_bound(coordinates) do
    if Enum.all?(coordinates, fn {x, y} ->
         x >= 0 and x <= @x_max and y >= 0
       end),
       do: {:ok, coordinates},
       else: {:error, :out_of_bound}
  end

  @doc """
  Check if current moving tetrimino conflicts with current coordinates
  """
  @spec check_conflict(coordinate_mapset(), coordinate_mapset()) ::
          {:error, :coordinates_conflicted} | {:ok, coordinate_mapset()}
  def check_conflict(coordinates, tetrimino_coordinates) do
    if MapSet.disjoint?(coordinates, tetrimino_coordinates),
      do: {:ok, tetrimino_coordinates},
      else: {:error, :coordinates_conflicted}
  end

  @doc """
  Check if current moving tetrimino conflicts with current coordinates, meanwhile its coordinates is within the boundary
  """
  @spec check_valid?(coordinate_mapset(), coordinate_mapset()) :: boolean
  def check_valid?(coordinates, tetrimino_coordinates) do
    Enum.all?(tetrimino_coordinates, fn {x, y} ->
      x >= 0 and x <= @x_max and y >= 0
    end) and MapSet.disjoint?(coordinates, tetrimino_coordinates)
  end
end
