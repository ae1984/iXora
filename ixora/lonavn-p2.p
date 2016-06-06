/* lonavn-p2.p
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

/* LOAN PRINCIPAL VALUE RETURN SCHEDULE */
define input parameter v-gl like gl.gl.
define input parameter v-dc like lonlizjl.dc.

/*def output parameter flag as inte.*/
def new shared var s-f0 like lnsch.f0.
def var svopnamt as char format "x(21)".
def var vall like lon.opnamt.

def shared var s-lon like lon.lon.
def shared var s-jh  like jh.jh.
vall = 0.
{mainhead.i}
pause 0.
upper:
repeat transaction:

{jjbr.i
&head = "lonlizjl"
&headkey = "jh"
&dttype  = "string"
&where = "lonlizjl.lon = s-lon and lonlizjl.gl = v-gl and lonlizjl.dc = v-dc "
&index = "longldc"
&formname = "lonavn-p2"
&framename = "lonavn-p2"
&addcon = "false"
&start = " "
&display = "lonlizjl.jh lonlizjl.gl lonlizjl.jdt lonlizjl.crc 
            lonlizjl.acc lonlizjl.amt lonlizjl.dc lonlizjl.who"
&postgo-on = ""GO""a
&postdisplay = " "
&postadd = " "
&postkey = "if lastkey = 13 then do:
               if available lonlizjl then do:
                  def var nrec as recid.
                  if lonlizjl.jh > 0 then do:
                     s-jh = lonlizjl.jh.
                     if clin = 1 then do:
                        if trec = frec then do:
                           find next lonlizjl where lonlizjl.lon = s-lon and 
                           lonlizjl.gl = v-gl and lonlizjl.dc = v-dc no-lock no-error.
                           if available lonlizjl then nrec = recid(lonlizjl).
                           else clin = 0.
                        end.
                     end.
                     else if trec <> frec then do:
                        find prev lonlizjl where lonlizjl.lon = s-lon and
                        lonlizjl.gl = v-gl and lonlizjl.dc = v-dc no-lock no-error.
                        if available lonlizjl then nrec = recid(lonlizjl).
                     end.

                     run lnx-jls.

                     find first lonlizjl where recid(lonlizjl) = crec 
                     no-lock no-error.
                     if not available lonlizjl then do:
                        if clin = 1 then trec = nrec.
                        clear frame lonavn-p2 all.
                        next upper.
                     end.
                     else do:
                        display lonlizjl.jh with frame lonavn-p2.
                        next inner.
                     end. 
                  end.
                  else bell.
               end.
               else bell.
            end.
            if keyfunction(lastkey) = 'GO' then leave upper."
&end = "leave upper."
}
end.
