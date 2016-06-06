/* rem_card.f
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

/** rem_card.f **/

define shared frame fcards
    t_card.card    label "KARTES"
    t_card.exdate  label "L§DZ"
    t_card.owner   label "KARTES §PA№NIEKS"
    t_card.amount  label "SUMMA"
    t_card.payment label "IESK.SUMMA"
    t_card.code    label "VAL."
    with row 15 down. 
