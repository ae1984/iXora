/* rotlxzp.p
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
        30.10.2002 nadejda  - наименование клиента заменено на форма собств + наименование
        20.08.2003 nadejda  - дополнительное логирование при любом изменении транспорта
        23.09.2003 nadejda  - проверка введенной суммы комиссии с учетом минимальной и максимальной суммы
        26.09.2003 nadejda  - добавлено определение комиссии по умолчанию для внешних валютных платежей и проверка при вводе кода комиссии
        15.10.2003 sasco    - переделал исправление счета отправителя, чтобы выводилось /RNN/ cif.jss
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/



def new shared var ee5 as cha initial "2" .
def var prilist as cha.
def shared var s-remtrz like remtrz.remtrz.
def var addrbank as char format "x(80)".
def var cmdk as char format "x(70)".
def new shared var f_title as char format "x(80)". /*title of frame mt100  */
def var Lswtdfb as log.
def var Lswbank as log.
def new shared buffer f57-bank for bankl.           /* nan */
def new shared buffer sw-bank  for bankl.           /* nan */
def new shared var realbic as char format "x(12)". /* real bic code    */
def new shared var remrem202 as char format "x(16)". /* field 20 of mt202  */
def new shared var F52-L as char format "x(1)".  /* ordering institution*/
def new shared var F53-L as char format "x(1)".  /* sender's corr.      */
def new shared var F54-L as char format "x(1)".             /*rec-r's corr. */
def new shared var F56-L as char format "x(1)".    /*intermediary.  */
def new shared var F53-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F53-2val as char extent 4 format "x(35)".
/*intermediary 202 .  */
def new shared var F56-2L as char format "x(1)".    /*intermediary 202.  */
def new shared var F56-2val as char extent 4 format "x(35)".
/*intermediary 202 .  */
def new shared var F57-2L as char format "x(1)".    /*intermediary 202.*/
def new shared var F57-2val as char extent 4 format "x(35)".
/*intermediary 202 .*/
def new shared var F58-2aval as char format "x(35)". /*58A - account 202.*/
def new shared var F72-2val as char extent 6 format "x(35)".
/*intermediary 202 .*/
def new shared var F57-L as char format "x(1)".       /*account with inst.  */
def new shared var F57-str4 as char extent 2 format "x(35)".
/*addit.str.for f57d in 100*/


def  var ootchoice as char extent 2 format "x(35)" initial
     [" ONLY MT100 MESSAGE TO DESTINATION ",
      " MT100  AND MT202 TO CORRESPONDENT "].
def new shared var domt100 as char format "x(12)". /*dest of mt100 if mt202*/
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
def var vv-crc like crc.crc .
def var v-cashgl like gl.gl.
def var vf1-rate like fexp.rate.
def var vfb-rate like fexp.rate.
def var vt1-rate like fexp.rate.
def var vts-rate like fexp.rate.
def shared frame remtrz.
def buffer xaaa for aaa.
def buffer fcrc for crc.
def buffer t-bankl for bankl.
def buffer tcrc for crc.
def var ourbank as cha.
def var clearing as cha.
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var receiver as cha.
def var s-bankl like remtrz.sbank .
def var v-oldcover like remtrz.cover.


{global.i}
{lgps.i }
{rmz.f}   /*
m_pid = "".
u_pid = "".
            */

{comchk.i}


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record OURBNK in sysc file !!".
 pause .
 undo .
 return .
end.
ourbank = sysc.chval.

find sysc where sysc.sysc = "PRI_PS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record PRI_PS in sysc file !!".
 pause .
 undo .
 return .
end.
prilist = sysc.chval.

find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " This isn't record CLEARING in sysc file !!".
 pause .
 undo .
 return .
end.
clearing = sysc.chval.

find first que where que.remtrz = s-remtrz exclusive-lock no-error .
if avail que then
  v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
    else
  v-priory = entry(1,prilist).

display v-priory with frame remtrz. pause 0 .


find first sysc where sysc.sysc = "RMCASH" no-lock no-error .
  if not avail sysc then do:
    message " There isn't RMCASH record in sysc . " .
    return.
    end  .
v-cashgl = sysc.inval .


