/* s-cdaprts.p
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

/* s-cdaprt.p

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def new shared var s-dolamt like aaa.opnamt decimals 2.
def new shared var s-dolstr as cha extent 2 format "x(50)".
def new shared var s-date as date.
def new shared var s-dstr as cha format "x(20)".
def var s-dstr1 as cha format "x(20)".
def var s-dstr2 as cha format "x(20)".
def var s-dstr3 as cha format "x(20)".
def var mbal as dec format "z,zzz,zzz,zzz,zz9.99" decimals 2.
def var vcif as char format "x(40)" extent 4.
def var kcode like crc.code.

def shared var s-aaa like aaa.aaa.

def var vterm as int format "zz9".

{global.i}

output to vou.img page-size 0.

find aaa where aaa.aaa = s-aaa no-lock.
find lgr where lgr.lgr eq aaa.lgr.
find crc of aaa.
kcode = crc.code.
find cif where cif.cif = aaa.cif.

if aaa.rollover = 1 then do:
   vcif[1] = "Automatic Roll Over".
   vcif[2] = "Add on the principal Renewed".
end.
else if aaa.rollover = 2 then do:
   vcif[1] = "Automatic Roll Over".
   if aaa.craccnt ne " " then
   vcif[2] = "Account # " + aaa.craccnt.
end.
else if aaa.rollover = 3 then do:
   vcif[1] = "Account # " + aaa.craccnt.
   vcif[2] = "Account # " + aaa.craccnt.
end.


s-date = g-today.
run s-date.
s-dstr1 = s-dstr.

s-date = aaa.regdt.
run s-date.
s-dstr2 = s-dstr.

s-date = aaa.expdt.
run s-date.
s-dstr3 = s-dstr.

vterm = aaa.expdt - aaa.regdt.

if lgr.complex  eq false then

mbal =
round(
( (aaa.cr[1] - aaa.dr[1] ) * (1 + aaa.rate * vterm / aaa.base / 100) )
   - (aaa.cr[1] - aaa.dr[1])   ,crc.decpnt).

else
mbal = round
( (aaa.cr[1] - aaa.dr[1] ) * exp(1 + aaa.rate / aaa.base / 100 , vterm)
   - (aaa.cr[1] - aaa.dr[1])  ,crc.decpnt).

vcif[4] = string(mbal / ( month(aaa.expdt) - month(aaa.regdt) ) ,
        "z,zzz,zzz,zzz,zz9.99" ) + " " + kcode.

    display skip(5)
            aaa.aaa at 31    s-dstr1 at 62 skip(3)
            vcif[1]  at 15   s-dstr2 at 62 skip(1)
            s-dstr3 at 62    skip
            vcif[2]  at 15   skip
            vcif[3]  at 15   aaa.rate at 64 "%" skip(1)
            vcif[4]  at 15   mbal to 77 skip(1)
            trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(30)" at 15   skip(1)
            cif.addr[1] at 15 skip(1)
            cif.addr[2] at 15 skip
            cif.addr[3] at 15 skip(2)

            aaa.cr[1] - aaa.dr[1]
            format "*,***,***,***,***.99-" crc.code
            with no-box no-label frame cer width 132.
output close.
unix silent prit    vou.img.
