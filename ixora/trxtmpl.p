/* trxtmpl.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       01.09.2004 sasco добавил поиск
        04/12/08 marinav - увеличение формы для IBAN
*/

def new shared var s-codfr as char. 
def input parameter vcrec as recid.
def var vln as inte.
def var vcode as char.
def shared var g-ofc as char.
def shared var g-today as date.
def shared var g-lang as char.
def var vsystem as char.
def buffer btrxtmpl for trxtmpl.
def buffer b-trxtmpl for trxtmpl.
def new shared frame trxtmpl.
def new shared frame trxheader.
def var vname as char.
def var vparty as char.
def var vpoint as inte.
def var vdepart as inte.
def var rcode as inte.
def var rdes as char.
def temp-table wcod 
    field cod as char 
    field name as char
    field drcod as char
    field drcod-f as char
    field drname as char
    field crcod as char
    field crcode-f as char
    field crname as char.

find trxhead where recid(trxhead) = vcrec no-lock.
vcode = trxhead.system + string(trxhead.code,"9999").
vsystem = substring(vcode,1,3).
vname = trxhead.des.

{jabro.i
&start     = " "
&head      = "trxtmpl"
&headkey   = "ln"
&index     = "codln"
&formname  = "trxtmpl"
&framename = "trxtmpl"
&where     = "trxtmpl.code = vcode"
&addcon    = "true"
&deletecon = "true"
&precreate = "   vln = 0.
              for each btrxtmpl where btrxtmpl.code = vcode 
                                  no-lock break by btrxtmpl.ln:
                 if btrxtmpl.ln - vln > 1 then leave.
                 vln = btrxtmpl.ln.
              end.  vln = vln + 1."
&postadd   = " trxtmpl.system = vsystem.
               trxtmpl.code = vcode.
               trxtmpl.ln = vln.
               disp trxtmpl.ln with frame trxtmpl.
               next upper."
&prechoose = "disp trxtmpl.rem-f[1] trxtmpl.rem[1]
                   trxtmpl.rem-f[2] trxtmpl.rem[2]
                   trxtmpl.rem-f[3] trxtmpl.rem[3]                    
                   trxtmpl.rem-f[4] trxtmpl.rem[4]
                   trxtmpl.rem-f[5] trxtmpl.rem[5] with frame trxfooter. 
              disp trxhead.sts trxhead.sts-f
                   trxhead.party trxhead.party-f
                   trxhead.point trxhead.point-f
                   trxhead.depart trxhead.depart-f
                   trxhead.opt trxhead.opt-f
                   trxhead.mult trxhead.mult-f with frame trxheader.
              color disp input trxhead.sts-f trxhead.point-f
                    trxhead.depart-f trxhead.party-f
                    trxhead.mult-f trxhead.opt-f with frame trxheader.
message 
'f10-del,f4-exit,Enter-edit,H-header,F-footer,R-remarks,C-codif-rs,L-labels'."
&predisplay = " "
&display    = " trxtmpl.ln trxtmpl.amt trxtmpl.amt-f
                trxtmpl.crc trxtmpl.crc-f trxtmpl.rate trxtmpl.rate-f
                trxtmpl.drgl trxtmpl.drgl-f trxtmpl.drsub trxtmpl.drsub-f
                trxtmpl.dev trxtmpl.dev-f trxtmpl.dracc trxtmpl.dracc-f
                trxtmpl.crgl trxtmpl.crgl-f trxtmpl.crsub trxtmpl.crsub-f
                trxtmpl.cev trxtmpl.cev-f trxtmpl.cracc trxtmpl.cracc-f"
&highlight =  " trxtmpl.ln trxtmpl.amt trxtmpl.crc trxtmpl.rate 
                trxtmpl.drgl trxtmpl.drsub trxtmpl.dev trxtmpl.dracc 
                trxtmpl.crgl trxtmpl.crsub trxtmpl.cev trxtmpl.cracc"
&postkey   = "else if keyfunction(lastkey) = 'RETURN' then do transaction:
                  run trxupd2.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd3.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd4.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd5.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd6.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd6a.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd7.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd8.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd9.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd9a.
                  if keyfunction(lastkey) = 'end-error' then next upper.
                  run trxupd10.
                  next upper.
              end.
              else if keyfunction(lastkey) = 'R' then do transaction:
                  run trxupd12.
              end.
              else if keyfunction(lastkey) = 'F' then do transaction:
                  run trxupd13.
              end.
              else if keyfunction(lastkey) = 'C' then do transaction:
                  run trxupd14.
              end.
              else if keyfunction(lastkey) = 'H' then do transaction:
                  run trxupd11.
              end. 
              else if keyfunction(lastkey) = 'L' then do transaction:
                  run trxlabs. end. "
              
&end = "hide frame trxtmpl.
        hide frame trxheader.
        hide frame trxfooter."
}
hide message.
/*
PROCEDURE trxupd1.
do on error undo, retry:
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.amt-refln with frame trxtmpl.
 run trxchk(vcrec,crec,"empty",output rcode, output rdes).
 if rcode > 0 then do:
   message rdes.
   pause 3 no-message.
   undo, retry.
 end.
end.                   
END.
*/
PROCEDURE trxupd2.
do on error undo, retry:
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.amt trxtmpl.amt-f with frame trxtmpl.
        if trxtmpl.amt-f <> "d" then do:
           trxtmpl.amt = 0.
           disp trxtmpl.amt with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.amt-f, output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd3.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.crc trxtmpl.crc-f with frame trxtmpl.
        if trxtmpl.crc-f <> "d" then do:
           trxtmpl.crc = 0.
           disp trxtmpl.crc with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.crc-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.         

