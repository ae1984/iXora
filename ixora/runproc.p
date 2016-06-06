/* runproc.p
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

/*--------------------------*/
/* Запуск процедур по имени */
/* 13/09/2002 by sasco      */
/*--------------------------*/
              
def var v-proc as char format 'x(20)'.
def var v-path as char format 'x(40)' extent 5.
def var fullpath as char.

update v-proc label "Введите название процедуры"
validate (trim(v-proc) <> "", "Введите ну хотя бы один символ!")
skip
"Полный путь к процедуре, если необходимо" skip
v-path[1] label '      ' skip
v-path[2] label '      ' skip
v-path[3] label '      ' skip
v-path[4] label '      ' skip
v-path[5] label '      '
with side-labels row 4 centered frame get-proc.

hide frame get-proc.

fullpath = trim (v-path[1]) +
           trim (v-path[2]) +
           trim (v-path[3]) +
           trim (v-path[4]) +
           trim (v-path[5]).

if fullpath <> '' then if substr(fullpath, length(fullpath), 1) <> "/" then
   fullpath = fullpath + "/".


fullpath = fullpath + trim(v-proc).
/*
if search(fullpath) = ? or
   search(fullpath + ".r") = ? or
   search(fullpath + ".p") = ?
   then message "Нет такой процедуры!" view-as alert-box.
*/

do on endkey undo, leave:
run value(fullpath) no-error.
end.


