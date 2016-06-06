/* kasmd.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Проверка состояния ARP касса в пути
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
         19/07/2004 dpuchkov
 * CHANGES
         23/07/2004 dpuchkov изменил валютные ARP счета кассы в пути для филиалов
         12/08/2005 suchkov  поправил для работы ЦО в выходные
         24/03/2008 madiyar - коды валют
         21/02/2009 madiyar - вставил в конце паузу
*/

{mainhead.i}
{get-dep.i}


def var l-fnd as logical init False.
def var i-rko as integer.

def var v-rkomerkur as char.
def var v-rkoreiz as char.
def var v-rkosamal as char.
def var v-rkopromenade as char.
def var v-rkosulpak as char.
def var s_account_b as char.

/* v-rkomerkur =    "000061001,000062301,000062505". 
   v-rkoreiz =      "000061810,000061111,000061412".
   v-rkosamal =     "000061603,000062903,000061409".
   v-rkopromenade = "000061014,000061315,000061616".
   v-rkosulpak =    "000061014,000061315,000061616".
*/
   find sysc where sysc.sysc = "904kas" no-lock no-error.
   if not avail sysc then do:
      message skip " Не настроен счет кассы в пути по ГК 100200 (настройка 904kas)!" 
              skip(1) view-as alert-box title " ОШИБКА ! ".
      return.
   end.

   find ofc where ofc.ofc = g-ofc no-lock no-error .
   if not available ofc then do:
        message "Вы не наш офицер!!!" view-as alert-box.
        quit.
   end.

   if int(get-dep(g-ofc, g-today)) = 1 and ofc.titcd <> "514" then do:
      s_account_b = sysc.chval.
   end.
   else do:
      for each arp where arp.gl = sysc.inval and (arp.crc = 2 or arp.crc = 1 or arp.crc = 3 or arp.crc = 4) no-lock:
         find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp no-lock no-error.
         if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.
         find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp no-lock no-error.
         if not avail sub-cod or (substr(sub-cod.ccode, 2, 2) <> string(int(get-dep(g-ofc, g-today)), "99") and sub-cod.ccode <> "514") then next.

         find first crc where crc.crc eq arp.crc no-lock no-error.
         if avail crc then do:
            displ arp.arp  label "ARP Счет" crc.crc label "Код" crc.code label "Валюта" arp.dam[1] - arp.cam[1] label "Остатки на счете " format "->>,>>>,>>>,>>>,>>9.99".
         end.

      end.
    end.

pause.




