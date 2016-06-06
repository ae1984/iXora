/* H11btrz_ps.p
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
        18.12.2005 tsoy     - добавил время создания платежа.
*/

{Hvars_ps.i }
{global.i }
{lgps.i }

define input parameter trz-num as int .

def var a1 as char .

/*do on error undo  :*/
     create remtrz .
     run n-remtrz.                     /* !!!!!!!!!!!!!!!! */
     remtrz.t_sqn = num[1] .
     remtrz.rdt = today .
     remtrz.remtrz = s-remtrz .
     remtrz.valdt1 = v-date .
     remtrz.saddr = tradr .
     remtrz.sacc = v-acc  .
     remtrz.tcrc = v-crc .
     remtrz.payment = v-amt .
     remtrz.amt = v-amt .
     if trz-num = 1 then do:
      trz1 = remtrz.remtrz .
      remtrz.svccgr = 527 .
     end .
     else do :
     /*-----------nado dodelat'-!-------------------*/
      trz2 = remtrz.remtrz .
      remtrz.svcrc = v-crc .
      if v-crc = 1 then do :
       remtrz.svccgr = 401 .
      end .
      else do :
       remtrz.svccgr = 402 .
      end .
      find first aaa where aaa.aaa = v-acc no-lock no-error.
      run perev(string(remtrz.svccgr),remtrz.payment,remtrz.tcrc,remtrz.svcrc,
        aaa.cif, output remtrz.payment, output snpgl2, output a1) .
      if remtrz.payment = 0 then do :
       trz2 = "single    " .
       delete remtrz .
       return .
      end .
      remtrz.amt = remtrz.payment .
      remtrz.svccgr = 0 .
     /*-----------nado dodelat'-^-------------------*/
     end .
     remtrz.dracc = v-acc  .
     find first aaa where aaa.aaa = v-acc no-lock no-error .
     remtrz.drgl = aaa.gl .
     remtrz.fcrc = v-crc .
     remtrz.jh1   = ?  . remtrz.jh2 = ? .
     remtrz.ord = v-ord .
     if remtrz.ord = ? then do:
        run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "H11btrz_ps.p 73", "1", "", "").
     end.
     remtrz.bb[1]  = "/" + substr(v-bb,1,35) .
     remtrz.bb[2]  = substr(v-bb,36,35) .
     remtrz.bb[3]  = substr(v-bb,71,70) .

     remtrz.intmed = v-intmed  .
     remtrz.intmedact  = v-intmedact  .

     remtrz.actins[1]  = "/" + substr(v-bb,1,35) .
     remtrz.actins[2]  = substr(v-bb,36,35) .
     remtrz.actins[3]  = substr(v-bb,71,35) .
     remtrz.actins[4]  = substr(v-bb,106,35) .

     remtrz.bn[1] = substr(v-ben,1,60) .
     remtrz.bn[2] = substr(v-ben,61,60) .
     remtrz.bn[3] = substr(v-ben,121,60) .
     remtrz.rcvinfo[1] = substr(v-info,1,35) .
     remtrz.rcvinfo[2] = substr(v-info,36,35) .
     remtrz.rcvinfo[3] = substr(v-info,71,35) .
     remtrz.rcvinfo[4] = substr(v-info,106,35) .
     remtrz.rcvinfo[5] = substr(v-info,141,35) .
     remtrz.rcvinfo[6] = substr(v-info,176,35) .
     remtrz.info[3] = v-info3 .

     remtrz.ba = v-ba .
     if not remtrz.ba begins  "/" then remtrz.ba = "/" + remtrz.ba .
     remtrz.bi = v-chg .
     remtrz.margb = 0.
     remtrz.margs = 0.
     remtrz.svca   = 0.
     remtrz.svcaaa = "".
     remtrz.svcmarg = 0.
     remtrz.svcp = 0.
     remtrz.svcrc = 0.
     remtrz.svccgl = 0.
     remtrz.svcgl = 0.
     if trz-num = 1 then do :
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
     end .