PROCEDURE trxupd4.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.rate trxtmpl.rate-f with frame trxtmpl.
        if trxtmpl.rate-f <> "d" then do:
           trxtmpl.rate = 0.
           disp trxtmpl.rate with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.rate-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.         
END.

PROCEDURE trxupd5.
do on error undo, retry:
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.drgl trxtmpl.drgl-f with frame trxtmpl.
        if trxtmpl.drgl-f <> "d" then do:
           trxtmpl.drgl = 0.
           disp trxtmpl.drgl with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.drgl-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd6.
do on error undo, retry:   
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.drsub trxtmpl.drsub-f with frame trxtmpl.
        if trxtmpl.drsub-f <> "d" then do:
           trxtmpl.drsub = "".
           disp trxtmpl.drsub with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.drsub-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd6a.
do on error undo, retry:   
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.dev trxtmpl.dev-f with frame trxtmpl.
        if trxtmpl.dev-f <> "d" then do:
           trxtmpl.dev = 0.
           disp trxtmpl.dev with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.dev-f, output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd7.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.dracc trxtmpl.dracc-f with frame trxtmpl.
        if trxtmpl.dracc-f <> "d" then do:
           trxtmpl.dracc = "".
           disp trxtmpl.dracc with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.dracc-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd8.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.crgl trxtmpl.crgl-f with frame trxtmpl.
        if trxtmpl.crgl-f <> "d" then do:
           trxtmpl.crgl = 0.
           disp trxtmpl.crgl with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.crgl-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd9.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.crsub trxtmpl.crsub-f with frame trxtmpl.
        if trxtmpl.crsub-f <> "d" then do:
           trxtmpl.crsub = "".
           disp trxtmpl.crsub with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.crsub-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd9a.
do on error undo, retry:   
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.cev trxtmpl.cev-f with frame trxtmpl.
        if trxtmpl.cev-f <> "d" then do:
           trxtmpl.cev = 0.
           disp trxtmpl.cev with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.cev-f, output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd10.
do on error undo, retry:         
find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
update  trxtmpl.cracc trxtmpl.cracc-f with frame trxtmpl.
        if trxtmpl.cracc-f <> "d" then do:
           trxtmpl.cracc = "".
           disp trxtmpl.cracc with frame trxtmpl.
        end.   
        run trxchk(vcrec,crec,trxtmpl.cracc-f,output rcode, output rdes).
        if rcode > 0 then do:
         message rdes.
         pause 3 no-message.
         undo, retry.
        end.
end.
END.

PROCEDURE trxupd11.  
    find trxhead where recid(trxhead) = vcrec exclusive-lock.
                update trxhead.sts trxhead.sts-f
                       trxhead.party trxhead.party-f
                       trxhead.point trxhead.point-f
                       trxhead.depart trxhead.depart-f
                       trxhead.mult trxhead.mult-f
                       trxhead.opt trxhead.opt-f with frame trxheader. 
