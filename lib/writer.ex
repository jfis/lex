
defmodule Writer do
  def ignore_case(list) do
    list
    |> Enum.reduce(%{}, fn({k,v}, a) ->
        # IO.inspect k
        k =
          k
          |> String.downcase
          |> String.to_char_list
          # |> Enum.sort
          |> to_string
        Map.update(a, k, v, &(&1 + v) )
      end)
  end

  def ignore_order(list) do
    list
    |> Enum.reduce(%{}, fn({k,v}, a) ->
        # IO.inspect k
        k =
          k
          # |> String.downcase
          |> String.to_char_list
          |> Enum.sort
          |> to_string
        Map.update(a, k, v, &(&1 + v) )
      end)
  end

  # def reject_spaces(list) do
  #   list
  #   |> Enum.reject( fn({k,_v}) -> k =~ ~r/\s/ end)
  # end
  # only_left =
  #   fn(list) ->
  #     list |> Enum.filter( fn({k,_v}) -> k =~ left end)
  #   end

  def per_letter(list) do
    list
    |> Enum.reduce(%{}, fn({k,v}, acc) ->
        letters = k |> String.to_char_list

        wi = letters |> Enum.with_index() #|> IO.inspect

          # for c1 <- letters,
          #     c2 <- letters,
              # c1 != c2,
        m =
          for {c1, i} <- wi,
              {c2, j} <- wi,
              i != j,
              into: %{}
          do
            acc
            |> Map.put_new(<<c1>>, %{})
            |> Map.put_new(<<c2>>, %{})

            {<<c1>>, Map.put(%{}, <<c2>>, v)}
          end
        Map.merge(acc, m, fn(_k, a, b) ->
          Map.merge(a, b, fn(_kk, aa, bb) ->
            aa + bb
          end)
        end)

        # |> IO.inspect
      end)
  end

  def sort2(list) do
    list
    |> Enum.map(fn({k,v}) -> {k, Util.sort_map_by_val(v)} end)
    |> Enum.sort_by(fn({_k,v}) ->
        Enum.reduce(v, 0, fn({_kk,vv}, acc) ->
          acc + vv
        end) #|> IO.inspect
      end)
    |> Enum.reverse
    #|> IO.inspect
  end

  def write(m, :ma, dir) do
    m
    # |> Util.reject_vowels()
    |> write_list(make_path(dir, "m"))
    |> ignore_case()
    |> Util.sort_map_by_val
    |> write_list(make_path(dir, "m_ignore_case"))
  end

  def write(m, mode, submode, dir) do
    n = to_string(mode) <> to_string(submode)

    m
    # |> Util.reject_vowels()
    |> write_list(make_path(dir, n))
    |> ignore_case()
    |> Util.sort_map_by_val
    |> write_list(make_path(dir, "#{n}_ignore_case"))
    |> ignore_order()
    |> Util.sort_map_by_val
    |> write_list(make_path(dir, "#{n}_ignore_order"))
    |> per_letter()
    |> sort2()
    |> write_list2(make_path(dir, "#{n}_per_letter"))

    m
    |> per_letter()
    |> sort2()
    |> write_list2(make_path(dir, "#{n}_per_letter2"))
  end

  def make_path(dir, filename), do: "#{dir}/#{filename}.txt"

  def write_list(list, path) do

    total = Enum.reduce(list, 0, fn({_k, v}, acc) -> acc + v end)

    for {k, v} <- list, into: "" do
      percent =
        Float.to_string(v / total * 100, [decimals: 2])
        # |> to_string
        |> String.rjust(5)

      "#{String.ljust(k, 4)} #{String.rjust(v |> to_string, 6)} #{percent}\n"
    end
    |> write_file(path)
    list
  end

  def write_list2(list, path) do
    # IO.inspect list
    #sum first
    with_sums =
      for {k, v} <- list do
        sum = Enum.reduce(v, 0, fn({_kk, vv}, acc) -> acc + vv end)
        {k,v,sum}
      end

    total =
      Enum.reduce(with_sums, 0, fn({_k, _v, sum}, acc) -> acc + sum end)

    for {k, v, sum} <- with_sums, into: "" do
      percent =
        Float.to_string(sum / total * 100, [decimals: 2])
        # |> to_string
        |> String.rjust(5)
      letters = for {kk, _vv} <- v, into: "", do: kk
      rest = for {kk, vv} <- v, into: "", do: "#{kk}.#{vv} "

      "#{String.ljust(k, 4)} #{String.rjust(sum |> to_string, 6)} #{percent}\n#{letters}\n#{rest}\n\n"
    end
    |> write_file(path)

    list
  end

  def write_file(b, filename) do
    File.write!(filename, b, [:write, :binary])
  end
end
