/* h-fun.p
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

/* h-fun.p
*/
{global.i}
{itemlist.i
       &updvar = "def var vfun like fun.fun.
                  {imesg.i 9827} update vfun."
       &file = "fun"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "fun.fun begins vfun"
       &flddisp = "fun.fun fun.grp format 'zz9' fun.gl
                          fun.dam[1] - fun.cam[1] format ""z,zzz,zzz,zz9.99-""
                          label ""balance"""
       &chkey = "fun"
       &chtype = "string"
       &index  = "fun"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
