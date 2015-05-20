require 'rparsec'

include RParsec
class Calculator
  include Parsers
  include Functors
  def parser
    ops = OperatorTable.new.
      infixl(char(?+) >> Plus, 20).
      infixl(char(?-) >> Minus, 20).
      infixl(char(?*) >> Mul, 40).
      infixl(char(?/) >> Div, 40).
      prefix(char(?-) >> Neg, 60)
    expr = nil
    term = integer.map(&To_i) | char('(') >> lazy{expr} << char (')')
    delim = whitespace.many_
    expr = delim >> Expressions.build(term, ops, delim)
  end
end
 
Calculator.new.parser.parse '1+2*(3-1)' # => 5