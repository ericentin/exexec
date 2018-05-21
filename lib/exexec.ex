defmodule Exexec do
  @moduledoc """
  Execute and control OS processes from Elixir.

  An idiomatic Elixir wrapper for Serge Aleynikov's excellent
  [erlexec](https://github.com/saleyn/erlexec), Exexec provides an Elixir
  interface as well as some nice Elixir-y goodies on top.
  """

  import Exexec.ToErl
  import Kernel, except: [send: 2]

  @type command :: String.t | [Path.t | [String.t]]

  @type os_pid :: non_neg_integer

  @type gid :: non_neg_integer

  @type output_file_option ::
    {:append, boolean} |
    {:mode, non_neg_integer}

  @type output_device :: :stdout | :stderr

  @type output_file_options :: [output_file_option]

  @type output_device_option ::
    boolean |
    :null |
    :close |
    :print |
    Path.t |
    {Path.t, output_file_options} |
    pid |
    :stream |
    (output_device, os_pid, binary -> any)

  @type command_option ::
    {:monitor, boolean} |
    {:sync, boolean} |
    {:executable, Path.t} |
    {:cd, Path.t} |
    {:env, %{String.t => String.t}} |
    {:kill_command, String.t} |
    {:kill_timeout, non_neg_integer} |
    {:kill_group, boolean} |
    {:group, String.t} |
    {:user, String.t} |
    {:success_exit_code, exit_code} |
    {:nice, -20..20} |
    {:stdin, boolean | :null | :close | Path.t} |
    {:stdout, :stderr | output_device_option} |
    {:stderr, :stdout | output_device_option} |
    {:pty, boolean}

  @type command_options :: [command_option]

  @type exec_option ::
    {:debug, boolean | non_neg_integer} |
    {:verbose, boolean} |
    {:args, [String.t]} |
    {:alarm, non_neg_integer} |
    {:user, String.t} |
    {:limit_users, [String.t]} |
    {:port_path, Path.t} |
    {:env, %{String.t => String.t}}

  @type exec_options :: [exec_option]

  @type signal :: pos_integer

  @type on_run ::
    {:ok, pid, os_pid} |
    {:ok, pid, os_pid, [{:stream, Enumerable.t, pid}]} |
    {:ok, [{output_device, [binary]}]} |
    {:error, any}

  @type exit_code :: non_neg_integer

  @doc """
  Send `signal` to `pid`.

  `pid` can be an `Exexec` pid, OS pid, or port.
  """
  @spec kill(pid | os_pid | port, signal) :: :ok | {:error, any}
  defdelegate kill(pid, signal), to: :exec

  @doc """
  Start an `Exexec` process to manage existing `os_pid` with options `options`.

  `os_pid` can also be a port.
  """
  @spec manage(os_pid | port) :: {:ok, pid, os_pid} | {:error, any}
  @spec manage(os_pid | port, command_options) :: {:ok, pid, os_pid} | {:error, any}
  def manage(os_pid, options \\ []),
    do: :exec.manage(os_pid, command_options_to_erl(options))

  @doc """
  Returns the OS pid for `Exexec` process `pid`.
  """
  @spec os_pid(pid) :: {:ok, os_pid} | {:error, any}
  def os_pid(pid) do
    case :exec.ospid(pid) do
      {:error, reason} -> {:error, reason}
      os_pid -> {:ok, os_pid}
    end
  end

  @doc """
  Returns the `Exexec` pid for `os_pid`.
  """
  @spec pid(os_pid) :: {:ok, pid} | {:error, any}
  def pid(os_pid) do
    case :exec.pid(os_pid) do
      {:error, reason} -> {:error, reason}
      :undefined -> {:error, :undefined}
      pid -> {:ok, pid}
    end
  end

  @doc """
  Run an external `command` with `options`.
  """
  @spec run(command) :: on_run
  @spec run(command, command_options) :: on_run
  def run(command, options \\ []) do
    prepare_run_exec(:run, command, options)
  end

  @doc """
  Run an external `command` with `options`, linking to the current process.

  If the external process exits with code 0, the linked process will not exit.
  """
  @spec run_link(command) :: on_run
  @spec run_link(command, command_options) :: on_run
  def run_link(command, options \\ []) do
    prepare_run_exec(:run_link, command, options)
  end

  defp handle_extras([{:stdout, :stream}]) do
    {:ok, stream, server} = Exexec.StreamOutput.create_line_stream()
    {:ok, [{:stdout, server}], [{:stream, stream, server}]}
  end
  defp handle_extras(_) do
    {:ok, [], []}
  end

  defp prepare_run_exec(type, command, options) do
    with :ok <- Exexec.Extras.validate(options) do
      command = command_to_erl(command)
      {extras, options} = Exexec.Extras.split(options)
      {:ok,  additional_options, stream} = handle_extras(extras)
      options = command_options_to_erl(options)
      case {run_exec(type, command, options ++ additional_options), stream} do
        {result, []} -> result
        {{:ok, pid, os_pid}, [{:stream, stream, server_pid}]} ->
          Kernel.send(server_pid, {:monitor, pid})
          {:ok, pid, os_pid, [{:stream, stream, server_pid}]}
      end
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp run_exec(:run, command, options) do
    :exec.run(command, options)
  end
  defp run_exec(:run_link, command, options) do
    :exec.run_link(command, options)
  end

  @doc """
  Send `data` to the stdin of `pid`.

  `pid` can be an `Exexec` pid or an OS pid.
  """
  @spec send(pid | os_pid, binary | :eof) :: :ok
  defdelegate send(pid, data), to: :exec

  @doc """
  Change group ID of `os_pid` to `gid`.
  """
  @spec set_gid(os_pid, gid) :: :ok | {:error, any}
  defdelegate set_gid(os_pid, gid), to: :exec, as: :setpgid

  @doc """
  Convert integer `signal` to atom, or return `signal`.
  """
  @spec signal(signal) :: atom | integer
  defdelegate signal(signal), to: :exec

  @doc """
  Start `Exexec`.
  """
  @spec start() :: {:ok, pid} | {:error, any}
  defdelegate start(), to: :exec

  @doc """
  Start `Exexec` with `options`.
  """
  @spec start(exec_options) :: {:ok, pid} | {:error, any}
  defdelegate start(options), to: :exec

  @doc """
  Start `Exexec` and link to calling process.
  """
  @spec start_link :: {:ok, pid} | {:error, any}
  def start_link(), do: start_link([])

  @doc """
  Start `Exexec` with `options` and link to calling process.
  """
  @spec start_link(exec_options) :: {:ok, pid} | {:error, any}
  defdelegate start_link(options), to: :exec

  @doc """
  Interpret `exit_code`.

  If the program exited by signal, returns `{:signal, signal, core}` where `signal`
  is the atom or integer signal and `core` is whether a core file was generated.
  """
  @spec status(exit_code) :: {:status, signal} | {:signal, signal | :atom, boolean}
  defdelegate status(exit_code), to: :exec

  @doc """
  Stop `pid`.

  `pid` can be an `Exexec` pid, OS pid, or port.

  The OS process is terminated gracefully. If `:kill_command` was specified,
  that command is executed and a timer is started. If the process doesn't exit
  immediately, then by default after 5 seconds SIGKILL will be sent to the process.
  """
  @spec stop(pid | os_pid | port) :: :ok | {:error, any}
  defdelegate stop(pid), to: :exec

  @doc """
  Stop `pid` and wait for it to exit for `timeout` milliseconds.

  See `Exexec.stop/1`.
  """
  @spec stop_and_wait(pid | os_pid | port) :: :ok | {:error, any}
  @spec stop_and_wait(pid | os_pid | port, integer) :: :ok | {:error, any}
  def stop_and_wait(pid, timeout \\ 5_000), do: :exec.stop_and_wait(pid, timeout)

  @doc """
  Return a list of OS pids managed by `Exexec`.
  """
  @spec which_children() :: [os_pid]
  defdelegate which_children(), to: :exec
end
