/* h-vdeal.p
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

/* h-vdeal.p */

{global.i}
{itemlist.i   &start = " "
              &file = "deal"
              &where = "deal.fun eq "" "" and deal.prn <> 0 and deal.regdt <> ?
                        and deal.valdt <> ?"
              &frame = "row 3 centered scroll 1 15 down overlay
                        title "" СПИСОК СДЕЛОК """
              &flddisp = "deal.deal deal.bank deal.prn 
               format 'z,zzz,zzz,zzz,zz9.99' deal.regdt deal.valdt"
              &chkey = "deal"
              &chtype = "string"
              &index  = "deal"
              &funadd = "if frame-value = "" "" then
                             do:
                                {imesg.i 9205}.
                                pause 1.
                                next.
                             end."
                             }
