defmodule CodeComplete do
  defmodule CodeModule do
    defstruct name: nil, methods: [], modules: [], structs: []
  end
  defmodule CodeStruct do
    defstruct name: nil, members: []
  end
  defmodule CodeMethod do
    defstruct name: nil, arguments: nil, guards: nil
  end
  defmodule CodeMethodGuard do
    defstruct name: nil, argument_name: nil
  end
  defmodule CodeMethodArgument do
    defstruct name: nil, prefix: nil, postfix: nil
  end
end