END.

PROCEDURE trxupd12.
    find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
                update trxtmpl.rem[1] trxtmpl.rem-f[1]
                       trxtmpl.rem[2] trxtmpl.rem-f[2]
                       trxtmpl.rem[3] trxtmpl.rem-f[3]
                       trxtmpl.rem[4] trxtmpl.rem-f[4]
                       trxtmpl.rem[5] trxtmpl.rem-f[5]
                        with frame trxfooter.
END.

PROCEDURE trxupd13.
    find trxtmpl where recid(trxtmpl) = crec exclusive-lock.
         update trxtmpl.rem[1] trxtmpl.rem-f[1] with frame trxfooter.
           if frame trxfooter trxtmpl.rem[1] entered
              or frame trxfooter trxtmpl.rem-f[1] entered then do:
                for each b-trxtmpl where b-trxtmpl.code = trxtmpl.code
                         and recid(b-trxtmpl) <> crec:
                  b-trxtmpl.rem[1] = trxtmpl.rem[1].
                  b-trxtmpl.rem-f[1] = trxtmpl.rem-f[1].
                end.
           end.
         update trxtmpl.rem[2] trxtmpl.rem-f[2] with frame trxfooter.
           if frame trxfooter trxtmpl.rem[2] entered
              or frame trxfooter trxtmpl.rem-f[2] entered then do:
                for each b-trxtmpl where b-trxtmpl.code = trxtmpl.code
                         and recid(b-trxtmpl) <> crec:
                  b-trxtmpl.rem[2] = trxtmpl.rem[2].
                  b-trxtmpl.rem-f[2] = trxtmpl.rem-f[2].
                end.
           end.
         update trxtmpl.rem[3] trxtmpl.rem-f[3] with frame trxfooter.
           if frame trxfooter trxtmpl.rem[3] entered
              or frame trxfooter trxtmpl.rem-f[3] entered then do:
                for each b-trxtmpl where b-trxtmpl.code = trxtmpl.code
                         and recid(b-trxtmpl) <> crec:
                  b-trxtmpl.rem[3] = trxtmpl.rem[3].
                  b-trxtmpl.rem-f[3] = trxtmpl.rem-f[3].
                end.
           end.
         update trxtmpl.rem[4] trxtmpl.rem-f[4] with frame trxfooter.
           if frame trxfooter trxtmpl.rem[4] entered
              or frame trxfooter trxtmpl.rem-f[4] entered then do:
                for each b-trxtmpl where b-trxtmpl.code = trxtmpl.code
                         and recid(b-trxtmpl) <> crec:
                  b-trxtmpl.rem[4] = trxtmpl.rem[4].
                  b-trxtmpl.rem-f[4] = trxtmpl.rem-f[4].
                end.
           end.
         update trxtmpl.rem[5] trxtmpl.rem-f[5] with frame trxfooter.
           if frame trxfooter trxtmpl.rem[5] entered
              or frame trxfooter trxtmpl.rem-f[5] entered then do:
                for each b-trxtmpl where b-trxtmpl.code = trxtmpl.code
                         and recid(b-trxtmpl) <> crec:
                  b-trxtmpl.rem[5] = trxtmpl.rem[5].
                  b-trxtmpl.rem-f[5] = trxtmpl.rem-f[5].
                end.
           end.
END.

