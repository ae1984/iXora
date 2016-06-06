/* commpl.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Основная процедура формирования REMTRZ
        Применяется при непосредственном зачислении платежей на счета организаций и при зачислении на транз. счета
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
        25.01.02 pragma
 * CHANGES
        07.07.2003 kanat    - добавил новый входной параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
        30.07.2003 kanat    - добавил новый входной параметр при вызове процедуры commpl - ФИО плательщика, у которого РНН = 000000000000
        03.11.2003 nadejda  - 1) при отправке клирингом проверка, работает ли банк-получатель по клирингу - если нет, то отправляем гроссом!
                              2) очередь-источник теперь будет PRR для всех коммунальных платежей - для выделения их в мониторе очередей
        25.12.2003 sasco    - проверка на соответствие счета БИКу
        29.12.2003 sasco    - обработка кодов TXB при проверке счета по БИКу
        31.12.2003 nadejda  - запрет на налоговые платежи 31 декабря
        17.02.2004 kanat    - если не найден РНН плательщика в БД РНН (физ. и юр. лиц), то берется поле s-fiozer (commonpl.fioadr).
        14.03.2004 kanat    - доавил проставление remtrz.ord РНН и наименование плательщиков для прочих платежей, наряду с таможенными плат-ми.
        18.03.2004 sasco    - валюта remtrz (tcrc, fcrc) проставляется по ARP счету
        08.04.2004 isaev    - правильно выставляется кор. счет банка корреспондента
        04.05.2004 nadejda  - исправлена проверка счета налоговых комитетов с 000080000 на ...080...
        06.05.2004 sasco    - переделал проверку на время по клирингу (вместо bankt.vtime вычисляем s-vtime по sysc.PSJTIM)
        11.05.2004 isaev    - кор счет находится по валюте sacc
        17.08.2004 kanat    - добавил формирование ордера на перевод при отправке прочих платежей.
        19.08.2004 kanat    - по просьбе ДРР добавил печать ордеров на перевод при отправке по комм. получателям.
        28.12.2004 kanat    - убрал печать ордеров на перевод для отпрвки таможенных платежей по СЗ ДРР.
        18.12.2005 tsoy     - добавил время создания платежа.
        13.05.2005 kanat    - добавил печать списка платежей для районных таможен по просьбе ДРР
        20.05.2005 kanat    - ФИО плательщика берется из квитанции
        03/03/2006 madiar   - если третьим параметром передается счет ааа, то rmz-ка отправляется с текущего счета
        06/03/2006 madiar   - убрал дебаг-сообщения
        07/03/2006 madiar   - указал правильный номер шаблона для "cif"
        20/04/2006 sasco    - добавил обработку неопределенных (?) значений в таблицах rnn / rnnu
        24/05/2006 marinav  - добавлен параметр даты факт приема платежа
        03/07/2006 sasco    - вместо temp в назначение платежа попадает просто номер телефона
        24/07/2006 tsoy     - Добавил в исключение АРП счет Картела

 */

def new shared var s-remtrz like remtrz.remtrz.
def new shared var s-jh like jh.jh.
def new shared var v-text as char.
def new shared var m_hst as char.
def new shared var m_copy as char.
def new shared var u_pid as char.
def new shared var m_pid like bank.que.pid.
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
/* def var s_cust_arp as char. */
def var s-acctype as char no-undo.
def var s-crc as integer no-undo.
def var v-tmpl as char no-undo.
def buffer b-aaa for aaa.


/* Входные параметры */
def input parameter s-ndoc as int.               /*  1 Номер документа */
def input parameter s-sum as deci.               /*  2 Сумма платежа */
def input parameter s-account as char.           /*  3 Счет отправителя т.е. АРП или текущий счет*/
def input parameter s-rbank as char.             /*  4 Банк получателя */
def input parameter s-racc as char.              /*  5 Счет получателя */

def input parameter s-kb as int.                 /*  6 КБК */
def input parameter s-bud as logical.            /*  7 Тип бюджета - проверяется если есть КБК */

def input parameter s-bn as char format "x(33)". /*  8 Бенефициар */
def input parameter s-bnrnn as char.             /*  9 РНН Бенефициара */

def input parameter s-knp as char format "x(3)". /* 10 KNP */
def input parameter s-kod as char format "x(2)". /* 11 Kod */
def input parameter s-kbe as char format "x(2)". /* 12 Kbe */

def input parameter s-nplin as char.             /* 13 Назначение платежа */

def input parameter s-pid as char format "x(3)". /* 14 Код очереди */
def input parameter s-prn as integer.            /* 15 Кол-во экз. */
def input parameter s-cov as integer.            /* 16 remtrz.cover (для проверки даты валютирования
                                                       т.е. 1-CLEAR00 или 2-SGROSS00) */

def input parameter s-rnn as char.               /* 17 РНН отправителя */
def input parameter s-fiozer as char.            /* 18 ФИО отпр. если не найдено в базе RNN */
def input parameter s-date as date.

define variable v-o as logical no-undo.
define variable s-vtime as integer no-undo. /* sasco - время для сверки транспорта */

