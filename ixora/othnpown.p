/* othnpown.p
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
*/

{global.i}
{functions-def.i}

{taxcom.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def stream m-out.        
def var v-dat as date.
def var ssum as deci init 0.0.
def var sumcom as deci init 0.0.
def var sumr as deci init 0.0.
def var uu as char format "x(8)".
/*def var i as int init 1.*/
v-dat = g-today.

if not g-batch then do:
    update v-dat label ' Укажите дату ' format '99/99/9999' skip
    with side-label row 5 centered frame dataa .
    end.

/*    update uu label ' Укажите имя кассира ' format 'x(8)' skip
    with side-label row 5 centered frame uuuu .*/
uu = userid("bank").


output stream m-out to reekas.img.

put stream m-out skip ' '
     FirstLine( 1, 1 ) format 'x(79)' skip
     FirstLine( 2, 1 ) format 'x(79)' skip(1) 
     '                      '
     'РЕЕСТР КАССИРА ' uu skip ' '
     '                       '
     ' ЗА ' v-dat format '99/99/9999' ' г.' skip(1) ' '.
     put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip.
     put stream m-out
/*     '   N '*/
     ' номер/док  '
     '   Сумма    '
     ' Комиссия '
     '   Всего   '
     '  РНН      '
     '      ФИО                                 JOU           RMZ ' skip.
     put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(1).

for each tax where comm.tax.txb = ourcode and tax.uid = uu and tax.date = v-dat and duid = ? 
     no-lock use-index datenum: 
  
     find first rnn where rnn.trn = tax.rnn no-lock no-error.
     if not avail rnn then find first rnnu where rnnu.trn = tax.rnn no-lock no-error.

     put stream m-out tax.dnum '  ' tax.sum format 'zzzzzzz9.99' ' '.

     if tax.com then put stream m-out tax.comsum format 'zzzzzz9.99' ' '.
                else put stream m-out 0 format 'zzzzzz9.99' ' '.

     if tax.com then put stream m-out tax.comsum + tax.sum format 'zzzzzzz9.99' ' '.
                else put stream m-out tax.sum format 'zzzzzzz9.99' ' '.

     put stream m-out ' ' tax.rnn ' ' 
          caps(if avail rnn then rnn.lname + ' ' + rnn.fname + ' ' + rnn.mname
               else if avail rnnu then rnnu.busname else '') format 'x(40)' ' '
          tax.taxdoc  format 'x(10)' " " 
          tax.senddoc format 'x(10)' skip .

     ssum = ssum + tax.sum.
     sumcom = sumcom + (if tax.com then tax.comsum else 0).
     sumr = sumr + (if tax.com then tax.comsum else 0) + tax.sum.  
/*     i = i + 1.*/
end.

put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip.
put stream m-out '    Итого : ' ssum format 'zzzzzzz9.99' ' ' sumcom 
format 'zzzzzz9.99' ' ' sumr format 'zzzzzzz9.99' skip.

put stream m-out ' ' fill( '-', 77 ) format 'x(77)' skip(2).

output stream m-out close.

run menu-prt('reekas.img').
