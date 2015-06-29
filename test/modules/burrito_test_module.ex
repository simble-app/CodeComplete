defmodule CodeComplete.TestModules.Burrito do
  defstruct protein: nil, toppings: nil, magic: "" # burrito's always have magic

  # Used for testing AST parsing of a single method
  def protein(protein_nugget) do
    "#{protein_nugget} burrito"
  end

  # Used for testing AST parsing of a method with multiple arguments
  def makeburrito(protein, toppings) do
    toppings()
  end

  # Multiple guards
  def toppings(toppings) when is_list(toppings) and !is_nil(toppings) do

  end
  
  def toppings(magical_toppings) when is_nil(magical_toppings) do

  end
end
