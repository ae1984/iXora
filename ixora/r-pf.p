/* r-pf.p
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

/* KOVAL Печать реестра принятых пенсионнок */

{global.i}
{functions-def.i}
{comm-txb.i}
{get-fio.i}

def var summa as decimal format '>>>,>>>,>>9.99'.
def var tmpsm as decimal format '>>>,>>>,>>9.99'.
def var count as integer init 0.

def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def var v-dat as date.
def stream m-out.        

v-dat = g-today.

update v-dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .

output stream m-out to reekas.img.
/* header */
put stream m-out skip ' '
     FirstLine( 1, 1 ) format 'x(79)' skip
     FirstLine( 2, 1 ) format 'x(79)' skip(1) 
     'РЕЕСТР ПРОВЕДЕННЫХ ПЕНСИОННЫХ ПЛАТЕЖЕЙ ЗА ' v-dat format '99/99/9999' ' г.' skip
     '                   ПО КАССИРУ ' g-ofc skip ' '
     ' ' fill( '-', 50 ) format 'x(50)' skip
     ' номер/док   БИК Бенеф.  ИИК Бенеф.         Сумма' skip
     ' ' fill( '-', 50 ) format 'x(50)' skip
     .

summa = 0.
count=0.
for each remtrz where rdt = v-dat and source="PNJ" and rwho = g-ofc no-lock.
 put stream m-out 
 ' ' remtrz.remtrz format "x(10)" ' ' 
 ' ' remtrz.rbank  format "x(9)"  ' ' 
 ' ' remtrz.racc   format "x(9)"  ' ' 
 ' ' remtrz.amt format '>>>,>>>,>>9.99' skip .
 summa = summa + remtrz.amt.
 count = count + 1.
end.

/* footer */
put stream m-out skip 
     ' ' fill( '-', 50 ) format 'x(50)' skip
     ' Итого : ' count ' пл, на сумму ' summa format '>>>,>>>,>>9.99' ' тг.' skip 
     ' ' fill( '-', 50 ) format 'x(50)' skip(1)
     ' Менеджер операцион-' skip
     ' ного департамента:  ' get-fio(g-ofc) format "x(30)" skip.



output stream m-out close.

run menu-prt('reekas.img').
