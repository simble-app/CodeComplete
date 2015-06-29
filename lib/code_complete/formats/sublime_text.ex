defmodule CodeComplete.Formats.SublimeText do
  alias CodeComplete.CodeModule
  alias CodeComplete.CodeStruct

  alias CodeComplete.CodeMethod
  alias CodeComplete.CodeMethodGuard
  alias CodeComplete.CodeMethodArgument

  def format(parsed_ast) when is_list(parsed_ast) do
    result = Enum.map(parsed_ast, fn (ast_chunk) -> 
      format(ast_chunk)
    end)
      |> List.flatten
      |> Enum.filter(fn (item) -> !is_nil(item) end)

    Enum.join(result, "")
  end

  def format(%CodeModule{} = module) do
    "// #{module.name} \n"
      <> format_methods(module)
      <> format_modules(module)
      <> format_structs(module)
  end

  defp format_structs(module) do
    if !is_nil(module.structs) do
      Enum.map(module.structs, &(to_completion_trigger(module.name, &1)))
        |> Enum.filter(&( !is_nil(&1) ))
        |> Enum.filter(&(String.length(&1) > 0))
        |> Enum.join("\n")

    else
      ""
    end
  end

  defp format_modules(module) do
    if !is_nil(module.modules) do
      Enum.map(module.modules, &format/1)
        |> Enum.filter(&( !is_nil(&1) ))
        |> Enum.filter(&(String.length(&1) > 0))
        |> Enum.join("\n")
    else
      ""
    end
  end

  defp format_methods(module) do
    if !is_nil(module.methods) do
      methods_to_completion_triggers(module.name, module.methods)
        |> Enum.filter(&( !is_nil(&1) ))
        |> Enum.filter(&(String.length(&1) > 0))
        |> Enum.join("\n")
    else
      ""
    end
  end

  def format(%CodeMethod{} = method) do
    # To do, figure out how to prevent from showing up here
  end

  def format(%CodeMethodArgument{} = method_argument) do
    # To do, figure out how to prevent from showing up here
  end

  def format(%CodeMethodGuard{} = method_guard) do
    # To do, figure out how to prevent from showing up here
  end

  def format(:ok = ast_chunk) do
    # No-op, figure out why this shows up
  end

  def methods_to_completion_triggers(module_name, methods) when is_list(methods) do
    Enum.map(methods, &(to_completion_trigger(module_name, &1)))
  end

  def methods_to_completion_triggers(module_name, methods) do
    [""]
  end

  def to_completion_trigger(module_name, %CodeMethod{} = method) do
    arity = cond do
      is_list(method.arguments) or is_map(method.arguments) ->
        Enum.count(method.arguments)
      true -> 0
    end
    method_name = Atom.to_string(method.name)
    contents = method_completion_contents(method)
    """
      {"trigger": "#{method_name}\\t#{module_name}", "contents": "#{method_name}(#{contents})"}
    """
  end

  def to_completion_trigger(module_name, %CodeMethodArgument{} = method) do
    # Not yet used
    ""
  end

  def to_completion_trigger(module_name, %CodeMethodArgument{} = method) do
    ""
  end

  # Inner defined modules
  def to_completion_trigger(module_name, %CodeStruct{} = struct) do
    contents = struct_completion_contents(struct)
    """
      {"trigger": "#{module_name}", "contents":"#{module_name}%{#{contents}}"}
    """
  end  

  # Inner defined modules
  def to_completion_trigger(module_name, %CodeModule{} = module) do
    format(module)
  end

  def to_completion_trigger(module_name, nil = method) do
    ""
  end

  defp struct_completion_contents(struct) do
    if !is_nil(struct.members) do
      struct.members
        |> Enum.filter(fn ({k,v}) -> !is_nil(v) end)
        |> Enum.with_index()
        |> Enum.map(fn ({{k,v}, index}) -> "#{k}:${#{index}:#{v}}" end)
        |> Enum.join(", ")
    end
  end

  defp method_completion_contents(method) do
    if !is_nil(method.arguments) do
      method.arguments
        |> Enum.filter(fn (arg) -> !is_nil(arg) end)
        |> Enum.with_index()
        |> Enum.map(fn ({arg, index}) -> "${#{index}:#{Atom.to_string(arg.name)}}" end)
        |> Enum.join(", ")
    end
  end
end
