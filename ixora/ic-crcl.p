/* ic-crcl.p
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

def var acode like crc.code.
def var bcode like crc.code.
def shared var s-remtrz like remtrz.remtrz.
/*
def shared frame remtrz.
*/
def var v-date as date.
def buffer tgl for gl.
def var ourbank as cha.
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".
def var vpname as char.
def var vpoint as inte.
def var vdep as inte.

{lgps.i}
{rmz.f}

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!".
   pause .
   undo .
   return .
end.
ourbank = sysc.chval.

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
if available remtrz then do :
  find aaa where aaa.aaa = remtrz.cracc no-lock no-error.
  if available aaa then do :
        find cif of aaa no-lock.
        tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
        tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
        vpname = ''.
        vpoint = integer(cif.jame) / 1000 - 0.5.
        vdep = integer(cif.jame) - vpoint * 1000.
        find ppoint where ppoint.point = vpoint and ppoint.dep = vdep
                                                  no-lock no-error.
        if available ppoint then vpname = ppoint.name + ', '.
        find point where point.point = vpoint no-lock no-error.
        if available point then vpname = vpname + point.addr[1].
        form
           vpname format "x(60)" label "Пункт" 
           tt1 label "Полное----"
           tt2 label "--название"
           cif.lname  label "Сокращенное" format "x(60)"
           cif.pss   label "Идент.карта"
           cif.jss   label "Рег.номер"  format "x(13)"
           with overlay  centered  row 13 1 column  frame ggg.
         disp   vpname tt1 tt2  cif.lname cif.pss cif.jss with frame ggg.
     pause . 
    end.
    else do :
      Message "Клиент не найден!".
      pause .
    end.
  end.
