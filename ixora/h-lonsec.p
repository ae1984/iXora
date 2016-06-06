/* h-lonsec.p
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
        12.08.2008 galina - добавила return frame-value.
*/

{global.i}
{itemlist.i &file = "lonsec"
       &where = "true"
       &frame = "row 5 centered scroll 1 12 down overlay "
       {h-lonsec.f}.
       &chkey = "lonsec"
       &chtype = "integer"
       &index  = "lonsec"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
return frame-value.