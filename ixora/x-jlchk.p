/* x-jlchk.p
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

/* x-jlchk.p

   01-30-95 Sushinin Vladimir - check after run new-arp.
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/
/*------------------------------------------------------------------------------
  #3.Papildin–ta subledgera LON kontrole
------------------------------------------------------------------------------*/
{global.i}
def shared var rtn as log.
def shared var s-jh like jh.jh.
def shared var s-jl like jl.ln.
def shared var vpart as log.
def shared var vcarry as dec.
def var vcif like cif.cif.
def var newacc as log initial false.
def var vans as log.
def buffer xaaa for aaa.
def var bila like aaa.cbal label "ATLIKUMS".
def var tt1 as char format "x(60)".
def var tt2 as char format "x(60)".


find jl where jl.jh = s-jh and jl.ln = s-jl.
find gl of jl.
find jh of jl.
vcif = jh.cif.

vans = false.
rtn  = true.
if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq jl.acc and ast.gl = jl.gl no-lock no-error.
    if not available ast
      then do:
        if gl.level = 1
          then do on error undo , return :
            vans = no.
            bell.
            {mesg.i 9803} update vans.
            if not vans then undo, retry.


            run new-ast.
            if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
            find ast where ast.ast eq jl.acc no-lock no-error.

            vpart = false.
            vcarry = -1 *  ast.amt[3].
            newacc = false.
          end.
          else do:
            bell.
            {mesg.i 9203}.
            rtn = true.
            return.
          end.
      end. /* if not available ast */
      else if jl.crc ne ast.crc
              or (gl.level eq 1 and jl.gl ne ast.gl)
              or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne ast.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
      else do: /* if available ast */
        {mesg.i 1809} ast.dam[1] - ast.cam[1].
        vpart = true.
      end.
  end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq jl.acc and bill.gl eq jl.gl no-lock no-error.
    if not available bill and gl.level ne 1
      then do:
        bell.
        {mesg.i 9201}.
            rtn = true.
            return.
      end.
    else if not available bill
      then do:
        vans = no.
        bell.
        {mesg.i 9804} update vans.
        if not vans then undo, retry.
        g-cif = jh.cif.
        run new-bill.
        if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
        g-cif = "".
        find bill where bill.bill eq jl.acc no-lock no-error.
        vpart = false.
        vcarry = - bill.payment.
        newacc = false.
      end.

    else if  jl.crc ne bill.crc
            or  (gl.level eq 1 and jl.gl ne bill.gl)
            or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne bill.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
    else if jh.cif ne "" and jh.cif ne bill.cif
      then do:
        bell.
        {mesg.i 6803}.
            rtn = true.
            return.
      end.
    else do:
      vpart = true.
      if gl.level = 1
        then vcarry = - bill.dam[1] + bill.cam[1].
      else if gl.level = 2
        then vcarry = bill.cam[2] - bill.interest.
    end.
      if bill.grp eq 1
        then jl.rem[1] = bill.lcno + "/"
                     + bill.refno.
        else jl.rem[1] =  bill.lcno + " "
                     + "DUE:" + string(bill.duedt) + " "
                     + string(bill.trm) + "D "
                     + string(bill.intrate) + "% " + bill.refno.
  end.
else if gl.subled eq "cif"
  then do:
    find aaa where aaa.aaa eq jl.acc and aaa.gl eq jl.gl no-lock no-error.
    if not available aaa
      then do:
        bell.
        {mesg.i 8800}.
            rtn = true.
            return.
      end.
    else if aaa.sta eq "C" then do:
      bell.
      {mesg.i 6207}.
      pause 4.
            rtn = true.
            return.
    end.
    /* overdraft */
    else find lgr where lgr.lgr = aaa.lgr and lgr.led = 'ODA'  no-lock
    no-error.
        if available lgr then do:
          bell.
          rtn = true.
          return.
        end.
    else if  jl.crc ne aaa.crc
              or (gl.level eq 1 and jl.gl ne aaa.gl)
              or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne aaa.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
    else if jh.cif ne "" and jh.cif ne aaa.cif
      then do:
        bell.
        {mesg.i 6803}.
            rtn = true.
            return.
      end.
    else do:
        form bila
           tt1 label "ПОЛНОЕS----"
           tt2 label "--НАИМЕНОВАНИЕ"
           cif.lname  label "КРАТКОЕ" format "x(60)"
           cif.pss   label "ИДЕНТ.КАРТА"
           cif.jss   label "РЕГ.НОМЕР"  format "x(13)"
           with overlay  1 column row 13 column 1 frame ggg.
       find cif of aaa no-lock.
          tt1 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),1,60).
          tt2 = substring(trim(trim(cif.prefix) + " " + trim(cif.name)),61,60).
      if aaa.craccnt ne "" then
        find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error .
      if available xaaa then do:
      if cif.cgr EQ 501 or cif.cgr EQ 502 then  do:
       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].

       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
      {mesg.i 0826} aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7]
      " Имя: " tt1.
      end.
      else do:
       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].

       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
      end.
      end.
      else do:
      if cif.cgr EQ 501 or cif.cgr EQ 502 then do:
       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].

       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
      {mesg.i 0826} aaa.cr[1] - aaa.dr[1] - aaa.hbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7]
      " Имя: " tt1.
      end.
      else do:
       bila =  aaa.cr[1] - aaa.dr[1] - aaa.hbal
       - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] - aaa.fbal[4]
       - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].
       disp  bila tt1 tt2 cif.lname cif.pss cif.jss with frame ggg.
      end.
      end.
      vpart = true.
    end.