find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock .


    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp.
    display pakal with frame remtrz .

if remtrz.rdt = ? then remtrz.rdt = g-today .

if remtrz.jh1 eq ? and m_pid <> "S" then
update
      remtrz.rdt
 /*    remtrz.valdt1     remtrz.valdt2   */
     with frame remtrz .

/* SENDER   */
do on error undo , retry   :
      display remtrz.fcrc with frame remtrz.

      /*
      if remtrz.sbank = "" then remtrz.sbank = ourbank.
        */

if remtrz.jh1 eq ? and m_pid <> "S" then  do:
      v-psbank = caps(remtrz.sbank) .
      update v-psbank validate(can-find(first bankl where bankl.bank
       = v-psbank),"") with frame remtrz.    end .
     remtrz.sbank = caps(v-psbank).
     find first bankl where bankl.bank = remtrz.sbank no-lock .
     remtrz.scbank = bankl.cbank .
     display remtrz.scbank with frame remtrz .

if remtrz.jh1 eq ? and m_pid <> "S" and remtrz.sbank ne ourbank then
      update remtrz.scbank validate(can-find(first bankt where bankt.cbank
       = remtrz.scbank)," NOT FOUND IN BANKT ") with frame remtrz.

     remtrz.scbank = caps(remtrz.scbank).

  /* SENDER - NOT OUR BANK */

     if bankl.bank ne ourbank then do on error undo ,retry :

     if remtrz.jh1 eq ? and m_pid <> "S" then
     update remtrz.fcrc validate( can-find(crc where crc.crc =
                                      remtrz.fcrc),"") with frame remtrz.
     find first crc where crc.crc = remtrz.fcrc.  acode = crc.code .


     find first bankt where bankt.cbank = remtrz.scbank
      and bankt.crc = remtrz.fcrc
      and bankt.racc = "1" no-lock no-error .
     if not avail bankt then do:
      message " ERROR !!! There isn't BANKT record !!! ".
      pause .
      undo,retry .
     end.
     if remtrz.valdt1 = ? then
      remtrz.valdt1 = g-today + bankt.vdate .
     if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.valdt1 with frame remtrz .

     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     if t-bankl.nu = "u" then sender = "u". else sender = "n" .
     remtrz.saddr = t-bankl.crbank.
     remtrz.dracc = bankt.acc.
     if bankt.subl = "dfb"
         then do:
         find first dfb where dfb.dfb = bankt.acc no-lock.
          remtrz.drgl = dfb.gl.
         find gl where gl.gl = remtrz.drgl no-lock.
/*         remtrz.fcrc = dfb.crc.     */
         end.
     if bankt.subl = "cif"
         then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.drgl = aaa.gl.
          find gl where gl.gl = remtrz.drgl no-lock.
 /*         remtrz.fcrc = aaa.crc.        */
         end.
      display remtrz.dracc remtrz.drgl gl.sub
       remtrz.fcrc acode
       /*
       remtrz.saddr   */
       with frame remtrz.
     if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.sacc validate(remtrz.sacc ne "","") with frame remtrz.
   end.
     else
 /*   SENDER - OUR BANK */
     do on error undo ,retry :
if remtrz.ptype ne "H" and remtrz.ptype ne "M" then remtrz.saddr = "".
      /*
      display remtrz.saddr with frame remtrz.
      */
      sender = "o".
     if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.valdt1 with frame remtrz .
if remtrz.jh1 eq ? and m_pid <> "S" then
      update remtrz.drgl validate(can-find(gl where gl.gl = remtrz.drgl ),"")
      with frame remtrz .
      find gl where gl.gl = remtrz.drgl no-lock.
      display remtrz.drgl gl.sub with frame remtrz.
      if gl.sub ne "" then
      do on error undo,retry :

if remtrz.jh1 eq ? and m_pid <> "S" then
       update remtrz.dracc validate(remtrz.dracc ne "","")
       with frame remtrz .
       c-acc = remtrz.dracc . {pschk.i} .
       if c-acc = "" then do: bell. undo ,retry . end.
        else do : remtrz.fcrc = vv-crc .
                  remtrz.sacc = remtrz.dracc .
                  display remtrz.sacc with frame remtrz.
                  find bank.crc where crc.crc = vv-crc.  acode = crc.code .
             end.
      end.
       else do: remtrz.dracc = "" .  remtrz.sacc  = string(remtrz.drgl) .
                display remtrz.dracc remtrz.sacc with frame remtrz.
