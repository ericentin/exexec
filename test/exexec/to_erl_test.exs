defmodule Exexec.ToErlTest do
  use ExUnit.Case

  import Exexec.ToErl

  test "converts string command to erl" do
    assert command_to_erl("hello") == 'hello'
    assert command_to_erl(["hello", "world"]) == ['hello', 'world']
  end

  test "converts all command options to erl" do
    output_fun = fn _, _, _ -> :ok end

    assert command_options_to_erl([
      monitor: true,
      monitor: false,
      sync: true,
      sync: false,
      executable: "executable",
      cd: "cd",
      env: %{"hello" => "world", "env" => "var"},
      kill_command: "kill_command",
      kill_timeout: 123,
      kill_group: true,
      kill_group: false,
      group: 0,
      user: "user",
      success_exit_code: 12,
      nice: 10,
      stdin: true,
      stdin: false,
      stdin: :null,
      stdin: :close,
      stdin: "stdin",
      stdout: true,
      stdout: false,
      stdout: :null,
      stdout: :close,
      stdout: :print,
      stdout: "stdout",
      stdout: {"stdout", append: true, append: false, mode: 0o123},
      stdout: self(),
      stdout: output_fun,
      stderr: true,
      stderr: false,
      stderr: :null,
      stderr: :close,
      stderr: :print,
      stderr: "stderr",
      stderr: {"stderr", append: true, append: false, mode: 0o12},
      stderr: self(),
      stderr: output_fun,
      pty: true,
      pty: false
    ]) == [
      :monitor,
      :sync,
      {:executable, 'executable'},
      {:cd, 'cd'},
      {:env, [{'env', 'var'}, {'hello', 'world'}]},
      {:kill, 'kill_command'},
      {:kill_timeout, 123},
      :kill_group,
      {:group, 0},
      {:user, 'user'},
      {:success_exit_code, 12},
      {:nice, 10},
      :stdin,
      {:stdin, :null},
      {:stdin, :close},
      {:stdin, 'stdin'},
      :stdout,
      {:stdout, :null},
      {:stdout, :close},
      {:stdout, :print},
      {:stdout, 'stdout'},
      {:stdout, 'stdout', [:append, {:mode, 83}]},
      {:stdout, self()},
      {:stdout, output_fun},
      :stderr,
      {:stderr, :null},
      {:stderr, :close},
      {:stderr, :print},
      {:stderr, 'stderr'},
      {:stderr, 'stderr', [:append, {:mode, 10}]},
      {:stderr, self()},
      {:stderr, output_fun},
      :pty
    ]
  end

  # {:debug, boolean | non_neg_integer} |
  # {:verbose, boolean} |
  # {:args, [String.t]} |
  # {:alarm, non_neg_integer} |
  # {:user, String.t} |
  # {:limit_users, [String.t]} |
  # {:port_path, Path.t} |
  # {:env, %{String.t => String.t}}
  test "converts all exec options to erl" do
    assert exec_options_to_erl([
      debug: true,
      debug: false,
      debug: 1,
      verbose: true,
      verbose: false,
      args: ["arg1", "arg2"],
      alarm: 2,
      user: "user",
      limit_users: ["user1", "user2"],
      port_path: "port_path",
      env: %{"hello" => "world", "env" => "var"}
    ]) == [
      :debug,
      {:debug, 1},
      :verbose,
      {:args, ['arg1', 'arg2']},
      {:alarm, 2},
      {:user, 'user'},
      {:limit_users, ['user1', 'user2']},
      {:portexe, 'port_path'},
      {:env, [{'env', 'var'}, {'hello', 'world'}]}
    ]
  end
end
