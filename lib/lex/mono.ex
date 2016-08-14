defmodule Lex.An do
  def monograph(curr, acc) do

    # Map.update(acc, curr, 1, &(&1 + 1) )
    Map.update(acc, curr, 1, &(&1 + 1) )
  end

  def digraph(_curr, last1, acc) when last1 == "" do
    acc
  end
  def digraph(curr, last1, acc) do
    # acc
    # k = last1 <> curr
    [last1 <> curr|acc]
    # Map.update(acc, k, 1, &(&1 + 1) )
  end

  def trigraph(_curr, last2, _last1, acc) when last2 == "" do
    acc
  end
  def trigraph(curr, last2, last1, acc) do
    # acc
    [last2 <> last1 <> curr|acc]
    # k = last2 <> last1 <> curr
    # Map.update(acc, k, 1, &(&1 + 1) )
  end

  # def wordgraph(word, acc) do
  #   wi =
  #     word
  #     # |> String.downcase
  #     # |> Enum.reject(&(&1 in [97,101,105,111,117]))
  #     |> Enum.with_index()

  #   keys =
  #     for {a, i} <- wi,
  #         {b, j} <- wi,
  #         i < j, a != b, do: <<b, a>>

  #   keys
  #   |> Enum.reduce(acc, fn(k, a) ->
  #     Map.update(a, k, 1, &(&1 + 1) )
  #   end)
  # end

end
