defmodule Exexec.Extras do
  @moduledoc """
  Extra functionality that is not handled by erlexec
  """

  def extra_option?({:stdout, :stream}), do: true
  def extra_option?(_), do: false

  def split(options) do
    options |> Enum.split_with(&extra_option?/1)
  end

  def validate(options) do
    if :sync in options and {:stdout, :stream} in options do
      {:error, :badarg}
    else
      :ok
    end
  end
end
