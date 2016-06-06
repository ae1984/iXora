/* s-harchs.p
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
        31/12/2004 madiyar - раньше не выводились кредиты с ОД на других уровнях кроме первого
        31/05/2006 madiyar - перекомпиляция в связи с изменениями в s-harchs.f
        12/12/2008 galina - перекомпиляция
        25/03/2009 galina - добавила поле Поручитель
        23.04.2009 galina - убираем поле поручитель
*/

/*------------------------------------------------------------------------------
  #3.KredЁta izvёle kredЁta aprakst–

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
-----------------------------------------------------------------------------*/
{lonlev.i}
define shared frame cif.
define variable v-uno like uno.uno.
{s-harchs.f}.
define variable laiks as integer.
define variable visi as logical.
define shared variable gs-cif like cif.cif.

def var ost_act as deci init 0.
def var actcr as logical.

v-cif = gs-cif.
visi = no.
repeat on error undo,retry:
   update v-cif go-on("PF3") with frame lon.
      if lastkey = keycode("PF4")
      then leave.
      if lastkey = keycode("PF3")
      then do:
           visi = not visi.
           next.
      end.
   if length(trim(v-cif)) = 0
   then repeat:
        update v-lcnt go-on("PF3") with frame lon.
        if lastkey = keycode("PF4")
        then leave.
        if lastkey = keycode("PF3")
        then do:
             visi = not visi.
             next.
        end.
        if length(trim(v-lcnt)) > 0
        then find first loncon  where loncon.lcnt = v-lcnt
                                             no-lock.
        else repeat:
             prompt loncon.lon go-on("PF3") with frame lon.
             if lastkey = keycode("PF4")
             then leave.
             if lastkey = keycode("PF3")
             then do:
                  visi = not visi.
                  next.
              end.
              find loncon where loncon.lon =
                  input frame lon loncon.lon no-lock.
              leave.
        end.
        v-cif = loncon.cif.
        leave.
   end.
   if lastkey = keycode("PF4")
   then leave.
   find cif where cif.cif = v-cif no-lock.
   v-vards = trim(trim(cif.prefix) + " " + trim(cif.name)).
   display v-cif with frame lon.
   display v-vards with frame cif.
   leave.
end.
if lastkey = keycode("PF4")
then return.
gs-cif = cif.cif.
repeat:
   update s-dt go-on("PF3") with frame lon.
   if lastkey = keycode("PF3")
   then do:
        visi = not visi.
        next.
   end.
   leave.
end.
if lastkey = keycode("PF4")
then undo,return.
find last lonhar where lonhar.lon = cif.cif and lonhar.fdt < s-dt
     no-lock no-error.
if not available lonhar
then do:
     s-frez0 = ?.
     s-dtf1 = s-dt.
     s-akc = ?.
end.
else do:
     s-frez0 = lonhar.finrez.
     if s-frez0 = 999999999999.99
     then s-frez0 = ?.
     s-dtf1 = lonhar.fdt.
     s-akc = lonhar.akc.
end.
display s-frez0 s-dtf1 s-akc with frame lon.

if visi
then find first lon where lon.cif = v-cif no-lock no-error.
else do:
/*
     find first lon where lon.cif = v-cif and lon.dam[1] > lon.cam[1]
     no-lock no-error.
     if not available lon
     then do:
          visi = yes.
          find first lon where lon.cif = v-cif no-lock no-error.
     end.
end.
if not available lon
then do:
     bell.
     undo,retry.
*/
find first lon where lon.cif = v-cif no-lock no-error.
     
     if not available lon
     then do:
       bell.
       undo,retry.
     end.
     else do:
       if not (lon.dam[1] > lon.cam[1]) then do:
         ost_act = 0.
       
         for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
              if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
         end.
         
         if ost_act = 0 then do:
            actcr = yes.
            repeat while ost_act = 0 and actcr:
              find next lon where lon.cif = v-cif no-lock no-error.
              if avail lon then do:
                ost_act = 0.
                for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                  if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                end. 
              end.
              else actcr = no.
            end. /* repeat */
         end. /* if ost_act = 0 */
       end.  /* if not (lon.dam[1] > lon.cam[1]) */
     end.
          
     if not(actcr) then do:
          visi = yes.
          find first lon where lon.cif = v-cif no-lock no-error.
     end.

