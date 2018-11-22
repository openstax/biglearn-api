Fx::SchemaDumper::Function.class_exec do
  def tables(stream)
    functions(stream)
    super
  end

  def functions(stream)
    if dumpable_functions_in_database.any?
      stream.puts '  execute "SET check_function_bodies = off"'
      stream.puts
    end

    dumpable_functions_in_database.each do |function|
      stream.puts(function.to_schema)
      stream.puts
    end

    if dumpable_functions_in_database.any?
      stream.puts '  execute "SET check_function_bodies = on"'
      stream.puts
    end
  end
end
