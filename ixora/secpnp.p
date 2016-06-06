/* secpnp.p
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

def var vofc like ofc.ofc.
update vofc.
display " W A I T ... ".
for each nmenu where length(nmenu.proc) > 0 .
find sec where sec.ofc = vofc and sec.fname = nmenu.fname no-error.
if not available sec then do:
create sec.
sec.ofc = vofc.
sec.fname = nmenu.fname.
display sec.
end.
pause 0.
end.