if remtrz.jh1 eq ? and m_pid <> "S" then
                update remtrz.fcrc validate( can-find(crc where crc.crc =
                                           remtrz.fcrc),"") with frame remtrz.
                find bank.crc where crc.crc = remtrz.fcrc.  acode = crc.code .
            end.
       display remtrz.fcrc acode with frame remtrz .
       if gl.sub eq "CIF" then do:
         find aaa where remtrz.dracc = aaa.aaa no-lock .
         find cif of aaa no-lock .
         remtrz.ord = trim(trim(cif.prefix) + " " + trim(cif.name)) + ' /RNN/' + trim(cif.jss).

         if remtrz.ord = ? then do:
           run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "rotlxzp.p 273", "1", "", "").
         end.

         disp remtrz.ord with frame remtrz. pause 0 .
       end.

     end.
   end .

/* RECEIVER  */
     do on error undo , retry :
      display remtrz.tcrc with frame remtrz.
    do on error undo , retry :
  if remtrz.rbank = "" and m_pid = "I" then remtrz.rbank = ourbank .
  if remtrz.jh2 eq ? and m_pid <> "S" then
    do:
     update remtrz.rbank with frame remtrz.
     if m_pid eq "3" then undo,retry .
    end.
    remtrz.rbank = caps(remtrz.rbank).
    if remtrz.rbank ne "" then do:
        find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
         if not avail bankl then undo,retry .
          else do:
           if remtrz.rbank ENTERED  or bankl.nu = "u"
           then remtrz.rcbank = bankl.cbank .
           display remtrz.rcbank with frame remtrz .
         end.
        end.
        else
         if not ourbank = clearing then remtrz.rcbank = clearing .
       end .
/* RECEIVER - NOT OUR BANK  */

   if ( remtrz.rbank ne ourbank )
    and not ( m_pid eq "3"  and remtrz.rbank = "" )
    then do on error undo ,retry :
      do on error undo , retry :

      find first bankl where bankl.bank = remtrz.rbank no-lock no-error.

      if ( ( avail bankl and bankl.nu ne "u" ) or remtrz.rbank = "" )
       and remtrz.jh2 eq ? and m_pid <> "S" then
        update remtrz.rcbank  validate(
          can-find(first bankt where remtrz.rcbank eq bankt.cbank),"")
            with frame remtrz.

     remtrz.rcbank = caps(remtrz.rcbank).

        find first bankl where bankl.bank = remtrz.rcbank no-lock .
        if bankl.nu = "n"  and sender = "n"
         then do:
          message
          " Bank-sender and bank-receiver must not be nonparticipant  both!! " .
          undo , retry .
         end .
        if bankl.crbank = remtrz.saddr and remtrz.rbank ne ourbank
         then do:
          message " Bank-sender must not be equal bank-receiver !! "  .
          undo , retry .
         end .
      end .

 if remtrz.jh1 eq ? and m_pid <> "S" then
     update remtrz.tcrc validate( can-find(crc where crc.crc =
                                  remtrz.tcrc),"") with frame remtrz.
     find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .


  find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc
      and bankt.racc = "1" no-lock no-error .
     if not avail bankt then do:
      message " ERROR !!! There isn't BANKT record !!! ".
      pause .
      undo,retry .
     end.
     if remtrz.valdt2 = ? then
     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
 if remtrz.jh2 eq ? and m_pid <> "S" then

     update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1,
     " Valdt2 < Valdt1 " )
     with frame remtrz. pause 0 .
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .

     if t-bankl.nu = "u" then receiver = "u". else receiver = "n" .

     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.
     if bankt.subl = "dfb"
         then do:
         find first dfb where dfb.dfb = bankt.acc no-lock.
         remtrz.crgl = dfb.gl.
         find tgl where tgl.gl = remtrz.crgl no-lock.