end.
else if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq jl.acc and dfb.gl = jl.gl no-lock no-error.
    if not available dfb
      then do:
        bell.
        {mesg.i 8800}.
            rtn = true.
            return.
      end.

    else if   jl.crc ne dfb.crc
              or (gl.level eq 1 and jl.gl ne dfb.gl)
              or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne dfb.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
    else do:
      message dfb.name.
      vpart = true.
    end.
  end.
else if gl.subled eq "eps"
  then do:
    find eps where eps.eps eq jl.acc and eps.gl = jl.gl no-lock no-error.
    if not available eps
      then do:
        bell.
        {mesg.i 8800}.
            rtn = true.
            return.
      end.
    else if   jl.crc ne eps.crc
              or (gl.level eq 1 and jl.gl ne eps.gl)
              or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne eps.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
    else do:
      message eps.des. /* "Dr-Cr:" eps.dam[1] "-" eps.cam[1]. */
      vpart = false.
    /*  run epsvou. */
      pause 100.
      {x-jlvf.i}

      /*
      31/01/95 svl

      find last epsrec where epsrec.jh eq jl.jh and
        epsrec.eps eq jl.acc no-error.
      if available epsrec then do:
        find eps where eps.eps eq epsrec.eps.
        vcarry = - epsrec.amt.
        jl.rem[1] = epsrec.rem[1].
        jl.rem[2] = epsrec.rem[2].
        jl.rem[3] = epsrec.rem[3].
        jl.rem[4] = epsrec.rem[4].
        jl.rem[5] = epsrec.rem[5].
        end.
      else undo, retry.
      */
    end.
  end.
  
else if gl.subled eq "fun"
then do:
   if gl.level ne 3 then do:
      find fun where fun.fun eq jl.acc and fun.gl = jl.gl no-lock no-error.
      
      if not available fun and gl.level ne 1
      then do:
         bell.
         {mesg.i 9201}.
            rtn = true.
            return.
      end.
      
      else if not available fun
      then do:
         vans = no.
         bell.
         {mesg.i 9807} update vans.
         if not vans then undo, retry.
         g-cif = jh.cif.
         run new-fun.
         if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
         g-cif = "".
         find fun where fun.fun eq jl.acc no-lock no-error.
         if gl.type eq "A"
           then vcarry = - fun.amt.
           else vcarry = fun.amt.
         vpart = false.
      end.

      else if jl.crc ne fun.crc
          or (gl.level eq 1 and jl.gl ne fun.gl)
          or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne fun.gl)
          then do:
             bell.
             {mesg.i 2208}.
                rtn = true.
                return.
          end.
      else do:
        vpart = true.
        if gl.level = 1
        then do:
           vpart = false.
           vcarry =   fun.dam[1] - fun.cam[1].
        end.
        else if gl.level = 2
        then do:
          if gl.type eq "R"
            then vcarry = fun.cam[2] - fun.dam[2] - fun.interest.
            else vcarry = fun.cam[2] - fun.dam[2] + fun.interest.
        end.
      end.
      if fun.grp le 10
         then jl.rem[1] = fun.bank + " "
                        + "DUE:" + string(fun.duedt) + " "
                        + string(fun.trm) + "D "
                        + string(fun.intrate) + "% ".
   end. /*level ne 3 */
   else do:
       rtn = no.
       find fun where fun.fun eq jl.acc no-lock no-error.
       if available fun then do :
            find gl where gl.gl eq fun.gl no-lock no-error.
            if available gl then do :
               if gl.glacr ne jl.gl then do:
                  bell. message "Invalid account #.".
                  rtn = yes.
               end.
            end.
            else do:
               bell.
               message  "Not GL record available .".
               rtn = yes.
            end.
            if rtn then return.

            if fun.dam[3] <> fun.cam[3] then do :
               if jl.crc <> fun.ncrc[3] then do:
                  bell.
                  message  "Invalid currency .".
                  rtn = yes.
               end.
            end.
        end.
        else rtn = yes.
        find gl where gl.gl eq jl.gl.
        return.
   end. /* fun 3 level */
