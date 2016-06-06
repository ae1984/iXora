/* debsrok.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату (с незакрытыми приходами по срокам)
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
        01/11/04 tsoy
 * CHANGES
        16/08/2005 marinav добавлен фактический срок
	10/05/06 u00121 - добавил индекс во временную таблицу wjh - формирование отчета сократилось с ~40 минут до ~ 1 минуты 
			- Добавил опцию no-undo в описание переменных и временных таблиц

*/

{global.i}
{debls.f}

def var vlen as int  init 90 no-undo.
def var slen as char init "90" no-undo.

def var grpost as decimal init 0.0 no-undo.

def temp-table wrkgrp no-undo
         field grp  like debls.grp          label "GRP"
         field ls   like debls.ls           label "NN"
         field arp  like debgrp.arp.

define new shared temp-table wrk no-undo
         field arp like debgrp.arp
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field ost  like debhis.ost         label "Остаток"
         field date like debhis.date        label "Дата"
         field ctime like debhis.ctime
         field period as character format "x(40)"
         field attn like debop.attn
         field srok as character
         field fsrok as character
         field name as char
         index idx_wrk is primary grp ls date ctime.

define new shared temp-table wjh no-undo
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field closed like debop.closed initial no
	index idx_wjh grp ls jh /*10/05/06 u00121*/	
         .


define buffer bdebhis for debhis.

hide all. pause 0.

form wrk.fsrok format "x(300)"
 with frame fr  overlay  row 14
  centered top-only no-label.
 
update v-grp with frame get-grp-all.
find debgrp where debgrp.grp = v-grp no-lock no-error.
if avail debgrp then displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

if v-grp <> 0 then do:
update v-ls with frame get-grp-all.
find debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
  if avail debls then displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.
end.

v-dat = g-today.

update v-dat with frame get-dat.
hide frame get-dat.
hide frame get-grp-all.


if v-grp = 0 then
   for each debls where debls.grp ne 0 and debls.ls ne 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.
else

if v-ls = 0 then 
   for each debls where debls.grp = v-grp and debls.ls ne 0  no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.
else
   for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.

define variable v-dtost as date format "99/99/99".

/* сформируем список проводок с остатками */
for each wrkgrp:
    run debost-get (wrkgrp.grp, wrkgrp.ls, wrkgrp.arp, v-dat).
end. 

if not can-find (first wrk) then do:
   message "На указанную дату нет остатков!" view-as alert-box.
   return.
end.


for each wrk .
    wrk.name = get-ls-name (wrk.grp, wrk.ls).
end.

{jabrw.i 

&start     = " def var v-base as char. 
               def var v-oldper as char.  
               def var v-oldsr as char.  
               def var v-code as integer.

               form 
                  v-base label ""Основание"" with overlay centered row 14 top-only side-label frame fff .
"                                                                     
&head        = "wrk"
&headkey     = "grp"
&index       = "idx_wrk"
&formname    = "debsrok"
&framename   = "f-dat"
&frameparm   = " "
&where       = " wrk.ost > 0 "
&addcon      = "false"
&deletecon   = "false"
&highlight   = " wrk.date wrk.name wrk.ost wrk.period wrk.fsrok wrk.attn "
&postcreate  = " "
&prechoose   = " hide message. message 'F4 - выход'. "
&predisplay  = " "
&display     = " wrk.date wrk.name wrk.ost wrk.period wrk.fsrok wrk.attn "
&postdisplay = " "
&update      = " wrk.period "
&preupdate   =  " v-oldper = wrk.period. v-oldsr = wrk.fsrok. "
&postupdate   = "  update wrk.fsrok with frame fr scrollable. hide frame fr no-pause. v-base = """".  
                     if wrk.period entered then do: 
                     v-code = integer (wrk.period) no-error .
                     if v-code > 0 then do:
                         find codfr where codfr.codfr = 'debsrok' and codfr.name[2] = string(v-code,'9') no-lock no-error .
                         if available codfr then assign
                             wrk.period = codfr.code
                             wrk.period:screen-value = codfr.code.
                         else do:
                             message ""Ошибочный код!!!"".
                             pause 2.
                             wrk.period:screen-value = v-oldper.
                         end.
                     end.
                     find last debop where debop.grp   = wrk.grp and debop.ls   = wrk.ls and
                                            debop.jh   = wrk.jh and debop.date = wrk.date exclusive-lock use-index jh no-error.
                     if avail debop then do:
                          debop.period = wrk.period:screen-value.
                     end.                    
                     release debop.
                     find codfr where codfr.codfr    = 'debsrok' and codfr.code = wrk.period:screen-value no-lock no-error.                   
                     if avail codfr then do:
                          wrk.period:screen-value = codfr.name[1].
                          wrk.period              = wrk.period:screen-value. 
                     end.
                         update v-base format ""x(65)"" with frame fff. hide frame fff.
                           create dbsrhis.     
                            dbsrhis.cdate   = today. dbsrhis.ctime   = time.         
                            dbsrhis.cwho    = g-ofc. dbsrhis.grp     = wrk.grp.      
                            dbsrhis.ls      = wrk.ls. dbsrhis.jh      = wrk.jh.       
                            dbsrhis.amt     = wrk.ost. dbsrhis.oldsr   = v-oldper.     
                            dbsrhis.newsr   = wrk.period. dbsrhis.res     = v-base. end.
                     if v-oldsr ne wrk.fsrok then do: 
                         displ wrk.fsrok with frame f-dat. pause 0. 
                         if v-base = """" then update v-base format ""x(65)"" with frame fff.
                         hide frame fff.
                         find first debhis where debhis.djh = wrk.jh and
                             debhis.grp = wrk.grp and
                             debhis.ls = wrk.ls and
                             debhis.type < 3 and
                             debhis.dactive
                             exclusive-lock use-index djh no-error.
                         if avail debhis then debhis.chval[1] = wrk.fsrok.
                         find current debhis no-lock.
                     end.
                "
&postkey   = " " 
&end = " "
}