/*         remtrz.tcrc = dfb.crc.        */
         end.
     if bankt.subl = "cif"
         then do:
          find first aaa where aaa.aaa = bankt.acc no-lock.
          remtrz.crgl = aaa.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
/*          remtrz.tcrc = aaa.crc.           */
         end.
      display remtrz.cracc remtrz.crgl tgl.sub
       remtrz.tcrc bcode
       /*
       remtrz.raddr
       */
       with frame remtrz.

      find first bankl where bankl.bank = rbank no-lock no-error .
      if avail bankl and bankl.nu = "u" then do:
         update remtrz.rsub with  frame remtrz .
         if remtrz.rsub ne ""
         then do:
          update remtrz.racc validate(remtrz.racc ne "","") with frame remtrz.
          remtrz.ba = "/" + remtrz.racc .
          remtrz.bb[1] = "/" + bankl.name.
          remtrz.bb[2] = bankl.addr[1].
          remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
         end .
         else
         do:
          remtrz.rsub = "" . remtrz.ba = "" .
         end .
      end .
       else
       do:
          remtrz.rsub = "" .
      /*    remtrz.racc = "" . remtrz.ba = "" .    */
       end .
      display remtrz.bb
        remtrz.rsub remtrz.ba remtrz.racc with frame remtrz . pause 0 .

   if receiver = "u" then do:
     if remtrz.cover <> 5 then do:
       v-text = " Автоматически изменен транспорт платежа " + remtrz.remtrz + " : receiver = 'u', трансп " + string(remtrz.cover) + " -> 5".
       run lgps.
     end.

     remtrz.cover = 5 .
   end.

   Lswtdfb = false .
   find sw-bank where sw-bank.bank = remtrz.rcbank no-lock no-error.
   if available sw-bank then do:
     if sw-bank.bic ne ? and receiver eq "n" then Lswtdfb = true.
   end.
   find bankl where bankl.bank = remtrz.rcbank no-lock no-error.

   {mesg.i 4823}.
   if (Lswtdfb ) then do:
     if remtrz.cover <> 4 then do:
       v-text = "Автоматически изменен транспорт платежа " + remtrz.remtrz + " : receiver = 'n', трансп " + string(remtrz.cover) + " -> 4".
       run lgps.
     end.

     remtrz.cover = 4.
   end.
                                       /*      else remtrz.cover = 1.    */
   if remtrz.cover < 5 then
        v-oldcover = remtrz.cover.

   update remtrz.cover validate(((remtrz.cover eq 1 or  remtrz.cover eq 3)
        or (remtrz.cover eq 4 and Lswtdfb )),  "") with frame remtrz.

        if remtrz.cover <> v-oldcover then do:
          v-text = "Изменен транспорт платежа " + remtrz.remtrz + " : трансп " + string(v-oldcover) + " -> " + string(remtrz.cover).
          run lgps.
        end.

        if remtrz.cover eq 4 then do on error undo , retry : /* SWIFT */
