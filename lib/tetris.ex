defmodule Tetris do
  use GenServer
  @moduledoc """
  Tetris OTP Server
  """

  def init(initial_number) do
    {:ok, initial_number}
  end

end
