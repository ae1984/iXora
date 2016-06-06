/* p_f_regp.p
 * MODULE
        Пенсионные и прочие платежи
 * DESCRIPTION
        Реестр пенсионных платежей за дату
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
        01/03/04 sasco только по cod <> 400
        18/10/05 ten добавил номер порядка и код КНП.
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

{global.i}
{functions-def.i}
def stream m-out.        
def var v-dat as date.
def var ssum as deci init 0.0.
def var sumcom as deci init 0.0.
def var sumr as deci init 0.0.
def var uu as char format "x(8)".
def var name as char format "x(30)" .
def var i as int.
v-dat = g-today. 
if not g-batch then do:
    update v-dat label ' Укажите дату ' format '99/99/9999' skip
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
'                       '
' ЗА ' v-dat format '99/99/9999' ' г.' skip(1) ' '.
put stream m-out  fill( '-', 120 ) format 'x(120)' skip.
put stream m-out
' н/д  '
' РНН           '
' Nп      '
' Сумма          '
' Комиссия      '
' Всего    '
' РНН П.Ф.    ' 
' Kод КНП '
' Ф.И.О.   ' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip(1).
i = 0.
for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.date = v-dat and
                           p_f_payment.cod <> 400   and p_f_payment.deluid = ? no-lock  break by p_f_payment.distr by dnum :
i = i + 1.
accumulate p_f_payment.amt (sub-total by distr).
accumulate p_f_payment.comiss (sub-total by distr).
accumulate p_f_payment.amt + p_f_payment.comiss (sub-total by distr).  
  
put stream m-out p_f_payment.dnum format 'zzzz9' '  ' p_f_payment.rnn format "x(12)". 
                                   	
put stream m-out ''i format "zz9".
 
put stream m-out '    ' p_f_payment.amt format 'zzzzzzz9.99' '      '.

put stream m-out p_f_payment.comiss format 'zzzzzz9.99' '    '.

put stream m-out amt + comiss format 'zzzzzzz9.99' '    '.

put stream m-out distr format 'x(13)'.

put stream m-out p_f_payment.cod. 

put stream m-out '  'p_f_payment.name format 'x(35)' skip .
if last-of(p_f_payment.distr ) then do:
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.
put stream m-out " Итого по Пенсионному Фонду" (accum sub-total by p_f_payment.distr amt) format 'zzzzzzz9.99'
                 '      '  (accum sub-total by p_f_payment.distr comiss) format 'zzzzzz9.99' '  '
                 (accum sub-total by p_f_payment.distr amt + comiss) format 'zzzzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.  
                                 end.

ssum = ssum + p_f_payment.amt.
sumcom = sumcom + p_f_payment.comiss.
sumr = sumr + p_f_payment.amt + p_f_payment.comiss.  
end.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip.
put stream m-out '    Итого :     ' ssum format 'zzzzzzz9.99' sumcom format 'zzzzzz9.99' sumr format 'zzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 120 ) format 'x(120)' skip(2).
put stream m-out 'Менеджер операцион-' skip.
put stream m-out ' ного департамента                'ofc.name format 'x(30)' skip(2).
output stream m-out close.
run menu-prt('p_f_regp.img').