/*------------------SWIFT START -----------------------*/
          cmdk = "swkeyfi " + dbname + " " +
           caps(trim(bankl.bic)).
          input through value(cmdk) no-echo.
          set addrbank with frame indata no-box no-labels width 80.
          input close.

          if addrbank eq "NO FOUND" then do:
              message "CAN'T FIND BANK " + "'" +
              caps(trim(bankl.bic)) + "'" +
                        " IN THE SWIFT A-KEYS DATA BASE".
              bell.
              undo, retry.
          end.
          else if addrbank eq "BAD DATE" then do:
              message "BANK " + "'" +
              caps(trim(bankl.bic)) +  "'" +
        " HAS BEEN FOUND IN THE SWIFT A-KEYS DATA BASE, BUT NOT UP TO DATE".
              bell.
              undo, retry.
          end.
          if remtrz.outcode = 4 then do:
               run swmt200p.
          end.

          else do:
           /* menu: one or two swift messages */
               do on error undo,retry:
                    form ootchoice
                      with overlay row 10 1 col centered no-labels
                      frame ootfr.
                    display ootchoice with frame ootfr.
                    choose field ootchoice AUTO-RETURN with frame ootfr.
               end. /* do on error */
               if FRAME-INDEX eq 1 then do:
                    domt100 = "ONE". /* only one mt100 */
                    run swmt100p.
               end.
               else do:
                    do on error undo,retry:
                    update domt100 label " DESTINATION OF MT100 "
                      format "x(12)"
                      with frame domt100
                      side-labels
                      row 14
                      centered
                      overlay
                      width 39.
                    domt100 = caps(trim(domt100)).
                    if (index(domt100, " ") ne 0 ) or
                       (domt100             eq "") or
                       (length(domt100)     le 7 )
                    then do:
                        bell.
                        undo, retry.
                    end.

                    cmdk = "swkeyfi " + dbname + " " + domt100.
                    input through value(cmdk) no-echo.
                    set addrbank with frame indata no-box no-labels width 80.
                    input close.

                    if addrbank eq "NO FOUND" then do:
                        message "CAN'T FIND BANK " + "'" + domt100 + "'" +
                                  " IN THE SWIFT A-KEYS DATA BASE".
                        bell.
                        undo, retry.
                    end.
                    else if addrbank eq "BAD DATE" then do:
                        message "BANK " + "'" + domt100 + "'" +
                                  " HAS BEEN FOUND IN THE SWIFT A-KEYS DATA BASE, BUT NOT UP TO DATE".
                        bell.
                        undo, retry.
                    end.
                    else if addrbank eq "NO BASE" then do:
                    end.
                    else do:
                        message addrbank.
                        pause 5.
                    end.
                    end. /* do on error */
                    run swmt100p.
               end.
          end.

          if lastkey eq keycode('pf4') then undo,retry.
/*------------------SWIFT STOP  -----------------------*/
     end.
/*
/* -------------------- INTERBRANCH START ---------------------- */
     else if remtrz.cover eq 5 then do:
        run swmt100f.
        if lastkey eq keycode('pf4') then undo,retry.
     end.
/* -------------------- INTERBRANCH STOP ---------------------- */
*/
     else do: /* remtrz.cover ne 4 */
          do on error undo,retry:
               if remtrz.bb[1] eq "" or rsub ne ""
                then s-bankl = remtrz.rbank.
               else s-bankl = "" .
               if remtrz.rsub eq  "" then do:
                disp s-bankl remtrz.bb remtrz.ba
                   with centered row 14 1 col overlay top-only frame bnkx.
                update s-bankl with frame bnkx.
               end.
               find bankl where bankl.bank = trim(s-bankl) no-lock no-error.
               if available bankl then do:
                         remtrz.bb[1] = "/" + bankl.name.
                         remtrz.bb[2] = bankl.addr[1].
                         remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
               end.
             if remtrz.ba = "" then remtrz.ba = "/" .
             if remtrz.rsub eq  "" then
              update remtrz.bb remtrz.ba with frame bnkx.
          end.  /* do on error */
