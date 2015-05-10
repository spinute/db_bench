# db_bench
趣味

ではないです。

## TODO
* 論文中の実験設定の再現
* ~~pgの使い方の理解~~
* 計測
* 下の方整理

-----
結合の実測
as planningと同じ条件でテーブルを生成してみる
postgersで実験の条件を再現

そのうち、cost sensitiveのケースにもてを出してみるかも

SQL for smarties chap.39にユーザー目線の最適化の詳細な記述がある

queryのクラスに色々あるっぽい
relation calculus
relational algebra
が等価であることをCodd72で示した
http://en.wikipedia.org/wiki/Codd%27s_theorem

関連して、
database management systemsのchap.4にrelational calculus
database complete booksのchap.5にAlgebraic and Logical Query Languages

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

実験
ベンチマークがない
商用DBMSの出力との比較のインターフェースがない
そのため、この論文の実験は3つの手法の比較を行うこと、それを通じてプランニングの手法をオプティマイザに応用することが出来そうかどうかを検証することを目指す

attrは2-10個
タプルは10k-500k個
ページに200タプル乗ると仮定した

Robinson
オーストラリアの人
optimalityを保証するsatベースプランナ作ったりしてる
planning as satで博論(200ページ)くらい書いてる
Query Optimization Revisited: An AI Planning Perspective
2013にほぼ同じ論文を同じメンバーで出している

pg

クライアントもサーバーも手元で実験した

n_attr=1(intger)へのinsert
num     | time(s)
100     | 0.1
1000    | 0.3
10000   | 2.4
100000  | 23.2
1000000 | 230

rubyからpostgresを呼ぶためのgem
なんかやや開発が鈍ってそうだけど、名前をよく聞く
ドキュメントがリファレンス程度
postgersの公式ドキュメントに入っていない
 psycopgがpythonなので公式に入ってるスクリプトのものだと一番簡単そう、jdbcが他のDBを使うことも考えると円満そう、libpqがCのAPIでpostgresの標準に入ってて速度も最も早そう
 TODO: ruby分の遅さの影響を測定するために簡単なクエリをlibpqでも投げてみて比較してみるA