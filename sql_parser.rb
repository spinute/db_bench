require 'rparsec'
include RParsec
 
module SqlParser
  include Functors
  include Parsers
  extend Parsers

  MyKeywords = Keywords.case_insensitive %w{select from where and}
  MyOperators = Operators.new %w{=}

  def self.operators(*ops)
    result = []
    ops.each do |op|
      result << (MyOperators[op] >> op.to_sym)
    end
    sum(*result)
  end

  Comparators = operators(*%w{=})

  StringLiteral = (char(?') >> (not_char(?')|str("''")).many_.fragment << char(?')).
    map do |raw|
      raw.gsub!(/''/,"'")
    end
  QuotedName = char(?[) >> not_char(?]).many_.fragment << char(?])
  Variable = char(?$) >> word
  MyLexer = number.token(:number) | StringLiteral.token(:string) | Variable.token(:var) | QuotedName.token(:word) |
    MyKeywords.lexer | MyOperators.lexer
  MyLexeme = MyLexer.lexeme(whitespaces | comment_line('#')) << eof

  ######################################### utilities #########################################
  def keyword
    MyKeywords
  end
  def operator
    MyOperators
  end
  def comma
    operator[',']
  end
  def list expr
    paren(expr.delimited(comma))
  end
  def word(&block)
    if block.nil?
      token(:word, &Id)
    else
      token(:word, &block)
    end
  end
  def paren parser
    operator['('] >> parser << operator[')']
  end
   
  ################################### predicate parser #############################
  def logical_operator op
    proc{|a,b|CompoundPredicate.new(a,op,b)}
  end
  def make_predicate expr, rel
    expr_list = list expr
    comparison = make_comparison_predicate expr, rel
    group_comparison = sequence(expr_list, Comparators, expr_list) do |g1, op, g2|
      GroupComparisonPredicate.new(g1, op, g2)
    end
    bool = nil
    lazy_bool = lazy{bool}
    bool_term = keyword[:true] >> true | keyword[:false] >> false |
      comparison | group_comparison | paren(lazy_bool) |
      make_exists(rel) | make_not_exists(rel)
    bool_table = OperatorTable.new.
      infixl(keyword[:or] >> logical_operator(:or), 20).
      infixl(keyword[:and] >> logical_operator(:and), 30).
      prefix(keyword[:not] >> proc{|pred|NotPredicate.new(pred)}, 40)
    bool = Expressions.build(bool_term, bool_table)
  end
  def make_comparison_predicate expr, rel
    expr.bind do |val1|
      comparison = sequence(Comparators, expr) {|op,e2|ComparePredicate.new(val1, op, e2)}
      in_clause = make_in val1, expr
      not_in_clause = make_not_in val1, expr
      in_relation = make_in_relation val1, rel
      not_in_relation = make_not_in_relation val1, rel
      between = make_between val1, expr
      not_between = make_not_between val1, expr
      comparison | in_clause | not_in_clause |
        in_relation | not_in_relation | between | not_between
    end
  end
   
  ################################ expression parser ###############################
  def calculate_simple_cases(val, cases, default)
    SimpleCaseExpr.new(val, cases, default)
  end
  def calculate_full_cases(cases, default)
    CaseExpr.new(cases, default)
  end
  def make_expression predicate, rel
    expr = nil
    lazy_expr = lazy{expr}
    simple_case = sequence(keyword[:when], lazy_expr, operator[':'], lazy_expr) do |w,cond,t,val|
      [cond, val]
    end
    full_case = sequence(keyword[:when], predicate, operator[':'], lazy_expr) do |w,cond,t,val|
      [cond, val]
    end
    default_case = (keyword[:else] >> lazy_expr).optional
    simple_when_then = sequence(lazy_expr, simple_case.many, default_case,
      keyword[:end]) do |val, cases, default|
      calculate_simple_cases(val, cases, default)
    end
    full_when_then = sequence(full_case.many, default_case, keyword[:end]) do |cases, default|
      calculate_full_cases(cases, default)
    end
    case_expr = keyword[:case] >> (simple_when_then | full_when_then)
    wildcard = operator[:*] >> WildcardExpr::Instance
    lit = token(:number, :string){|l|LiteralExpr.new l} | token(:var){|name|VarExpr.new name}
    atom = lit | wildcard |
      sequence(word, operator['.'], word|wildcard) {|owner, _, col| QualifiedColumnExpr.new owner, col} |
      word {|w|WordExpr.new w}
    term = atom | (operator['('] >> lazy_expr << operator[')']) | case_expr
    # table = OperatorTable.new.
    #   infixl(operator['+'] >> Plus, 20).
    #   infixl(operator['-'] >> Minus, 20).
    #   infixl(operator['*'] >> Mul, 30).
    #   infixl(operator['/'] >> Div, 30).
    #   infixl(operator['%'] >> Mod, 30).
    #   prefix(operator['-'] >> Neg, 50)
    # expr = Expressions.build(term, table)
  end
   
  ################################ relation parser ###############################
  def make_relation expr, pred
    exprs = expr.delimited1(comma)
    relation = nil
    lazy_relation = lazy{relation}
    term_relation = word {|w|TableRelation.new w} | operator['('] >> lazy_relation << operator[')']
    sub_relation = sequence(term_relation, (keyword[:as].optional >> word).optional) do |rel, name|
      case when name.nil?: rel else AliasRelation.new(rel, name) end
    end
    joined_relation = sub_relation.postfix(join_maker(lazy{joined_relation}, pred))
    where_clause = keyword[:where] >> pred
    order_element = sequence(expr, (keyword[:asc] >> true | keyword[:desc] >> false).optional(true)) do |e,order|
      OrderElement.new e, order
    end
    order_elements = order_element.separated1(comma)
    exprs = expr.separated1(comma)
    order_by_clause = keyword[:order] >> keyword[:by] >> order_elements
    group_by = keyword[:group] >> keyword[:by] >> exprs
    group_by_clause = sequence(group_by, (keyword[:having] >> pred).optional) do |by, having|
      GroupByClause.new(by, having)
    end
    relation = sub_relation | sequence(keyword[:select],
      keyword[:distinct].optional(false), exprs,
      keyword[:from], joined_relation,
      where_clause.optional, group_by_clause.optional, order_by_clause.optional
    ) do |_, distinct, projected, _, from, where, groupby, orderby|
      SelectRelation.new(projected, distinct, from, where, groupby, orderby)
    end
    relation = sequence(relation, (keyword[:limit] >> token(:number, &To_i)).optional) do |rel, limit|
      case when limit.nil?: rel else LimitRelation.new(rel, limit) end
    end
    relation = relation.infixl(union_maker)
  end
  def join_maker rel, pred
    crossjoin = keyword[:cross] >> keyword[:join] >> rel.map do |r|
      proc {|r0| CrossJoinRelation.new(r0, r)}
    end
    leftjoin = outer_join :left
    rightjoin = outer_join :right
    fulljoin = outer_join :full
    innerjoin = keyword[:inner].optional >> keyword[:join] >> :inner
    join_with_condition = sequence(sum(leftjoin, rightjoin, innerjoin), rel,
      keyword[:on], pred) do |kind, r, _, on|
        proc{|r0|JoinRelation.new(kind, r0, r, on)}
      end
    sum(crossjoin, join_with_condition)
  end
   
  ########################## put together ###############################
  def expression
    assemble[0]
  end
 
  def relation
    assemble[2]
  end
  def predicate
    assemble[1]
  end
   
  def assemble
    pred = nil
    rel = nil
    lazy_predicate = lazy{pred}
    lazy_rel = lazy{rel}
    expr = make_expression lazy_predicate, lazy_rel
    pred = make_predicate expr, lazy_rel
    rel = make_relation expr, pred
    return expr, pred, rel
  end

  def make parser
    MyLexeme.nested(parser << eof)
  end
end