/* h-deal.p
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

/* h-deal.p */
{global.i}
{itemlist.i &start = " "
       &file = "deal"
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &flddisp = "deal.deal deal.bank deal.prn format 'z,zzz,zzz,zzz,zz9.99'
        deal.regdt deal.valdt"
       &chkey = "deal"
       &chtype = "string"
       &index  = "deal"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
