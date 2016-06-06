/* lns-jls.p
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

def shared var s-jh like jl.jh.
def new shared var s-jl like jl.ln.
def var vbal like jl.dam.
def var vdam like jl.dam.
def var vcam like jl.cam.
def var lstk as inte.
def var nrec as recid.
def var vnrr as inte.
def new shared var vans as log.
{mainhead.i}

upper: repeat:
{jjbr.i

&start = " if lastkey = 404 then do: /* run ln-jlgens */. 
if not vans then leave upper.  vans = false. end.
{x-jlvf.i} 
find jh where jh.jh = s-jh no-lock.
find first jl of jh no-error.
/*if not available jl then do: update jh.crc with frame party.
create jl. jl.jh = s-jh. jl.jdt = g-today. jl.who = g-ofc. end. */"

&head = "jl" 
&headkey = "ln" 
&where = "jl.jh = s-jh" 
&index = "jhln"
&formname = "jhjl" 
&framename = "jl"
&dttype = "string" 
&dtfor = ", ""999""" 
&predisplay = "find first gl where gl.gl = jl.gl no-lock no-error."
&display = "jl.ln jl.gl gl.sname when available gl jl.crc jl.acc jl.dam jl.cam"
&display1 = "gl.sname when available gl" 
&prechoose = "disp jl.rem with frame rem. {imesg.i 410}."
&postkey = "else if lastkey = 404 then /* run ln-jlgens */ .
            else if lastkey = 13 then do: s-jl = jl.ln. 
              if crec = trec then do: nrec = trec. 
                 find prev jl where jl.jh = s-jh no-error.
                  if available jl then nrec = recid(jl).
                  else do: find jl where recid(jl) = trec.
                    find next jl where jl.jh = s-jh no-error.
                    if available jl then nrec = recid(jl).
                  end.
              end. find jl where recid(jl) = crec. /* run ln-jlgens. */
              find jl where jl.jh = s-jh and jl.ln = s-jl no-error.
              if not available jl then do:
                 vnrr = 1. 
                for each jl where jl.jh = s-jh:
                  jl.ln = vnrr. vnrr = vnrr + 1.
                end.
                if crec = trec then trec = nrec.
                clear frame jl all. clear frame rem.
                next upper.
              end.
           end.
           else if lastkey = 49 or lastkey = 51 or lastkey = 52 or lastkey = 53 
            then do: lstk = lastkey. s-jl = jl.ln. /* run ln-jlgens. */
               if lstk = 51 then do: run x-jlvou. next upper. end.
               if lstk = 52 then do:
                 find jl where jl.jh = s-jh and jl.ln = s-jl no-error.
                 if not available jl then leave upper. end.
               if lstk = 53 then next upper.
            end."
&addcon = "false" /* "true" */
&postadd = "release jl. /* run ln-jlgens.*/
find last jl where jl.jh = s-jh. /* if jl.gl = 0 then delete jl. */"
&precreate = "find jh where jh.jh = s-jh no-lock.
              if jh.post = true then do: bell. {imesg.i 224}. next inner. end.
              if jh.sts >= 6 then do: bell. {imesg.i 602}. 
              next inner. end. s-jl = jl.ln." 
&postcreate = " jl.ln = s-jl + 1. s-jl = jl.ln.
jl.jh = s-jh." } end. /*upper*/
/*
for each jl where jl.jh = s-jh:
  if jl.gl = 0 then delete jl.
end. */
hide frame rem.  hide frame jl. 
hide frame tot. hide frame bal. hide frame party. hide frame jh.
