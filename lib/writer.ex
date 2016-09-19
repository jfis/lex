#key => {val, [{k,v}]}
defmodule Writer do
  def int_rjust(int, just) do
    to_string(int) |> String.rjust(just)
  end
  def float_rjust(float, just) do
    Float.to_string(float, [decimals: 2]) |> String.rjust(just)
  end


  def sort_by_val(list) do
    Enum.sort(list, fn({_k1, v1}, {_k2, v2}) -> v1 > v2 end)
  end

  def sort_grouped(list) do
    Enum.sort(list, fn({_k1, {v1, _}}, {_k2, {v2, _}}) -> v1 > v2 end)
  end

  def sum(list) do
    Enum.reduce(list, 0, fn({_k,v}, acc) -> v + acc end)
  end

  def ignore_case(list) do
    list
    |> Enum.group_by(fn({k,_v}) -> k |> String.downcase end)
    |> Enum.map(fn({k,l}) -> {k, {sum(l), sort_by_val(l)}} end)
    |> sort_grouped()
    # |> Enum.reduce(%{}, fn({k,v}, a) ->
    #     norm = k |> String.downcase
    #       # |> String.to_char_list
    #       # |> to_string

    #     Map.update(a, norm, {v, [{k,v}]}, fn({v, }&(&1 + v) )
    #   end)
  end

  # def ignore_order(list) do
  #   list
  #   |> Enum.group_by(fn({k,_v}) -> k |> String.to_char_list |> Enum.sort |> to_string end)
  #   |> Enum.map(fn({k,l}) -> {k, {sum(l), sort_by_val(l)}} end)
  #   |> sort_grouped()
  #   # |> Enum.reduce(%{}, fn({k,v}, a) ->
  #     #   k =
  #     #     k
  #     #     |> String.to_char_list
  #     #     |> Enum.sort
  #     #     |> to_string
  #     #   Map.update(a, k, v, &(&1 + v) )
  #     # end)
  # end
  def ignore_case_and_order(list) do
    list
    |> Enum.group_by(fn({k,_v}) -> k |> String.downcase |> String.to_char_list |> Enum.sort |> to_string end)
    |> Enum.map(fn({k,l}) -> {k, {sum(l), sort_by_val(l)}} end)
    |> sort_grouped()
    # |> Enum.reduce(%{}, fn({k,v}, a) ->
      #   k =
      #     k
      #     |> String.to_char_list
      #     |> Enum.sort
      #     |> to_string
      #   Map.update(a, k, v, &(&1 + v) )
      # end)
  end

  def per_letter(list) do
    list
    |> Enum.reduce(%{}, fn({k,v}, acc) ->
        letters = k |> String.to_char_list

        wi = letters |> Enum.with_index()

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
    |> Enum.map(fn({k,v}) -> {k, sort_by_val(v)} end)
    |> Enum.sort_by(fn({_k,v}) ->
        Enum.reduce(v, 0, fn({_kk,vv}, acc) ->
          acc + vv
        end) #|> IO.inspect
      end)
    |> Enum.reverse
    #|> IO.inspect
  end

  defp blah([_tail], _total), do: ""
  defp blah(list, total) do
    for {k,v} <- list, into: "" do
      percent = float_rjust(v / total * 100, 5)
      "| #{String.ljust(k, 4)} #{int_rjust(v, 6)} #{percent} "
    end
  end

  # defp blah(ic, a, b, total) when a != b do
  #   {_, v_a} = List.keyfind(ic, a, 0, {"", 0})
  #   {_, v_b} = List.keyfind(ic, b, 0, {"", 0})

  #   {k_fst, v_fst, k_snd, v_snd} =
  #     if v_a >= v_b do
  #       {a, v_a, b, v_b}
  #     else
  #       {b, v_b, a, v_a}
  #     end

  #   if v_fst != 0 && v_snd != 0 do
  #     x = float_rjust(v_fst / v_snd, 5)

  #     percent_fst = float_rjust(v_fst / total * 100, 5)
  #     percent_snd = float_rjust(v_snd / total * 100, 5)

  #     "| #{String.ljust(k_fst, 4)} #{int_rjust(v_fst, 6)} #{percent_fst} " <>
  #     "| #{String.ljust(k_snd, 4)} #{int_rjust(v_snd, 6)} #{percent_snd} " <>
  #     "| #{x}"
  #   end
  # end
  # defp blah(_, _, _, _), do: ""

  # def write_order(io, ic, path, name, total) do
  #   for {k, v} <- io, into: "" do
  #     percent = float_rjust(v / total * 100, 5)

  #     b = String.to_char_list(k) |> Enum.reverse |> to_string
  #     addtl = blah(ic, k, b, total)

  #     "#{String.ljust(k, 4)} #{int_rjust(v, 6)} #{percent} #{addtl}\n"
  #   end
  #   |> write_file("#{path}/#{name}_order")
  # end
#
#
#
#
  def write(list, mode, submode, dir) do
    n = to_string(mode) <> to_string(submode)
    total = Enum.reduce(list, 0, fn({_k, v}, acc) -> acc + v end)

    path = "#{dir}/#{mode}"
    write(list, mode, path, n, total)
  end

  def write(list, :m, path, name, total) do
    list
    |> sort_by_val
    |> write_list(total, "#{path}/#{name}.txt")

    list
    |> ignore_case()
    |> write_grouped(total, "#{path}/#{name}_ignore_case.txt")
  end

  def write(list, :w, path, name, _total) do
    # list
    # |> ignore_case()
    # |> per_letter()
    # |> sort2()
    # |> write_list2("#{path}/#{name}_per_letter.txt")

    list
    |> per_letter()
    |> sort2()
    |> write_list2("#{path}/#{name}_per_letter2.txt")
  end

  def write(list, mode, path, name, total) when mode in [:pe, :p1, :p2] do
    list
    |> sort_by_val
    |> write_list(total, "#{path}/#{name}.txt")
  end

  def write(list, _mode, path, name, total) do
    list
      |> sort_by_val
      |> write_list(total, "#{path}/#{name}.txt")

    list
      |> ignore_case()
      |> write_grouped(total, "#{path}/#{name}_icase.txt")

    # list
    #   |> ignore_order()
    #   |> write_grouped(total, "#{path}/#{name}_iorder.txt")

    list
      |> ignore_case_and_order()
      |> write_grouped(total, "#{path}/#{name}_iboth.txt")

    # io
    # |> per_letter()
    # |> sort2()
    # |> write_list2("#{path}/#{name}_per_letter.txt")

    list
    |> per_letter()
    |> sort2()
    |> write_list2("#{path}/#{name}_per_letter2.txt")
  end
#
#
#
#

  # def make_path(dir, mode, filename), do: "#{dir}/#{mode}/#{filename}.txt"

  def write_list(list, total, path) do
    for {k, v} <- list, into: "" do
      pct = float_rjust(v / total * 100, 5)
      s_k = String.ljust(k, 4)
      s_v = int_rjust(v, 6)
      "#{s_k} #{s_v} #{pct}\n"
    end
    |> write_file(path)
  end

  def write_grouped(list, total, path) do
    for {k, {v, l}} <- list, into: "" do
      pct = float_rjust(v / total * 100, 5)
      s_k = String.ljust(k, 4)
      s_v = int_rjust(v, 6)

      addtl = blah(l, v)
      "#{s_k} #{s_v} #{pct}    #{addtl}\n"
    end
    |> write_file(path)
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
      percent = float_rjust(sum / total * 100, 5)
      letters = for {kk, _vv} <- v, into: "", do: kk
      rest = for {kk, vv} <- v, into: "", do: "#{kk}.#{vv} "

      "#{String.ljust(k, 4)} #{int_rjust(sum, 6)} #{percent}\n#{letters}\n#{rest}\n\n"
    end
    |> write_file(path)
  end

  def write_file(b, filename) do
    File.write!(filename, b, [:write, :binary])
  end
end
