/* pf_ownrp.p
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
   06/07/2006 u00568 Evgeniy - переделал на commonpl
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

def var is_it_pens as integer init 0.  /*0 - платежи в ГЦВП*/ /*1 - платежи в пенсионный фонд*/
def var lis_it_pens as logical.

v-dat = g-today.

if not g-batch then do:
    update v-dat label ' Укажите дату ' format '99/99/9999' skip
    is_it_pens label " 0 - социальные / 1 - пенсионные " format "9" skip
    with side-label row 5 centered frame dataa .
    end.

lis_it_pens  = is_it_pens = 1.

uu = userid("bank").
find first ofc where ofc eq uu.
output stream m-out to pf_ownrp.img.
put stream m-out skip ' '
FirstLine( 1, 1 ) format 'x(79)' skip(2)
FirstLine( 2, 1 ) format 'x(79)' skip(1)
'  '
'                    РЕЕСТР КАССИРА  ' uu skip ' '
'                       '
' ЗА ' v-dat format '99/99/9999' ' г.' skip(1) ' '.
if lis_it_pens then
  put unformatted  "РЕЕСТР ПО ПРИЕМУ ПЛАТЕЖЕЙ ПЕНС. ОТЧИСЛЕНИЙ " skip.
else
  put unformatted  "РЕЕСТР ПО ПРИЕМУ ПЛАТЕЖЕЙ СОЦ. ОТЧИСЛЕНИЙ " skip.

put stream m-out  fill( '-', 75 ) format 'x(75)' skip.
put stream m-out
' номер/док  '
' КОД       РНН         '
'      Сумма    '
'    Комиссия '
'      Всего   ' skip.
put stream m-out ' ' fill( '-', 75 ) format 'x(75)' skip(1).

/*for each p_f_payment no-lock where txb = seltxb and date = v-dat and uid = uu by dnum:
  
  put stream m-out dnum '       ' cod '   ' rnn ' '  .
 
  put stream m-out '   ' amt format 'zzzzzzz9.99' '      '.

  put stream m-out comiss format 'zzzzzz9.99' ' '.

  put stream m-out amt + comiss format 'zzzzzzz9.99' '    ' skip .

  ssum = ssum + amt.
  sumcom = sumcom + comiss.
  sumr = sumr + amt + comiss.
end.*/

for each commonpl no-lock where commonpl.txb = seltxb and commonpl.date = v-dat and commonpl.uid = uu and commonpl.abk = integer(lis_it_pens) by dnum:

  put stream m-out dnum '       ' /*cod*/ '   ' rnn ' '  .

  put stream m-out '   ' sum format 'zzzzzzz9.99' '      '.

  put stream m-out comsum format 'zzzzzz9.99' ' '.

  put stream m-out sum + comsum format 'zzzzzzz9.99' '    ' skip .

  ssum = ssum + sum.
  sumcom = sumcom + comsum.
  sumr = sumr + sum + comsum.
end.


put stream m-out ' ' fill( '-', 75 ) format 'x(75)' skip.
put stream m-out '    Итого :                        ' ssum format 'zzzzzzz9.99'
'      ' sumcom format 'zzzzzz9.99' ' '  sumr format 'zzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 75 ) format 'x(75)' skip(2).
output stream m-out close.
run menu-prt('pf_ownrp.img').
