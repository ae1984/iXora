/* trxhead.p
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
        04/12/08 marinav - увеличение формы для IBAN
*/

def shared var g-lang as char.
def var vsystem as char.
def var vcode as inte.
def buffer btrxhead for trxhead.
def var tmpsys as char initial "*" no-undo.
def var tmpdes as char initial "*" no-undo.
def var tmpcode as inte initial 1 no-undo.
def var vlines as inte no-undo.

{trxtmpl1.f "new"}

{jabro.i
&start     = "view frame trxtmpl1."
&head      = "trxhead"
&headkey   = "code"
&index     = "syscode"
&formname  = "trxhead"
&framename = "trxhead"
&where     = "trxhead.sys matches tmpsys and trxhead.des matches tmpdes"
&addcon    = "true"
&deletecon = "true"
&predelete = "run trxtmpldel." 
&precreate = "find trxhead where recid(trxhead) = crec no-lock no-error.
              if not available trxhead then vsystem = 'GNR'.
              else vsystem = trxhead.system.
                 vcode = 0.
              for each btrxhead where btrxhead.system = vsystem 
                                  no-lock break by btrxhead.code:
                 if btrxhead.code - vcode > 1 then leave.
                 vcode = btrxhead.code.
              end.
                 vcode = vcode + 1."
&postadd   = " trxhead.system = vsystem.
               trxhead.code = vcode.
               disp trxhead.system trxhead.code trxhead.des with frame trxhead.
               trxhead.code = 0.
               update trxhead.system 
               validate(can-find(trxsys where trxsys.system = trxhead.system),
                         'System not registered ! Register first !')
                          with frame trxhead.
               if frame trxhead trxhead.system entered then do:
                   trxhead.code = 0.
                   vcode = 0.
                for each btrxhead where btrxhead.system = trxhead.system 
                                           no-lock break by btrxhead.code:
                   if btrxhead.code - vcode > 1 then leave.
                   vcode = btrxhead.code.
                end.
                 vcode = vcode + 1.
               end.   
                 trxhead.code = vcode.
                 disp trxhead.code with frame trxhead.
                 update trxhead.des with frame trxhead."
&prechoose = " message 'F4-exit, INS-add, E-edit, C-copy, F10-delete, D-delete lines, F-filter'.
               run trxlndisp(trxhead.system + string(trxhead.code,'9999'))."
&predisplay = "vlines = 0. 
               for each trxtmpl where trxtmpl.code = trxhead.system + 
                                string(trxhead.code,'9999') no-lock:
                   vlines = vlines + 1.
               end."
&display   = " trxhead.system trxhead.code trxhead.des vlines"
&highlight = " trxhead.system trxhead.code trxhead.des vlines"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction
                                             on endkey undo, next inner:
              find trxhead where recid(trxhead) = crec exclusive-lock.
                update trxhead.des with frame trxhead.
              end.
              else if keyfunction(lastkey) = 'f' then do transaction:
               update tmpsys tmpcode tmpdes with frame trxhead1.
                find first btrxhead where btrxhead.system matches tmpsys and 
                           btrxhead.des matches tmpdes no-lock no-error.
                if not available btrxhead then do: tmpsys = '*'. tmpdes = '*'. 
                   bell.
                   next inner.
                end.
                find first btrxhead where 
                           btrxhead.system matches tmpsys and
                           btrxhead.des matches tmpdes and
                           btrxhead.code >= tmpcode no-lock no-error.
                if available btrxhead then do:
                   trec = recid(btrxhead).
                   next upper.
                end.
                else do:  
                   clin = 0.
                   next upper.
                end.
              end.
              else if keyfunction(lastkey) = 'e' then do:
                run trxtmpl(crec).
                next upper.
              end.
              else if keyfunction(lastkey) = 'C' then do:
                run trxcopy.
                next upper.
              end.
              else if keyfunction(lastkey) = 'd' then do:
                  run trxlndel.
                next upper.
              end."
&end = "hide frame trxhead.
        hide frame trxtmpl1."
}
hide message.

