defmodule Mix.Tasks.Lex do
  use Mix.Task

  @shortdoc "lex"

  def run(args) do
    modes = [:ma, :da, :ta, :dl, :dr, :tl, :tr]
    modes = [
      {:m,:a},
      {:d,:a},
      {:d,:l},
      {:d,:r},
      {:t, :a},
      {:t, :l},
      {:t, :r},
    ]
    # modes = [:m]#, :d, :t, :dl, :dr, :dl, :tr]
    # modes = [:tr]#, :d, :t, :dl, :dr, :dl, :tr]

    [filename, output_dir] = args
    o = String.rstrip("output/#{output_dir}", ?/)
    File.mkdir(o)
    Benchmark.measure(fn ->
      Reader.start(modes)
      Reader.file(modes, "input/#{filename}", o)
    end)
    |> IO.inspect
  end
end
