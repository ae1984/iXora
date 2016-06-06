/* findclsaaatxb1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        10/05/2011 evseev
 * BASES
        COMM TXB
 * CHANGES
        01/02/2012 evseev - добавил no-undo
*/


def shared var s-aaa  like txb.aaa.aaa no-undo.
def shared var s-res  as logical no-undo.

find first txb.aaa where txb.aaa.aaa = s-aaa no-lock no-error.

if avail txb.aaa then do:
   if txb.aaa.sta <> 'C' then do:
     s-res = no.
   end.
end.