PROCEDURE trxupd14.

 find sysc where sysc.sysc = "trxcdf" no-lock no-error.
 for each wcod:
   delete wcod.
 end.
 for each codific no-lock:
    if available sysc then if index(sysc.chval,codific.codfr) <= 0 then next. 
    create wcod.
    wcod.cod = codific.codfr.
    wcod.name = codific.name.
    find trxcdf where trxcdf.trxcode = trxtmpl.code 
                  and trxcdf.trxln = trxtmpl.ln 
                  and trxcdf.codfr = codific.codfr no-lock no-error.
    if available trxcdf then do:
       wcod.drcod = trxcdf.drcod.
       wcod.drcod-f = trxcdf.drcod-f.
       wcod.crcod = trxcdf.crcod.
       wcod.crcode-f = trxcdf.crcode-f.
    end.
    else do:
       wcod.drcod = "msc".
       wcod.drcod-f = "".                              
       wcod.crcod = "msc".
       wcod.crcode-f = "".
    end.
    find codfr where codfr.codfr = codific.codfr 
                 and codfr.code = wcod.drcod no-lock no-error.
    if not available codfr then do:
         create codfr.
         codfr.codfr = codific.codfr.
         codfr.code = wcod.drcod.
         codfr.name[1] = "Остальные" .
    end.
         wcod.drname = codfr.name[1].
         
    find codfr where codfr.codfr = codific.codfr 
                 and codfr.code = wcod.crcod no-lock no-error.
    if not available codfr then do:
         create codfr.
         codfr.codfr = codific.codfr.
         codfr.code = wcod.drcod.
         codfr.name[1] = "Остальные".
    end.
    wcod.crname = codfr.name[1].
 end. 

  {jabre.i
   &start = " on help of wcod.drcod in frame trxcdf do:
                  run trx-help1.
              end.    
              on help of wcod.crcod in frame trxcdf do:
                  run trx-help1.
              end."    

   &head = "wcod"
   &headkey = "cod"
   &where = "true"
   &formname = "trxcdf"
   &framename = "trxcdf"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F4-exit; Enter-edit'. "
   &predisplay = " "
   &display = "wcod.cod wcod.name wcod.drcod wcod.drcod-f wcod.drname wcod.crcod wcod.crcode-f wcod.crname"
   &highlight = "wcod.cod wcod.name wcod.drcod wcod.drname wcod.crcod wcod.crname"
   &postkey = "else if keyfunction(lastkey) = 'return' then do:
                s-codfr = wcod.cod.
                update wcod.drcod with frame trxcdf. 
                find codfr where codfr.codfr = wcod.cod
                             and codfr.code = wcod.drcod no-lock.
                wcod.drname = codfr.name[1].
                disp wcod.drname with frame trxcdf.
                update wcod.drcod-f with frame trxcdf.
                update wcod.crcod with frame trxcdf.
                find codfr where codfr.codfr = wcod.cod
                             and codfr.code = wcod.crcod no-lock.
                wcod.crname = codfr.name[1].
                disp wcod.crname with frame trxcdf.
                update wcod.crcode-f with frame trxcdf.
                if   frame trxcdf wcod.drcod entered 
                  or frame trxcdf wcod.crcod entered 
                  or frame trxcdf wcod.drcod-f entered
                  or frame trxcdf wcod.crcode-f entered then do: 
                  find trxcdf where trxcdf.trxcode = trxtmpl.code 
                        and trxcdf.trxln = trxtmpl.ln 
                        and trxcdf.codfr = wcod.cod exclusive-lock no-error.
                  if available trxcdf then do:
                     trxcdf.drcod = wcod.drcod.
                     trxcdf.drcod-f = wcod.drcod-f.
                     trxcdf.crcod = wcod.crcod.
                     trxcdf.crcode-f = wcod.crcode-f.
                     trxcdf.who = g-ofc.
                     trxcdf.whn = g-today.
                  end.
                  else do:
                     create trxcdf.
                     trxcdf.trxcode = trxtmpl.code.
                     trxcdf.trxln = trxtmpl.ln.
                     trxcdf.codfr = wcod.cod.
                     trxcdf.drcod = wcod.drcod.
                     trxcdf.drcod-f = wcod.drcod-f.
                     trxcdf.crcod = wcod.crcod.
                     trxcdf.crcode-f = wcod.crcode-f.
                     trxcdf.who = g-ofc.
                     trxcdf.whn = g-today.
                  end.
                 release trxcdf.     
                end. 
               end."
   &end = "hide frame trxcdf."
}
END procedure.
 
 def temp-table b-labs field code like trxtmpl.code field ln like trxtmpl.ln 
 field lf as int 
 field fld as cha field des as cha format "x(60)". 
   
