/* taxpl.p
 * MODULE
        Налоговые платежи
 * DESCRIPTION
        Формирование REMTRZ для отправки налоговых платежей
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
        05.11.2003 nadejda  - очередь-источник теперь будет PRR для всех коммунальных платежей - для выделения их в мониторе очередей
        24.11.2003 sasco    - отменил печать квитков RMZ для Уральска
        25.12.2003 sasco    - проверка на соответствие счета БИКу
        29.12.2003 sasco    - обработка кодов TXB при проверке счета по БИКу
        31.12.2003 nadejda  - запрет на налоговые платежи 31 декабря
        17.02.2004 kanat    - если РНН налогплательщика <> 000000000000 и РНН не найден в БД в comm, то все равно берется наименование
                              из поля s-fiozer
        04.05.2004 nadejda  - исправлена проверка счета налоговых комитетов с 000080000 на ...080...
        06.05.2004 sasco    - переделал проверку на время по клирингу (вместо bankt.vtime вычисляем s-vtime по sysc.PSJTIM)
        18.12.2005 tsoy     - добавил время создания платежа.
        20.05.2005 kanat    - ФИО плательшика берется из ФИО квитанции
        20/04/2006 sasco    - добавил обработку неопределенных (?) значений в таблицах rnn / rnnu
        21/04/06 marinav    - в назначении платежа указывать ФИО и РНН
        12/05/2006 sasco    - убрал окно с предупреждением об отсутствующем ФИО (просьба Баталовой П.С.)
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/

{comm-txb.i}

define variable seltxb as int.
seltxb = comm-cod().

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

define variable s-vtime as integer no-undo. /* sasco - время для сверки транспорта */

/* Входные параметры */
def input parameter s-ndoc as int.    /* Номер документа */
def input parameter s-sum as deci.    /* Сумма платежа */
def input parameter s-arp as char.    /* Счет отправителя т.е. АРП счет */
def input parameter s-rbank as char.  /* Банк получателя */
def input parameter s-racc as char.   /* Счет получателя */
def input parameter s-kb as int.      /* КБК */
def input parameter s-bud as logical. /* Тип бюджета - проверяется если есть КБК */
def input parameter s-bn as char format "x(33)".     /* Бенефициар */
def input parameter s-bnrnn as char.  /* РНН Бенефициара */
def input parameter s-knp as char format "x(3)".  /* KNP */
def input parameter s-kod as char format "x(2)".  /* Kod */
def input parameter s-kbe as char format "x(2)".  /* Kbe */
def input parameter s-nplin as char.  /* Назначение платежа */
def input parameter s-pid as char format "x(3)". /* Код очереди */
def input parameter s-prn as integer. /* Кол-во экз. */
def input parameter s-cov as integer. /* remtrz.cover (для проверки даты валютирования
                                         т.е. 1-CLEAR00 или 2-SGROSS00) */
def input parameter s-rnn as char.    /* РНН отправителя */
def input parameter s-fiozer as char.
def input parameter s-date as date.

if s-kb <> 0 and month(g-today) = 12 and day(g-today) = 31 then do:
  message "Запрещено отправлять казначейские платежи в последний день года!" view-as alert-box title "Happy New Year".
  return.
end.

if s-cov = 5 and substr(s-rbank,1,3) = "TXB"
     then s-rsub = "cif". /* Выбираем полочку для операционниста */
     else s-rsub = "".

def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.
def var retval as char init '' no-undo.

define variable v-o as logical no-undo.

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

find first comm.rnn where comm.rnn.trn = s-rnn no-lock no-error.
find first comm.rnnu where comm.rnnu.trn = s-rnn no-lock no-error.

/* 20/04/06 sasco -> проверка на неопределенное значение ------------------------ */
if s-rnn = ? then s-rnn = "".

if avail comm.rnn then if (comm.rnn.lname + comm.rnn.fname + comm.rnn.mname) = ?
then do transaction:
   find current comm.rnn exclusive-lock no-error.
   if comm.rnn.lname = ? then comm.rnn.lname = " ".
   if comm.rnn.fname = ? then comm.rnn.fname = " ".
   if comm.rnn.mname = ? then comm.rnn.mname = " ".
   find current comm.rnn no-lock no-error.
end.

if avail comm.rnnu then if comm.rnnu.busname = ?
then do transaction:
   find current comm.rnnu exclusive-lock no-error.
   comm.rnnu.busname = "".
   find current comm.rnnu no-lock no-error.
end.
/* <- 20/04/06 sasco ------------------------------------------------------------- */

do trans:
  run n-remtrz.
  create remtrz.
  remtrz.rtim = time.

  remtrz.remtrz = s-remtrz.

  if ourbank = "TXB00" then remtrz.ptype = "6".
                       else remtrz.ptype = "4".
  assign
  remtrz.rsub = s-rsub
  remtrz.rdt = g-today
  remtrz.valdt1 = g-today
  remtrz.rtim = time
  remtrz.rwho = g-ofc
  remtrz.sbank = ourbank
  remtrz.rbank = s-rbank
  remtrz.sacc = string(integer(s-arp), "999999999")
  remtrz.racc = string(integer(s-racc), "999999999")
  remtrz.dracc = sacc.

