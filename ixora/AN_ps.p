/* AN_ps.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
        25/11/2013 Luiza - *ТЗ 2181
*/

def var a1 as char .
def var num as cha extent 100 .
def var ksm as cha.
def var v-err like sysc.chval  .
def var v-sqn like remtrz.sqn  .
def var impok as log initial false .
def var ok as log initial false .
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var i as int .
def var v-ierr as int initial 0 .
def var fou as log initial false .
def var exitcod as cha .
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var v-cl as cha.
def var v-sender like remtrz.sbank .
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var v-field as cha .
def var receiver as cha.
def new shared var s-remtrz like remtrz.remtrz .
def var v-reterr as int initial 0 .
def var v-weekend as int.
def var v-weekbeg as int.
def var oldvdt2 as date.

/* 18.08.98  10 santim */
 def var lbnstr as cha .
 find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
 if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */

{global.i}
{lgps.i}
{rmz.f}

 /*
  m_pid = "AN".
  u_pid = "AUTORG".
 */

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет OURBNK записи в sysc файле ! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.
find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "CLCEN" no-lock no-error.  /* Clearing cent.code */
if not available sysc or sysc.chval = "" then do :
  v-text = " Нет CLGEN записи в sysc файле ! ".
  run lgps.
  return .
end.
v-cl = sysc.chval.


find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " Нет PS_ERR записи в sysc файле ! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.

do transact :
 find first que where que.pid = m_pid and que.con = "W"
    use-index fprc  exclusive-lock no-error.

 if avail que then
 do  :
   que.dw = today.
   que.tw = time.
   que.con = "P".
   find first remtrz where remtrz.remtrz = que.remtrz exclusive-lock .

   ksm = remtrz.remtrz + remtrz.source +
   string(remtrz.rdt) +
   string(remtrz.valdt1) +
   string(remtrz.amt) +
   string(remtrz.payment) +
   string(remtrz.rsub)  +
   string(remtrz.racc)  +
   string(remtrz.sbank) +
   string(remtrz.rbank) +
   string(remtrz.sqn)   +
   string(remtrz.fcrc)  +
   string(remtrz.tcrc)  +
   string(remtrz.rdt)   +
   string(remtrz.sacc)  +
   string(remtrz.racc)  +
   string(remtrz.ord)   +
   string(remtrz.ref)   +
   string(remtrz.bb[1]) +
   string(remtrz.bb[2]) +
   string(remtrz.bb[3]) +
   string(remtrz.info[3]) +
   string(remtrz.info[9]) +
   string(remtrz.intmed) +
   string(remtrz.intmedact) .
   do i = 1 to 4: ksm = ksm + remtrz.actins[i] . end.
   do i = 1 to 3: ksm = ksm + remtrz.bn[i] . end .
   do i = 1 to 6: ksm = ksm + remtrz.rcvinfo[i] . end  .
   do i = 1 to 4: ksm = ksm + remtrz.detpay[i] . end  .
   do i = 1 to 4: ksm = ksm + remtrz.ordins[i] . end  .
  ksm = ksm + remtrz.ba + remtrz.bi .

  find first sysc where sysc.sysc = "ourbnk" no-lock no-error .
  if avail sysc then ksm = ksm + trim(sysc.stc) .
  if remtrz.info[1] ne encode(ksm) then do:
    v-text = remtrz.remtrz + " Ошибка контрольной суммы  ! " .
    run lgps.
    que.con = "F".
    que.dp = today.
    que.tp = time.
    que.pri = 29999 .
    que.rcod = "2" .
    return .
  end.

  oldvdt2 = remtrz.valdt2. /* KOVAL */

/*cracc and crgl*/
if remtrz.info[3] begins "11B" then do :
  find first sysc where sysc.sysc = "SNIPGL" no-lock no-error.
  if not avail sysc then do :
   v-text = "Нет записи SNIPGL в sysc файле ! " .
   v-reterr = v-reterr + 1024 .
   run lgps .
   remtrz.cracc = "" .
   remtrz.crgl = 0 .
  end .
  else do :
   remtrz.cracc = entry(2,sysc.chval) .
   find first arp where arp.arp = remtrz.cracc no-lock no-error .
   if remtrz.cracc <> "" and not avail arp then do :
    v-text = " Ошибка . Не найден " + remtrz.cracc  .
    v-reterr = v-reterr + 1024 .
    run lgps .
   end .
   else if remtrz.cracc <> "" and arp.crc <> remtrz.tcrc then do :
   v-text = "Ошибка ! Валюта " + remtrz.cracc + " " + string(arp.crc)
          + " не соответствует валюте " + remtrz.dracc + string(remtrz.tcrc) .
    v-reterr = v-reterr + 1024 .
    run lgps .
   end .
   remtrz.crgl = integer(entry(1,sysc.chval)) .
   find first gl where gl.gl = remtrz.crgl no-lock no-error .
   if not avail gl then do :
    v-text = "Не найден счет  Г/К " + string(remtrz.crgl) .
    v-reterr = v-reterr + 1024 .
    run lgps .
   end .
  end .
