# db_bench
趣味

ではないです。

## TODO
- [ ] 論文中の実験設定の再現
- [x] pgの使い方の理解
- [ ] 計測
  - [ ] postgres
  - [ ] mariaDB
  - [ ] sqlite3
- [ ] 下の方整理

## 結合の実測
Cost-Based Query Optimization via AI Planningと同じ条件でDBMSを使って実験を行う
まずはpostgres、その後他のDBMSもやってみる
(TODO: maria, sqliteなどのオプティマイザがどうなっているのかの調査も行う必要がある)

## 実験
オプティマイザのベンチマークはない(らしい)
商用DBMSの出力との比較のインターフェースがない
そのため、この論文の実験は3つの手法の比較を行うこと、それを通じてプランニングの手法をオプティマイザに応用することが出来そうかどうかを検証することを目指す

attrは2-10個
タプルは10k-500k個
ページに200タプル乗ると仮定
1行目はp-key(distinct integer)
他の値はテーブルのタプル数の10%にあたる数までのなかからランダム生成した整数

各実験に対してR, Vを定める
Rはn_relations(5,10,...,60)
 どうせ大きい方は全然解けず、12付近で爆発するので、もう少し粒度細かく計測してみる必要がありそう
Vは変数の個数(V*R)を決める係数(1.2, 1.5, 2.0)
 整数にならないときは...?
変数のうち、3つは定数変数、10個はselectの対象(変数が足らないケースでは後者を削る)
> Every query has 3 variables set as constants and 10 other variables selected (less if there is not enough variables). For each relation in the query there is a 10% chance of reusing an existing table, otherwise a new table is used. Variables are randomly assigned to relations and we ensure that queries are connected.
10回ずつ実験は行う
2.6GHz Six-Core AMD Opteron(tm)
メモリ2GB

## クライアントとしてなにを使うか
クライアントもサーバーも手元で実験した
n_attr=1(intger)へのinsert

| num     | time(s)  |
|---------|--------|
| 100     | 0.1  |
| 1000    | 0.3  |
| 10000   | 2.4  |
| 100000  | 23.2 |
| 1000000 | 230  |

pg: rubyからpostgresを呼ぶためのgem
なんかやや開発が鈍ってそうだけど、名前をよく聞く
ドキュメントがリファレンス程度
postgersの公式ドキュメントに入っていない
psycopgがpythonなので公式に入ってるスクリプトのものだと一番簡単そう、jdbcが他のDBを使うことも考えると円満そう、libpqがCのAPIでpostgresの標準に入ってて速度も最も早そう
TODO: ruby分の遅さの影響を測定するために簡単なクエリをlibpqでも投げてみて比較してみるA

## 参考資料
- SQL for smarties chap.39にユーザー目線の最適化の詳細な記述がある

queryのクラスに色々あるっぽい
relation calculus
relational algebra
が等価であることをCodd72で示した
http://en.wikipedia.org/wiki/Codd%27s_theorem

関連して、
- database management systemsのchap.4にrelational calculus
- database complete booksのchap.5にAlgebraic and Logical Query Languages

predicate calculus

http://en.wikipedia.org/wiki/Conjunctive_query
conjunctive queriesは以下のもの
(x_0, ...).\exist{y_0, ...} CNF of QFFL
select x_0, ...
from table
where CNF of QFFL(x_0, ..., y_0, ...) = true
表現力としてはrelational algebraの大部分を包含する、また扱いやすいため、研究でよく用いられる。

select-project-join queries in relational algebra
where内が=とandのみのselect-from-where queries in SQL
(subquery, aggregationがない)

Robinson
オーストラリアの人
optimalityを保証するsatベースプランナ作ったりしてる
planning as satで博論(200ページ)くらい書いてる
Query Optimization Revisited: An AI Planning Perspective
2013にほぼ同じ論文を同じメンバーで出している