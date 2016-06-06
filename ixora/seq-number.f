/* seq-number.f
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
        03/12/08 marinav - размер фрейма 
*/

/** seq-number.f **/


define frame fujo
    ujo.docnum label 'Документ'
    ujo.whn    label 'Дата'
    vtime      label 'Время'
    ujo.jh     label 'Транз.'
    template   label 'Шаблон'
    with row 10 centered overlay 12 down.
