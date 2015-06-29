defmodule CodeComplete.Generator do
  alias CodeComplete.Formats.SublimeText, as: Formatter
  alias CodeComplete.ASTParser

  def generate(folders \\ []) do
    Enum.map(folders, &process!/1)
  end

  def process!(item) do
    cond do
      File.dir?(item) ->
        {:ok, items} = File.ls(item)
        
        Enum.map(items, &("#{item}/" <> &1))
          |> Enum.map(&process!/1)
          |> List.flatten
          
      item =~ ~r(\.ex) -> process_elixir_file(item)
      true -> nil
    end
  end

  defp process_elixir_file(file_path) do
    case File.read(file_path) do
      {:ok, elixir_file} -> 
        Code.string_to_quoted(elixir_file)
          |> parse_quoted
          |> format
          |> write_file

        file_path
      _ -> nil
    end
  end

  def parse_quoted(quoted) do
    ASTParser.parse_quoted(quoted)
  end

  defp format(data) do
    Formatter.format(data)
  end

  defp write_file(string_data) do
    if !is_nil(string_data) do
      File.write("completions.sublime-settings", "#{string_data}", [:append])
    end
  end
end