end.
/*
else if gl.subled eq "iof"
  then do:
    find iof where iof.iof eq jl.acc no-lock no-error.
    if not available iof
      then do:
        bell.
        {mesg.i 8800}.
        undo, retry.
      end.
    message iof.name /* "Dr-Cr:" iof.dam[1] "-" iof.cam[1]. */
    vpart = true.
  end.
*/
else if gl.subled eq "lcr"
  then do:
    if vcif = "" then do:
    bell.
    {mesg.i 2209}.
            rtn = true.
            return.
    end.
    find lcr where lcr.lcr eq jl.acc and lcr.gl = jl.gl no-lock no-error.
    if not available lcr and gl.level ne 1
      then do:
        bell.
        {mesg.i 9201}.
            rtn = true.
            return.
      end.
    else if not available lcr
        then do:
          {mesg.i 4801} update vans.
          if not vans then undo, retry.
          g-cif = jh.cif.
          run new-lcr.
          if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
          g-cif = "".
          {x-jlvf.i} /* view frame */
          find lcr where lcr.lcr eq jl.acc no-lock no-error.
          if not available lcr then do:
          bell.
            rtn = true.
            return.
         end.
    end.

    else if   jl.crc ne lcr.crc
              or  (gl.level eq 1 and jl.gl ne lcr.gl)
              or ((gl.level eq 2 and gl.gl1 ne 0 or
                   gl.level eq 3 and gl.gl1 ne 0)
              and gl.gl1 ne lcr.gl)
           then do:
             bell.
             {mesg.i 2208}.
            rtn = true.
            return.
           end.
    else if jh.cif ne "" and jh.cif ne lcr.cif
      then do:
        bell.
        {mesg.i 6803}.
            rtn = true.
            return.
    end.
    else do:
      {mesg.i 1809} lcr.dam[1] - lcr.cam[1] .
      vpart = true.
    end.
 end.
else if gl.subled eq "lon"
then do:
/* if vcif = "" then do:
    bell.
    {mesg.i 2209}.
            rtn = true.
            return.
    end. */
    if gl.level < 3
    then do:
         if gl.level = 1
         then do:
         find lon where lon.lon eq jl.acc and lon.gl = jl.gl no-lock no-error.
         if not available lon then do:
            bell. bell.
            {mesg.i 0229}.
            undo,retry.
         end.
         end.
         else find lon where lon.lon = jl.acc no-lock.
         /*
              if gl.level = 1
              then do:
                   vans = no.
                   bell. bell.
                   {mesg.i 3803} update vans.
                   if not vans then undo, retry.
                   run new-lon.
                   if rtn
                   then do :
                        bell. pause 2. undo, return .
                   end.
                   else rtn = yes.
                   find lon where lon.lon eq jl.acc no-lock no-error.
                   vpart = false.
                   vcarry = - lon.opnamt.
              end.
              else do:
                   find lon where lon.lon eq jl.acc no-lock no-error.
                   find gl where gl.gl = lon.gl no-lock.
                   if ( jl.gl ne gl.gl1 ) or ( jl.crc ne lon.crc ) then do:
                      bell. bell.
                      {mesg.i 9203}.
                      rtn = true.
                      return.
                   end.
              end.
         end.   if not available */

         /* else */ if   jl.crc ne lon.crc
                   or (gl.level eq 1 and jl.gl ne lon.gl)
                   /*
                   or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne lon.gl)
         */
         then do: 
              bell.
              {mesg.i 2208}.
              rtn = true.
              return.
         end.
         else if jh.cif ne "" and jh.cif ne lon.cif
         then do:
              bell.
              {mesg.i 6803}.
              rtn = true.
              return.
         end.
         else do:
              {mesg.i 1809} lon.dam[1] - lon.cam[1] .
              vpart = true.
              /* vcarry = lon.dam[1] - lon.cam[1]. */
         end.
         jl.rem[1] = "L/C#" + lon.lcr
                + " RATE:" + lon.base + "+" + string(lon.prem)
                + " DUE:" + string(lon.duedt).
    end.
    else do:
         find lon where lon.lon = jl.acc no-lock no-error.
         if not available lon or (gl.level > 3 and lon.crc <> jl.crc )
         then do:
              bell. bell.
              {mesg.i 2208}.
              rtn = true.
              return.
         end.
    end.
end.

