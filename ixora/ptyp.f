/* ptyp.f
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

/* pid.f
*/

form " " ptyp.ptype column-label "Тип платежа" ptyp.des
    column-label "      Описание    " ptyp.receiver 
    column-label  "Получатель"
    ptyp.sender column-label "Отправитель"
   with centered row 6 down frame ptyp.
