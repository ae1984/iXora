/* tdainthist.p
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
    22/08/03 nataly
    - Line 24 substring(pri.pri,2,1) -> substring(pri.pri,2,3)
    - Line 39: substring(pri.pri,2,1) -> substring(pri.pri,2,3)
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
    - Line 40,42: substring(pri.pri,3,2) -> substring(pri.pri,5,2)*/

{global.i}
def input parameter s-pri as char.
def var vi as inte.
def var vpri as char.
def var head1 as char initial "Срок".
def var head11 as char initial "Ступень 1".
def var head12 as char initial "Ступень 2".
def var head13 as char initial "Ступень 3".
def var head14 as char initial "Ступень 4".
def var head15 as char initial "Ступень 5".
def temp-table gpri 
    field gpri as char
    field name as char
    field itype as inte
    field rate like pri.rate
    field tlimit like pri.tlimit.
def temp-table vrate 
    field vterm as inte 
    field rate like pri.rate extent 5.

find first pri where pri.pri begins  "^" + s-pri.
if available pri then do:
     create gpri.
            gpri.gpri = substring(pri.pri,2,3).
            gpri.name = pri.name.
            gpri.rate = pri.rate.
            gpri.itype = pri.itype.
            gpri.tlimit[1] = pri.tlimit[1].
            gpri.tlimit[2] = pri.tlimit[2].
            gpri.tlimit[3] = pri.tlimit[3].
            gpri.tlimit[4] = pri.tlimit[4].
            gpri.tlimit[5] = pri.tlimit[5].
            gpri.tlimit[6] = pri.tlimit[6].
end.

find first gpri.

for each pri where pri.pri begins "^" 
               and substring(pri.pri,2,3) = gpri.gpri
               and substring(pri.pri,5,2) <> "00":
   create vrate.
          vrate.vterm = integer(substring(pri.pri,5,2)).
          do vi = 1 to 5:
             vrate.rate[vi] = pri.trate[vi].
          end.
end.

display  head1 gpri.tlimit[1] gpri.tlimit[2] gpri.tlimit[3] 
               gpri.tlimit[4] gpri.tlimit[5] with frame ss1.
color display input head1 with frame ss1.
color display message gpri.tlimit[1] with frame ss1.
color display message gpri.tlimit[2] with frame ss1.
color display message gpri.tlimit[3] with frame ss1.
color display message gpri.tlimit[4] with frame ss1.
color display message gpri.tlimit[5] with frame ss1.

display head11 head12 head13 head14 head15 with frame ss2.

color display input head11 head12 head13 head14 head15 with frame ss2.

{jabre.i
   &head = "vrate"
   &headkey = "vterm"
   &where = "true"
   &formname = "tdainttab"
   &framename = "ss"
   &addcon = "false"
   &deletecon = "false"
   &prechoose = " "
   &predisplay = " "
   &display = "vrate.vterm vrate.rate"
   &highlight = "vrate.vterm"
   &postkey = " "
   &postadd = " "
   &predelete = " "           
   &end = "hide frame ss.
           hide frame ss1.
           hide frame ss2.
          " 
}


