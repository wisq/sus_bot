defmodule SusBot.Commands.Def do
  defmacro __using__(_opts) do
    quote do
      require SusBot.Commands.Def
      import SusBot.Commands.Def
      @before_compile SusBot.Commands.Def

      Module.register_attribute(__MODULE__, :command_defs, accumulate: true)

      @desc nil
      @opts []
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def commands, do: @command_defs
      def run(event), do: SusBot.Commands.Def.run(__MODULE__, event)
    end
  end

  defmacro defcommand({name, _, _} = define, do: expr) do
    IO.inspect(name)
    # expr = wrap_function_do(expr)

    quote do
      name = unquote(name)

      if @desc do
        @command_defs %{
          name: Atom.to_string(name),
          description: @desc,
          options: @opts
        }
      end

      @desc nil
      @opts []

      def unquote(define), do: unquote(expr)
    end
  end

  def run(module, event) do
    name = String.to_existing_atom(event.data.name)
    opts = event.data.options |> options_to_map()
    apply(module, name, [event, opts])
  end

  defp options_to_map(opts) do
    opts
    |> Map.new(fn opt ->
      {String.to_existing_atom(opt.name), opt.value}
    end)
  end
end
