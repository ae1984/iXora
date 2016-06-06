/* h-accscu.p
 * MODULE
        Окно счетов SCU
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
        02.03.2004 tsoy
 * CHANGES
*/

/* h-accscu.p
*/

{global.i}
def shared var s-scugl like scu.gl.

{itemlist.i 
       &file    = "scu"
       &start   = " "
       &where   = "scu.scu <>"""""
       &frame   = "row 5 centered scroll 1 12 down overlay  "
       &flddisp = "scu.scu LABEL ""Счет SCU"" scu.gl LABEL ""Счет ГК"""
       &chkey   = "scu"
       &chtype  = "string"
       &index   = "scu"
}
