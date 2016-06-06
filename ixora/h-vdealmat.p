/* h-vdealmat.p
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

/* h-vdealmat.p
*/
{global.i}
{itemlist.i
       &updvar = "def var vfun like fun.fun.
                  def var vint like fun.interest.
                  {imesg.i 9827} update vfun."
       &file = "fun"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "fun.fun begins vfun and fun.duedt le g-today
        and fun.dam[1] ne fun.cam[1]"
       &predisp = "find gl of fun. if gl.type = ""A"" then
        vint = fun.interest - fun.cam[2]. else
        vint = fun.interest - fun.dam[2]."
       &flddisp = "fun.fun fun.grp format 'zz9' fun.duedt fun.gl
                          fun.dam[1] - fun.cam[1] format ""z,zzz,zzz,zz9.99-""
                          label ""BALANCE"" vint"
       &chkey = "fun"
       &chtype = "string"
       &index  = "fun"
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
