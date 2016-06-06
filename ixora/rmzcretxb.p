/* rmzcretxb.p
 * MODULE
        Платежные системы
 * DESCRIPTION
        Основная процедура формирования REMTRZ
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
        BANK COMM TXB
 * AUTHOR
        25/07/08
 * CHANGES
        05.10.10 marinav - название банка плательщика всегда ForteBank
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
 */
{nbankBik-txb.i}
def new shared var s-remtrz like bank.remtrz.remtrz.
def new shared var s-jh like bank.jh.jh.
def new shared var v-text as char.
def new shared var m_pid like bank.que.pid.
def shared var g-ofc like bank.ofc.ofc.
def shared var g-today as date.
def var ourbank like bank.bankl.bank no-undo.
def var rcode as int no-undo.
def var rdes  as char no-undo.
def var v-bb  as char no-undo.
def var s-npl as char no-undo.
def var s-rem as char no-undo.
def var ii as integer init 1 no-undo.
def var s-acctype as char no-undo.
def var s-crc as integer no-undo.
def var v-tmpl as char no-undo.
def buffer b-aaa for txb.aaa.


/* Входные параметры */
def input parameter s-ndoc as int.               /*  1 Номер документа */
def input parameter s-sum as deci.               /*  2 Сумма платежа */
def input parameter s-account as char.           /*  3 Счет отправителя т.е. АРП или текущий счет*/
def input parameter s-rnn as char.               /* 17 РНН отправителя */
def input parameter s-fiozer as char.            /* 18 ФИО отпр. если не найдено в базе RNN */

def input parameter s-rbank as char.             /*  4 Банк получателя */
def input parameter s-racc as char.              /*  5 Счет получателя */
def input parameter s-bn as char format "x(33)". /*  8 получатель */
def input parameter s-bnrnn as char.             /*  9 РНН получателя */

def input parameter s-kb as int.                 /*  6 КБК */
def input parameter s-bud as logical.            /*  7 Тип бюджета - проверяется если есть КБК */
def input parameter s-knp as char format "x(3)". /* 10 KNP */
def input parameter s-kod as char format "x(2)". /* 11 Kod */
def input parameter s-kbe as char format "x(2)". /* 12 Kbe */
def input parameter s-nplin as char.             /* 13 Назначение платежа */
def input parameter s-pid as char format "x(3)". /* 14 Код очереди */
def input parameter s-prn as integer.            /* 15 Кол-во экз. */
def input parameter s-cov as integer.            /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) 5 -внутр */
def input parameter s-date as date.
def input parameter s-rsub as char . /* Полочка */

define variable v-o as logical no-undo.
define variable s-vtime as integer no-undo. /* sasco - время для сверки транспорта */

/* Выбираем полочку для операционниста */
/*
if s-cov = 5 and substr(s-rbank,1,3) = "TXB"
     then s-rsub = "cif".
     else s-rsub = "".
*/

def var v-weekbeg as int no-undo.
def var v-weekend as int no-undo.
def var retval as char init "" no-undo.

m_pid = s-pid.   /* Код очереди */

find bank.sysc "WKEND" no-lock no-error.
if available bank.sysc then v-weekend = bank.sysc.inval. else v-weekend = 6.

find bank.sysc "WKSTRT" no-lock no-error.
if available bank.sysc then v-weekbeg = bank.sysc.inval. else v-weekbeg = 2.


find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if not avail txb.sysc or txb.sysc.chval = "" then do:
    display " This isn't record OURBNK in sysc file !!".
    pause.
    return retval.
end.
ourbank = trim(txb.sysc.chval).

do trans:
    find txb.nmbr where txb.nmbr.code eq "REMTRZ" exclusive-lock no-error.
    s-remtrz = txb.nmbr.prefix + string(txb.nmbr.nmbr,txb.nmbr.fmt) + txb.nmbr.sufix.
    txb.nmbr.nmbr = txb.nmbr.nmbr + 1.
    release txb.nmbr.

    create txb.remtrz.
    txb.remtrz.rtim = time.
    txb.remtrz.remtrz = s-remtrz.
    txb.remtrz.ptype = "4".

     assign
     txb.remtrz.rsub = s-rsub
     txb.remtrz.rdt = g-today
     txb.remtrz.valdt1 = g-today
     txb.remtrz.rtim = time
     txb.remtrz.rwho = g-ofc
     txb.remtrz.sbank = ourbank
     txb.remtrz.rbank = s-rbank
     txb.remtrz.sacc = s-account
     txb.remtrz.racc = s-racc
     txb.remtrz.dracc = sacc.

