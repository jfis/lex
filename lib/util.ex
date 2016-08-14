defmodule Util do
  require Logger

  # @vowels [?e,?a,?o,?i,?u, ?E,?A,?O,?I,?U]

  def starting(r, mode) do
    Logger.debug "starting #{inspect mode} "
    r
  end
  def merged(r, mode) do
    Logger.debug "merged #{inspect mode} "
    r
  end
  def wait_over(r, mode) do
    Logger.debug "wait over #{inspect mode} #{Enum.count r}"
    r
  end
  def sort_map_by_val(m) do
    Enum.sort(m, fn({_k1, v1}, {_k2, v2}) -> v1 > v2 end)
  end

  # def map_merge(a, b) do
  #   Map.merge(a, b, fn(_k, va, vb) -> va + vb end)
  # end

  # def map_merge_async(maps) do
  #   #divide and conquer
  #   maps
  #   # |> IO.inspect
  #   # |> Enum.map(&List.keysort(&1, 0))
  #   |> Enum.chunk(2, 2, [%{}])
  #   # |> IO.inspect
  #   |> Parallel.pmap(&:erlang.apply(__MODULE__, :map_merge, &1))
  #   # |> Enum.map(&Task.await(&1))
  #   # |> Enum.chunk(2, 2, [%{}])
  #   # |> Parallel.pmap(&:erlang.apply(__MODULE__, :map_merge, &1))
  #   # |> Enum.map(&Task.await(&1))
  #   |> merge_list_of_maps
  # end

  def merge_list_of_maps(maps) do
    maps
      |> Enum.reduce(%{}, fn(i, acc) ->
          Map.merge(acc, i, fn(_k, a, b) -> a + b end)
        end)
  end

  # @letters :binary.compile_pattern(~r/^[a-z]$/i)
  @letters ~r/^[a-z]+$/i
  def ignore_all_letters(list) do
    list
    |> Enum.reject( fn({k,_v}) -> k =~ @letters end)
    # |> IO.inspect
  end

  @left ~r/[aeiou]/
  def reject_vowels(list) do
    list
    |> Enum.reject( fn({k,_v}) -> k =~ @left end)
    # |> IO.inspect
  end
end

