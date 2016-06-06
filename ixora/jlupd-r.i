/* jlupd-r.i
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

 /* jlupd-r.i
*/
/*------------------------------------------------------------------------------
  #3.Papildin–ta subledgera LON apstr–de
------------------------------------------------------------------------------*/

if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc exclusive-lock no-error.
    ast.dam[gl.level] = ast.dam[gl.level] + jl.dam.
    ast.cam[gl.level] = ast.cam[gl.level] + jl.cam.
end.

else if gl.subled eq "arp" then do:
  find arp where arp.arp eq jl.acc exclusive-lock no-error.
  arp.ncrc[gl.level] = jl.crc.
  arp.dam[gl.level] = arp.dam[gl.level] + jl.dam.
  arp.cam[gl.level] = arp.cam[gl.level] + jl.cam.

  if (arp.dam[gl.level] lt arp.cam[gl.level] and gl.type eq "A" or
     arp.cam[gl.level] lt arp.dam[gl.level] and gl.type eq "L") then do:
    bell.
    {mesg.i 0888}.
    pause.
    undo , retry.
  end.

end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq jl.acc exclusive-lock no-error.
    bill.dam[gl.level] = bill.dam[gl.level] + jl.dam.
    bill.cam[gl.level] = bill.cam[gl.level] + jl.cam.
    if gl.level eq 1 and bill.dam[1] - bill.cam[1] lt 0
      then do:
        bell.
/*      {mesg.i 0888}. */
        pause.
        undo , retry.
    end.
end.
else if gl.subled eq "cif"
  then do:
/*
       if gl.level eq 1
         then do:
              if jl.aah eq 0
                then do :
                     run aah-num.
                     find aah where aah.aah eq s-aah.
                     aah.crc = jl.crc.
                     jl.aah = s-aah.
                     create aal.
                     aal.aah = jl.aah.
                     aal.ln = 1.
                     aal.crc = jl.crc.
                     aal.jh = jl.jh.
              end.
              else do :  
                   find aah where aah.aah eq jl.aah.
                   find aal of aah where aal.ln eq 1.
              end.
              aah.aaa = jl.acc.
              find aaa where aaa.aaa eq aah.aaa no-lock.
              aah.lgr = aaa.lgr.
              aal.aaa = jl.acc.
              aal.lgr = aaa.lgr.
              if jl.dc eq "D"
                then do:
                     aal.aax = 21.
                     aal.amt = jl.dam.
              end.
              else do:
                   aal.aax = 71.
                   aal.amt = jl.cam.
              end.
              aal.regdt = g-today.
              aal.who = g-ofc.
              aal.whn = today.
              aal.tim = time.
              aal.stn = 9.
              find aax where aax.lgr eq aal.lgr and aax.ln eq aal.aax.
              s-aah = jl.aah.
              s-line = 1.
              run aaa-pls.
              find aal where aal.aah eq jl.aah and aal.ln  eq 1.
              if aal.sta eq "RJ"
                then do:
                     {mesg.i 0888}.
                     pause 2.
                     undo, retry.
              end.
              jl.bal = aaa.cr[1] - aaa.dr[1].
              aah.amt = aah.amt + aal.amt * aax.drcr.
              aah.bal = aaa.cr[1] - aaa.dr[1].
              aal.bal = aaa.cr[1] - aaa.dr[1].
       end.
       else 
*/
	do:
            find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.
            aaa.dr[gl.level] = aaa.dr[gl.level] + jl.dam.
            aaa.cr[gl.level] = aaa.cr[gl.level] + jl.cam.
       end.
end.

else if gl.subled eq "dfb"
  then do:
       find dfb where dfb.dfb eq jl.acc exclusive-lock no-error.
       dfb.dam[gl.level] = dfb.dam[gl.level] + jl.dam.
       dfb.cam[gl.level] = dfb.cam[gl.level] + jl.cam.
    
  /*  if ( gl.level eq 3 ) and 
       (dfb.dam[gl.level] lt dfb.cam[gl.level] and gl.type eq "A" or
        dfb.cam[gl.level] lt dfb.dam[gl.level] and gl.type eq "L") then do:
        bell.
        {mesg.i 0888}.
        pause.
        undo , retry.
    end. */
end.

