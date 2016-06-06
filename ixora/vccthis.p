/* vccthis.p
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
11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
05.08.2011 aigul - recompile
*/

/* vccthis.p Валютный контроль
   Просмотр истории контракта

   08.11.2002 nadejda создан

*/

def new shared var s-viewcommand as char.
s-viewcommand = "ps_less".
run vccthis0.
