/* h-londic.p
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

/* h-londic.p  - просмотр кодификаторов по кредитам по F2
   изменения от 19.05.2000 */

{global.i}
{itemlist.i
       &file = "codific"
       &where = "codific.codfr begins 'ln' "
       &frame = "row 6 column 20 scroll 1 12 down overlay "
       &findadd = " "
       &flddisp = "codific.codfr label 'КОД' 
                   codific.name format 'x(50)' label 'НАИМЕНОВАНИЕ'
                  "
       &chkey = "codfr"
       &chtype = "string"
       &index  = "codfr_idx"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
