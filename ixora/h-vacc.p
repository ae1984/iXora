/* h-vacc.p
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

/* h-vacc.p
*/
{global.i}
define shared variable s-ptype as integer format "z".
define variable i as integer.

if s-ptype <> 4
then return.


find first que use-index fprc where que.pid = "2L" and
     que.con = "W" and can-find(remtrz where remtrz.remtrz = que.remtrz and
     remtrz.rsub = "LON") no-lock no-error.
if not available que
then do:
     bell.
     message  "Nav kredЁtu p–rvedumu !".
     pause.
     return.
end.


{itemlist.i
       &updvar = " "
       &file = "que"
       &frame = "row 5 centered scroll 1 12 down overlay "
       &where = "que.pid = '2L' and que.con = 'W' and can-find(remtrz
        where remtrz.remtrz = que.remtrz and remtrz.rsub = 'LON')"
       &predisp = " "
       &flddisp = "que.remtrz    label 'P–rveduma Nr'
                   remtrz.ba        label 'Konts'
                   remtrz.payment   label 'Summa'
                   remtrz.jh1       label '1.trans.' "
       &chkey = "remtrz"
       &chtype = "string"
       &index  = "fprc"
       &findadd = "find remtrz where remtrz.remtrz = que.remtrz and 
                   remtrz.rsub = 'LON' no-lock."
       &funadd = "if frame-value = "" "" then do:
                    {imesg.i 9205}.
                    pause 1.
                    next.
                  end." }