/* DISABLED FOR BATCH PROCESSING by SIMON Y. KIM
else if gl.subled eq "eck"
  then do:
       find eck where eck.eck eq jl.acc exclusive-lock no-error.
       eck.dam[gl.level] = eck.dam[gl.level] + jl.dam.
       eck.cam[gl.level] = eck.cam[gl.level] + jl.cam.
end.
*/

else if gl.subled eq "eps"
  then do:
       find eps where eps.eps eq jl.acc exclusive-lock no-error.
       eps.dam[gl.level] = eps.dam[gl.level] + jl.dam.
       eps.cam[gl.level] = eps.cam[gl.level] + jl.cam.
end.

else if gl.subled eq "fun"
then do:
       find fun where fun.fun eq jl.acc exclusive-lock no-error.
       fun.ncrc[gl.level] = jl.crc.
       fun.dam[gl.level] = fun.dam[gl.level] + jl.dam.
       fun.cam[gl.level] = fun.cam[gl.level] + jl.cam.
       
       if gl.type eq "A" and fun.dam[gl.level] - fun.cam[gl.level] lt 0
       then do:
          bell.
          {mesg.i 0888}.
          undo, retry.
       end.
       else if gl.type eq "L" and fun.cam[gl.level] - fun.dam[gl.level] lt 0
       then do:
          bell.
          {mesg.i 0888}.
          undo, retry.
       end.
end.

/*
else if gl.subled eq "iof"
  then do:
       find iof where iof.iof eq jl.acc exclusive-lock no-error.
       iof.dam[gl.level] = iof.dam[gl.level] + jl.dam.
       iof.cam[gl.level] = iof.cam[gl.level] + jl.cam.
end.
*/

else if gl.subled eq "lcr"
  then do:
       find lcr where lcr.lcr eq jl.acc exclusive-lock no-error.
       lcr.dam[gl.level] = lcr.dam[gl.level] + jl.dam.
       lcr.cam[gl.level] = lcr.cam[gl.level] + jl.cam.
       if gl.level eq 1 and lcr.dam[1] - lcr.cam[1] lt 0
         then do:
              bell.
              {mesg.i 0888}.
              undo, retry.
       end.
end.

if gl.subled = "lon" or gl.subled = "cif" or gl.subled = "arp" or gl.subled = ""
then do:
     if gl.subled = "lon"
     then do:
          find lon where lon.lon = jl.acc exclusive-lock no-error.
          if gl.level < 3
          then do:
               if jl.tim = 0 
               then do:
                    lon.dam[gl.level] = lon.dam[gl.level] + jl.dam.
                    lon.cam[gl.level] = lon.cam[gl.level] + jl.cam.
                    if gl.level eq 1 and lon.dam[1] - lon.cam[1] lt 0
                    then do:
                         bell.
                         {mesg.i 0888}.
                         undo, retry.
                    end.
               end.
        
               run lnsch+(jl.jh, jl.gl, jl.acc, jl.tim, jl.jdt, jl.dam, jl.cam).
          end.
          if gl.level >= 3
          then do:
               if gl.level = 3
               then do:
                    if lon.cam[3] - lon.dam[3] <> 0 and jl.crc <> lon.prnyrs
                    then do:
                         bell.
                         {mesg.i 0998}.
                         pause.
                         undo,retry.
                    end.
               end.
               run lonres+1(jl.jh,jl.ln).
          end.
     end.
     run jlupd-rlon(jl.jh,jl.ln,jl.gl,jl.acc,jl.dc,jl.rem[5]).
     /*run jlupd-liz("+", jl.rem[5], 0, gl.subled, jl.jh, jl.gl, jl.dc, jl.cam,
         jl.dam, jl.who, jl.jdt, jl.crc, jl.acc, jl.ln).*/
end.

else if gl.subled eq "ock"
  then do:
       find ock where ock.ock eq jl.acc exclusive-lock no-error.
       ock.ncrc[gl.level] = jl.crc.
       ock.dam[gl.level] = ock.dam[gl.level] + jl.dam.
       ock.cam[gl.level] = ock.cam[gl.level] + jl.cam.
       
    if ( gl.level eq 3 ) and 
       (ock.dam[gl.level] lt ock.cam[gl.level] and gl.type eq "A" or
        ock.cam[gl.level] lt ock.dam[gl.level] and gl.type eq "L") then do:
        bell.
        {mesg.i 0888}.
        pause.
        undo , retry.
    end.
end.
