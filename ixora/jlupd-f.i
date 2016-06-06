/* jlupd-f.i
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
        14/02/2007 madiyar - поле lon.sts используем под статус кредита (погашен/не погашен), соотв. изменения
*/

/* jlupd-f.i
*/
/*------------------------------------------------------------------------------
  #3.Papildin–ta subledgera LON apstr–de
------------------------------------------------------------------------------*/
if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc exclusive-lock no-error.
    ast.dam[gl.level] = ast.dam[gl.level] - jl.dam.
    ast.cam[gl.level] = ast.cam[gl.level] - jl.cam.
/* lll */
    run astdel(jl.jh, jl.gl, jl.acc, jl.ln, jl.jdt, jl.dam, jl.cam).
    if ast.dam[gl.level] eq 0 and ast.cam[gl.level] eq 0 then  
     for each astjln where astjln.aast=ast.ast and astjln.ajh=0 use-index astdt:
       delete astjln.
     end.         
/* lll */

  end.

else if gl.subled eq "arp"
  then do:
    find arp where arp.arp eq jl.acc exclusive-lock no-error.
    arp.dam[gl.level] = arp.dam[gl.level] - jl.dam.
    arp.cam[gl.level] = arp.cam[gl.level] - jl.cam.
  end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq jl.acc exclusive-lock no-error.
    bill.dam[gl.level] = bill.dam[gl.level] - jl.dam.
    bill.cam[gl.level] = bill.cam[gl.level] - jl.cam.
  end.

else if gl.subled eq "cif"
  then do:
    if gl.level eq 1
      then do:
        find aaa where aaa.aaa eq jl.acc exclusive-lock no-error.
        if not available aaa then undo,retry.
/* u00121 26.10.2005
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
*/
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
        aaa.dr[gl.level] = aaa.dr[gl.level] - jl.dam.
        aaa.cr[gl.level] = aaa.cr[gl.level] - jl.cam.
      end.
  end.

else if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq jl.acc exclusive-lock no-error.
    dfb.dam[gl.level] = dfb.dam[gl.level] - jl.dam.
    dfb.cam[gl.level] = dfb.cam[gl.level] - jl.cam.
  end.

/* DISABLED FOR BATCH PROCESSING by SIMON Y. KIM
else if gl.subled eq "eck"
  then do:
    find eck where eck.eck eq jl.acc exclusive-lock no-error.
    eck.dam[gl.level] = eck.dam[gl.level] - jl.dam.
    eck.cam[gl.level] = eck.cam[gl.level] - jl.cam.
  end.
*/

else if gl.subled eq "eps"
  then do:
    find eps where eps.eps eq jl.acc exclusive-lock no-error.
    eps.dam[gl.level] = eps.dam[gl.level] - jl.dam.
    eps.cam[gl.level] = eps.cam[gl.level] - jl.cam.
  end.

else if gl.subled eq "fun"
  then do:
    find fun where fun.fun eq jl.acc exclusive-lock no-error.
    fun.dam[gl.level] = fun.dam[gl.level] - jl.dam.
    fun.cam[gl.level] = fun.cam[gl.level] - jl.cam.
  end.

/*
else if gl.subled eq "iof"
  then do:
    find iof where iof.iof eq jl.acc exclusive-lock no-error.
    iof.dam[gl.level] = iof.dam[gl.level] - jl.dam.
    iof.cam[gl.level] = iof.cam[gl.level] - jl.cam.
  end.
*/
else if gl.subled eq "lcr"
  then do:
    find lcr where lcr.lcr eq jl.acc exclusive-lock no-error.
    lcr.dam[gl.level] = lcr.dam[gl.level] - jl.dam.
    lcr.cam[gl.level] = lcr.cam[gl.level] - jl.cam.
  end.

if gl.subled eq "lon" or gl.subled = "cif" or gl.subled = "arp" or gl.subled = ""
then do:
     if gl.subled = "lon"
     then do:
          find lon where lon.lon eq jl.acc exclusive-lock no-error.
          if gl.level < 3
          then do:
               find lonsat where lonsat.jh = jl.jh and lonsat.ln = jl.ln
                    no-error. 
               if available lonsat
               then do:
                    find lonsa where lonsa.lon = lon.lon.
                    lonsa.dam = lonsa.dam - jl.dam.
                    lonsa.cam = lonsa.cam - jl.cam.
                    delete lonsat.
               end.
               else do:
                    if jl.tim = 0
                    then do:
                         lon.dam[gl.level] = lon.dam[gl.level] - jl.dam.
                         lon.cam[gl.level] = lon.cam[gl.level] - jl.cam.
                         /* if gl.level = 1 and jl.dc = "C" and lon.sts = 9 then lon.sts = 2. */
                    end.
                    run lnsch-(jl.jh, jl.gl, jl.acc, jl.tim, jl.jdt, jl.dam,
                               jl.cam).
               end.
          end.
          if  gl.level >= 3
          then run lonres-1(jl.jh,jl.ln).
     end.
    
     else if gl.subled = "arp" then do:
        /* Ja ARP karti‡a ir norakstЁtais kredЁts - Juris Omuls */
    
        find lon where lon.lon = jl.acc exclusive-lock no-error.
        if available lon
        then do:
         /*  if lon.sts = 9 and jl.dc = "C"
           then lon.sts = 8.*/
           find lonarp where lonarp.lon = jl.acc and lonarp.jh = jl.jh and 
                lonarp.ln = jl.ln and lonarp.gl = jl.gl no-error.
           if available lonarp
           then delete lonarp.
        end.
     end. /* arp */

     run jlupd-flon(jl.jh,jl.ln,jl.gl,jl.acc,jl.rem[5]).
     run jlupd-liz("-", jl.rem[5], 0, gl.subled, jl.jh, jl.gl, jl.dc, jl.cam,
         jl.dam, jl.who, jl.jdt, jl.crc, jl.acc, jl.ln).
end.

else if gl.subled eq "ock"
  then do:
    find ock where ock.ock eq jl.acc exclusive-lock no-error.
    ock.dam[gl.level] = ock.dam[gl.level] - jl.dam.
    ock.cam[gl.level] = ock.cam[gl.level] - jl.cam.
  end.