PROCEDURE trxtmpldel.
  for each trxtmpl where trxtmpl.code = trxhead.system + string(trxhead.code,'9999'): 
           delete trxtmpl. 
end.
END procedure.

PROCEDURE trxcopy.
   def buffer tmpl for trxtmpl.
   def var v-code like trxtmpl.code.
   def var f-ln like trxtmpl.ln.
   def var t-ln like trxtmpl.ln.
   def var vvln as inte.
   def var vvcode as char.
   form v-code label "Trx code " skip
          f-ln label "From line" skip 
          t-ln label "To line  "
   with side-labels title " Copy from " centered row 9 overlay frame trxcopy.
   vvcode = trxhead.system + string(trxhead.code,'9999').
   find last tmpl where tmpl.code = vvcode no-lock no-error.
   if available tmpl then vvln = tmpl.ln.
   else vvln = 0.
   update v-code validate(can-find(first tmpl where tmpl.code = v-code),"")
          with frame trxcopy.
   find first tmpl where tmpl.code = v-code no-lock. f-ln = tmpl.ln.       
   find last  tmpl where tmpl.code = v-code no-lock. t-ln = tmpl.ln.  
   update f-ln validate(can-find(tmpl where tmpl.code = v-code 
                        and tmpl.ln = f-ln) and f-ln <= t-ln,"")
          t-ln validate(can-find(tmpl where tmpl.code = v-code 
                        and tmpl.ln = t-ln) and t-ln >= f-ln,"")
         with frame trxcopy.     
   
      for each tmpl where tmpl.code = v-code 
               and tmpl.ln >= f-ln and tmpl.ln <= t-ln no-lock:
          vvln = vvln + 1.
          create trxtmpl.
          trxtmpl.code = vvcode.
          trxtmpl.ln = vvln.
          trxtmpl.amt = tmpl.amt. trxtmpl.amt-f = tmpl.amt-f.
          trxtmpl.crc = tmpl.crc. trxtmpl.crc-f = tmpl.crc-f.
          trxtmpl.rate = tmpl.rate. trxtmpl.rate-f = tmpl.rate-f.
          trxtmpl.drgl = tmpl.drgl. trxtmpl.drgl-f = tmpl.drgl-f.
          trxtmpl.drsub = tmpl.drsub. trxtmpl.drsub-f = tmpl.drsub-f.
          trxtmpl.dev = tmpl.dev. trxtmpl.dev-f = tmpl.dev-f.
          trxtmpl.dracc = tmpl.dracc. trxtmpl.dracc-f = tmpl.dracc-f.
          trxtmpl.crgl = tmpl.crgl. trxtmpl.crgl-f = tmpl.crgl-f.
          trxtmpl.crsub = tmpl.crsub. trxtmpl.crsub-f = tmpl.crsub-f.
          trxtmpl.cev = tmpl.cev. trxtmpl.cev-f = tmpl.cev-f.
          trxtmpl.cracc = tmpl.cracc. trxtmpl.cracc-f = tmpl.cracc-f.
          trxtmpl.rem[1] = tmpl.rem[1]. trxtmpl.rem-f[1] = tmpl.rem-f[1].
          trxtmpl.rem[2] = tmpl.rem[2]. trxtmpl.rem-f[2] = tmpl.rem-f[2].
          trxtmpl.rem[3] = tmpl.rem[3]. trxtmpl.rem-f[3] = tmpl.rem-f[3].
          trxtmpl.rem[4] = tmpl.rem[4]. trxtmpl.rem-f[4] = tmpl.rem-f[4].
          trxtmpl.rem[5] = tmpl.rem[5]. trxtmpl.rem-f[5] = tmpl.rem-f[5].
          trxtmpl.System = trxhead.System.
          trxtmpl.lgr = tmpl.lgr.
      end.
END procedure.

PROCEDURE trxlndel.
   message "Вы уверены что хотите удалить все линии?" view-as alert-box buttons YES-NO title ""
            update choice as logical.
case choice:
 when true then  

for each trxtmpl where trxtmpl.code = trxhead.system 
                                    + string(trxhead.code,"9999"):
    delete trxtmpl.
end.
end.

END procedure.