/*     remtrz.svccgr = 527 . ----------*/
/*     find first crchs where crchs.crc = remtrz.fcrc no-lock .*/
/*------------------------------- nado men'at'-!--------------------*/
/*     if m-typ = "10B" and v-crc = 1 then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      find bankl where bankl.bank = v-bank no-lock no-error.
      if avail bankl then do:
       if bankl.nu = "u"
        then remtrz.svccgr = 501 .
        else do:
         if v-pri = "n" then
             remtrz.svccgr = 502 .
         else if v-pri = "u" then
             remtrz.svccgr = 503 .
        end.
      end.
     end.
     else
     if  ( m-typ eq "10E" and v-crc = 1 ) or crchs.hs = "h" then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      find bankl where bankl.bank = v-bank no-lock no-error.
      if avail bankl then do:
       if bankl.nu = "u"
        then remtrz.svccgr = 501 .
       else do:
        if v-chg = "OUR" then
        do:
         if v-pri = "n" then
          remtrz.svccgr = 511 .
         if v-pri = "u" then
          remtrz.svccgr = 512 .
         if v-pri = "e" then
          remtrz.svccgr = 513 .
        end.
        if v-chg = "BEN" then
        do:
         if v-pri = "n" then
          remtrz.svccgr = 508 .
         if v-pri = "u" then
          remtrz.svccgr = 509 .
         if v-pri = "e" then
          remtrz.svccgr = 510 .
        end.
       end.
      end.
     end .
     else
     if   m-typ ne "10B" and  crchs.hs = "s" then do:
      remtrz.svcrc = remtrz.fcrc.
      remtrz.svcaaa = remtrz.dracc.
      remtrz.svcgl = remtrz.drgl.
      remtrz.svccgr = 524 .
     end.
     if remtrz.sacc = '2560000011' then remtrz.svccgr = 232.
     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error .

     if avail aaa and aaa.cif = "G13644" and remtrz.fcrc = 1 then do:
          remtrz.svcrc = 0.
          remtrz.svcaaa = "".
          remtrz.svcgl = 0.
          remtrz.svccgr = 0 .
     end.
     if avail aaa and aaa.cif = "G01255" then do:
               remtrz.svcrc = remtrz.fcrc .
               remtrz.svcaaa = remtrz.dracc.
               remtrz.svcgl = remtrz.drgl.
               remtrz.svccgr = 234 .
   end.
 */

     if remtrz.svccgr ne 0
      then run comiss .

/*------------------------------- nado men'at'-^--------------------*/
     remtrz.crgl = snpgl .
     remtrz.cracc = snpacc .
