/* commonrp.p
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

/* commonrp.p
 * Модуль
     Коммунальные платежи 
 * Назначение
     Отчет по кассиру за дату по станциям диагностики и отделам миграции
 * Применение   
  
 * Вызов
     
 * Меню
     п.3.2.10.7.2 Отчет по кассиру за дату
 * Автор
     pragma
 * Дата создания:
     16.09.02
 * Изменения
     29.07.03 kanat По просьбе сотрудников таможенного поста добавил в конце отчета их finish
*/

{global.i}
{functions-def.i}
{get-dep.i}
{deparp.i}

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def stream m-out.        

def var v-dat as date.
def var ssum as deci init 0.0.
def var sumcom as deci init 0.0.
def var sumr as deci init 0.0.
def var uu as char format "x(8)".


def var s_ofcarp as char.


def input parameter selgrp   as integer.

v-dat = g-today.

update v-dat label ' За дату ' format '99/99/9999' skip
          uu label ' Имя кассира ' format 'x(8)' skip
       with side-label row 5 centered frame uuuu .

output stream m-out to reekas.img.
put stream m-out  unformatted chr(27) chr(64) chr(27) 'P' chr(27) 's0' chr(27) chr(15) chr(27) chr(48) chr(27) chr(120) '0' chr(10).
put stream m-out skip ' '
     FirstLine( 1, 1 ) format 'x(79)' skip
     FirstLine( 2, 1 ) format 'x(79)' skip(1) 
     '                      '
     'РЕЕСТР КАССИРА ' uu skip ' '
     '                       '
     ' ЗА ' v-dat format '99/99/9999' ' г.' skip(1) ' '.
     put stream m-out ' ' fill( '-', 112 ) format 'x(112)' skip.
     put stream m-out
     ' номер/док  '
     '   Сумма    '
     ' Комиссия '
     '   Всего   '
     '  РНН      '
     '            ФИО, адрес                   ' 
     ' Отправка ' skip.

put stream m-out ' ' fill( '-', 112 ) format 'x(112)' skip(1).

for each commonpl where commonpl.txb = seltxb and commonpl.uid = uu and
                        commonpl.date = v-dat and commonpl.deluid = ? and
                        commonpl.grp = selgrp : 
  
     put stream m-out commonpl.dnum '  ' commonpl.sum format 'zzzzzzz9.99' ' '.

     if commonpl.com then put stream m-out commonpl.comsum format 'zzzzzz9.99' ' '.
                     else put stream m-out 0 format 'zzzzzz9.99' ' '.

     if commonpl.com then put stream m-out commonpl.comsum + commonpl.sum format 'zzzzzzz9.99' ' '.
                     else put stream m-out commonpl.sum format 'zzzzzzz9.99' ' '.

     put stream m-out ' ' commonpl.rnn ' '
     caps(trim(commonpl.fioadr)) format 'x(39)' ' '
     commonpl.rmzdoc format 'x(10)' skip .

     ssum = ssum + commonpl.sum.
     sumcom = sumcom + (if commonpl.com then commonpl.comsum else 0).
     sumr = sumr + (if commonpl.com then commonpl.comsum else 0) + commonpl.sum.  
end.

put stream m-out ' ' fill( '-', 112 ) format 'x(112)' skip.

put stream m-out '    Итого : ' ssum format 'zzzzzzz9.99' ' ' sumcom 
format 'zzzzzz9.99' ' ' sumr format 'zzzzzzz9.99' skip.
put stream m-out ' ' fill( '-', 112 ) format 'x(112)' skip(7).


s_ofcarp = deparp(get-dep(uu, v-dat)).
if (uu = "nvv" or uu = "maira") and (s_ofcarp = "000076960") then do:
put stream m-out '     Начальник Акцизного таможенного поста                        К. Ахметов' skip.    
put stream m-out '                                            ___________________' skip.
put stream m-out '                                                 (подпись)' skip.    
end.



put stream m-out unformatted chr(27) chr(64).
output stream m-out close.

run menu-prt('reekas.img').


