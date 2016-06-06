/* deplist.p
 * MODULE
       Платежная система 
 * DESCRIPTION
        список отделений филиала
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
       02.04.2009 galina - выводим один департамент пользователя, если человек привязан к СП
*/
def output parameter p-departlist as char.

define shared var g-ofc like txb.ofc.ofc.

/**выбор СПФ соотвествующего филиала**/
find last txb.ofchis where txb.ofchis.ofc = g-ofc no-lock no-error.
if not avail txb.ofchis then do:
    message 'Нет сведений о пользователе!!!' view-as alert-box.
    return.
end.

if txb.ofchis.depart = 1 then do:
   for each txb.ppoint where txb.ppoint.point = txb.ofchis.point no-lock:
      if p-departlist <> "" then p-departlist = p-departlist + ",".
      p-departlist = p-departlist + string(txb.ppoint.depart).
   end.
end.
else p-departlist = string(txb.ofchis.depart).







