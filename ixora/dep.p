/* dep.p
 * MODULE
       Платежная система
 * DESCRIPTION
        выбор ИД и наименования отделений филиала
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        repMT998.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK TXB
 * CHANGES
        25/02/2013 zhasulan - ТЗ 1505 Добавлен подпункт "Консолидированный отчет по ЦОКам"
*/
define shared var g-ofc like txb.ofc.ofc.
define shared var v-bank as char.
define shared var hasAccess as logical.

def output parameter p-depart as integer.
def output parameter p-departch as char.
def var v-dep as char.

def var v-sel as integer.
/**выбор СПФ соотвествующего филиала**/
find first txb.ofchis where txb.ofchis.ofc = g-ofc no-lock no-error.
if not avail txb.ofchis then do:
    message 'Нет сведений о пользователе!!!' view-as alert-box.
    return.
end.

find first txb.ofc where txb.ofc.ofc = g-ofc no-lock no-error.
if avail txb.ofc then do:

if hasAccess then do:
   for each txb.ppoint where txb.ppoint.point = txb.ofchis.point no-lock:
      if v-dep <> "" then v-dep = v-dep + " |".
      v-dep = v-dep + string(txb.ppoint.depart) + " " + txb.ppoint.name.
   end.
   if v-bank = "TXB16" then v-dep = v-dep + " |99 Консолидированный отчет по ЦОКам".
   v-sel = 0.
   run sel2 (" ВЫБЕРИТЕ ОФИС БАНКА ", v-dep, output v-sel).
   if v-sel = 0  then return.
   p-depart = integer(trim(entry(1,(entry(v-sel,v-dep, '|')),' '))).
   hasAccess = true.
end.
else p-depart = txb.ofchis.depart.

if p-depart <> 99 then do:
   find txb.ppoint where txb.ppoint.depart = p-depart no-lock.
   p-departch = txb.ppoint.name.
end.
else p-departch = "Консолидированный отчет по ЦОКам".

end.