end .
/*cracc and crgl*/

find sysc where sysc.sysc = "othbnk" no-lock no-error .
if avail sysc and sysc.chval ne "" then do:
  if lookup(trim(remtrz.rbank),sysc.chval,",") ne 0 then
   do:
    v-text = remtrz.remtrz + " " + remtrz.rbank + " изменен на  -> " + ourbank.
    run lgps.
    remtrz.rbank = ourbank.
   end.
 end.



   find first bankl where bankl.bank = remtrz.sbank no-lock .

   /* SENDER */
     remtrz.scbank = bankl.cbank .
     find first crc where crc.crc = remtrz.fcrc.  acode = crc.code .

     find first bankt where bankt.cbank = bankl.cbank and
     bankt.crc = remtrz.fcrc and bankt.racc = "1" no-lock no-error .
   if not avail bankt then do:
      v-text = remtrz.remtrz + " Внимание ! Нет " + bankl.cbank
                 +  " записи в bankt файле ! " .
      run lgps .
      v-reterr = 1 .  /* dracc with fcrc for sbank wasn't found */  .
    end.
    else do :  /* not error */
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     if t-bankl.nu = "u" then sender = "u". else sender = "n" .
     remtrz.saddr = t-bankl.crbank.
     remtrz.scbank = t-bankl.bank.
     remtrz.dracc = bankt.acc.
     if bankt.subl = "dfb"
        then do:
         find first dfb where dfb.dfb = bankt.acc no-lock no-error .
   if not avail dfb then do:
      v-text = remtrz.remtrz +
      " Не найден " + bankt.acc + "  в dfb файле !" .
      run lgps .
      v-reterr = v-reterr + 23.
           end.
           else do:
            remtrz.drgl = dfb.gl .
            find gl where gl.gl = remtrz.drgl  no-lock no-error .
          end.
        end.
     if bankt.subl = "cif"
         then do:
          find first aaa where aaa.aaa = bankt.acc no-lock no-error .
      if not avail aaa then do:
      v-text = remtrz.remtrz + " Не найден счет " + bankt.acc
       + " в ааа файле !!! " .
      run lgps .
      v-reterr = v-reterr + 22.
           end.
           else do:
            remtrz.drgl = aaa.gl .
            find gl where gl.gl = remtrz.drgl
           no-lock no-error .
          end.
         end.
     end.       /* not error */
    /* end sender */


/* RECEIVER */
  if remtrz.rbank ne "" then do :
   find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

   if not avail bankl then do:
     v-text = remtrz.remtrz + " Не найден " + remtrz.rbank + " в bankl файле".
      receiver = "n" .
      run lgps .
      v-reterr = v-reterr + 2.  /* dracc with fcrc for sbank wasn't found */  .
   end.
   else
   if bankl.bank ne ourbank then
    do  :
