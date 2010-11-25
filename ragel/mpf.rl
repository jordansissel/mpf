require "rubygems"
require "awesome_print"

%%{
  machine mpf;

  action foo {
    puts "OK"
  }

  ws = ([ \t\n])* ;
  arrow = "->" | "<-" | "~>" | "<~" ;
  uppercase_name = [A-Z][A-Za-z0-9:]* ;
  quoted_string = "\"" ( (any - "\"") | "\\" any)* "\"" |
                  "'" ( (any - "'") | "\\" any)* "'" ;
  #naked_string = alnum+ ;
  naked_string = [A-Za-z0-9:+\-\[\]] ;
  string = quoted_string | naked_string ;
  type_name = [A-Za-z0-9_:]+ ;
  param_name = [A-Za-z0-9_]+ ;
  param_value = string ;

  parameter = param_name ws "=>" ws param_value ;
  parameters = parameter ( ws "," ws parameter )* ;

  reference = uppercase_name "[" string "]" > { puts "reference!" } ;
  edge = reference ws arrow ws reference ( ws arrow ws reference )* > { puts "Edge" } ;
  name = [A-Za-z0-9]+ ;
  
  resource_entry = name ws ":" ws parameters ws ";" ;
  resource_entries = resource_entry ( ws resource_entry )* ;

  resource = type_name ws "{" ws resource_entries ws "}" > foo ;
  statement = (ws (resource > { puts "res" } | edge > { puts "edge" } ) )+ ;

  main := statement*
          0 @{ puts "Failed" }
          $err { 
            # Compute line and column of the cursor (p)
            line = string[0 .. p].count("\n") + 1
            column = string[0 .. p].split("\n").last.length
            puts "Error at line #{line}, column #{column}: #{string[p .. -1].inspect}"
          } ;
}%%

class MPF
  attr_accessor :eof

  def initialize
    # BEGIN RAGEL DATA
    %% write data;
    # END RAGEL DATA

  end

  def parse(string)
    data = string.unpack("c*")

    # BEGIN RAGEL INIT
    %% write init;
    # END RAGEL INIT

    # BEGIN RAGEL EXEC 
    %% write exec;
    # END RAGEL EXEC

    return cs
  end

end # class MPF

def parse(string)
  puts MPF.new.parse(string)
end

parse(<<"MPF")
  foo { 
    test: 
      fizzle => 'bar'; 
    foo:
      bar => 'baz';
  }

  Foo["test"] -> Foo["foo"]
MPF