/*          pause 1234.   */
         disp   remtrz.bb remtrz.ba  with frame remtrz.

        /*
        end. /* else */

      if remtrz.cover ne 4  then do:
          */

         update remtrz.bn remtrz.ord with frame remtrz.
          remtrz.ben[1] = trim(remtrz.bn[1]) + " " + trim(remtrz.bn[2])
          + " " + trim(remtrz.bn[3]).
          remtrz.ordcst[1] = remtrz.ord.
      /*    {ordupdp.f}      */
         find bankl where bankl.bank = remtrz.sbank no-lock no-error.
           if available bankl and remtrz.ordins[1] = "" then do:
                       remtrz.ordins[1] = bankl.name.
                       remtrz.ordins[2] = bankl.addr[1].
                       remtrz.ordins[3] = bankl.addr[2].
                       remtrz.ordins[4] = bankl.addr[3].
                    end.
          update
               remtrz.ordins
           /*  remtrz.ordins[1]  */
               with overlay top-only row 8 1 col centered frame ads.
          update
               remtrz.detpay
               with overlay top-only row 8 1 col centered frame adsd.


  do on error undo,retry:
  if remtrz.rcvinfo[1] = "" then remtrz.rcvinfo[1] = remtrz.dracc .

  display      /* O72 - Sender to receivers information */
    remtrz.rcvinfo[1] format "x(35)"
    remtrz.rcvinfo[2] format "x(35)"
    remtrz.rcvinfo[3] format "x(35)"
    remtrz.rcvinfo[4] format "x(35)"
    remtrz.rcvinfo[5] format "x(35)"
    remtrz.rcvinfo[6] format "x(35)"
         with overlay top-only row 13 column 41 no-labels 1 col
         title "Sender to Receiver information"
         frame ff72.

       update      /* O72 - Sender to receivers information */
         remtrz.rcvinfo[1] format "x(35)"
         remtrz.rcvinfo[2] format "x(35)"
         remtrz.rcvinfo[3] format "x(35)"
         remtrz.rcvinfo[4] format "x(35)"
         remtrz.rcvinfo[5] format "x(35)"
         remtrz.rcvinfo[6] format "x(35)"
          with overlay top-only row 13 column 41 no-labels 1 col
          title "Sender to Receiver information"
         frame ff72.
  end. /* do on error */

        if remtrz.bi eq "" and remtrz.svca ne 0 then remtrz.bi = "OUR".
        else remtrz.bi = "NON"  .
         update remtrz.bi validate( remtrz.bi = "BEN" or
          remtrz.bi = "OUR" or remtrz.bi = "NON" ," OUR,BEN,NON ")
           with frame remtrz .
  end.        /* cover ne 4  */


      disp remtrz.bb remtrz.ba remtrz.bn remtrz.ord
       remtrz.bi with frame remtrz.

        /* end of today change  PNP 29/01/96    */
  end.

    else
     if  not (  m_pid eq "3"  and remtrz.rbank = "" ) then

        /* RECEIVER -  OUR BANK  */

 do on error undo ,retry :
      remtrz.cover = 9.
      v-text = "Автоматически изменен транспорт платежа " + remtrz.remtrz + " : receiver = 'o', трансп " + string(remtrz.cover) + " -> 9".
      run lgps.

      display remtrz.cover with frame remtrz. pause 0 .
      remtrz.raddr = "".  remtrz.rcbank = "".
      display /* remtrz.raddr */ remtrz.rcbank with frame remtrz.
      receiver = "o".
    if remtrz.jh2 eq ? then
      update remtrz.crgl validate(can-find(gl where gl.gl = remtrz.crgl ),"")
      with frame remtrz .
      find tgl where tgl.gl = remtrz.crgl no-lock.
      display remtrz.crgl tgl.sub with frame remtrz.
      if tgl.sub ne "" then
      do on error undo,retry :
       if remtrz.jh2 eq ? then
       update remtrz.cracc validate(remtrz.cracc ne "","")
       with frame remtrz .
       find gl where gl.gl = tgl.gl.
       c-acc = remtrz.cracc . {pschk.i} .
       if c-acc = "" then do: bell. undo ,retry . end.
        else do : remtrz.tcrc = vv-crc .
                  remtrz.racc = remtrz.cracc .
                  display remtrz.racc with frame remtrz.
                  find bank.crc where crc.crc = vv-crc.  bcode = crc.code .
                  if tgl.sub = "cif" then do:
                   find first aaa where aaa.aaa = remtrz.cracc no-lock .
                   find cif of aaa no-lock .
                   if remtrz.bn[1] = "" then
                     remtrz.bn[1] = trim(trim(cif.prefix) + " " + trim(cif.name)) + ' /RNN/' + trim(cif.jss).
                  end.
             end.
      end.
       else do: remtrz.cracc = "" .  remtrz.racc  = string(remtrz.crgl) .
                display remtrz.cracc remtrz.racc with frame remtrz.
       if remtrz.jh1 eq ? then
                update remtrz.tcrc validate( can-find(crc where crc.crc =
                                          remtrz.tcrc),"") with frame remtrz.
                find bank.crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
            end.
       display remtrz.tcrc bcode with frame remtrz .
       if remtrz.valdt2 = ? then
       remtrz.valdt2 = remtrz.valdt1  .
       if remtrz.jh2 eq ? then
       update remtrz.valdt2 validate(remtrz.valdt2 >= remtrz.valdt1,
       " Valdt2 < valdt1 ")
       with frame remtrz. pause 0 .