Procedure trxlabs.
 def var i as int .
 def var n as int . 
 def var vh as widget-handle . 
 def var vhs as widget-handle .
 vhs = frame trxtmpl:first-child . 
 vh = vhs:first-child .
 repeat : 
   if trim(vh:screen-value) = trim(string(trxtmpl.ln,'99')) then leave .
   vhs = vhs:NEXT-SIBLING  .
   vh = vhs:first-child .
 end.
 i = 0 . 
 n = 0 . 

 repeat:
  i = i + 1 . 
  if vh:screen-value = "r" then do:
     n = n + 1 .
       find first trxlabs where
       trxlabs.code = trxtmpl.code and
       trxlabs.ln = trxtmpl.ln and
       trxlabs.lf = i  and
       trxlabs.fld = vh:name  no-lock no-error . 
   if not avail  trxlabs then do:
    create trxlabs . 
    trxlabs.code = trxtmpl.code . 
    trxlabs.ln = trxtmpl.ln . 
    trxlabs.lf = i . 
    trxlabs.fld = vh:name .  
   end.   
  end. 
  else 
  do:
   find first trxlabs where
   trxlabs.code = trxtmpl.code and
   trxlabs.ln = trxtmpl.ln and
   trxlabs.lf = i  and
   trxlabs.fld = vh:name  exclusive-lock no-error .
   if avail trxlabs then delete trxlabs . 
  end.
   vh = vh:NEXT-SIBLING .
   if not valid-handle(vh) then leave .  
 end.

/*Added by ja for codificators labels processing */  
   for each trxcdf where trxcdf.trxcode = trxtmpl.code
                     and trxcdf.trxln = trxtmpl.ln:
      if trxcdf.drcod-f = "r" then do:               
         find first trxlabs where
         trxlabs.code = trxtmpl.code and
         trxlabs.ln = trxtmpl.ln and
         trxlabs.lf = 98  and
         trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error . 
       if not avail  trxlabs then do:
         create trxlabs . 
         trxlabs.code = trxtmpl.code . 
         trxlabs.ln = trxtmpl.ln . 
         trxlabs.lf = 98. 
         trxlabs.fld = trxcdf.codfr + "_Dr".  
       end.
      end.
      else do:
         find first trxlabs where
         trxlabs.code = trxtmpl.code and
         trxlabs.ln = trxtmpl.ln and
         trxlabs.lf = 98  and
         trxlabs.fld = trxcdf.codfr + "_Dr" exclusive-lock no-error.
         if available trxlabs then delete trxlabs. 
      end.     
      if trxcdf.crcode-f = "r" then do:               
         find first trxlabs where
         trxlabs.code = trxtmpl.code and
         trxlabs.ln = trxtmpl.ln and
         trxlabs.lf = 99  and
         trxlabs.fld = trxcdf.codfr + "_Cr" no-lock no-error . 
       if not avail  trxlabs then do:
         create trxlabs . 
         trxlabs.code = trxtmpl.code . 
         trxlabs.ln = trxtmpl.ln . 
         trxlabs.lf = 99. 
         trxlabs.fld = trxcdf.codfr + "_Cr".  
       end.
      end.
      else do:
         find first trxlabs where
         trxlabs.code = trxtmpl.code and
         trxlabs.ln = trxtmpl.ln and
         trxlabs.lf = 99  and
         trxlabs.fld = trxcdf.codfr + "_Cr" exclusive-lock no-error.
         if available trxlabs then delete trxlabs. 
      end.     
   end.
/*End of changes */    

 def query q1 for trxlabs .
 DEFINE BROWSE b1 QUERY q1 
 DISPLAY trxlabs.lf format "99" label "N/N" trxlabs.fld 
  label "Поле" format "x(10)" 
  trxlabs.des format "x(55)" 
  label " Наименование" 
  enable des  with 5 down . /* centered overlay row 10 
  title "For Ln = " + string(trxtmpl.ln) .  */
 def frame f1 b1 with centered overlay row 10 
   title "For Ln = " + string(trxtmpl.ln).  
 open query q1 for each trxlabs where 
    trxlabs.code = trxtmpl.code and
    trxlabs.ln = trxtmpl.ln . 
 message " < F4 > - exit " . 
 enable b1 with frame f1 .
 wait-for end-error of b1 .
 disable b1 with frame f1 . 
 hide frame  f1 .
end procedure .
  
       
    