if s-kb <> 0 and month(g-today) = 12 and day(g-today) = 31 then do:
  message "Запрещено отправлять казначейские платежи в последний день года!" view-as alert-box title "Happy New Year".
  return.
end.

/*
find first sysc where sysc = "cstarp" no-lock no-error.
if avail sysc then do:
s_cust_arp = sysc.chval.
end.
*/

/* Выбираем полочку для операционниста */
/*
if s-cov = 5 and substr(s-rbank,1,3) = "TXB"
     then s-rsub = "cif".
     else s-rsub = "".
*/
s-rsub = 'cif'.

def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.
def var retval as char init "" no-undo.

m_pid = s-pid.   /* Код очереди */

/* Проверка на БИК / счет */
run acc-ctr(string(integer(s-racc), "999999999"), s-rbank, output v-o).
if not v-o and SUBSTR (CAPS(s-rbank), 1, 3) <> "TXB" then do:
   message "Счет " s-racc " не соответствует БИК " s-rbank.
   m_pid = "31".
end.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.


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
  end. else
    remtrz.ptype = "4".


  assign
  remtrz.rsub = s-rsub
  remtrz.rdt = g-today
  remtrz.valdt1 = g-today
  remtrz.rtim = time
  remtrz.rwho = g-ofc
  remtrz.sbank = ourbank
  remtrz.rbank = s-rbank
  remtrz.sacc = string(integer(s-account), "999999999")
  remtrz.racc = string(integer(s-racc), "999999999")
  remtrz.dracc = sacc.

/* Получим корсчет банка */

  s-acctype = ''.
  find arp where arp = remtrz.sacc no-lock no-error.
  if avail arp then assign remtrz.drgl = arp.gl s-acctype = "arp" s-crc = arp.crc v-tmpl="PSY0040".
  else do:
    find aaa where aaa.aaa = remtrz.sacc no-lock no-error.
    if avail aaa then assign remtrz.drgl = aaa.gl s-acctype = "cif" s-crc = aaa.crc v-tmpl="PSY0042".
    else do: bell. undo. return retval. end.
  end.

  def var mcbank as char.
  mcbank = if remtrz.ptype = '6' or ourbank <> 'txb00' then ourbank else s-rbank.
  find first bankt where bankt.cbank = mcbank
                   and bankt.racc = "1"
                   and bankt.crc = s-crc
                   no-lock no-error.

  remtrz.cracc = bankt.acc .    /*  Корсчет банка "900161014" */

  if remtrz.ptype = '6' or ourbank <> 'txb00' then do:
    find first dfb where dfb.dfb = bankt.acc no-lock no-error.
    remtrz.crgl = dfb.gl. /* 105100 */

  end. else do:
    find first b-aaa where b-aaa.aaa = bankt.acc no-lock no-error.
    remtrz.crgl = b-aaa.gl.
  end.


  /* Kanat - для таможенных и прочих платежей РНН банка отправителя заменяется на РНН самого плательщика */

  if s-acctype = "arp" then do:

    if s-rnn <> "" and s-rnn <> ? then do:

    if trim(s-fiozer) <> "" and s-fiozer <> ? then do:
     remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
     if remtrz.ord = ? then do:
        run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "commpl.p 220", "1", "", "").
     end.
    end.
    else do:

    find first comm.rnn where comm.rnn.trn = s-rnn no-lock no-error.
    find first comm.rnnu where comm.rnnu.trn = s-rnn no-lock no-error.


    /* 20/04/06 sasco -> проверка на неопределенное значение -------------------*/
    if s-rnn = ? then s-rnn = "".

    if avail rnn then if (comm.rnn.lname + comm.rnn.fname + comm.rnn.mname) = ?
    then do transaction:
       find current comm.rnn exclusive-lock no-error.
       if comm.rnn.lname = ? then comm.rnn.lname = " ".
       if comm.rnn.fname = ? then comm.rnn.fname = " ".
       if comm.rnn.mname = ? then comm.rnn.mname = " ".
       find current comm.rnn no-lock no-error.
    end.

    if avail comm.rnnu then if (comm.rnnu.busname) = ?
    then do transaction:
       find current comm.rnnu exclusive-lock no-error.
       comm.rnnu.busname = "".
       find current comm.rnnu no-lock no-error.
    end.
    /* <- 20/04/06 sasco --------------------------------------------------------*/


    if avail comm.rnn then remtrz.ord = caps(trim(comm.rnn.lname) + " " + trim(comm.rnn.fname) + " " + trim(comm.rnn.mname)) + " /RNN/" + s-rnn.
    else
    if avail comm.rnnu then remtrz.ord = caps(trim(comm.rnnu.busname)) + " /RNN/" + s-rnn.
    else
       remtrz.ord =  (if s-fiozer <> ? then s-fiozer else "") + " /RNN/" + s-rnn.

    end. /* s-fiozer */
    end. /* s-rnn */
    else do:
       remtrz.ord = arp.des.
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
  end.

  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "commpl.p 250-275", "1", "", "").
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
  find ofc where ofc.ofc eq g-ofc no-lock.
  remtrz.ref = "PU" + string(integer(truncate(ofc.regno / 1000 , 0)),"9999")
    + "    " + remtrz.remtrz + "-S" + trim(remtrz.sbank) +
    fill(" " , 12 - length(trim(remtrz.sbank))) +
    (trim(remtrz.dracc) + fill(" " , 10 - length(trim(remtrz.dracc)))) +
    substring(string(g-today),1,2) + substring(string(g-today),4,2) +
    substring(string(g-today),7,2).
  remtrz.source = "PRR".  /*m_pid + string(integer(truncate(ofc.regno / 1000 , 0)),"99"). 03.11.2003 nadejda */
  remtrz.sqn = trim(ourbank) + "." + trim(remtrz.remtrz) + ".." +
      trim(string(s-ndoc, ">>>>>>>>9" )).
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
  remtrz.ordins[2] = "Департамент 1".
  remtrz.ordins[3] = "г.Алматы".
  remtrz.ordins[4] = "KAZAKHSTAN".
  remtrz.ordcst[1] = ord.
  remtrz.bn[1] = s-bn.
  remtrz.bn[3] = " /RNN/" + s-bnrnn.
  remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].

  if s-kb = 0 then do:
                      remtrz.rcvinfo[1] = "".
                      remtrz.ba = "/" + remtrz.racc + "/".
                     end.
                else do:
                      remtrz.rcvinfo[1] = "/TAX/" .
                      remtrz.ba = "/" + remtrz.racc + "/" + string(s-kb, "999999" ).
                     end.

  remtrz.rcvinfo[2] = string(s-date).
  v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
  remtrz.actins[1] = "/" + substr(v-bb,1,34) .
  remtrz.actins[2] = substr(v-bb,35,35) .
  remtrz.actins[3] = substr(v-bb,70,35) .
  remtrz.actins[4] = substr(v-bb,105,35) .
  remtrz.actinsact = remtrz.rbank.

  find first budcode where code = s-kb use-index code no-lock no-error .

  if avail budcode /* and (s-account <> "000904883" or s-account <> "000904786" ) */
   then do:
    s-npl = budcode.name.
    if budcode.hand then s-npl = s-npl + " (" + (if s-bud then "местный" else "республиканский") + " бюджет)".
  end.

  s-npl = trim(s-npl) + " " + s-nplin.
  remtrz.detpay[1] = substring(s-npl, 1, 35).
  remtrz.detpay[2] = substring(s-npl, 36, 35).
  remtrz.detpay[3] = substring(s-npl, 71, 35).
  remtrz.detpay[4] = substring(s-npl, 106, 35).

  s-rem = remtrz.remtrz + " " + s-npl.
  if s-acctype = "arp" then s-rem = s-rem + " " + arp.des.
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

  run rmzque.