/* Получим корсчет банка */
  find first bankt where bankt.cbank = ourbank and bankt.racc = "1" no-lock no-error .
  remtrz.cracc = bankt.acc .    /*  Корсчет банка "900161014" */

  find first dfb where dfb.dfb = bankt.acc no-lock no-error.
  remtrz.crgl = dfb.gl. /* 105100 */

  find arp where arp = sacc no-lock no-error.
  if not avail arp then do: bell. undo. return retval. end.
  remtrz.drgl = arp.gl.


        if s-rnn = "000000000000" then do:
           if s-fiozer <> ? then remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
                            else do: /* 20/04/06 sasco */
                                 /*
                                 message "Внимание ! В платеже " s-remtrz " отсутствует ФИО плательщика! " view-as alert-box title "".
                                 */
                                 remtrz.ord =  "/RNN/" + s-rnn.
                            end.
              if remtrz.ord = ? then do:
                run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "taxpl.p 179-184", "1", "", "").
              end.

        end.
        else do:

        if trim(s-fiozer) <> "" and s-fiozer <> ? then
        remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
        else do:

  if avail rnn then remtrz.ord = caps(trim( comm.rnn.lname ) + " " + trim( comm.rnn.fname ) + " " + trim( comm.rnn.mname )) + " /RNN/" + s-rnn.
  else
  if avail rnnu then remtrz.ord = caps(trim( comm.rnnu.busname )) + " /RNN/" + s-rnn.
  else
     remtrz.ord =  (if s-fiozer <> ? then s-fiozer else "") + " /RNN/" + s-rnn.

        /* 20/04/06 sasco */
        /*
        if trim (remtrz.ord) begins "/RNN/" then
                        message "Внимание! В платеже " s-remtrz " отсутствует ФИО плательщика! " view-as alert-box title "".
        */
        end.
        end.


  if remtrz.ord = ? then do:
    run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "taxpl.p 194-201", "1", "", "").
  end.

  remtrz.amt = s-sum.
  remtrz.payment = s-sum.
  remtrz.svca = 0.
  remtrz.svcp = 0.
  remtrz.fcrc = 1.
  remtrz.tcrc = 1.
  remtrz.cover = s-cov. /* 2.*/
  remtrz.chg = 7.
  remtrz.outcode = 6.
  find ofc where ofc.ofc eq g-ofc no-lock.
  remtrz.ref = 'PU' + string(integer(truncate(ofc.regno / 1000 , 0)),'9999')
    + '    ' + remtrz.remtrz + '-S' + trim(remtrz.sbank) +
    fill(' ' , 12 - length(trim(remtrz.sbank))) +
    (trim(remtrz.dracc) + fill(' ' , 10 - length(trim(remtrz.dracc)))) +
    substring(string(g-today),1,2) + substring(string(g-today),4,2) +
    substring(string(g-today),7,2).
  remtrz.source = "PRR".  /*m_pid + string(integer(truncate(ofc.regno / 1000 , 0)),'99').*/
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

  if avail budcode and (s-arp <> '000904883' or s-arp <> '000904786' )
   then do:
    s-npl = budcode.name.
    if budcode.hand then s-npl = s-npl + " (" + (if s-bud then "местный" else "республиканский") + " бюджет)".
  end.

  s-npl = trim(s-npl) + " " + s-nplin.
  /* 21/04/06 marinav - в назначении платежа указывать ФИО и РНН */
  if s-kb = 201501 then s-npl = s-npl + ' ' + remtrz.ord.

  remtrz.detpay[1] = substring(s-npl, 1, 35).
  remtrz.detpay[2] = substring(s-npl, 36, 35).
  remtrz.detpay[3] = substring(s-npl, 71, 35).
  remtrz.detpay[4] = substring(s-npl, 106, 35).

  s-rem = remtrz.remtrz + " " + s-npl + " " + arp.des.
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
    if remtrz.valdt1 >= g-today then  remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
                                else  remtrz.valdt2 = g-today + bankt.vdate .
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

  create sub-cod.
  sub-cod.acc = s-remtrz.
  sub-cod.sub = 'rmz'.
  sub-cod.d-cod = 'eknp'.
  sub-cod.ccode = 'eknp'.
  sub-cod.rcode = s-kod + ',' + s-kbe + ',' + s-knp.

  run rmzque.
end.

if m_pid <> "31" then do:

do trans:

    find first remtrz where remtrz.remtrz = s-remtrz share-lock.
    find first que of remtrz share-lock.

    s-jh = 0.
    def var dlm as char init "|".
    run trxgen("PSY0040", dlm,
    remtrz.remtrz + dlm +
    string(remtrz.amt) + dlm +        /* Summa */
    s-arp + dlm +
    substr(s-rem, 1, 55 ) + dlm +
    substr(s-rem, 56, 55 ) + dlm +
    substr(s-rem, 111, 55 ) + dlm +
    substr(s-rem, 166, 55 ) + dlm +
    substr(s-rem, 221, 55 ),
     "rmz", remtrz.remtrz, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do :
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

  /* проверка на счета для Алматы и на Уральск */
  if (s-arp <> '000904883' and s-arp <> '000904786' and (seltxb <> 0 or not s-racc matches '...080...')) and seltxb <> 2 then run x-jlvouPl.

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