/*     remtrz.rcbank = bankl.cbank .     */
     find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
     find first bankt where bankt.cbank = bankl.cbank and
     bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

    if not avail bankt then do:
      v-text = remtrz.remtrz + " Не найден " + bankl.cbank + " в bankt файле" .
      run lgps .
      v-reterr = v-reterr + 4. /* cracc with tcrc for rbank wasn't found */  .
    end.

    else do :        /* not error */
     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
     repeat:
        find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
        if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
               and  weekday(remtrz.valdt2) le v-weekend then leave.
        else remtrz.valdt2  = remtrz.valdt2 + 1.
     end.

     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.rcbank = t-bankl.bank .
     if t-bankl.nu = "u" then receiver = "u". else receiver = "n" .
     remtrz.rcbank = t-bankl.bank .
     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.
     if bankt.subl = "dfb"
        then do:
          find first dfb where dfb.dfb = bankt.acc no-lock.
          remtrz.crgl = dfb.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       if bankt.subl = "cif"
        then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.crgl = aaa.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
     end .  /* not error */

    end.     /* rbank isn't our bank */

   else
   if bankl.bank eq ourbank then
    do :
      remtrz.raddr = "".
      remtrz.valdt2 = remtrz.valdt1 .
      remtrz.rcbank = remtrz.rbank .
      receiver = "o".
      if remtrz.rsub ne "" then do:
       c-acc = remtrz.racc .
       if rsub = "cif" then do:
        find aaa where aaa.aaa = c-acc
         and aaa.crc eq remtrz.tcrc no-lock no-error .
        if avail aaa and aaa.sta ne "C" then do:
           find tgl where tgl.gl = aaa.gl no-lock.
           remtrz.cracc = remtrz.racc .
           remtrz.crgl = tgl.gl.
        end.
        else if avail aaa and aaa.sta eq "C" then
        do:
                v-text = remtrz.remtrz + " Закрытый счет : " + c-acc.
        for each aas where aas.aaa = c-acc and aas.sic = "KM" no-lock .
        v-text = remtrz.remtrz + " Счет  " +
           c-acc + " переведен в " + aas.payee .
         end .
         run lgps .
         v-reterr = v-reterr + 8.
         /* aaa for rbank.racc  wasn't found */  .
        end.
        else
        do:
          v-text = " Не найден " + c-acc + " в aaa файле" .
          run lgps .
          v-reterr = v-reterr + 8.  /* aaa for rbank.racc  wasn't found */  .
        end.
       end.         /* cif */
       /*******************************/
       else if rsub = "arp" then do:
        find arp where arp.arp = c-acc
        and arp.crc eq remtrz.tcrc no-lock no-error .
        if avail arp then do:
            find tgl where tgl.gl = arp.gl no-lock.
            remtrz.cracc = remtrz.racc .
            remtrz.crgl = tgl.gl.
        end.
        else do:
            v-text = " Не найден " + c-acc + " в arp файле" .
            run lgps .
            v-reterr = v-reterr + 8.  /* aaa for rbank.racc  wasn't found */  .
        end.
       end. /* arp */
        else
        do:
         v-text = remtrz.remtrz + " RSUB не CIF:   " + rsub + " " +
                    c-acc   .
          run lgps .
          v-reterr = v-reterr + 16 .  /* */ .
        end.

      end.        /*  rsub ne "" */
        else
        do:
          v-text = remtrz.remtrz + " пустой RSUB  " +
           c-acc  + " , 6 bit retcode = 1 " .
          run lgps .
          v-reterr = v-reterr + 32 .  /* */ .
        end.

   end .        /* end rbank = ourbank */
  end .

/* 18.08.98  10 santim */
     if remtrz.info[2] = lbnstr then do:
       find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(307)
                           and tarif2.stat = "r" no-lock no-error .
       if avail tarif2 then do:
           remtrz.svccgr = 307.
           remtrz.svcrc = remtrz.tcrc .
           s-remtrz = remtrz.remtrz .
           run comiss .
          end.
       end.
/* 18.08.98  10 santim */

   /*
 if sender ne "" and receiver ne "" then do:
    find first ptyp where ptyp.sender = sender and
      ptyp.receiver = receiver no-lock no-error .
    if avail ptyp then remtrz.ptype = ptyp.ptype.
 end . */

if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank .
if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .


find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
if avail bankl then
  if bankl.nu = "u" then sender  = "u". else sender  = "n" .
 find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
if avail bankl then
 if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .

  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
  find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then remtrz.ptype = ptyp.ptype.
                else remtrz.ptype = "N".

/* V2 for branches
  if remtrz.ptype = "2" then do:
    	remtrz.valdt2=oldvdt2.
	/* ДЛя филальских уже известно valdt2 */
	v-text = "TEST4 ourbank=" + ourbank + " bankl.bank=" + bankl.bank + " " + remtrz.remtrz + " Ptype  " + remtrz.ptype + " valdt2=" + string(remtrz.valdt2) + " valdt1=" + string(remtrz.valdt1) .
	run lgps .
  end.
 */
{nbal+r.i}
/*          nbal           */

/* create que.
 que.remtrz = remtrz.remtrz.
 que.pid = m_pid.    */

 remtrz.source = "A" .
 remtrz.remtrz = que.remtrz .
 que.ptype = remtrz.ptype.
 if v-reterr = 0 then
  que.rcod = string(v-reterr).
 else
 do:
  que.rcod = "1".
  que.pvar = string(v-reterr).
 end.
 que.con = "F".
 que.dp = today.
 que.tp = time.
 que.pri = 29999 .
 ok = true  .
  v-text = "Автоматическая регистрация платежа " + remtrz.remtrz +
   " тип = " + remtrz.ptype + " код завершения = " + que.rcod +
  " " + remtrz.sbank + " -> " + remtrz.rbank +
  ". remtrz.source изменен  AN -> A" .
 run lgps.
    /* проставление вида документа */
    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = 'pdoctng' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.sub = 'rmz'.
        sub-cod.acc = remtrz.remtrz.
        sub-cod.d-cod = 'pdoctng'.
        if remtrz.sqn matches "*IBH*" then sub-cod.ccode = "01". /*платежн поручение*/
        else sub-cod.ccode = "20" /* Прочие зачисления */.
        sub-cod.rdt = g-today.
    end.
end.
end .

pause 0 .