else if gl.subled eq "ock"
then do:
   if gl.level ne 3 then do:
           find ock where ock.ock eq jl.acc and ock.gl = jl.gl no-lock no-error.

           if not available ock
      then do:
         if gl.level = 1
         then do:
            vans = no.
            bell.
            {mesg.i 9810} update vans.
            if not vans then undo, retry.
            run new-ock.
            if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
            find ock where ock.ock eq jl.acc no-lock no-error.
            vpart = false.
            vcarry = -1 * ock.amt.
            newacc = false.
         end.
          
         else do: bell. bell.
             {mesg.i 9203} " INVALID NUMBER...".
             rtn = true.
             return.
         end.   /* if gl.level ne 1 */

         vpart = false.
         vcarry = ock.amt.
         jl.rem[1] = ock.ref.
      end.  /* if not available ock */

      else do: /* if available ock */
         if jl.crc ne ock.crc
         or (gl.level eq 1 and jl.gl ne ock.gl)
         or ((gl.level eq 2 or gl.level eq 3) and gl.gl1 ne ock.gl)
         then do:
            bell.
            {mesg.i 2208}.
            rtn = true.
            return.
         end.

         if ock.spflag eq true
         then do:
             bell.
             {mesg.i 8820}.
             rtn = true.
             return.
         end.
         if ock.cam[1] le ock.dam[1] and gl.type eq "L"
         then do:
             bell.
             message "Atlikums = 0.".
             rtn = true.
             return.
         end.
         if ock.dam[1] lt ock.cam[1] and gl.type eq "A"
         then do:
            message ock.dam[1] ock.cam[1].
             bell.
             message "Atlikums = 0.".
             rtn = true.
             return.
         end.



         vpart = false.
         vcarry = ock.dam[1] - ock.cam[1].
      end. /* do */
   end. /* ock level ne 3 */
   else do:
        rtn = no.
        find ock where ock.ock eq jl.acc no-lock no-error.
        if available ock then do :
            find gl where gl.gl eq ock.gl no-lock no-error.
            if available gl then do :
               if gl.glacr ne jl.gl then do:
                  bell. message "Invalid account #.".
                  rtn = yes.
               end.
            end.
            else do:
               bell.
               message  "Not GL record available .".
               rtn = yes.
            end.
            if rtn then return.

            if ock.dam[3] ne ock.cam[3] then do :
               if jl.crc ne ock.ncrc[3] then do:
                  bell.
                  message  "Invalid currency .".
                  rtn = yes.
               end.
            end.
        end.
        else rtn = yes.
        find gl where gl.gl eq jl.gl.
        return.
   end.  /* ock 3 level */
end.  /* ock */

else if gl.subled eq "arp"
then do:
   if gl.level ne 3 then do :
            find arp where arp.arp eq jl.acc 
            /* and arp.gl = jl.gl */ no-lock no-error.
            if not available arp and gl.level ne 1
      then do:
              bell.
              {mesg.i 9201}.
         rtn = true.
         return.
      end.
            else if not available arp
      then do:
        vans = no.
        rtn = yes.
        bell.
        {mesg.i 1808} update vans.
        if not vans then undo,retry.
        g-cif = jh.cif.
        run new-arp.
        if rtn then do : bell. pause 2. undo, return . end. else rtn = yes.
        g-cif = "".
        find arp where arp.arp eq jl.acc no-lock no-error.
        if gl.type eq "A"
          then vcarry = arp.cam[1] - arp.dam[1].
          else vcarry = arp.dam[1] - arp.cam[1].
        vpart = false.
      end.

      else if jl.crc ne arp.crc  or (gl.level eq 1 and jl.gl ne arp.gl)
      then do:
         bell.
         {mesg.i 2208}.
         rtn = true.
         return.
      end.
      else do:
              vpart = true.
              if gl.level = 1
        then do:
            vpart = false.
            /* vcarry = arp.dam[1] - arp.cam[1]. */
        end.
      end.
   end. /* ne 3 */
   else do :  /* level 3 */
        rtn = no.
        find arp where arp.arp eq jl.acc no-lock no-error.
        if available arp then do :
            find gl where gl.gl eq arp.gl no-lock no-error.
            if available gl then do :
               if gl.glacr ne jl.gl then do:
                  bell. message "Invalid account #.".
                  rtn = yes.
               end.
            end.
            else do:
               bell.
               message  "Not GL record available .".
               rtn = yes.
            end.
            if rtn then return.

            if arp.dam[3] ne arp.cam[3] then do :
               if jl.crc ne arp.ncrc[3] then do:
                  bell.
                  message  "Invalid currency .".
                  rtn = yes.
               end.
            end.
        end.
        else rtn = yes.
        find gl where gl.gl eq jl.gl.
        return.
   end. /* arp 3 level */
end.

rtn = no.                                            
return.