/*     remtrz.sbank = ourbank.*/
     remtrz.scbank = ourbank.
     find bankl where bankl.bank = remtrz.sbank no-lock no-error.
     if available bankl then do:
                       remtrz.ordins[1] = bankl.name.
                       remtrz.ordins[2] = bankl.addr[1].
                       remtrz.ordins[3] = bankl.addr[2].
                       remtrz.ordins[4] = bankl.addr[3].
                    end.

     remtrz.sqn   = v-cif + "." + string(dep-date,"99/99/9999") + "." +
     trim(v-ref) + "." + string(trz-num) .
     remtrz.sbank = ourbank.
     remtrz.rcbank = "".
     remtrz.rbank = v-bank.
     if l-chng then
     do:
      v-text = remtrz.remtrz + " " + old-bank + " изменен -> " + ourbank.
      run lgps.
     end.
     acode = "".
     remtrz.racc = v-ba .
     remtrz.outcode = 3 .


     if v-bank eq "" and not brnch then  do:
        v-text = remtrz.remtrz +

        " Внимание ! Не найден код банка-получателя ! " .
        run lgps.
     end.
    else
    do:
     if brnch and v-bank = "" then  v-bank = clecod.

       /*  known RECEIVER  */

     find first bankl where bankl.bank = v-bank no-lock no-error.

     if not avail bankl then do:
       v-text = remtrz.remtrz + " Не найден код банка " +
       v-bank + " ! " .
       run lgps .
       v-reterr = v-reterr + 8.  /*  */  .
     end.
     else if bankl.bank ne ourbank  then
     do  :
      find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
      find first bankt where bankt.cbank = bankl.cbank and
        bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

      if not avail bankt then do:
        v-text = remtrz.remtrz + " HOME " +
        " Внимание ! не найден корр.счет для " + bankl.cbank +
        " Валюта = " + bcode  .
        run lgps .
      end.
      else do :        /* not error */
       if remtrz.valdt1 >= g-today then
       remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
       else
       remtrz.valdt2 = g-today + bankt.vdate .
       if remtrz.valdt2 = g-today and bankt.vtime < time
       then remtrz.valdt2 = remtrz.valdt2 + 1 .

       repeat:
        find hol where hol.hol eq remtrz.valdt2 no-lock  no-error.
        if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
          and  weekday(remtrz.valdt2) le v-weekend then leave.
        else remtrz.valdt2  = remtrz.valdt2 + 1.
       end.

       find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
       remtrz.rcbank = t-bankl.bank .    /* ??????????? */
       if t-bankl.nu = "u" then
       do:
        receiver = "u".
        remtrz.rsub = "cif".
       end.
       else do:
        receiver = "n" .
        remtrz.ba = "/" +  v-ba .
       end .
       remtrz.rcbank = t-bankl.bank .
       remtrz.raddr = t-bankl.crbank.
       remtrz.cracc = bankt.acc.
       if bankt.subl = "dfb" then do:
        find first dfb where dfb.dfb = bankt.acc no-lock no-error .
        if not avail dfb  then do:
         v-text = remtrz.remtrz + " Вниминие ! Не найден DFB " +
         bankt.acc  + " для " + v-bank .
         run lgps .
         v-reterr = v-reterr + 125.  /*  */  .
        end.
        else do:
         remtrz.crgl = dfb.gl.
         find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.

       if bankt.subl = "cif" then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
        if not avail aaa  then do:
        v-text = remtrz.remtrz + " Внимание ! Не найден LORO счет " +
          bankt.acc  + " для " + v-bank + " ! " .

          run lgps .
          v-reterr = v-reterr + 126.  /*  */  .
        end.
        else do:
           remtrz.crgl = aaa.gl.
           find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.
      end .  /* not error */
      find first bankl where bankl.bank = v-bank no-lock no-error.
    end.     /* rbank isn't our bank  */
    else do :
     remtrz.rsub = "" .
     remtrz.raddr = "" .
     remtrz.valdt2 = remtrz.valdt1 .
    end .

    /*else do :        /*-rem because not avaible receiver-*/
      remtrz.rsub = "cif".
      remtrz.raddr = "".
      remtrz.valdt2 = remtrz.valdt1 .
      if remtrz.rsub ne "" then do:
       c-acc = remtrz.racc .
       if rsub = "cif" then do:
         find first aaa where aaa.aaa = c-acc
         and aaa.crc eq remtrz.tcrc no-lock no-error .
         if avail aaa then do:
          if aaa.sta eq "C" then do:
          v-text = remtrz.remtrz + " Закрытый счет : " + c-acc.
          for each aas where aas.aaa = c-acc and aas.sic = "KM" no-lock .
          v-text = remtrz.remtrz + " Счет  " + c-acc +
                   " переведен в " + aas.payee .
           end .
           run lgps .
           v-reterr = v-reterr + 8.
           /* aaa for rbank.racc  wasn't found */  .
          end.
          else do :
           find tgl where tgl.gl = aaa.gl no-lock.
           remtrz.cracc = remtrz.racc .
           remtrz.crgl = tgl.gl.
          end .
         end.
         else
         do:
                   v-text = remtrz.remtrz + " Не найден счет " +
                   c-acc  + " или валюта счета не = валюте платежа " .
          run lgps .
          v-reterr = v-reterr + 32.  /* aaa for rbank.racc  wasn't found */  .
         end.
       end.         /* cif */
       else
       do:
          v-text = remtrz.remtrz + " RSUB не CIF:   " + rsub + " " +
           c-acc  .
          run lgps .
          v-reterr = v-reterr + 64 .  /* */ .
       end.
      end.        /*  rsub ne "" */
      else
      do:
          v-text = remtrz.remtrz + " RSUB пуст " +
           c-acc .
          run lgps .
          v-reterr = v-reterr + 128 .  /* */ .
      end.
    end .        /* end rbank = ourbank */ */
