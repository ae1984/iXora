/* trxupd-f.i
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
        26/11/03 nataly добавлена обработка subledger SCU
        18/04/06 nataly добавлена обработка subledger TRF
        18/04/06 nataly добавлена обработка subledger TSF
*/

/* trxupd-f.i
   18/12/97 created                           J.Jansons
   03/07/98 added dfb subledger treatment     J.Jansons
   15/07/99 change fot cif subledger          V. Sushinin */
/*---------------------------------------------------------------------------*/
vdam = 0.
vcam = 0.

if jl.subled eq "arp" then do:
    find arp where arp.arp eq jl.acc exclusive-lock no-error.
     vcrc = arp.crc.
/*     if vcrc <> jl.crc then do:
        find fcrc where fcrc.crc = jl.crc no-lock.
        find tcrc where tcrc.crc = vcrc no-lock.
        if jl.dam > 0 then vdam = round(jl.dam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / tcrc.rate[9], tcrc.decpnt). 
        else vcam               = round(jl.cam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / fcrc.rate[9], tcrc.decpnt). 
     end.
     else do:     */
        vdam = jl.dam.
        vcam = jl.cam.
/*     end.       */
   if jl.lev <= 5 and arp.crc = jl.crc then do:  
     arp.dam[jl.lev] = arp.dam[jl.lev] - vdam.
     arp.cam[jl.lev] = arp.cam[jl.lev] - vcam.
   end.
   run trxupd-.
end.
else 
if jl.subled eq "ast" then do:
    find ast where ast.ast eq jl.acc exclusive-lock no-error.
     vcrc = ast.crc.
/*     if vcrc <> jl.crc then do:
        find fcrc where fcrc.crc = jl.crc no-lock.
        find tcrc where tcrc.crc = vcrc no-lock.
        if jl.dam > 0 then vdam = round(jl.dam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / tcrc.rate[9], tcrc.decpnt). 
        else vcam               = round(jl.cam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / fcrc.rate[9], tcrc.decpnt). 
     end.
     else do:     */
        vdam = jl.dam.
        vcam = jl.cam.
/*     end.       */
   if jl.lev <= 5 and ast.crc = jl.crc then do:  
     ast.dam[jl.lev] = ast.dam[jl.lev] - vdam.
     ast.cam[jl.lev] = ast.cam[jl.lev] - vcam.
   end.
   run trxupd-.
end.

else if jl.subled eq "cif" then do:
  find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.
    /*    ******* svl 15/07/99 ************
    if jl.lev eq 1 and aaa.crc = jl.crc 
      then do:
        find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.
        if not available aaa then undo,retry.
        if jl.aah gt 0 then do:
            find aah where aah.aah eq jl.aah.
            find aal of aah where aal.ln eq 1.
            find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
            s-aah = jl.aah.
            s-line = 1.
            run aaa-mns.
            aah.amt = aah.amt - aal.amt * aax.drcr.
            aal.amt = 0.
        end.
        else
        if jl.aah eq 0 then do:
            if jl.dc eq "D" then do:
                aaa.dr[1] = aaa.dr[1] - jl.dam.
                aaa.cbal = aaa.cbal + jl.dam.
            end.
            else do:
                aaa.cr[1] = aaa.cr[1] - jl.cam.
                aaa.cbal = aaa.cbal - jl.cam.
            end.
        end.
        if aaa.craccnt ne "" and jl.aah ge 0 then run updoda(aaa.aaa).
      end.
      else do:
        find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.
        vcrc = aaa.crc.
/*        if vcrc <> jl.crc then do:
           find fcrc where fcrc.crc = jl.crc no-lock.
           find tcrc where tcrc.crc = vcrc no-lock.
           if jl.dam > 0 then vdam = round(jl.dam * fcrc.rate[1] * tcrc.rate[9] 
                                   / tcrc.rate[1] / tcrc.rate[9], tcrc.decpnt). 
           else vcam               = round(jl.cam * fcrc.rate[1] * tcrc.rate[9] 
                                   / tcrc.rate[1] / fcrc.rate[9], tcrc.decpnt). 
        end.
        else do:           */
           vdam = jl.dam.
           vcam = jl.cam.
