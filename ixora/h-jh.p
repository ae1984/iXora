/* h-jh.p
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

/* h-jh.p
*/
{global.i}

def var vkey as char format "x(16)".
def var vsts as char format "x(3)" label "STS".
{mesg.i 0950} update vkey.
if g-ofc = "ROOT" then do:
  if keyfunction(lastkey) = "go" then do:
    {itemlist.i &where = "jh.jdt eq g-today and jh.cif eq vkey  "
           &file = "jh"
           &set = "a"
           &frame = "row 5 centered scroll 1 12 down overlay "
           &flddisp = "jh.jh jh.cif jh.party jh.who vsts"
           &predisp = " vsts = "" "".
                        find first jl of jh no-error.
                        if not available jl then vsts = ""***""."
           &dispadd = "if jh.cif ne "" "" then do:
                       find cif where cif.cif eq jh.cif.
                       display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ jh.party with frame xf. end."
           &chkey = "jh"
           &chtype = "integer"
           &index  = "cif"
           &funadd = "if frame-value = "" "" then do:
                        {imesg.i 9205}.
                        pause 1.
                        next.
                      end." }
  end.
  else do:
    {itemlist.i &where = "jh.jdt eq g-today and jh.jh ge integer(vkey)"
           &file = "jh"
           &set = "b"
           &frame = "row 5 centered scroll 1 12 down overlay "
           &flddisp = "jh.jh jh.cif jh.party jh.who vsts"
           &predisp = " vsts = "" "".
                        find first jl of jh no-error.
                        if not available jl then vsts = ""***""."
           &dispadd = "if jh.cif ne "" "" then do:
                       find cif where cif.cif eq jh.cif.
                       display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ jh.party with frame xf. end."
           &chkey = "jh"
           &chtype = "integer"
           &index  = "jh"
           &funadd = "if frame-value = "" "" then do:
                        {imesg.i 9205}.
                        pause 1.
                        next.
                      end." }
  end.
end.
else do:
  if keyfunction(lastkey) = "go" then do:
    {itemlist.i &where = "jh.who = g-ofc and
                     jh.jdt eq g-today and jh.cif eq vkey  "
           &file = "jh"
           &set = "c"
           &frame = "row 5 centered scroll 1 12 down overlay "
           &flddisp = "jh.jh jh.cif jh.party jh.who vsts"
           &predisp = " vsts = "" "".
                        find first jl of jh no-error.
                        if not available jl then vsts = ""***""."
           &dispadd = "if jh.cif ne "" "" then do:
                       find cif where cif.cif eq jh.cif.
                       display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ jh.party with frame xf. end."
           &chkey = "jh"
           &chtype = "integer"
           &index  = "cif"
           &funadd = "if frame-value = "" "" then do:
                        {imesg.i 9205}.
                        pause 1.
                        next.
                      end." }
  end.
  else do:
  {itemlist.i &where = "jh.who = g-ofc and jh.jdt eq g-today
                   and jh.jh ge integer(vkey)"
         &file = "jh"
         &set = "d"
         &frame = "row 5 centered scroll 1 12 down overlay "
         &flddisp = "jh.jh jh.cif jh.party jh.who vsts"
         &predisp = " vsts = "" "".
                      find first jl of jh no-error.
                      if not available jl then vsts = ""***""."
         &dispadd = "if jh.cif ne "" "" then do:
                     find cif where cif.cif eq jh.cif.
                     display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ jh.party with frame xf. end."
         &chkey = "jh"
         &chtype = "integer"
         &index  = "jh"
         &funadd = "if frame-value = "" "" then do:
                      {imesg.i 9205}.
                      pause 1.
                      next.
                    end." }
 end.
end.