end .

                remtrz.ref =
                 (if trz-num = 1 then "SNIP payment" else (trz1 +
                 " SNIP tax for cash" )) .
                    /*
                (substring(trim(v-cif),1,6) +
                fill(" " , 6 - length(substring(trim(v-cif),1,6))))
                +  "HOME" +
                (substring(trim(v-ref),1,12) +
                fill(" " , 12 - length(substring(trim(v-ref),1,12))))
                +
                (substring(trim(ourbank),1,12) +
                fill(" " , 12 - length(substring(trim(ourbank),1,12))))
                +
                (substring(trim(v-acc),1,10) +
                fill(" " , 10 - length(substring(trim(v-acc),1,10))))

                + string(day(dep-date),"99")
                + string(month(dep-date),"99")
                + substr(string(year(dep-date),"9999"),3,2) .*/
                                                  /*
                + substring(v-rcvinfo[1],11,5) .
                                                    */

        if m-typ = "10B" and remtrz.fcrc = 1
          and remtrz.crgl ne 0 and remtrz.cracc ne "0"
            then remtrz.chg = 0. else remtrz.chg = 7 .


 /* ptype determination  */
if remtrz.rbank = ourbank then remtrz.rcbank = ourbank.

if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank .
if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .

find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
if avail bankl then
  if bankl.nu = "u" then sender = "u". else sender = "n" .
find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
if avail bankl then
  if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .
  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
     no-lock no-error .
if avail ptyp then remtrz.ptype = ptyp.ptype.
else remtrz.ptype = "N".

/*
if remtrz.ptype = "M" and remtrz.rbank ne ourbank
*/
if remtrz.ptype = "4" then do :
   v-det = trim(remtrz.ba) + " " + v-det.
   remtrz.det[1] = substr(v-det,1,35) .
   remtrz.det[2] = substr(v-det,36,35) .
   remtrz.det[3] = substr(v-det,71,35) .
   remtrz.det[4] = substr(v-det,106,35) .
end.
else do :
   remtrz.det[1] = substr(v-det,1,35) .
   remtrz.det[2] = substr(v-det,36,35) .
   remtrz.det[3] = substr(v-det,71,35) .
   remtrz.det[4] = substr(v-det,106,35) .
end.

remtrz.rwho = g-ofc .
remtrz.source = m_pid .

 if receiver ne "o" and v-bank ne "" then do:
  {nbal+r.i}       /*  nbal   */
 end.


 create que.
 que.remtrz = remtrz.remtrz.
 que.pid = m_pid.
 remtrz.remtrz = que.remtrz .
 que.ptype = remtrz.ptype.
 if v-reterr = 0 then  do:
   que.rcod = "5" .
   if remtrz.cracc = lbnstr then que.rcod = "3" .
  end.
 else
 do:
  trzerr = true .
  que.pvar = string(v-reterr).
 end.

 que.con = "F".
 que.dp = today.
 que.tp = time.
 if v-pri = "E" then
  que.pri = 9999 .
  else
 if v-pri = "U" then
  que.pri = 19999 .
  else
  que.pri = 29999 .

 if trz-num = 1 then
  find first que1 where que1.remtrz = trz1 exclusive-lock .
 else
  find first que2 where que2.remtrz = trz2 exclusive-lock .


