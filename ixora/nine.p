/* nine.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        26/08/05 ten
 * CHANGES
*/


def new shared stream st-out.
def new shared var v-gl as char extent 200.
def new shared var s-gl as char extent 200.
def new shared var vasof as date.
def new shared var v-pass as char.

def input parameter v-inp as date. 
def new shared var i as int. 
def new shared var k as int. 
def new shared var j as int init 1. 

def var sum as decimal.
def var coef as decimal.
def var v-tmp as decimal format 'zzzzzzzzz9'.


{global.i}

for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

def new  shared  temp-table temp  /*workfile*/
  field  kod  as char
  field  gl  as integer   format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 
  
def  temp-table final  /*workfile*/
  field  kod  as char
  field  gl  as integer   format 'zzzzzz'
  field  val  as decimal format 'z,zzz,zzz,zz9.99-'
  field rem  as char. 

def buffer t-final for final.
def buffer b-final for final.
def buffer t2-final for final.
def buffer t3-final for final.
def buffer t4-final for final.
def buffer t5-final for final.
def var sum2 as decimal.
def output parameter pr as decimal.


v-gl[3] = '003,9999'.
v-gl[4] = '004,9999'.
v-gl[5] = '005,9999'.
v-gl[6] = '006,2855'.
v-gl[7] = '007,2870'.
v-gl[8] = '008,2225'.


vasof = v-inp.




run 9st-prf2.


 for each temp break by kod. 
   ACCUMULATE temp.val (total by  temp.kod).
   if last-of(temp.kod)  then do: 
    create final.  final.kod = temp.kod. 
    sum  =  ACCUMulate total  by (temp.kod) temp.val.
    final.val =  sum.
   end.
 end.

  for each final break by kod:
    accumulate final.val (total).
  pr = (accum total final.val).


end.

  