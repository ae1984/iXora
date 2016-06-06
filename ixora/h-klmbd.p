/* h-klmbd.p
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

/* h-klmbd.p */
{global.i}
define variable v-prc as integer.
{itemlist.i
       &defvar  = " "
       &updvar  = " "
       &where = "codfr = 'klmbd' and code <= '100' "
       &frame = "row 5 centered scroll 1 12 down overlay title 
                 'Группы классификации' "
       &form = "codfr.code label 'Группа' v-prc format 'zz9'
         label 'Норма провизии'
         codfr.name[1] label 'Наименование' format 'x(50)' "
       &index = "cdco_idx"
       &chkey = "code"
       &chtype = "string"
       &file = "codfr"
       &predisp = "v-prc = integer(codfr.code). "
       &flddisp = "codfr.code v-prc codfr.name[1]"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
