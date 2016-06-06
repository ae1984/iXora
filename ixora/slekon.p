/* slekon.p
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
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*slekon.p*/
/*mainhead.i}*/

def var menu1 as char extent 2 format "x(25)"
    initial ["Юридические лица","Физические лица"].
def var val as character.

disp menu1 with no-label 1 columns centered frame ma.
message "Выберите вид отчета".

choose field menu1 auto-return with frame ma.
hide frame ma.

if frame-value = "Юридические лица" then do:
    run sljur.
end.
if frame-value = "Физические лица" then do:
    run slfiz.
end.


