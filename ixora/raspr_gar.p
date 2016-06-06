/* raspr_gar.p
 * MODULE
        Название модуля
 * DESCRIPTION
        РАСПОРЯЖЕНИЕ НА ВЫДАЧУ ГАРАНТИИ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26.05.2011 ruslan
 * BASES
        BANK COMM
 * CHANGES
        14.06.2013 yerganat tz1314, новый шаблон распоряжений
        02/09/2013 galina - ТЗ1918 перекомпиляция
*/

{global.i}

def stream rep.
def var coun as int no-undo.
def var v-sum as deci no-undo.
def var v-sum1 as deci no-undo.
def var v-itogo as deci no-undo extent 3.
def var v-ofile as char no-undo.
def var mm as char no-undo extent 12 init ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'].
def var v-name like ofc.name.
def var t-prnmos as int format "9".
def var i as int.

def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.

def var ListType as char extent 2.

ListType[1] = "Конкурсная/Тендерная".
ListType[2] = "Другое".

find first garan where garan.garan = s-aaa and garan.cif = s-cif no-lock no-error.
if not avail garan then do:
  message " Гарантия не найдена " view-as alert-box error.
  return.
end.

find first cif where cif.cif = garan.cif no-lock no-error.
if not avail cif then do:
  message " Клиент не найден " view-as alert-box error.
  return.
end.

def var num_dog as char.

num_dog = garan.garnum.


def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
v-ofile = "rep.htm".

find first ofc where ofc.ofc = garan.who no-lock no-error.
if not avail ofc then
  assign v-name = "__________________".
  else
  assign v-name = entry(1,ofc.name," ") + " " + substring(entry(2,ofc.name," "),1,1) + ".".

def var v-crc like crc.des.
def var v-crc2 like crc.des.

find first crc where crc.crc = garan.crc no-lock no-error.
if avail crc then v-crc = crc.des.

find first crc where crc.crc = garan.crc2 no-lock no-error.
if avail crc then v-crc2 = crc.des.

def var v-city as char no-undo.
if s-ourbank = "txb00" then v-city = "ЦО".
else do:
    find first cmp no-lock no-error.
    if avail cmp then v-city = entry(1, cmp.addr[1],",").
end.


def var v-rep-date as char no-undo.
def var v-city2 as char no-undo.
def var v-date  as char no-undo.

v-rep-date = '«' + string(day(g-today), "99") + '» ' + mm[month(g-today)] + ' ' + string(year(g-today), "9999") + '  '.
if garan.dtto <> ? then v-date = string(garan.dtto, "99/99/9999").

find sysc where sysc.sysc = "ourbnk".
if avail sysc then do:
     if not connected ("comm") then run comm-con.
     find txb where txb.bank = sysc.chval.
     if avail txb then v-city2=txb.info.
end.

output stream rep to value(v-ofile).

{raspr2_garan.i}

output stream rep close.

unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -r " + v-ofile).