/* tmp-aaax.p
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

def var vaaa like aaa.aaa.

repeat:

update vaaa validate( can-find( first aaa where aaa.name = vaaa),"")
format "x(15)" label "OLD-ACCOUNT"

with  with row 1 frame pp 17 down.

for each aaa where aaa.name = vaaa:
find cif of aaa.
find crc of aaa.
disp aaa.aaa
crc.code
aaa.cif
aaa.lgr aaa.cbal
with frame pp .
down 1 with frame pp.
end.

end.
