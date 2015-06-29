defmodule Mix.Tasks.CodeComplete do
  @moduledoc false
  defmodule CodeCompleteTask do
    @moduledoc false
    defstruct silence_log: false, args: "", completed: false, return_value: nil
  end

  defmacro __using__(opts) do
    task_name = Keyword.get(opts, :task_name)
    quote do
      use Mix.Task
      import Mix.Generator
      import Mix.Utils, only: [camelize: 1, underscore: 1]
      
      import Mix.Tasks.CodeComplete
      alias Mix.Tasks.CodeComplete.CodeCompleteTask

      def print_started_task(task, started_message) do
        log_task task, unquote(task_name)
        log_task task, started_message
      end

      def print_completed_task(task, completed_message) do
        log_task task, completed_message
      end

      defp log_task(%CodeCompleteTask{} = task, message) do
        if !task.silence_log, do: Mix.shell.info(message)
      end
    end
  end
end
