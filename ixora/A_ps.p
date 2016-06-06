/* A_ps.p
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
        18.12.2005 tsoy     - добавил время создания платежа.
        29/08/06 u00121 заменил nawk на awk
*/

def var num as cha extent 100 .
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

{global.i }
{lgps.i }
{rmz.f}

        /*
 m_pid = "A".
 u_pid = "AUTORG".
          */
find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

/* 18.08.98  10 santim */
def var lbnstr as cha .
find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
if avail sysc then lbnstr = sysc.chval .
/* 18.08.98  10 santim */

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

if ourbank = v-cl then
 input through value("lget 10A  -q BRNCH ; echo $? ") .
else
  input through value("lget 10A  -q RECVD ; echo $? ") .

num = "".
repeat:
  import num  .
  leave .
end.

if  num[1]  = "0"
 then do:
  return .
 end.

exitcod = "".
repeat:
  import exitcod  .
end.

   fou = false .
   do i = 1 to length(num[1]) .
      if substr(num[1],i,1) > "9" or substr(num[1],i,1) <  "0"
       then do: fou = true . leave . end .
   end.

  if not fou then
  do i = 2 to 100 .
   if num[i] ne ""  then
   do: fou = true . leave . end .
  end.


if  ( exitcod ne "0" ) or fou
 then do:
  do i = 1 to 100 .
   if num[i] ne "" then
   v-text = v-text + " " + num[i]  .
  end.
  v-text = " Ошибка транспортной системы ! (LGET) " + v-text .
  run lgps.
  return .
 end.


input close .

input through value("larc -F s -s " + string(num[1]) +
 " |  awk ' \{ sub(""HOWDOYOUDO"",""hihowareu.""); print $0 \} ' - " ) . /*29/08/06 u00121 заменил nawk на awk*/

 import v-field .
 if substr(v-field,34,3) ne "10A" then
  do:
     input close .
     return .
  end .

repeat :
 import v-field .
 /*   display v-field .    */
 if v-field = ":C5:" then leave .
end .
if v-field ne ":C5:"
 then do:
  v-text = "Ошибка формата сообщения SQN = " + string(num[1]) .
  run lgps.
  return .
 end.


import v-sender v-sqn .
/*
 display v-sender v-sqn .
*/
find first bankl where bankl.bank = v-sender no-lock no-error .

if not avail bankl then do:
  v-text = "Банк-отправитель " + v-sender + " для SQN = " + string(num[1]) +
  "." + v-sqn  +
  " не найден в справочнике банков  " + v-err .
  run lgps.
  v-ierr = 1 . 
end .
else do:
 find first remtrz where remtrz.sbank = v-sender
     and remtrz.sqn  begins substr(v-sqn,1,16) no-lock no-error .
 if avail remtrz then do:
   v-text = "Получен дубликат  SQN = " + string(num[1]) + "." + v-sqn + " от " +
    v-sender + " " + remtrz.remtrz + " <- " + remtrz.sqn .
    run lgps. 
  v-ierr = 1 . 
 end .
end . 

if v-ierr > 0 then do transact :

     create reject .
       reject.ref = string(num[1]) + "." + v-sqn  .
       reject.t_sqn = string(num[1]) .
       reject.whn = today.
       reject.who = g-ofc.
       reject.tim = time.
       v-text = "Отправлено отвержение " + reject.ref + " SQN = " + 
        string(num[1])  .
       run lgps . 
   
    /*
     if ourbank = v-cl then
       unix silent value("lget -q BRNCH --done " + string(num[1])) .
        else
       unix silent value("lget -q RECVD --done " + string(num[1])) .
     */

 if ourbank = v-cl then
      input through
           value( "lget -q BRNCH --done " + string(num[1]) + " ; echo $? " ) .
            else
             input through
          value( "lget -q RECVD --done " + string(num[1]) + " ; echo $? " ) .

   exitcod = "".
   repeat:
    import exitcod .
   end.
   input close .

    if  exitcod ne "0"  then do:
      v-text = " Ошибка транспортной системы ( LGET DONE ) для " +
      string(num[1])  + "." + v-sqn  + " SQN = " + string(num[1])  .
      run lgps.
     end.
 
  return .
end.



