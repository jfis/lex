
defmodule Reader do

  @vowels [?e,?a,?o,?i,?u]
    |> Enum.flat_map(&([&1, &1-32]))


  @left [?e,?a,?o,?i,?h,?y,?u,?f, ?k]
    |> Enum.flat_map(&([&1, &1-32]))
    |> Enum.concat([?,, ?., ?'])

  @right [?t,?n,?s,?r, ?c,?d,?l, ?m,?g,?w,?p,?b, ?v,?x, ?q,?j,?z]
    |> Enum.flat_map(&([&1, &1-32]))
    |> Enum.concat([?(,?),?[,?],?{,?} ])

  # @shift_left [?|, ?&, ?=, ?<, ?>, ?!, ?+, ]
  # @shift_right [?(, ?), ?{, ?}, ?_, ?%, ?# ]


  #TODO this makes digraphs unnecessarily
  def process_word(_mode, [], acc), do: acc
  def process_word(:pe, chars, acc) do
    Map.update(acc, << Enum.at(chars, 0) >>, 1, &(&1 + 1))
  end
  def process_word(:p1, chars, acc) do
    rchars = Enum.reverse(chars)
    Map.update(acc, << Enum.at(rchars, 0) >>, 1, &(&1 + 1))
  end
  def process_word(_mode, [_|[]], acc), do: acc
  def process_word(:p2, chars, acc) do
    rchars = Enum.reverse(chars)
    Map.update(acc, << Enum.at(rchars, 1) >>, 1, &(&1 + 1))
  end
  def process_word(_mode, chars, acc) do
    cwi = chars |> Enum.with_index()

    dis =
      for {c1, i} <- cwi,
          {c2, j} <- cwi,
          i < j, do: <<c1, c2>>
    dis
    |> Enum.reduce(acc, fn(k, a) ->
      Map.update(a, k, 1, &(&1 + 1))
    end)
    # Map.update(acc, List.to_string(chars), 1, &(&1 + 1)) #was slower!!!
  end

  def read_word(mode, submode, line, state, acc) do
    case read_word(line) do
      :end ->
        process_word(mode, state, acc)
      {:reset, remaining}->
        read_word(mode, submode, remaining, [], process_word(mode, state, acc))
      {char, remaining} ->
        if subfilter(submode, char) do
          read_word(mode, submode, remaining, [char | state], acc)
        else
          read_word(mode, submode, remaining, state, acc)
        end
      _ ->
        raise "???"
    end
  end
  def read_word(<<>>), do: :end
  def read_word(<<10>>), do: :end
  def read_word(<<32, rest::binary>>), do: {:reset, rest}
  def read_word(<<c, rest::binary>>) when c < 33 or c > 126 do
    read_word(rest)
  end
  def read_word(<<c, rest::binary>>), do: {c, rest}


  def read_n(mode, submode, line, state, acc) do
    case read_n(line) do
      :end ->
        acc
      {:reset, remaining}->
        read_n(mode, submode, remaining, init_state(mode), acc)
      {char, remaining} ->
        if subfilter(submode, char) do
          acc =
            case make_gram(mode, char, state) do
              nil ->
                acc
              gram ->
                Map.update(acc, gram, 1, &(&1 + 1))
            end
          read_n(mode, submode, remaining, next_state(mode, char, state), acc)
        else
          read_n(mode, submode, remaining, state, acc)
        end
      _ ->
        raise "???"
    end
  end

  def subfilter(:a, _), do: true
  def subfilter(:r, c) when c in @left, do: false
  def subfilter(:l, c) when c in @right, do: false
  def subfilter(:nv, c) when c in @vowels, do: false
  def subfilter(:v, c) when not c in @vowels, do: false
  def subfilter(:p, c) when (c >= 65 and c <= 90) or (c >= 97 and c <= 122), do: false
  def subfilter(:np, c) when c < 65 or (c > 90 and c < 97) or c > 122, do: false
  def subfilter(_, _), do: true

  def read_n(<<>>), do: :end
  def read_n(<<10>>), do: :end
  def read_n(<<32, rest::binary>>), do: {:reset, rest}
  def read_n(<<c, rest::binary>>) when c < 33 or c > 126 do
    read_n(rest)
  end
  def read_n(<<c, rest::binary>>), do: {c, rest}


  def next_state(:m, _char, _state), do: []
  def next_state(:d, char, _state), do: {<<char>>}
  def next_state(:t, char, {last1, _}), do: {<<char>>, last1}
  def next_state(:q, char, {last1, last2, _}), do: {<<char>>, last1, last2}

  def make_gram(:m, char, _prev), do: <<char>>
  def make_gram(:d, _char, {""}), do: nil
  def make_gram(:d, char, {last1}), do: last1 <> <<char>>
  def make_gram(:t, _char, {_last1, ""}), do: nil
  def make_gram(:t, char, {last1, last2}), do: last2 <> last1 <> <<char>>
  def make_gram(:q, _char, {_last1, _last2, ""}), do: nil
  def make_gram(:q, char, {last1, last2, last3}), do: last3 <> last2 <> last1 <> <<char>>

  def init_state(:m), do: []
  def init_state(:d), do: {""}
  def init_state(:t), do: {"", ""}
  def init_state(:q), do: {"", "", ""}

  # def do_line(line, mode, submode) do
  #   spawn(__MODULE__, :read_n, [self, mode, submode, line, init_state(mode)])
  #   loop(%{})
  # end

  # def loop(state) do
  #   receive do
  #     :done ->
  #       state
  #     {:gram, nil} ->
  #       loop(state)
  #     {:gram, gram} ->
  #       Map.update(state, gram, 1, &(&1 + 1))
  #       |> loop()
  #     _ ->
  #       loop(state)
  #   end
  # end

  #returns list of maps
  def do_line(line, :pe=mode, submode) do
    read_word(mode, submode, line, [], %{})
  end
  def do_line(line, :p1=mode, submode) do
    read_word(mode, submode, line, [], %{})
  end
  def do_line(line, :p2=mode, submode) do
    read_word(mode, submode, line, [], %{})
  end
  def do_line(line, :w=mode, submode) do
    read_word(mode, submode, line, [], %{})
  end

  def do_line(line, mode, submode) do
    # IO.inspect byte_size(line)
    # spawn(__MODULE__, :read_n, [self, mode, submode, line, init_state(mode), %{}])

    read_n(mode, submode, line, init_state(mode), %{})
    # |> IO.inspect# loop(%{})
  end


  #process for each line, results merged as they come in
  def do_lines(lines, {mode, submode}=_m, output_dir) do

    lines
    |> Parallel.pmap_map_merge(&__MODULE__.do_line(&1, mode, submode))
    # |> Util.sort_map_by_val
    # |> Enum.sort(fn({_k1, v1}, {_k2, v2}) -> v1 > v2 end)
    |> Writer.write(mode, submode, output_dir)

  end

  def do_modes(lines, modes, output_dir) do
    #process for each mode
    modes
    |> Parallel.pmap(&:erlang.apply(__MODULE__, :do_lines, [lines, &1, output_dir]))
  end

  def file(modes, filename, output_dir) do
    File.stream!(filename, [:read, :binary], :line)
    |> Enum.reject(&(&1 == "\n"))
    # |> Enum.map(&String.strip(&1))
    |> do_modes(modes, output_dir)
    0
  end

  def modetable({mode, submode}) do
    String.to_atom(to_string(mode) <> to_string(submode))
  end

end
