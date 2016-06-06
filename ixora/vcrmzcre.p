/* vcrmzcre.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Процедура формирования REMTRZ для возвратного платежа с транзитного счета
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
 * BASES
        BANK COMM
 * AUTHOR
        28/07/09 galina
        переписала с программы rmzcre.
 * CHANGES
        07/10/2010 galina - счет отправителя и получателя не числовые
                            для филиалов mcbank = TXB00
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
 */
{get-fio.i}
def shared var s-remtrz like remtrz.remtrz.
def shared var m_pid like bank.que.pid.
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var ourbank like bankl.bank no-undo.
def var rcode as int no-undo.
def var rdes  as char no-undo.
def var v-bb  as char no-undo.
def var s-npl as char no-undo.
def var s-rem as char no-undo.
def var s-rsub as char no-undo.
def var ii as integer init 1 no-undo.
def var s-acctype as char no-undo.
def var s-crc as integer no-undo.
def var v-tmpl as char no-undo.
def buffer b-aaa for aaa.
def var mcbank as char.


/* Входные параметры */
def input parameter s-ndoc as char.               /*  1 Номер документа */
def input parameter s-sum as deci.               /*  2 Сумма платежа */
def input parameter s-account as char.           /*  3 Счет отправителя т.е. АРП или текущий счет*/
def input parameter s-rnn as char.               /* 17 РНН отправителя */
def input parameter s-fiozer as char.            /* 18 ФИО отпр. если не найдено в базе RNN */
def input parameter s-rbank as char.             /*  4 Банк получателя */
def input parameter s-racc as char.              /*  5 Счет получателя */
def input parameter s-bn as char format "x(33)". /*  8 получатель */
def input parameter s-bnrnn as char.             /*  9 РНН получателя */
def input parameter s-knp as char format "x(3)". /* 10 KNP */
def input parameter s-kod as char format "x(2)". /* 11 Kod */
def input parameter s-kbe as char format "x(2)". /* 12 Kbe */
def input parameter s-nplin as char.             /* 13 Назначение платежа */
def input parameter s-cov as integer.            /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) 5 -внутр */
def input parameter s-date as date.

define variable v-o as logical no-undo.
define variable s-vtime as integer no-undo. /* время для сверки транспорта */


def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.
def var retval as char init "" no-undo.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval.
else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.


find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " This isn't record OURBNK in sysc file !!".
    pause.
    return retval.
end.
ourbank = trim(sysc.chval).

do trans:
  run n-remtrz.
  create remtrz.
  remtrz.rtim = time.
  remtrz.remtrz = s-remtrz.


  if ourbank = "TXB00" then do:
    find first bankl where bankl.bank = s-rbank and bankl.nu = 'u' no-lock no-error.
    if avail bankl then remtrz.ptype = "4".
    else remtrz.ptype = "6".
  end.
  else remtrz.ptype = "4".


  assign
  remtrz.rsub = s-rsub
  remtrz.rdt = g-today
  remtrz.valdt1 = g-today
  remtrz.rtim = time
  remtrz.rwho = g-ofc
  remtrz.sbank = ourbank
  remtrz.sacc = s-account /*string(integer(s-account), "999999999")*/
  remtrz.racc = s-racc /*string(integer(s-racc), "999999999")*/
  remtrz.dracc = sacc.

