/* trxupd-r.i
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
        24.09.2003 nadejda  - для LON убрала проверку на валюту проводки
        26/11/03 nataly добавлена обработка subledger SCU
        31/07/06 nataly добавлена обработка subledger TSF
*/

/****************************************************************************/
/* trxupd-r.i 
   18/12/97 created                          J.Jansons 
   03/07/98 added dfb subledger treatment    J.Jansons 
   15/07/99 change fot cif subledger          V. Sushinin */
/****************************************************************************/

vdam = 0.
vcam = 0.
if jl.subled eq "arp" then do:
  find arp where arp.arp eq jl.acc exclusive-lock no-error.
     vcrc = arp.crc.
        vdam = jl.dam.
        vcam = jl.cam. 

   if jl.lev <= 5 and jl.crc = arp.crc then do:  
     arp.dam[jl.lev] = arp.dam[jl.lev] + vdam.
     arp.cam[jl.lev] = arp.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.

if jl.subled eq "ast" then do:
  find ast where ast.ast eq jl.acc exclusive-lock no-error.
     vcrc = ast.crc.
        vdam = jl.dam.
        vcam = jl.cam.
   if jl.lev <= 5 and jl.crc = ast.crc 
   then do:  
     ast.dam[jl.lev] = ast.dam[jl.lev] + vdam.
     ast.cam[jl.lev] = ast.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.

else if jl.subled eq "cif"
  then do:
   find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.

       if jl.lev ge 1 and  jl.lev le 5 and aaa.crc eq jl.crc then do:  
            aaa.dr[jl.lev] = aaa.dr[jl.lev] + jl.dam.
            aaa.cr[jl.lev] = aaa.cr[jl.lev] + jl.cam.
            if jl.lev eq 1 then do:
                aaa.cbal = aaa.cbal - jl.dam + jl.cam.
                if jl.aax = 1 then   do:
                 aaa.fbal[1] = aaa.fbal[1]  + jl.cam.
                 aaa.cbal = aaa.cbal -  jl.cam .
                 end. 
            end.
       end.
       vdam = jl.dam.
       vcam = jl.cam.
       run trxupd+.

       if jl.consol then run tdasethold(jl.acc, jl.cam).

end.
else if jl.subled eq "ock" then do:
     find ock where ock.ock eq jl.acc exclusive-lock no-error.
     vcrc = ock.crc.
        vdam = jl.dam.
        vcam = jl.cam.

   if jl.lev <= 5 and ock.crc = jl.crc then do:  
     ock.dam[jl.lev] = ock.dam[jl.lev] + vdam.
     ock.cam[jl.lev] = ock.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.
else if jl.subled eq "dfb" then do:
   find dfb where dfb.dfb eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
   if jl.lev <= 5 and dfb.crc = jl.crc then do:  
     dfb.dam[jl.lev] = dfb.dam[jl.lev] + vdam.
     dfb.cam[jl.lev] = dfb.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.
else if jl.subled eq "eps" then do:
   find eps where eps.eps eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
   if jl.lev <= 5 and eps.crc = jl.crc then do:  
     eps.dam[jl.lev] = eps.dam[jl.lev] + vdam.
     eps.cam[jl.lev] = eps.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.
else if jl.subled eq "fun" then do:
   find fun where fun.fun eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
   if jl.lev <= 5 and fun.crc = jl.crc then do:  
     fun.dam[jl.lev] = fun.dam[jl.lev] + vdam.
     fun.cam[jl.lev] = fun.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.
else if jl.subled eq "scu" then do:   /*26/11/03 nataly*/
   find scu where scu.scu eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
   if jl.lev <= 5 and scu.crc = jl.crc then do:  
     scu.dam[jl.lev] = scu.dam[jl.lev] + vdam.
     scu.cam[jl.lev] = scu.cam[jl.lev] + vcam.
   end.
   run trxupd+.
end.                                 /*26/11/03 nataly*/
if jl.subled eq "lon" then do:
    find lon where lon.lon eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 /* and jl.crc = lon.crc    24.09.2003 nadejda */  then do:  
      lon.dam[jl.lev] = lon.dam[jl.lev] + vdam.
      lon.cam[jl.lev] = lon.cam[jl.lev] + vcam.
    end.
    run trxupd+.
end.
if jl.subled eq "tsf" then do:
    find tsf where tsf.tsf eq jl.acc exclusive-lock no-error.
        vdam = jl.dam.
        vcam = jl.cam.
    if jl.lev <= 5 /* and jl.crc = tsf.crc    24.09.2003 nadejda */  then do:  
      tsf.dam[jl.lev] = tsf.dam[jl.lev] + vdam.
      tsf.cam[jl.lev] = tsf.cam[jl.lev] + vcam.
    end.
    run trxupd+.
end.

