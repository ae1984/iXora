/* trg_upl_del.p
 * MODULE
        БИОМЕТРИЯЧЕСКИЙ АНАЛИЗ
 * DESCRIPTION
        Назначение программы, описание процедур и функций
	Контроль удаление доверенного лица, если доверенному лицу выписывались доверенности то нельзя удалить
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
        19/09/05 u00121
 * CHANGES
        05/05/2010 galina - перекомпиляция
*/

TRIGGER PROCEDURE FOR Delete OF upl.
find last uplcif where uplcif.uplid = upl.uplid no-lock no-error.
if avail uplcif then
do:
   message "Есть связанные данные, удаление не возможно (upl -> uplcif)" view-as alert-box.
   return error.
end.