/* Получим корсчет банка */

  s-acctype = ''.
  find arp where arp = remtrz.sacc no-lock no-error.
  if avail arp then assign remtrz.drgl = arp.gl s-acctype = "arp" s-crc = arp.crc. /*v-tmpl="PSY0040".*/
  else do:
    find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
    if avail aaa then assign remtrz.drgl = aaa.gl s-acctype = "cif" s-crc = aaa.crc. /*v-tmpl="PSY0042".*/
    else do:
      bell.
      undo.
      return retval.
    end.
  end.

  /*банк получатель*/
  if ourbank <> 'TXB00' and s-crc <> 1 then remtrz.rbank = 'VALOUT'.
  else remtrz.rbank = s-rbank.

  mcbank = if ourbank <> 'txb00' then 'TXB00' else s-rbank.
  find first bankt where bankt.cbank = mcbank and bankt.racc = "1" and bankt.crc = s-crc no-lock no-error.
  remtrz.cracc = bankt.acc .    /*  Корсчет банка */

  if remtrz.ptype = '6' or ourbank <> 'txb00' then do:
    find first dfb where dfb.dfb = bankt.acc no-lock no-error.
    remtrz.crgl = dfb.gl. /* 105100 */
  end.
  else do:
    find first b-aaa where b-aaa.aaa = bankt.acc no-lock no-error.
    remtrz.crgl = b-aaa.gl.
  end.


  /* Kanat - для таможенных и прочих платежей РНН банка отправителя заменяется на РНН самого плательщика */

  if s-acctype = "arp" then do:

    if s-rnn <> "" and s-rnn <> ? then do:

         if trim(s-fiozer) <> "" and s-fiozer <> ? then do:
            remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
            if remtrz.ord = ? then do:
                run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "vcrmzcre.p 154", "1", "", "").
            end.
         end.
         else do:

               find first comm.rnn where comm.rnn.trn = s-rnn no-lock no-error.
               find first comm.rnnu where comm.rnnu.trn = s-rnn no-lock no-error.
               if s-rnn = ? then s-rnn = "".

               if avail rnn then if (comm.rnn.lname + comm.rnn.fname + comm.rnn.mname) = ?
               then do:
                  find current comm.rnn exclusive-lock no-error.
                  if comm.rnn.lname = ? then comm.rnn.lname = " ".
                  if comm.rnn.fname = ? then comm.rnn.fname = " ".
                  if comm.rnn.mname = ? then comm.rnn.mname = " ".
                  find current comm.rnn no-lock no-error.
               end.

               if avail comm.rnnu then if (comm.rnnu.busname) = ?
               then do:
                  find current comm.rnnu exclusive-lock no-error.
                  comm.rnnu.busname = "".
                  find current comm.rnnu no-lock no-error.
               end.

               if avail comm.rnn then remtrz.ord = caps(trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname)) + " /RNN/" + s-rnn.
               else
               if avail comm.rnnu then remtrz.ord = caps(trim(comm.rnnu.busname)) + " /RNN/" + s-rnn.
               else
                  remtrz.ord =  (if s-fiozer <> ? then s-fiozer else "") + " /RNN/" + s-rnn.

               if remtrz.ord = ? then do:
                run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "vcrmzcre.p 181-185", "1", "", "").
               end.

         end. /* s-fiozer */
    end. /* s-rnn */
    else do:
       remtrz.ord = arp.des.
       if remtrz.ord = ? then do:
          run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "vcrmzcre.p 194", "1", "", "").
       end.
    end.
  end.
  else
  if s-acctype = "cif" then do:
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if trim(s-fiozer) <> "" then remtrz.ord = s-fiozer + " /RNN/".
    else do:
      if avail cif then remtrz.ord = caps(trim(cif.name)) + " /RNN/".
      else remtrz.ord = s-fiozer + " /RNN/".
    end.
    if s-rnn <> "" then remtrz.ord = remtrz.ord + s-rnn.
    else do:
      if avail cif then remtrz.ord = remtrz.ord + cif.jss.
      else remtrz.ord = remtrz.ord + s-rnn.
    end.

    if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "vcrmzcre.p 202-211", "1", "", "").
    end.
  end.

  if trim (remtrz.ord) begins "/RNN/" then /* 20/04/06 sasco */
                       message "Внимание! В платеже " s-remtrz " отсутствует ФИО плательщика! " view-as alert-box title "".

  remtrz.amt = s-sum.
  remtrz.payment = s-sum.
  remtrz.svca = 0.
  remtrz.svcp = 0.
  remtrz.fcrc = s-crc.
  remtrz.tcrc = s-crc.
  remtrz.cover = s-cov. /* 2.*/
  remtrz.chg = 7.
  remtrz.outcode = 6.
  remtrz.vcact = g-ofc + "," + string(g-today,'99/99/9999').
  remtrz.info[7] = get-fio(g-ofc).
  find ofc where ofc.ofc eq g-ofc no-lock.
  remtrz.ref = "PU" + string(integer(truncate(ofc.regno / 1000 , 0)),"9999")
    + "    " + remtrz.remtrz + "-S" + trim(remtrz.sbank) +
    fill(" " , 12 - length(trim(remtrz.sbank))) +
    (trim(remtrz.dracc) + fill(" " , 10 - length(trim(remtrz.dracc)))) +
    substring(string(g-today),1,2) + substring(string(g-today),4,2) +
    substring(string(g-today),7,2).
  remtrz.source = "PRR".  /*m_pid + string(integer(truncate(ofc.regno / 1000 , 0)),"99"). 03.11.2003 nadejda */
  remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." + s-ndoc.
  find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
  if not avail bankl then
  find first bankl where substr(bankl.bank,7,3)=remtrz.rbank no-lock no-error.
  if not avail bankl then do: bell. undo. return. end.
  remtrz.rcbank = bankl.cbank.
  remtrz.bb[1] = bankl.name.
  remtrz.bb[2] = bankl.addr[1].
  remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
  find bankl where bankl.bank = remtrz.sbank no-lock no-error.
  if not available bankl then do: bell. undo. return. end.
  remtrz.scbank = bankl.cbank.
  remtrz.ordins[1] = "Зал 1".
  remtrz.ordins[2] = "Департамент ".
  remtrz.ordins[3] = "г.Алматы".
  remtrz.ordins[4] = "KAZAKHSTAN".
  remtrz.ordcst[1] = ord.
  remtrz.bn[1] = s-bn.
  remtrz.bn[3] = " /RNN/" + s-bnrnn.
  remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].
  remtrz.rcvinfo[1] = "".
  remtrz.ba = "/" + remtrz.racc + "/".
  remtrz.rcvinfo[2] = string(s-date).
  v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
  remtrz.actins[1] = "/" + substr(v-bb,1,34) .
  remtrz.actins[2] = substr(v-bb,35,35) .
  remtrz.actins[3] = substr(v-bb,70,35) .
  remtrz.actins[4] = substr(v-bb,105,35) .
  remtrz.actinsact = remtrz.rbank.
  remtrz.detpay[1] = substring(s-nplin, 1, 35).
  remtrz.detpay[2] = substring(s-nplin, 36, 35).
  remtrz.detpay[3] = substring(s-nplin, 71, 35).
  remtrz.detpay[4] = substring(s-nplin, 106, 35).


  find first bankt where bankt.cbank = remtrz.rcbank and bankt.crc = remtrz.tcrc and
  bankt.racc = "1" no-lock no-error.
  if not avail bankt then do:
    message "Отсутствует запись в таблице BANKT!".
    pause.
    undo,return.
  end.

  /*--- sasco : корректировка времени по клирингу */
  s-vtime = bankt.vtime.
  if ourbank <> "TXB00" and bankt.cbank = "TXB00" then do:
     find sysc where sysc.sysc = "PSJTIM" no-lock no-error.
     if avail sysc then s-vtime = sysc.inval.
  end.
  /*---*/

  if remtrz.cover = 1 then do:
    if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
                                else remtrz.valdt2 = g-today + bankt.vdate .
    if remtrz.valdt2 = g-today and
       /* здесь сверяем не с bankt.vtime, s-vtime */
       s-vtime < time then remtrz.valdt2 = remtrz.valdt2 + 1 .
  end.
  else do:
    if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1.
                                else remtrz.valdt2 = g-today.
  end.

  repeat:
    find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
    if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and
       weekday(remtrz.valdt2) le v-weekend then leave.
    else remtrz.valdt2 = remtrz.valdt2 + 1.
  end.

  /* 03.11.2003 nadejda  - если это клиринг, то:
     проверим, работает ли банк-получатель по клирингу - если нет, то отправляем гроссом!
     проверка специально стоит ПОСЛЕ смены даты валютирования - если бы платеж пошел по завтрашнему клирингу,
     то пусть он и по гроссу пойдет завтра с утра, это дешевле будет
  */
  if remtrz.cover = 1 then do:
    find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
    if not avail bankl then do: undo. return. end.
    if bankl.crbank <> "clear" then remtrz.cover = 2.
  end.
  /************************/

  create sub-cod.
  sub-cod.acc = s-remtrz.
  sub-cod.sub = "rmz".
  sub-cod.d-cod = "eknp".
  sub-cod.ccode = "eknp".
  sub-cod.rcode = s-kod + "," + s-kbe + "," + s-knp.

  create sub-cod.
  sub-cod.acc = s-remtrz.
  sub-cod.sub = "rmz".
  sub-cod.d-cod = "pdoctng".
  sub-cod.ccode = '01'.

  run rmzque.
end.



