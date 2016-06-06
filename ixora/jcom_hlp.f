/* jcom_hlp.f
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

/** jcom_hlp.f **/

define frame f_hlp
    joucom.comcode label "КОД КОМИССИИ"
    joucom.comdes  label "ОПИСАНИЕ КОМИССИИ"
    joucom.comnat  label "НАЦ.ВАЛ."
    joucom.comprim label "ПРИОР"
    with row 6 centered 8 down overlay .
