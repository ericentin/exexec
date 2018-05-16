defmodule Exexec.StreamOutput do

  def create_line_stream do
    {:ok, pid} = Exexec.StreamOutput.Server.start()
    stream = Stream.unfold(pid, &get_line/1)
    {:ok, stream, pid}
  end

  def stop(pid) do
    send(pid, :stop)
  end

  defp get_line(pid) do
    try do
      case GenServer.call(pid, :get_data, :infinity) do
        nil -> nil;
        data -> {data, pid}
      end
    catch
      :exit, {:noproc, _} -> nil
    end
  end

  defmodule Server do
    use GenServer
    require Record
    Record.defrecordp :state, [:done, :chunks, :client, :port]

    def start() do
      GenServer.start(__MODULE__, state(chunks: :queue.new))
    end

    def init(state) do
      {:ok, state}
    end

    def handle_info({:stdout, _, data}, state(client: nil, chunks: q) = state) do
      # nobody is waiting for data
      {:noreply, state(state, chunks: :queue.in(data, q))}
    end

    def handle_info({:stdout, _, data}, state(client: from, chunks: q) = state) do
      # there is a client waiting for this piece of data
      true = :queue.is_empty(q)
      GenServer.reply(from, data)
      {:noreply, state(state, client: nil)}
    end

    def handle_info({:monitor, pid}, state) do
      Process.monitor(pid)
      {:noreply, state(state, port: pid)}
    end

    def handle_info({:"DOWN", _ref, :process, pid, _reason}, state(client: nil, port: port_pid) = state)
    when port_pid == pid do
      {:noreply, state(state, done: true)}
    end

    def handle_info({:"DOWN", _ref, :process, pid, _reason}, state(client: from, port: port_pid) = state)
    when port_pid == pid do
      GenServer.reply(from, nil)
      {:stop, :shutdown, state}
    end

    def handle_info(:stop, state) do
      {:stop, :shutdown, state}
    end

    def handle_call(:get_data, _from, state(done: true, chunks: q) = state) do
      if :queue.is_empty(q) do
        {:stop, :shutdown, nil, state}
      else
        {:reply, :queue.head(q), state(state, chunks: :queue.tail(q))}
      end
    end

    def handle_call(:get_data, from, state(chunks: q) = state) do
      if :queue.is_empty(q) do
        {:noreply, state(state, client: from)}
      else
        {:reply, :queue.head(q), state(state, chunks: :queue.tail(q))}
      end
    end
  end
end