end.

if  m_pid <> "31" then do:

do trans:

    find first remtrz where remtrz.remtrz = s-remtrz share-lock.

    find first que of remtrz share-lock.

    s-jh = 0.
    def var dlm as char init "|".


    run trxgen(v-tmpl, dlm,
    remtrz.remtrz + dlm +
    string(remtrz.amt) + dlm +        /* Summa */
    s-account + dlm +
    substr(s-rem, 1, 55 ) + dlm +
    substr(s-rem, 56, 55 ) + dlm +
    substr(s-rem, 111, 55 ) + dlm +
    substr(s-rem, 166, 55 ) + dlm +
    substr(s-rem, 221, 55 ),
     "rmz", remtrz.remtrz, output rcode, output rdes, input-output s-jh).

    if rcode ne 0 then do :
        message rcode " " rdes view-as alert-box buttons ok.
        pause 1000.
        delete remtrz.
        v-text = " Ошибка проводки rcode = " +
        string(rcode) + ":" +
        rdes + " " + remtrz.remtrz + " " + remtrz.dracc .
        message v-text. pause.
        return.
    end.
    remtrz.jh1 = s-jh.
    retval = remtrz.remtrz.
    release remtrz.
    release que.

end.

  if s-acctype = "arp" then do:
    if (ourbank = "txb00" and s-account <> "011999832" and s-account <> "002076162" and s-account <> "000076261" and s-account <> "000904883" and s-account <> "000904786" and s-account <> "001076668" and not s-racc matches "...080...") or ourbank <> "txb00" then run x-jlvouPl.
  end.
  else if s-acctype = "cif" then run x-jlvouPl.

  /* Штампует транзакцию */
  find first jh where jh.jh = s-jh no-error.
  if available jh and jh.sts = 5 then do:
       for each jl of jh:
          jl.sts = 6.
          jl.teller = g-ofc.
       end.
       jh.sts = 6.
  end.
/*    run jl-stmp.*/

do ii=1 to s-prn:
    run payprn.
end.

end. /* проверка на соответствие БИК */
else do:
   v-text = remtrz.remtrz + "Несоответствие счета получателя БИКу! Перенос на 31 очередь".
   run lgps.
   retval = remtrz.remtrz.
   release remtrz.
   release que.
end.

return retval.
