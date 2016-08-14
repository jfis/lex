defmodule Parallel do
  require Logger

  def pmap(collection, fun) do
    me = self
    collection
      |> Enum.map(fn (elem) ->
          spawn fn -> (send me, fun.(elem) ) end
        end)
      |> Enum.map(fn (_pid) ->
          receive do result -> result end
        end)
  end

  def pcast(collection, fun) do
    me = self
    collection
      |> Enum.map(fn (elem) ->
          spawn fn ->
              send me, fun.(elem)
            end
        end)
      |> Enum.flat_map(fn (_pid) ->
          receive do _ -> [] end
        end)
  end

  # def reducer2(state, count, total, pid) when count == total do
  #   # IO.inspect total
  #   # IO.inspect count
  #   send(pid, state)
  # end
  # def reducer2(state, count, total, pid) do
  #   receive do
  #     result ->
  #       Logger.debug count
  #       # IO.inspect Process.info(self, :message_queue_len)
  #       Map.merge(state, result, fn(_k, va, vb) -> va + vb end)
  #       |> reducer2(count+1, total, pid)
  #   end
  # end

  def reducer(state, count, total, pid) when count == total do
    # IO.inspect total
    # IO.inspect count
    send(pid, state)
  end
  def reducer(state, count, total, pid) do
    receive do
      result ->
        # IO.inspect Process.info(self, :message_queue_len)
        Map.merge(state, result, fn(_k, va, vb) -> va + vb end)
        |> reducer(count+1, total, pid)
    end
  end

  def pmap_map_merge(collection, fun) do
    num_reducers = 4
    level2 = spawn(__MODULE__, :reducer, [%{}, 0, num_reducers, self])
    count = Enum.count(collection)
    per = div(count, num_reducers)
    leftover = rem(count, num_reducers)

    reducers =
      for i <- 0..num_reducers-1, into: %{} do
        add =
          case leftover do
            0 -> 0
            n when i < n -> 1
            _ -> 0
          end
        {i, spawn(__MODULE__, :reducer, [%{}, 0, per+add, level2])}
      end

    collection
      |> Stream.with_index()
      |> Enum.map(fn({elem, i}) ->
        which_reducer = rem(i, num_reducers)
        rpid = reducers[which_reducer]
        spawn fn -> (send rpid, fun.(elem) ) end
      end)

    receive do
      m -> m
    end
  end
end
