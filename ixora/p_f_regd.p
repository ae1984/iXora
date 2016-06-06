/* p_f_regd.p
 * MODULE
        Пенсионные и прочие платежи
 * DESCRIPTION
        Реестр пенсионных платежей за период
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
        01/03/04 sasco только пенсионные (cod <> 400)
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var dd as date.
def temp-table dates field dt as date
                     index dt is primary dt.

{global.i}
{functions-def.i}
def stream m-out.        
def var v-d1 as date.
def var v-d2 as date.
def var ssum as deci init 0.0.
def var sumcom as deci init 0.0.
def var sumr as deci init 0.0.
def var uu as char format "x(8)".
def var name as char format "x(30)" .
v-d1 = g-today. 
v-d2 = g-today.
if not g-batch then do:
    update v-d1 label ' Укажите начало периода' v-d2 label 'конец периода'
    with side-label row 5 centered frame dataa .
    end.

uu = userid("bank").
find first ofc where ofc eq uu.
output stream m-out to p_f_regp.img.
put stream m-out skip ' '
FirstLine( 1, 1 ) format 'x(79)' skip(2)
/*FirstLine( 2, 1 ) format 'x(79)' skip(1) */
'  '
'"РЕЕСТР ИЗВЕЩЕНИЙ ПО ПРИЕМУ ПЕНСИОННЫХ ПЛАТЕЖЕЙ"' /*uu*/ skip ' '
'      '
' ЗА ' v-d1 format '99/99/9999' ' - ' v-d2 format '99/99/9999' ' г.' skip(1) ' '.
put stream m-out  fill( '-', 120 ) format 'x(120)' skip.
put stream m-out
'  дата   '
' номер/док  '
'    РНН         '
'      Сумма    '
'    Комиссия '
'         Всего '
'   РНН П.Ф.           '
'   Ф.И.О.                          ' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip(1).

do dd = v-d1 to v-d2:
   create dates.
   assign dates.dt = dd.
end.

define temp-table tmp like p_f_payment.

for each dates:
   for each p_f_payment no-lock where p_f_payment.txb = seltxb and p_f_payment.date = dates.dt and p_f_payment.cod <> 400 and p_f_payment.deluid = ?:
     create tmp.
     buffer-copy p_f_payment to tmp no-error.
   end.
end. 

for each tmp break by tmp.distr by tmp.date by tmp.dnum:

accumulate tmp.amt (sub-total by tmp.distr).
accumulate tmp.comiss (sub-total by tmp.distr).
accumulate tmp.amt + tmp.comiss (sub-total by tmp.distr).  
  
put stream m-out tmp.date ' ' tmp.dnum format 'zzzzzzzz9' '    ' tmp.rnn. ' '  .
 
put stream m-out '  ' tmp.amt format 'zzzzzzz9.99' '      '.

put stream m-out tmp.comiss format 'zzzzzz9.99' '    '.

put stream m-out tmp.amt + tmp.comiss format 'zzzzzzz9.99' '    '.

put stream m-out tmp.distr format 'x(13)' '  '.

put stream m-out tmp.name format 'x(35)' skip .

if last-of(tmp.distr ) then do:
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.
put stream m-out " Итого по Пенсионному Фонду" (accum sub-total by tmp.distr amt) format 'zzzzzzz9.99'
                 '      '  (accum sub-total by tmp.distr comiss) format 'zzzzzz9.99' '  '
                 (accum sub-total by tmp.distr amt + comiss) format 'zzzzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.  
                                 end.

ssum = ssum + tmp.amt.
sumcom = sumcom + tmp.comiss.
sumr = sumr + tmp.amt + tmp.comiss.  

delete tmp.

end.


put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.
put stream m-out '    Итого :                ' ssum format 'zzzzzzz9.99' 
'      ' sumcom format 'zzzzzz9.99' '    '  sumr format 'zzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip(2).
put stream m-out 'Менеджер операцион-' skip.
put stream m-out ' ного департамента                'ofc.name format 'x(30)' skip(2).

output stream m-out close.

run menu-prt('p_f_regp.img').
