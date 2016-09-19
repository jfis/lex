defmodule Mix.Tasks.Lex do
  use Mix.Task

  @shortdoc "lex"

  def run(args) do
    modes = [
      {:m,:a},
      {:d,:a},
      {:d,:l},
      {:d,:r},
      {:d, :nv},
      {:d, :v},
      {:t, :a},
      {:t, :l},
      {:t, :r},
      {:w, :a},
      {:w, :l},
      {:w, :r},
      {:p1, :a},
      {:p1, :l},
      {:p1, :r},
      {:p2, :a},
      {:p2, :l},
      {:p2, :r},
      {:pe, :a},
      {:pe, :l},
      {:pe, :r},
      {:pe, :np},
      {:q, :a},
      {:q, :l},
      {:q, :r},
    ]
    # modes = [:m]#, :d, :t, :dl, :dr, :dl, :tr]
    # modes = [:tr]#, :d, :t, :dl, :dr, :dl, :tr]

    [filename, output_dir] = args
    o = String.rstrip("output/#{output_dir}", ?/)

    for {m,_} <- modes do
      File.mkdir_p!("#{o}/#{m}")
    end

    Benchmark.measure(fn ->
      # Reader.start(modes)
      Reader.file(modes, "input/#{filename}", o)
    end)
    |> IO.inspect
  end
end
