/* dcls61.p
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
        25/01/2005 kanat
 * CHANGES
        09/03/2005 kanat - изменение в запрос - берутся все платежи
*/

{global.i}

def var v-sum-tmp as decimal.

for each remtrz where remtrz.valdt2 = g-today and
                     (remtrz.ptype = "2" or
                      remtrz.ptype = "6") and remtrz.tcrc = 1 and
                      remtrz.cracc = "900161014" no-lock.
v-sum-tmp = v-sum-tmp + remtrz.amt.
end.

find first rmzshst where rmzshst.regdate = g-today no-lock no-error.
if not avail rmzshst then do:
create rmzshst.
update rmzshst.ofc     = g-ofc
       rmzshst.regtime = time
       rmzshst.regdate = g-today
       rmzshst.ptype   = "I"
       rmzshst.sum     = v-sum-tmp.
end.       
