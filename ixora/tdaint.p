/* tdaint.p
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
 * BASES
        BANK COMM        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   22/08/03 nataly
   - Line 24,25: substring(pri.pri,1,2) -> substring(pri.pri,1,4)
   - Line 27: substring(pri.pri, 2,1) -> substring(pri.pri,2,3)
   - Line 81: substring(pri.pri,2,1) -> substring(pri.pri,2,3)
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
   - Line 82,84: substring(pri.pri,3,2) -> substring(pri.pri,5,2)
   30.06.2008 alex - редактирование только из ЦО, синхронизация с филиалами
   01.07.2008 alex - добавил параметр в lgrpribranch
   
*/

{mainhead.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
if s-ourbank ne "txb00" then do:
message "Редактирование доступно только из ЦО" view-as alert-box.
return.
end.


def new shared var head1 as char initial "Срок".
def new shared var head11 as char initial "Ступень 1".
def new shared var head12 as char initial "Ступень 2".
def new shared var head13 as char initial "Ступень 3".
def new shared var head14 as char initial "Ступень 4".
def new shared var head15 as char initial "Ступень 5".
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
&addcon = "true"
&deletecon = "true"
&prechoose = "message 'Enter-Редактировать таблицу, E-Редактировать строку, Insert-Добавить строку, F10-Удалить строку, F4-Выход'. 
              run ShowTable."
&predisplay = " "
&display = "gpri.gpri gpri.name gpri.itype gpri.rate"
&highlight = "gpri.gpri"
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
              run tdaintrat(gpri.gpri).
              run SavePriHistory.
            end.
            else if keyfunction(lastkey) = 'E' then do:
              update gpri.name gpri.itype gpri.rate with frame ss3.
              run SaveUpdatedGpri.
              run SavePriHistory.
            end."
&postadd = "gpri.tlimit = 999999999.99. 
            run ShowTable.
            update gpri.gpri gpri.name gpri.itype gpri.rate with frame ss3.
            run SaveCreatedGpri.
            run SavePriHistory.
           "
&predelete = "run DeleteGpri."           
&end = "hide frame ss. hide frame ss1. hide frame ss2. hide frame ss3.
        hide message."
}


/****************************************************************************************************/

def var v-all as log.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

if s-ourbank = "txb00" then do:
    v-all = no.
    message "Производить изменения по всем филиалам?" view-as alert-box question buttons yes-no title "" update v-all.
    if v-all then do:
        displ " Синхронизация с филиалами... " with no-label row 7 centered frame vmess.
        {r-branch.i &proc = "lgrpribranch(no)"}
        hide frame vmess.
    end.
end.

/****************************************************************************************************/


   
Procedure ShowTable.
def var iii as inte.
for each vrate:
   delete vrate.
end. 

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

iii = 0.
clear frame ss all.
for each vrate:
    iii = iii + 1.
    if iii > vdown then leave.
    disp vrate.vterm vrate.rate with frame ss.
    down with frame ss.
end.  
End Procedure.

Procedure SaveUpdatedGpri.
  vpri = "^" + gpri.gpri.
  do transaction:
     for each pri where pri.pri begins vpri exclusive-lock:
          pri.name = gpri.name.
          pri.itype = gpri.itype.
          pri.rate = gpri.rate.
     end. 
  end.   
End Procedure.

Procedure SaveCreatedGpri.
  gpri.tlimit = 999999999.99.
do transaction:
  create pri.
         pri.pri = "^" + gpri.gpri + "00".
         pri.name = gpri.name.
         pri.itype = gpri.itype.
         pri.rate = gpri.rate.
         do vi = 1 to 6:
           pri.tlimit[vi] = gpri.tlimit[vi].
         end.
end.
End Procedure.

Procedure DeleteGpri.
 do transaction:
   for each pri where pri.pri begins "^" + gpri.gpri exclusive-lock:
      for each prih where prih.pri = pri.pri exclusive-lock:
         delete prih.
      end.
      delete pri.
   end.
 end.
End Procedure.

Procedure SavePriHistory.
 do transaction:
   for each pri where pri.pri begins "^" + gpri.gpri no-lock:
      find first prih where prih.pri = pri.pri and prih.until = g-today 
                            exclusive-lock no-error.
      if not available prih then create prih.
      prih.pri = pri.pri.
      prih.rat = pri.rate.
      prih.itype = pri.itype.
      prih.until = g-today.
      prih.who = g-ofc.
      prih.whn = g-today.
      prih.tim = time.
      prih.tlimit[1] = pri.tlimit[1]. prih.trate[1] = pri.trate[1].
      prih.tlimit[2] = pri.tlimit[2]. prih.trate[2] = pri.trate[2].
      prih.tlimit[3] = pri.tlimit[3]. prih.trate[3] = pri.trate[3].
      prih.tlimit[4] = pri.tlimit[4]. prih.trate[4] = pri.trate[4].
      prih.tlimit[5] = pri.tlimit[5]. prih.trate[5] = pri.trate[5].
      prih.tlimit[6] = pri.tlimit[6]. prih.trate[6] = pri.trate[6].
   end.  
 end.
End Procedure.