/* Получим корсчет банка */

  s-acctype = "".
  find txb.arp where txb.arp.arp = txb.remtrz.sacc no-lock no-error.
  if avail txb.arp then assign txb.remtrz.drgl = txb.arp.gl s-acctype = "arp" s-crc = txb.arp.crc.
  else do:
    find txb.aaa where txb.aaa.aaa = txb.remtrz.sacc no-lock no-error.
    if avail txb.aaa then assign txb.remtrz.drgl = txb.aaa.gl s-acctype = "cif" s-crc = txb.aaa.crc .
    else do: bell. undo. return retval. end.
  end.

  def var mcbank as char.
  mcbank = if ourbank <> 'txb00' then 'TXB00' else s-rbank.
  find first txb.bankt where txb.bankt.cbank = mcbank
                   and txb.bankt.racc = "1"
                   and txb.bankt.crc = s-crc
                   no-lock no-error.

  txb.remtrz.cracc = txb.bankt.acc .    /*  Корсчет банка */

  if ourbank <> 'txb00' then do:
    find first txb.dfb where txb.dfb.dfb = txb.bankt.acc no-lock no-error.
    txb.remtrz.crgl = txb.dfb.gl. /* 105100 */
  end.
  else do:
    find first b-aaa where b-aaa.aaa = txb.bankt.acc no-lock no-error.
    txb.remtrz.crgl = b-aaa.gl.
  end.


  if s-acctype = "arp" then do:

    if s-rnn <> "" and s-rnn <> ? then do:
         if trim(s-fiozer) <> "" and s-fiozer <> ? then do:
           txb.remtrz.ord =  s-fiozer + " /RNN/" + s-rnn.
           if txb.remtrz.ord = ? then do:
              run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "rmzcretxb.p 156", "1", "", "").
           end.
         end.
    end. /* s-rnn */
    else do:
       txb.remtrz.ord = txb.arp.des.
       if txb.remtrz.ord = ? then do:
         run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "rmzcretxb.p 163", "1", "", "").
       end.
    end.
  end.
  else
  if s-acctype = "cif" then do:

    find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if trim(s-fiozer) <> "" then txb.remtrz.ord = s-fiozer + " /RNN/".
    else do:
      if avail txb.cif then txb.remtrz.ord = caps(trim(txb.cif.name)) + " /RNN/".
      else txb.remtrz.ord = s-fiozer + " /RNN/".
    end.
    if s-rnn <> "" then txb.remtrz.ord = txb.remtrz.ord + s-rnn.
    else do:
      if avail txb.cif then txb.remtrz.ord = txb.remtrz.ord + txb.cif.jss.
      else txb.remtrz.ord = txb.remtrz.ord + s-rnn.
    end.

    if txb.remtrz.ord = ? then do:
      run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "rmzcretxb.p 173-181", "1", "", "").
    end.
  end.


  txb.remtrz.amt = s-sum.
  txb.remtrz.payment = s-sum.
  txb.remtrz.svca = 0.
  txb.remtrz.svcp = 0.
  txb.remtrz.fcrc = s-crc.
  txb.remtrz.tcrc = s-crc.
  txb.remtrz.cover = s-cov. /* 2.*/
  txb.remtrz.chg = 7.
  txb.remtrz.outcode = 6.

  find txb.ofc where ofc.ofc eq 'superman' no-lock.
  txb.remtrz.ref = "PU" + string(integer(truncate(txb.ofc.regno / 1000 , 0)),"9999")
    + "    " + txb.remtrz.remtrz + "-S" + trim(txb.remtrz.sbank) +
    fill(" " , 12 - length(trim(txb.remtrz.sbank))) +
    (trim(txb.remtrz.dracc) + fill(" " , 10 - length(trim(txb.remtrz.dracc)))) +
    substring(string(g-today),1,2) + substring(string(g-today),4,2) +
    substring(string(g-today),7,2).
  txb.remtrz.source = "PRR".
  txb.remtrz.sqn = trim(ourbank) + "." + trim(txb.remtrz.remtrz) + ".." +
      trim(string(s-ndoc, ">>>>>>>>9" )).
  find first txb.bankl where txb.bankl.bank = txb.remtrz.rbank no-lock no-error.
  if not avail txb.bankl then
  find first txb.bankl where substr(txb.bankl.bank,7,3)=txb.remtrz.rbank no-lock no-error.
  if not avail txb.bankl then do: bell. undo. return. end.
  txb.remtrz.rcbank = txb.bankl.cbank.
  txb.remtrz.bb[1] = txb.bankl.name.
  txb.remtrz.bb[2] = txb.bankl.addr[1].
  txb.remtrz.bb[3] = txb.bankl.addr[2] + " " + txb.bankl.addr[3].
  find txb.bankl where txb.bankl.bank = txb.remtrz.sbank no-lock no-error.
  if not available txb.bankl then do: bell. undo. return. end.
  txb.remtrz.scbank = txb.bankl.cbank.
  txb.remtrz.ordins[1] = v-nbankru.
  txb.remtrz.ordins[2] = "".
  txb.remtrz.ordins[3] = "".
  txb.remtrz.ordins[4] = "".
  txb.remtrz.ordcst[1] = ord.
  txb.remtrz.bn[1] = s-bn.
  txb.remtrz.bn[3] = " /RNN/" + s-bnrnn.
  txb.remtrz.ben[1] = txb.remtrz.bn[1] + txb.remtrz.bn[3].

  if s-kb = 0 then do:
                      txb.remtrz.rcvinfo[1] = "".
                      txb.remtrz.ba = "/" + txb.remtrz.racc + "/".
                     end.
                else do:
                      txb.remtrz.rcvinfo[1] = "/TAX/" .
                      txb.remtrz.ba = "/" + txb.remtrz.racc + "/" + string(s-kb, "999999" ).
                     end.

  txb.remtrz.rcvinfo[2] = string(s-date).
  v-bb = trim(bb[1]) + " " + trim(bb[2]) + " " + trim(bb[3]) .
  txb.remtrz.actins[1] = "/" + substr(v-bb,1,34) .
  txb.remtrz.actins[2] = substr(v-bb,35,35) .
  txb.remtrz.actins[3] = substr(v-bb,70,35) .
  txb.remtrz.actins[4] = substr(v-bb,105,35) .
  txb.remtrz.actinsact = txb.remtrz.rbank.

  find first txb.budcode where txb.budcode.code = s-kb use-index code no-lock no-error .

  if avail txb.budcode
   then do:
    s-npl = txb.budcode.name.
    if txb.budcode.hand then s-npl = s-npl + " (" + (if s-bud then "местный" else "республиканский") + " бюджет)".
  end.

  s-npl = trim(s-npl) + " " + s-nplin.
  txb.remtrz.detpay[1] = substring(s-npl, 1, 35).
  txb.remtrz.detpay[2] = substring(s-npl, 36, 35).
  txb.remtrz.detpay[3] = substring(s-npl, 71, 35).
  txb.remtrz.detpay[4] = substring(s-npl, 106, 35).

  s-rem = txb.remtrz.remtrz + " " + s-npl.
  if s-acctype = "arp" then s-rem = s-rem + " " + txb.arp.des.
  find first txb.bankt where txb.bankt.cbank = txb.remtrz.rcbank and txb.bankt.crc = txb.remtrz.tcrc and
  txb.bankt.racc = "1" no-lock no-error.
  if not avail txb.bankt then do:
    message "Отсутствует запись в таблице BANKT!".
    pause.
    undo,return.
  end.


    if txb.remtrz.valdt1 >= g-today then txb.remtrz.valdt2 = txb.remtrz.valdt1.
                                    else txb.remtrz.valdt2 = g-today.

  repeat:
    find txb.hol where txb.hol.hol eq txb.remtrz.valdt2 no-lock no-error.
    if not available txb.hol and weekday(txb.remtrz.valdt2) ge v-weekbeg and
       weekday(txb.remtrz.valdt2) le v-weekend then leave.
    else txb.remtrz.valdt2 = txb.remtrz.valdt2 + 1.
  end.

  /************************/

  create txb.sub-cod.
  txb.sub-cod.acc = s-remtrz.
  txb.sub-cod.sub = "rmz".
  txb.sub-cod.d-cod = "eknp".
  txb.sub-cod.ccode = "eknp".
  txb.sub-cod.rcode = s-kod + "," + s-kbe + "," + s-knp.

  if txb.remtrz.rbank begins "TXB" then do:
      find first txb.sub-cod where txb.sub-cod.sub = "rmz" and txb.sub-cod.acc = s-remtrz and txb.sub-cod.d-cod = 'pdoctng' exclusive-lock no-error.
      if not available txb.sub-co then do:
          create txb.sub-cod.
          txb.sub-cod.acc = s-remtrz.
          txb.sub-cod.sub = "rmz".
          txb.sub-cod.d-cod = "pdoctng".
      end.
      if txb.remtrz.fcrc = 1 then txb.sub-cod.ccode = "01". /* платежное поручение */
      else txb.sub-cod.ccode = "19". /* Иные способы */
  end.


def var v-propath as char no-undo.
v-propath = propath. /* так как нам будут мешаться тригеры , перенаправим путь к библиотеке в каталог в котором лежат эти тригеры откомпиленые под логическое имя txb*/
propath = "/pragma/lib/RX/rcode_debug/for_trg" no-error.

  create txb.que.
  txb.que.remtrz = txb.remtrz.remtrz.
  txb.que.pid = m_pid.
  txb.remtrz.remtrz = txb.que.remtrz .
  txb.que.ptype = txb.remtrz.ptype.
  txb.que.rcod = "99".
  txb.que.con = "W".
  txb.que.dp = today.
  txb.que.tp = time.
  txb.que.df = today.
  txb.que.tf = time.
  txb.que.dw = today.
  txb.que.tw = time.
  txb.que.pvar = " , , , , ,".
  txb.que.pri = 29999 .
  txb.que.ptype = txb.remtrz.ptype .
  txb.que.rcod = "99" .
  txb.que.dp = today.
  txb.que.tp = time.
  txb.que.dw = today.
  txb.que.tw = time.
end .

propath = v-propath no-error. /*вернем старый путь к библотеки на "родину"*/

   retval = txb.remtrz.remtrz.
   release remtrz.
   release que.


return retval.