/*    end.      */

               find bankl where bankl.bank = remtrz.rbank no-lock no-error.
               if available bankl then do:
                         remtrz.bb[1] = "/" + bankl.name.
                         remtrz.bb[2] = bankl.addr[1].
                         remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
               end.
         find bankl where bankl.bank = remtrz.sbank  no-lock no-error.
         if available bankl and remtrz.ordins[1] = "" then do:
                       remtrz.ordins[1] = bankl.name.
                       remtrz.ordins[2] = bankl.addr[1].
                       remtrz.ordins[3] = bankl.addr[2].
                       remtrz.ordins[4] = bankl.addr[3].
                    end.
          update
               remtrz.ordins
           /*  remtrz.ordins[1]  */
               with overlay top-only row 8 1 col centered frame ads.
          if remtrz.ba = "" then remtrz.ba = remtrz.racc .
          update remtrz.ba remtrz.bn remtrz.ord with frame remtrz.

display      /* O72 - Sender to receivers information */
    remtrz.rcvinfo[1] format "x(35)"
    remtrz.rcvinfo[2] format "x(35)"
    remtrz.rcvinfo[3] format "x(35)"
    remtrz.rcvinfo[4] format "x(35)"
    remtrz.rcvinfo[5] format "x(35)"
    remtrz.rcvinfo[6] format "x(35)"
         with overlay top-only row 13 column 41 no-labels 1 col
         title "Sender to Receiver information"
         frame ff72.

       update      /* O72 - Sender to receivers information */
         remtrz.rcvinfo[1] format "x(35)"
         remtrz.rcvinfo[2] format "x(35)"
         remtrz.rcvinfo[3] format "x(35)"
         remtrz.rcvinfo[4] format "x(35)"
         remtrz.rcvinfo[5] format "x(35)"
         remtrz.rcvinfo[6] format "x(35)"
          with overlay top-only row 13 column 41 no-labels 1 col
          title "Sender to Receiver information"
         frame ff72.

      disp remtrz.bb remtrz.ba remtrz.bn remtrz.ord
       remtrz.bi with frame remtrz.  pause 0 .
end .
end.       /* end of    receiver = "o" */
           /*
if m_pid <> "S" then do:
    update v-priory validate(lookup(trim(v-priory),prilist) ne 0 ,
    prilist) with frame rortrz.
   end.    */

if remtrz.jh1 eq ? and m_pid <> "S" then do:

do on error undo.
 update remtrz.amt validate ( remtrz.amt >= 0 ," " )
   with frame remtrz .

  if remtrz.amt = 0 then do:
   update remtrz.payment validate ( remtrz.payment > 0, "")
   with frame remtrz .
  end. else remtrz.payment = 0 .
end.
if remtrz.fcrc ne remtrz.tcrc then do on error undo :
                    /*  FOREIGN EXCANGE */

if remtrz.drgl eq v-cashgl then
 b = 2.
 else b = 4.

if remtrz.crgl eq v-cashgl then
 s = 3.
 else s = 5.


find crc where crc.crc = 1 no-lock.
find fcrc where fcrc.crc = remtrz.fcrc no-lock.
vfb-rate = fcrc.rate[b].
vf1-rate = fcrc.rate[1].
find tcrc where tcrc.crc = remtrz.tcrc no-lock.
vts-rate = tcrc.rate[s].
vt1-rate = tcrc.rate[1].


if remtrz.amt eq 0 then do:
 remtrz.amt = round( remtrz.payment * vts-rate / tcrc.rate[9] , crc.decpnt).
 remtrz.amt = round( remtrz.amt / vfb-rate * fcrc.rate[9] , fcrc.decpnt).
end.
else do:
  t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
  remtrz.payment = round(t-pay / vts-rate * tcrc.rate[9] , tcrc.decpnt).
end.
 t-pay = round( remtrz.amt * vfb-rate / fcrc.rate[9] , crc.decpnt).
 remtrz.margb  = round( remtrz.amt * vf1-rate / fcrc.rate[9] , crc.decpnt) -
  t-pay.
 remtrz.margs = round(
  t-pay * ( 1 - vt1-rate / vts-rate ) , crc.decpnt).
  t-pay = margb + margs .

