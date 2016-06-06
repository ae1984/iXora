/* splis.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Реестр проведеных платежей за указанную дату по менеджеру
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        19.09.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        27.09.2012 Lyubov - дописала в шапку BASES
*/

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
     FirstLine( 1, 1 ) format 'x(100)' skip
     FirstLine( 2, 1 ) format 'x(100)' skip(1)
     '        РЕЕСТР ПРОВЕДЕННЫХ ЗАРПЛАТНЫХ ПЛАТЕЖЕЙ ЗА ' v-dat format '99/99/9999' ' г.' skip
     '                   ПО МЕНЕЖДЕРУ ' g-ofc skip
     ' ' fill( '-', 90 ) format 'x(90)' skip
     ' №п/п    Отправитель       Бенефициар      БИК Бенеф.  ИИК Бенефициара          Сумма' skip
     ' ' fill( '-', 90 ) format 'x(90)' skip
     .

summa = 0.
count=0.
for each remtrz where rdt = v-dat and source = "ZP" and rwho = g-ofc no-lock.
 put stream m-out
 ' ' trim( substring( remtrz.sqn,23,8 ))
 ' ' substring(remtrz.ord, 1, index(remtrz.ord,'/') - 1) format 'x(15)'
 ' ' substring(remtrz.bb[1], 2) format "x(15)" ' '
 ' ' remtrz.rbank  format "x(9)"  ' '
 ' ' remtrz.racc   format "x(20)"  ' '
 ' ' remtrz.amt format '>>,>>>,>>9.99' skip .
 summa = summa + remtrz.amt.
 count = count + 1.
end.

/* footer */
put stream m-out skip
     ' ' fill( '-', 90 ) format 'x(90)' skip
     ' Итого : ' count ' пл, на сумму ' summa format '>>>,>>>,>>9.99' ' тг.' skip
     ' ' fill( '-', 90 ) format 'x(90)' skip(1)
     ' Менеджер ОО: ' get-fio(g-ofc) format "x(30)" skip.

output stream m-out close.

run menu-prt('reekas.img').
