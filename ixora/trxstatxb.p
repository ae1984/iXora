/* trxstatxb.p
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
 * BASES
        TXB 
 * AUTHOR
        29.10.2010 k.gitalov 
 * CHANGES
       
*/


def input param p-txb as char.
def input param p-jh as int.
def output param p-stat as int.

   
find first txb.jh where txb.jh.jh = p-jh no-lock no-error.
if avail txb.jh then
do:
  p-stat = txb.jh.sts.
end.
else p-stat = -1. 