/* end of FOREIGN EXCHANGE */
 end.
 else
 do:
  if remtrz.amt ne 0 then remtrz.payment = remtrz.amt .
     else remtrz.amt = remtrz.payment .
  remtrz.margb = 0.
  remtrz.margs = 0.
 end.
 display remtrz.amt remtrz.payment /* remtrz.margb remtrz.margs t-pay */
   with frame remtrz .

 do on error undo , retry :
 if remtrz.svcrc eq ? or remtrz.svcrc = 0  then remtrz.svcrc = remtrz.fcrc .
 if m_pid <> "S" then do :
   update remtrz.svcrc validate(remtrz.svcrc > 0 ,"" )  with frame remtrz.

   /* определение кода комиссии */
   if remtrz.svccgr = 0 and remtrz.fcrc <> 1 and sender = "o" and receiver = "n" then do:
     find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
     if avail aaa then do:
       /* если это внешний валютный клиентский платеж, то проставить по умолчанию комиссию за счет отправителя */
       {comdef.i &cif = " aaa.cif "}
     end.
   end.

   update remtrz.svccgr validate (chkkomcod (remtrz.svccgr), v-msgerr) with frame remtrz .
   if remtrz.svccgr > 0 then do:
    run comiss2 (output v-komissmin, output v-komissmax).
    find first tarif2 where tarif2.str5 = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
    if avail tarif2 then pakal = tarif2.pakalp .
    display remtrz.svccgl pakal with frame remtrz .

    update remtrz.svca validate (chkkomiss(remtrz.svca), v-msgerr) with frame remtrz.
   end.
 end.

 if remtrz.svca > 0 and m_pid <> "S" then do:

   if sender = "o" and remtrz.dracc ne "" and remtrz.svcrc = remtrz.fcrc
    and remtrz.svcaaa eq "" and
     ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.drgl )
   then  remtrz.svcaaa = remtrz.dracc .

   if receiver = "o" and remtrz.cracc ne "" and remtrz.svcrc = remtrz.tcrc
    and remtrz.svcaaa eq "" and
     ( remtrz.svcgl = 0 or remtrz.svcgl = remtrz.crgl )
   then  remtrz.svcaaa = remtrz.cracc .
   do on error undo,retry :
    update remtrz.svcaaa with frame remtrz.
    if remtrz.svcaaa ne "" then do:
     find first aaa where aaa.aaa = remtrz.svcaaa and aaa.crc = remtrz.svcrc
     no-lock no-error .
     if not avail aaa then undo,retry .
    end.
   end.
   if remtrz.svcaaa eq ""
    then do:

       /*
       if remtrz.svcgl = 0 then remtrz.svcgl = remtrz.drgl .
       do on error undo , retry :
       update remtrz.svcgl with frame remtrz .
        find first gl where gl.gl = remtrz.svcgl and gl.sub = "" no-lock
          no-error .
        if not avail gl then undo , retry .
       end .  */

       remtrz.svcgl = v-cashgl.
       Message " Service charge will be take through CASH G/L !!!! " .
       pause .
      end .
    else
    do :
     find aaa where aaa.aaa = remtrz.svcaaa no-lock .
     remtrz.svcgl = aaa.gl .
    end.
  do on error undo,retry :
  update svccgl  with frame remtrz .

  find first gl where  gl.gl = remtrz.svccgl and gl.sub eq "" no-lock
   no-error .
  if not avail gl then undo,retry .
  end.
 end.
  else
   do:
     remtrz.svcrc = 0 . remtrz.svcgl = 0 . remtrz.svcaaa = "" .
     remtrz.svccgl = 0.
   end.

 display remtrz.svcrc remtrz.svcaaa remtrz.svccgl remtrz.svca with frame remtrz.
end.     /*   undo service charge   */
end .    /*   if jh1 eq ? */


if remtrz.ptype ne "H" and remtrz.ptype ne "M"  then do :
  find first ptyp where ptyp.sender = sender and
  ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then
  remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".
 end .
if sender = "o" and receiver = "o" then remtrz.ptype = "M".


find first ptyp where ptyp.ptype = remtrz.ptype no-lock .
find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error .
display  remtrz.ptype ptyp.des remtrz.cover with frame remtrz.

run rmzque.
