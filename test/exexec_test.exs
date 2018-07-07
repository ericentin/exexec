defmodule ExexecTest do
  use ExUnit.Case

  import Exexec
  require Logger

  setup do
    {:ok, pid} = Exexec.start()

    on_exit fn ->
      try do
        GenServer.stop(pid, :shutdown)
      catch
        _, _ -> :ok
      end
    end

    :ok
  end

  test "kill" do
    {:ok, sleep_pid, sleep_os_pid} = run("sleep 10", monitor: true)

    assert :ok = kill(sleep_os_pid, 9)

    assert_receive {:DOWN, _, :process, ^sleep_pid, {:exit_status, 9}}
  end

  test "manage" do
    bash = System.find_executable("bash")
    {:ok, _spawner_pid, spawner_os_pid} = run([bash, "-c" ,"sleep 100 & echo $!"], stdout: true)

    sleep_os_pid =
      receive do
        {:stdout, ^spawner_os_pid, sleep_pid_string} ->
          {sleep_pid, _} = Integer.parse(sleep_pid_string)
          sleep_pid
      end

    {:ok, sleep_pid, ^sleep_os_pid} = manage(sleep_os_pid)

    assert :ok = kill(sleep_pid, 9)

    {:ok, _ps_pid, ps_os_pid} = run("ps -p #{sleep_os_pid}", stdout: true)

    stdout =
      receive do
        {:stdout, ^ps_os_pid, stdout} -> stdout
      end

    refute stdout =~ to_string(sleep_os_pid)
  end

  test "os_pid" do
    {:ok, sleep_pid, sleep_os_pid} = run_link("sleep 100")

    assert os_pid(sleep_pid) == {:ok, sleep_os_pid}

    {:ok, pid} = Task.start_link fn ->
      receive do
        {{pid, ref}, :ospid} -> Kernel.send pid, {ref, {:error, :testing}}
      end
    end

    assert os_pid(pid) == {:error, :testing}
  end

  test "pid" do
    {:ok, sleep_pid, sleep_os_pid} = run_link("sleep 100")

    assert pid(sleep_os_pid) == {:ok, sleep_pid}

    assert pid(123411231231) == {:error, :undefined}
  end

  test "run" do
    assert run("echo hi", sync: true, stdout: true) == {:ok, [stdout: ["hi\n"]]}
  end

  test "run_link" do
    Process.flag(:trap_exit, true)

    {:ok, pid, os_pid} =
      run_link("echo $EXEXEC_TEST_VAR; false", stdout: true, env: %{"EXEXEC_TEST_VAR" => "TRUE"})

    assert_receive {:stdout, ^os_pid, "TRUE\n"}

    assert_receive {:EXIT, ^pid, {:exit_status, 256}}
  end

  test "send" do
    {:ok, cat_pid, cat_os_pid} = run_link("cat", stdin: true, stdout: true)

    assert :ok = Exexec.send(cat_pid, "hi\n")

    assert_receive {:stdout, ^cat_os_pid, "hi\n"}

    assert :ok = Exexec.send(cat_os_pid, "hi2\n")

    assert_receive {:stdout, ^cat_os_pid, "hi2\n"}
  end

  @tag :capture_log
  test "set_gid" do
    Process.flag(:trap_exit, true)

    {:ok, _sleep_pid, sleep_os_pid} = run_link("sleep 100")

    try do
      set_gid(sleep_os_pid, 123123)
    catch
      :exit, reason ->
        assert reason == {{:exit_status, 139}, {:gen_server, :call, [:exec, {:port, {:setpgid, sleep_os_pid, 123123}}]}}
    end
  end

  test "status" do
    assert status(1) == {:signal, :sighup, false}
    assert status(256) == {:status, 1}
    assert status(0) == {:status, 0}
  end

  # test "stop" do
  #   {:ok, sleep_pid, sleep_os_pid} = run_link("sleep 10")
  #
  #   assert :ok = stop(sleep_os_pid)
  #
  #   # Is this broken in erlexec? it doesn't really seem to do anything
  # end

  # test "stop_and_wait" do
  #   {:ok, sleep_pid, sleep_os_pid} = run_link("sleep 1; echo ok")
  #
  #   assert :ok = stop_and_wait(sleep_pid)
  #
  #   {:ok, _ps_pid, ps_os_pid} = run("ps -p #{sleep_os_pid}", stdout: true)
  #
  #   stdout =
  #     receive do
  #       {:stdout, ^ps_os_pid, stdout} -> stdout
  #     end
  #
  #   refute stdout =~ to_string(sleep_os_pid)
  #   # Is this broken in erlexec? it doesn't really seem to do anything
  # end

  test "which_children" do
    {:ok, _sleep_pid, sleep_os_pid} = run_link("sleep 10")

    assert which_children() == [sleep_os_pid]
  end
end