do transaction  on error undo  :
 /*    input from value(v-file) .    */          /*  !!!!!!!!!!!!!! */
     create remtrz .

     remtrz.rtim = time.

     import remtrz .
     impok = true .
     input close .

     run n-remtrz.                     /* !!!!!!!!!!!!!!!! */
     remtrz.source = m_pid . 
     remtrz.t_sqn = num[1] .
     remtrz.rdt = g-today .
     remtrz.remtrz = s-remtrz .
     remtrz.valdt1 = remtrz.valdt2 .
     remtrz.dracc = "" . remtrz.drgl = ? .
     remtrz.jh1   = ?  . remtrz.jh2 = ? .

     acode = "".

     remtrz.fcrc = remtrz.tcrc .
     remtrz.amt = remtrz.payment .
     remtrz.saddr = "" . 
     remtrz.ptype = "0" .
     remtrz.margb = 0.
     remtrz.margs = 0.
     remtrz.svca   = 0.
     remtrz.svcaaa = "".
     remtrz.svcmarg = 0.
     remtrz.svcp = 0.
     remtrz.svcrc = 0.
     remtrz.svccgl = 0.
     remtrz.svccgr = 0. 
     remtrz.svcgl = 0.
     remtrz.cracc = "".
     remtrz.dracc = "".
     remtrz.crgl = 0.
     remtrz.drgl = 0.
/*   remtrz.sacc = "".      */
     remtrz.scbank = "".
     remtrz.rcbank = "".

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
      v-text = remtrz.remtrz + " Не найден dfb " + bankt.acc + " !" .
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
      v-text = remtrz.remtrz + " Не найден счет " + bankt.acc + 
      " в ааа файле !!! " .
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
      v-text = remtrz.remtrz + 
      " Не найден " + bankl.cbank + " в bankt файле" .
      run lgps .
      v-reterr = v-reterr + 4. /* cracc with tcrc for rbank wasn't found */  .
    end.

    else do :        /* not error */

     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
     repeat:
       find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
       if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
             and  weekday(remtrz.valdt2) le v-weekend then leave.
       else remtrz.valdt2  = remtrz.valdt2 + 1.
     end.

     find  first  t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.rcbank = t-bankl.bank .
     if t-bankl.nu = "u" then receiver = "u". else receiver = "n" .
     remtrz.rcbank = t-bankl.bank .
     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.
     if bankt.subl = "dfb"
        then do:
       find first dfb where dfb.dfb = bankt.acc no-lock no-error .
       if not avail dfb then do:
         v-text = " Не найден " + bankt.acc + " в dfb файле" .
         run lgps .
         v-reterr = v-reterr + 29.
        end.
     else do:
      remtrz.crgl = dfb.gl .
      find tgl where tgl.gl = remtrz.crgl  no-lock no-error .
     end.
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
   if bankl.bank eq  ourbank then
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
          v-text = remtrz.remtrz + " Счет  " + c-acc +
            " переведен в " + aas.payee .
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
        else
        do:
          v-text = remtrz.remtrz + " RSUB не CIF:   " + rsub + " " +
           c-acc  + " , 5 bit retcode = 1 " .
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
  find first ptyp where ptyp.sender = sender and
  ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then
  remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".



{nbal+r.i}       /*          nbal           */

 create que.
 que.remtrz = remtrz.remtrz.
 que.pid = m_pid.
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
  " <- SQN = " + string(num[1]) +
  " <- " + v-sender + " " + remtrz.sqn + " тип = " + remtrz.ptype +
  " retcode = " + que.rcod +
  " " + remtrz.sbank + " -> " + remtrz.rbank .
 run lgps.
end.
  if ok then do transaction :
  if ourbank = v-cl then
    input through
         value( "lget -q BRNCH --done " + string(num[1]) + " ; echo $? " ) .
          else
           input through
          value( "lget -q RECVD --done " + string(num[1]) + " ; echo $? " ) .
      exitcod = "".
      repeat:
       import exitcod .
      end.
       input close .

      if  exitcod ne "0"  then do:
       v-text = " Ошибка транспортной системы ( LGET DONE ) для "  +
       string(num[1])  + "." + v-sqn  +
        " Laska SQN = " + string(num[1])  .
       run lgps.
   end.

  end . 

pause 0 .
