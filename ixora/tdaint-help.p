/* tdaint-help.p
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
    - Line 24,25: substring(pri.pri,1,2) -> substring(pri.pri,1,4)
    - Line 27: substring(pri.pri, 2,1) -> substring(pri.pri,2,3)  
    - Line 70,72: substring(pri.pri,3,2) -> substring(pri.pri,5,2)>
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
 */

{mainhead.i}

def new shared var head1 as char initial "Term".
def new shared var head11 as char initial "Limit 1".
def new shared var head12 as char initial "Limit 2".
def new shared var head13 as char initial "Limit 3".
def new shared var head14 as char initial "Limit 4".
def new shared var head15 as char initial "Limit 5".
def var vpri as char.
def var vprii as char.
def var vi as inte.
def new shared temp-table gpri 
    field gpri as char
    field name as char
    field itype as inte
    field rate like pri.rate
    field tlimit like pri.tlimit.
def new shared temp-table vrate 
    field vterm as inte 
    field rate like pri.rate extent 5.
def new shared frame ss.
def new shared frame ss1.

for each pri where pri.pri begins "^" group by substring(pri.pri,1,4):
   if first-of(substring(pri.pri,1,4)) then do:   
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
end.

{jabre.i
&start = " " 
&head = "gpri" 
&headkey = "gpri" 
&where = "true"
&formname = "tdainttab" 
&framename = "ss3" 
&addcon = "false"
&deletecon = "false"
&prechoose = "message 'Enter - выбрать таблицу % ставок'. 
              run ShowTable."
&predisplay = " "
&display = "gpri.gpri gpri.name gpri.itype gpri.rate"
&highlight = "gpri.gpri"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              frame-value = gpri.gpri.
              leave upper.
            end."
&postadd = " "
&predelete = " "           
&end = "hide frame ss. hide frame ss1. hide frame ss2. hide frame ss3.
        hide message."
}
   
Procedure ShowTable.
def var iii as inte.
for each vrate:
   delete vrate.
end. 
for each pri where pri.pri begins "^" + gpri.gpri
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

iii = 0.
clear frame ss all.
for each vrate:
    iii = iii + 1.
    if iii > vdown then leave.
    disp vrate.vterm vrate.rate with frame ss.
    down with frame ss.
end.  
End Procedure.

