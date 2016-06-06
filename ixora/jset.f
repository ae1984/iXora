/* jset.f
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

/** jset.f **/

define frame fset
    space(5)
    jouset.des    label "ОПИСАНИЕ"
    jouset.drtype label "ДЕБЕТ"  help "   F2 - ПОМОЩЬ   "
    jouset.crtype label "КРЕДИТ" help "   F2 - ПОМОЩЬ   "
    jouset.natcur label "НАЦ.ВАЛ."
    jouset.proc   label "ПРОЦЕДУРА"
    with centered row 6 10 down.