/*        end.             */
******* svl 15/07/99 ************
*/      
      if jl.lev ge 1 and jl.lev <= 5 and aaa.crc = jl.crc then do:  
         aaa.dr[jl.lev] = aaa.dr[jl.lev] - jl.dam.
         aaa.cr[jl.lev] = aaa.cr[jl.lev] - jl.cam.
         if jl.lev eq 1 then do:
            aaa.cbal = aaa.cbal + jl.dam - jl.cam.
            if jl.aax = 1 then  do:
               aaa.fbal[1] = aaa.fbal[1]  - jl.cam.
               aaa.cbal = aaa.cbal + jl.cam.
              end. 
         end.
      end.
 /* ******* svl 15/07/99 ************
      end.
 ******* svl 15/07/99 ************ */     
      vdam = jl.dam.
      vcam = jl.cam.
      run trxupd-.
/* TDA Special Teatment */
      if jl.consol then run tdaremhold(jl.acc, jl.cam).
/* End TDA */
end.
else if jl.subled eq "ock" then do:
find ock where ock.ock eq jl.acc exclusive-lock no-error.
     vcrc = ock.crc.
/*     if vcrc <> jl.crc then do:
        find fcrc where fcrc.crc = jl.crc no-lock.
        find tcrc where tcrc.crc = vcrc no-lock.
        if jl.dam > 0 then vdam = round(jl.dam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / tcrc.rate[9], tcrc.decpnt). 
        else vcam               = round(jl.cam * fcrc.rate[1] * tcrc.rate[9] 
                                / tcrc.rate[1] / fcrc.rate[9], tcrc.decpnt). 
     end.
     else do:      */
        vdam = jl.dam.
        vcam = jl.cam.
/*     end.        */
   if jl.lev <= 5 and ock.crc = jl.crc then do:  
     ock.dam[jl.lev] = ock.dam[jl.lev] - vdam.
     ock.cam[jl.lev] = ock.cam[jl.lev] - vcam.
   end.
   run trxupd-. 

/*Update turnovers in trxbal for specified level*/
/*
/*If no more non zero turnovers on any level then delete OCK subled*/ 
   find first trxbal where trxbal.subled = jl.subled
                     and trxbal.acc = jl.acc 
                     and (trxbal.dam > 0 or trxbal.cam > 0) no-lock no-error.
    if not available trxbal then do:
       for each trxbal where trxbal.subled = jl.subled
                       and trxbal.acc = jl.acc exclusive-lock:
           delete trxbal.
       end.
       find ock where ock.ock = jl.acc exclusive-lock no-error.
       if available ock then delete ock.
    end.
/*End of OCK subled deletion*/
*/
end.
else if jl.subled eq "dfb" then do:
find dfb where dfb.dfb eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and dfb.crc = jl.crc then do:  
      dfb.dam[jl.lev] = dfb.dam[jl.lev] - vdam.
      dfb.cam[jl.lev] = dfb.cam[jl.lev] - vcam.
    end.
    run trxupd-. /*Update turnovers in trxbal for specified level*/
end.
if jl.subled eq "eps" then do:
    find eps where eps.eps eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and eps.crc = jl.crc then do:  
      eps.dam[jl.lev] = eps.dam[jl.lev] - vdam.
      eps.cam[jl.lev] = eps.cam[jl.lev] - vcam.
    end.
    run trxupd-.
end.
if jl.subled eq "fun" then do:
    find fun where fun.fun eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and jl.crc = fun.crc then do:  
      fun.dam[jl.lev] = fun.dam[jl.lev] - vdam.
      fun.cam[jl.lev] = fun.cam[jl.lev] - vcam.
    end.
    run trxupd-.
end.
if jl.subled eq "scu" then do: /*26/11/03 nataly*/
    find scu where scu.scu eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and jl.crc = scu.crc then do:  
      scu.dam[jl.lev] = scu.dam[jl.lev] - vdam.
      scu.cam[jl.lev] = scu.cam[jl.lev] - vcam.
    end.
    run trxupd-.
end.                            /*26/11/03 nataly*/
if jl.subled eq "tsf" then do: /*18/04/06 nataly*/
    find tsf where tsf.tsf eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and jl.crc = tsf.crc then do:  
      tsf.dam[jl.lev] = tsf.dam[jl.lev] - vdam.
      tsf.cam[jl.lev] = tsf.cam[jl.lev] - vcam.
    end.
    run trxupd-.
end.                            /*26/11/03 nataly*/
if jl.subled eq "lon" then do:
    find lon where lon.lon eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 and jl.crc = lon.crc then do:  
      lon.dam[jl.lev] = lon.dam[jl.lev] - vdam.
      lon.cam[jl.lev] = lon.cam[jl.lev] - vcam.
    end.
    run trxupd-.
end.
