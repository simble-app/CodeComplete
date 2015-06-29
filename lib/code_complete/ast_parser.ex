defmodule CodeComplete.ASTParser do
  alias CodeComplete.CodeModule
  alias CodeComplete.CodeStruct

  alias CodeComplete.CodeMethod
  alias CodeComplete.CodeMethodArgument

  def parse_quoted(quoted) do
    parse(quoted)
  end

  defp parse_inner_module(inner_module, code_module) when is_list(inner_module) do
    Enum.reduce(inner_module, code_module, fn(inner_module_chunk, outer_module) ->
      case inner_module_chunk do
        %CodeModule{} -> %{outer_module | modules: outer_module.modules ++ [inner_module_chunk]}
        %CodeStruct{} -> %{outer_module | structs: outer_module.structs ++ [inner_module_chunk]}
        %CodeMethod{} -> %{outer_module | methods: outer_module.methods ++ [inner_module_chunk]}
        _ -> outer_module
      end
    end)
  end
  
  defp parse({:defmodule, _, data}) do
    code_module = List.first(data) |> parse
    inner_module = List.last(data) |> parse

    cond do
      is_nil(List.first(inner_module)) ->
        parse_inner_module([], code_module)

      is_nil(inner_module) ->
        parse_inner_module([], code_module)

      is_list(inner_module) ->
        List.first(inner_module)
          |> parse_inner_module(code_module)

      true ->
        parse_inner_module(inner_module, code_module)
    end
  end
  
  defp parse({:__aliases__, _, data}) do
    %CodeModule{ name: List.last(data) }
  end

  defp parse({:error, _}) do
    
  end

  defp parse({:__block__, _, data}) do
    parse(data)
  end

  defp parse({:when, _, data}) do
    parse(data)
  end

  defp parse({:and, _, data}) do
    parse(data)
  end

  defp parse({:use, _, _}) do
    # no-op
  end

  defp parse({:def, _, data}) do
    case List.first(data) do
      {:when, _, method_data} -> 
        {method_name, _, method_args} = List.first(method_data)

        %CodeMethod{name: method_name, arguments: parse(method_args), guards: []}
      {name, _, method_data} -> 
        %CodeMethod{name: name, arguments: parse(method_data), guards: []}
    end
  end

  defp parse({:defp, _, _}) do
    # no-op
  end

  defp parse({:defstruct, _, data}) do
    %CodeStruct{members: List.first(data)}
  end

  defp parse({:ok, data}) do
    parse(data)
  end

  defp parse({:%{}, data}) do
    parse(data)
  end

  defp parse({name, _, arguments}) do
    if !is_nil(arguments) && !Enum.empty?(arguments) do
      {arg_name, _, val} = Enum.filter(arguments, &filter_arguments/1)
        |> Enum.filter(&( !is_nil(&1) ))
        |> List.first

      postfix_value = cond do
        is_binary(val) -> "= #{val}"
        true   -> nil
      end

      %CodeMethodArgument{name: arg_name, postfix: postfix_value}
    else
      %CodeMethodArgument{name: name}
    end
  end

  defp parse(list) when is_list(list) do
    Enum.map(list, fn (item) ->
      case item do
        {:do, {:__block__, _, data}} ->
          parse(data)
        {name, line, data} -> 
          parse({name, line, data})
        _ ->
          nil
      end
    end)
  end

  defp parse(nil) do
    # no-op
  end

  defp filter_arguments({name, _, _}) do
    case name do
      :%    -> false
      :=    -> false
      :|>   -> false
      :.    -> false
      :!    -> false
      :<>   -> false
      :%{}  -> false
      :+    -> false
      :@    -> false
      _     -> true
    end
  end

  defp filter_arguments(:ok) do
    false
  end

  defp filter_arguments(nil) do
    false
  end

  defp filter_arguments(argument) when is_list(argument) do
    false
  end
end
