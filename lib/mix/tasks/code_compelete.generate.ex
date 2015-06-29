defmodule Mix.Tasks.CodeComplete.Generate do
  use Mix.Tasks.CodeComplete, [task_name: "CodeComplete.Generate"]
  
  @shortdoc "Generate sublime text autocompletions"

  @moduledoc """
  Generate elixir code completions for the current project
  """

  def run(["silence" | args] = _) do
    %CodeCompleteTask{silence_log: true, args: args}
      |> _run
  end

  def run(args) do
    %CodeCompleteTask{args: args}
      |> _run
  end

  defp _run(%CodeCompleteTask{} = task) do
    start(task) |> complete(task)
  end
  
  # Task - Start

  defp start(task) do
    print_start_generating(task)
    CodeComplete.Generator.generate(task.args)
  end
  
  @started_generating_message "[start] recursively processing:"

  defp print_start_generating(task) do
    folders = Enum.join(task.args, ",")
    print_started_task(task, "#{@started_generating_message} #{folders}")
  end
  
  # Task - Finish

  defp complete(folders, task) do
    print_complete_generating(task, folders)
  end
  
  @completed_generating_message "[success] created the following completions:"

  defp print_complete_generating(task, folders) when is_list(folders) do
    file_output = Enum.map(folders, &folder_processed_string/1)
      |> List.flatten
      |> Enum.join("\n")

    print_completed_task(task, @completed_generating_message <> "\n" <> file_output)    
  end

  defp folder_processed_string(folder) do
    Enum.map(folder, &file_processed_string/1)
  end

  defp file_processed_string(elixir_file) do
    "\t#{elixir_file}"
  end
end