end.

find loncon  where loncon.lon = lon.lon no-lock no-error.
s-lon = loncon.lon.
v-lcnt = loncon.lcnt.
/*v-guarantor = trim(loncon.rez-char[8]).*/
readkey pause 0.
repeat:
    display loncon.lon with frame ln.
    pause 0.
    if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN")
    then do:
         if visi
         then find next lon where lon.cif = v-cif no-lock no-error.
         else /*find next lon where lon.cif = v-cif and lon.dam[1] >
              lon.cam[1] no-lock no-error.*/
              do:
                ost_act = 0.
                actcr = yes.
                repeat while ost_act = 0 and actcr:
                  find next lon where lon.cif = v-cif no-lock no-error.
                  if avail lon then do:
                    ost_act = 0.
                    for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                      if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                    end. 
                  end.
                  else actcr = no.
                end. /* repeat */
              end.
        if not available lon
         then do:
              if visi
              then find last lon where lon.cif = v-cif no-lock.
              else /*find last lon where lon.cif = v-cif and lon.dam[1] >
                   lon.cam[1] no-lock.*/
                   do:
                     find last lon where lon.cif = v-cif no-lock.
                     
                     if not (lon.dam[1] > lon.cam[1]) then do:
                        ost_act = 0.
                        
                        for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                            if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                        end.
                        
                        if ost_act = 0 then do:
                          actcr = yes.
                          repeat while ost_act = 0 and actcr:
                             find prev lon where lon.cif = v-cif no-lock no-error.
                             if avail lon then do:
                                ost_act = 0.
                                for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                                   if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                                end. 
                             end.
                             else actcr = no.
                          end.  /* repeat */
                        end.  /* if ost_act = 0 */
                     end.  /* if not (lon.dam[1] > lon.cam[1]) */
                     
                   end.
              find loncon where loncon.lon = lon.lon no-lock.
              display loncon.lon with frame ln.
              pause 0.
              {s-harchs.i}.
              choose row loncon.lon
                  go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3") with frame ln.
              pause 0.
              if lastkey <> keycode("RETURN")
              then color display normal loncon.lon with frame ln.
         end.
         else do:
              find loncon where loncon.lon = lon.lon no-lock.
              down with frame ln.
         end.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
    end.
    if lastkey = keycode("CURSOR-UP")
    then do:
         if visi
         then find prev lon where lon.cif = v-cif no-lock no-error.
         else /*find prev lon where lon.cif = v-cif and lon.dam[1] > lon.cam[1]
              no-lock no-error.*/
              do:
                ost_act = 0.
                actcr = yes.
                repeat while ost_act = 0 and actcr:
                  find prev lon where lon.cif = v-cif no-lock no-error.
                  if avail lon then do:
                     ost_act = 0.
                     for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                       if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                     end. 
                  end.
                  else actcr = no.
                end. /* repeat */
              end.
         if not available lon
         then do:
              if visi
              then find first lon where lon.cif = v-cif no-lock.
              else /*find first lon where lon.cif = v-cif and
                   lon.dam[1] > lon.cam[1] no-lock.*/
                   do:
                     find first lon where lon.cif = v-cif no-lock.
                     
                     if not (lon.dam[1] > lon.cam[1]) then do:
                        ost_act = 0.
                        
                        for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                           if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                        end.
                        
                        if ost_act = 0 then do:
                           actcr = yes.
                           repeat while ost_act = 0 and actcr:
                             find next lon where lon.cif = v-cif no-lock no-error.
                             if avail lon then do:
                               ost_act = 0.
                               for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                                 if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                               end. 
                             end.
                             else actcr = no.
                           end.  /* repeat */
                        end.  /* if ost_act = 0 */
                     end.  /* if not (lon.dam[1] > lon.cam[1]) */
                   end.
              find loncon  where loncon.lon = lon.lon no-lock.
         end.
         else do:
              find loncon where loncon.lon = lon.lon no-lock.
              up with frame ln.
         end.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
         {s-harchs.i}.
         display loncon.lon with frame ln.
         choose row loncon.lon
                go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3")  with frame ln.
         pause 0.
         if lastkey <> keycode("RETURN")
         then color display normal loncon.lon with frame ln.
    end.
    if lastkey = keycode("CURSOR-DOWN")
    then do:
         if visi
         then find next lon where lon.cif = v-cif no-lock no-error.
         else /*find next lon where lon.cif = v-cif and lon.dam[1] > lon.cam[1]
              no-lock no-error.*/
              do:
                ost_act = 0.
                actcr = yes.
                repeat while ost_act = 0 and actcr:
                   find next lon where lon.cif = v-cif no-lock no-error.
                   if avail lon then do:
                     ost_act = 0.
                     for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                       if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                     end. 
                   end.
                   else actcr = no.
                end. /* repeat */
              end.
         if not available lon
         then do:
              if visi
              then find last lon where lon.cif = v-cif no-lock.
              else /*find last lon where lon.cif = v-cif and lon.dam[1] >
                   lon.cam[1] no-lock.*/
                   do:
                     find last lon where lon.cif = v-cif no-lock.
                     
                     if not (lon.dam[1] > lon.cam[1]) then do:
                        ost_act = 0.
                        
                        for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                           if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                        end.
                        
                        if ost_act = 0 then do:
                          actcr = yes.
                          repeat while ost_act = 0 and actcr:
                            find prev lon where lon.cif = v-cif no-lock no-error.
                            if avail lon then do:
                               ost_act = 0.
                               for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
                                 if lookup(string(trxbal.level),v-lonprnlev,";") gt 0 then ost_act = ost_act + (trxbal.dam - trxbal.cam). 
                               end. 
                            end.
                            else actcr = no.
                          end.  /* repeat */
                        end.  /* if ost_act = 0 */
                     end.  /* if not (lon.dam[1] > lon.cam[1]) */
                   end.
         end.
         else down with frame ln.
         find loncon where loncon.lon  = lon.lon no-lock.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
         {s-harchs.i}.
         display loncon.lon with frame ln.
         choose row loncon.lon
         go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3") with frame ln.
         if lastkey <> keycode("RETURN")
         then color display normal loncon.lon with frame ln.
         pause 0.
    end.
    if lastkey = keycode("PF3")
    then do:
         pause 0.
         clear frame ln all.
         visi = not visi.
         if visi
         then find first lon where lon.cif = v-cif no-lock no-error.
         else find first lon where lon.cif = v-cif and lon.dam[1] >
              lon.cam[1] no-lock no-error.
         find loncon  where loncon.lon = lon.lon no-lock no-error.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
         s-lon = lon.lon.
         readkey pause 0.
    end.
    if lastkey = keycode("RETURN") or lastkey = keycode("PF1")
    then  do:
          hide frame ln.
          run atl-dat(lon.lon,s-dt,output dam1-cam1).
          find last ln%his where ln%his.lon = lon.lon and ln%his.stdat < s-dt
               no-lock no-error.
          if not available ln%his
          then find first ln%his where ln%his.lon = lon.lon no-lock.
          v-uno = lon.prnmos.
          display v-cif
                  v-lcnt
                  loncon.lon
                  s-longrp
                  v-uno
                  lon.crc
                  crc-code
                  loncon.objekts
                  ln%his.rdt
                  ln%his.duedt
                  ln%his.opnamt
                  dam1-cam1
                  ln%his.intrate
                  /*v-guarantor*/
                  lon.lcr
                  with frame lon.
          color display input dam1-cam1 with frame lon.
          display v-vards with frame cif.
          gs-cif = v-cif.
          return.
    end.
end.
