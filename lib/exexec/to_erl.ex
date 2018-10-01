defmodule Exexec.ToErl do
  @moduledoc false

  def command_to_erl(command) when is_list(command) do
    Enum.map(command, &to_charlist/1)
  end

  def command_to_erl(command) do
    to_charlist(command)
  end

  def command_options_to_erl(options) do
    for {key, value} <- options,
        option = command_option_to_erl(key, value),
      do: option
  end

  @boolean_options [:monitor, :sync, :kill_group, :pty]
  def command_option_to_erl(boolean_option, value)
  when boolean_option in @boolean_options do
    if value, do: boolean_option
  end

  @string_options [:executable, :cd, :kill_command, :user]
  def command_option_to_erl(string_option, value)
  when string_option in @string_options do
    string_option =
      if string_option == :kill_command, do: :kill, else: string_option

    {string_option, to_charlist(value)}
  end

  @integer_options [:kill_timeout, :success_exit_code, :nice]
  def command_option_to_erl(integer_option, value)
  when integer_option in @integer_options do
    {integer_option, value}
  end

  def command_option_to_erl(:group, value) do
    {:group,
     case value do
       value when is_integer(value) -> value
       value -> to_charlist(value)
     end}
  end

  def command_option_to_erl(:env, value) do
    env = to_env(value)

    {:env, env}
  end

  def command_option_to_erl(:stdin, value) do
    if value do
      case value do
        true -> :stdin
        string when is_binary(string) -> {:stdin, to_charlist(string)}
        other -> {:stdin, other}
      end
    end
  end

  @output_device_options [:stdout, :stderr]
  def command_option_to_erl(output_device_option, value)
  when output_device_option in @output_device_options do
    other_option = List.delete(@output_device_options, output_device_option)

    case value do
      true -> output_device_option
      false -> nil
      :stream -> {output_device_option, :stream}
      ^other_option ->
        {output_device_option, other_option}

      {filename, output_file_options} ->
        filename = to_charlist(filename)
        output_file_options = output_file_options_to_erl(output_file_options)
        {output_device_option, filename, output_file_options}

      _ ->
        {output_device_option, output_device_option_to_erl(value)}
    end
  end

  def output_device_option_to_erl(:null), do: :null
  def output_device_option_to_erl(:close), do: :close
  def output_device_option_to_erl(:print), do: :print
  def output_device_option_to_erl(path) when is_binary(path), do: to_charlist(path)
  def output_device_option_to_erl(pid) when is_pid(pid), do: pid
  def output_device_option_to_erl(fun) when is_function(fun, 3), do: fun

  def output_file_options_to_erl(output_file_options) do
    for {key, value} <- output_file_options,
        option = output_file_option_to_erl(key, value),
        do: option
  end

  def output_file_option_to_erl(:append, value), do: if value, do: :append
  def output_file_option_to_erl(:mode, value), do: {:mode, value}

  def exec_options_to_erl(options) do
    for {key, value} <- options,
        option = exec_option_to_erl(key, value),
        do: option
  end

  def exec_option_to_erl(:debug, value) do
    if value do
      case value do
        true -> :debug
        integer -> {:debug, integer}
      end
    end
  end

  def exec_option_to_erl(:verbose, value) do
    if value do
      :verbose
    end
  end

  def exec_option_to_erl(:alarm, value) do
    {:alarm, value}
  end

  @output_device_string_options [:user, :port_path]
  def exec_option_to_erl(string_option, value)
  when string_option in @output_device_string_options do
    string_option =
      if string_option == :port_path, do: :portexe, else: string_option
    {string_option, to_charlist(value)}
  end

  @output_device_string_list_options [:args, :limit_users]
  def exec_option_to_erl(string_list_option, value)
  when string_list_option in @output_device_string_list_options do
    {string_list_option, Enum.map(value, &to_charlist/1)}
  end

  def exec_option_to_erl(:env, value) do
    {:env, to_env(value)}
  end

  def to_env(value),
    do: for {key, value} <- value, do: {to_charlist(key), to_charlist(value)}
end
