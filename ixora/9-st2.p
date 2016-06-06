/* 9-st2.p
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
        31/12/99 pragma
 * CHANGES
       12/12/03 nataly внесены изменения в связи с новым ПС
       17.11.05 nataly внесены изменения в связи с новой 9-ой строкой
       23/03/06 nataly закомментировала 9st-prf1
*/

/* изменения 9-ой строки от 15.10.02 */

def new shared stream st-out.
def new shared var v-gl as char extent 200.
def new shared var s-gl as char extent 200.
def new shared var vasof as date.
def new shared var v-pass as char.

def new shared var i as int. 
def new shared var k as int. 
def new shared var j as int init 1. 

def var sum as decimal no-undo.
def var coef as decimal no-undo.
def var v-tmp as decimal format 'zzzzzzzzz9' no-undo.


{global.i}

for each sysc where sysc.sysc="SYS1" no-lock.
v-pass = ENTRY(1,sysc.chval).
end.

output stream st-out to rpt.img.

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
def var sum2 as decimal no-undo.

s-gl[1] = '001,*,*,1,1001,1002,1003,1005,1006,1008'.  /* only KZT */
s-gl[2] = '013,2,3,2,1001,1002,1003,1005,1006,1007,1008'.  /* нерезиденты в USD */
s-gl[3] = '013,2,4,2,1001,1002,1003,1005,1006,1007,1008'.  /* нерезиденты в USD */
s-gl[4] = '015,*,*,d1t,d2t'.


v-gl[1] = '002,9999'.
v-gl[3] = '003,9999'.
v-gl[4] = '004,9999'.
v-gl[5] = '005,9999'.
/*v-gl[6] = '006,2855'.
v-gl[7] = '007,2870'.
v-gl[8] = '008,2225'.*/


if not g-batch then do:
update vasof label 'Введите отчетную дату' validate (vasof le g-today, 
                " Дата не может быть больше текущего закрытого ОД " 
         + string(g-today)) 
            with row 8 centered  side-label frame opt.
end.
 hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .


put stream st-out unformatted 
"                      ПРИЛОЖЕНИЕ ї 4 " skip
"               К правилам о минимальных резервных требованиях (9-я строка) " skip
"за " at 20  vasof " (в тыс.тенге)" skip(2).

find last cls.
/* if last cls then take current balance else see stroka8 */
/*if vasof = cls.whn then  run 8st-prf2.p.
else run 8st-prf3.p.  */

run 9st-prf2.
/*run 9st-prf1.*/


 for each temp break by kod. 
   ACCUMULATE temp.val (total by  temp.kod).
   if last-of(temp.kod)  then do: 
    create final.  final.kod = temp.kod. 
    sum  =  ACCUMulate total  by (temp.kod) temp.val.
    final.val =  sum.
   end.
 end.
 
/*  for each temp where kod matches '020'. 
   find final where final.kod = '020/7' no-lock no-error.
   if available final then final.val = final.val - round(temp.val,0) .
   else do: 
     create final. final.kod = '020/7'.
     find b-final where b-final.kod = '020' no-lock no-error. 
     final.val = round(b-final.val,0).
    end.
 end.
*/

/*for each temp break by kod. put stream st-out  skip temp.kod temp.val. end.
*/

  for each final break by kod:
      put stream st-out  skip
    final.kod ' ' final.val format 'z,zzz,zzz,zz9'.   
  end. /*each*/

 output stream st-out close .

 hide frame ww.
