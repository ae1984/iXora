/* dirpl.p
 * MODULE
        Прямые кор. отношения
 * DESCRIPTION
        Процедура генерации входящих REMTRZ
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
        04.02.2005 kanat
 * CHANGES
        25/03/2005 kanat - увеличил формат detpay до 70 символов
        28/03/2005 kanat - добавил проверки по полям 53 и 54 во входящем MT100
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
def var ourbank like bankl.bank.
def var rcode as int.
def var rdes  as char.
def var v-bb  as char.
def var s-npl as char.
def var s-rsub as char.
def var ii as integer init 1.


/* Входные параметры */
def input parameter s-ndoc as int.               /*  1 Номер документа */
def input parameter s-sum as deci.               /*  2 Сумма платежа */
def input parameter s-valdt1 as date.

def input parameter s-sbank as char.             /*  Банк отправителя */
def input parameter s-sbank1 as char.            /*  Банк отправителя - корреспондент - участник */
def input parameter s-sacc1 as char.             /*  Ностро счет отправителя - корреспондент - участник */
def input parameter s-acc as char.               /*  3 Счет отправителя */
def input parameter s-ord as char.

def input parameter s-rbank as char.             /*  4 Банк получателя */
def input parameter s-rbank2 as char.            /*  4 Банк получателя - корреспондент - участник */
def input parameter s-racc2 as char.             /*  4 Ностро счет получателя - корреспондент - участник */
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

def input parameter s-cbank as char.             /* Кор. счет банка */
def input parameter s-chief as char.
def input parameter s-mainbk as char.
def input parameter s-ord-rnn as char.
def input parameter s-filename as char.
def input parameter s-t-sqn as char.
def input parameter s-num as char.
def input parameter s-mt-ref as char.


define variable v-o as logical.
define variable s-vtime as integer. /* sasco - время для сверки транспорта */

def var receiver as char.


if s-kb <> 0 and month(g-today) = 12 and day(g-today) = 31 then do:
  message "Запрещено отправлять казначейские платежи в последний день года!" view-as alert-box title "Happy New Year".
  return.
end.

def var v-weekbeg as int.
def var v-weekend as int.
def var retval as char init "".

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
    display " There isn't record OURBNK in sysc file !!".
    pause.
    return retval.
end.
ourbank = trim(sysc.chval).

do trans:
  run n-remtrz.
  create remtrz.
  remtrz.remtrz = s-remtrz.


  assign
  remtrz.rdt = g-today
  remtrz.valdt1 = s-valdt1
  remtrz.rtim = time
  remtrz.sbank = s-sbank
  remtrz.rsub = "cif".

  find first bankl where bankl.bank = s-rbank no-lock no-error.
  if avail bankl then
  remtrz.rbank = bankl.acct.

  assign remtrz.sacc = string(integer(s-acc), "999999999")
  	 remtrz.racc = string(integer(s-racc), "999999999")
  	 remtrz.dracc = s-cbank.

  find first dfb where dfb.dfb = s-cbank no-lock no-error.
  if avail dfb then do:
  remtrz.drgl = dfb.gl.
  end.


  if remtrz.rbank = ourbank then
  remtrz.cracc = remtrz.racc.
  else do:
  find first bankt where bankt.cbank = remtrz.rbank and bankt.subl = "CIF" and bankt.crc = remtrz.tcrc no-lock no-error.
  if avail bankt then do:
  find first aaa where aaa.aaa = bankt.acc no-lock no-error.
  remtrz.cracc = bankt.acc.
  remtrz.crgl = aaa.gl.
  remtrz.rsub = "cif".
  end.
  end.

  find first aaa where aaa.aaa = remtrz.racc no-lock no-error.
  if avail aaa then do:
  remtrz.crgl = aaa.gl.
  remtrz.rsub = "cif".
  end.

  find first arp where arp.arp = remtrz.racc no-lock no-error.
  if avail arp then do:
  remtrz.crgl = arp.gl.
  remtrz.rsub = "arp".
  end.

  /* в жизни всякое случается ... */
  find first dfb where dfb.dfb = remtrz.racc no-lock no-error.
  if avail dfb then do:
  remtrz.crgl = dfb.gl.
  remtrz.rsub = "dfb".
  end.

  remtrz.ord = s-ord + "/RNN/" + s-ord-rnn. /*NAME + RNN + CHIEF + MAINBK*/

  if trim(s-chief) <> "" then
  remtrz.ord = remtrz.ord + "/CHIEF/" + s-chief.

  if trim(s-mainbk) <> "" then
  remtrz.ord = remtrz.ord + "/MAINBK/" + s-mainbk.

  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "dirpl.p 181-187", "1", "", "").
  end.

  remtrz.amt = s-sum.
  remtrz.payment = s-sum.

  remtrz.svca = 0.
  remtrz.svcp = 0.

  remtrz.fcrc = 1.
  remtrz.tcrc = 1.

  remtrz.cover = s-cov. /* 2.*/

  remtrz.chg = 0.
  remtrz.outcode = 3.

  find ofc where ofc.ofc eq g-ofc no-lock.

  remtrz.ref = s-filename + "/100/".
  remtrz.source = "DIR".

  remtrz.sqn = fill(".",18) + trim(s-num) + fill("",13) + "." + trim(s-mt-ref) + remtrz.rbank + remtrz.remtrz + ".." + trim(s-num).

/* 28.03.2005 - kanat - если проставлены поля 53 и 54 в MT100 */

  if trim(s-sbank1) <> "" then
  remtrz.scbank = s-sbank1.

  if trim(s-rbank2) <> "" then
  remtrz.rcbank = s-rbank2.

  find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
  if avail bankl then do:
  remtrz.rcbank = bankl.cbank.
  remtrz.bb[1] = bankl.name.
  remtrz.bb[2] = bankl.addr[1].
  remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
  end.


  if remtrz.rbank <> ourbank then do:
  find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
  find first bankt where bankt.cbank = bankl.cbank and bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
  if not avail bankt then do:
  v-text = remtrz.remtrz + " DRSTW " + " WARNING !!! There isn't BANKT " + bankl.cbank + " for CRC = " + string(remtrz.tcrc)  +  " record !!!? ".
  run lgps .
  end.
  else do:
  if remtrz.valdt1 >= g-today then
  remtrz.valdt2 = remtrz.valdt1 + bankt.vdate.
  else
  remtrz.valdt2 = g-today + bankt.vdate.
  if remtrz.valdt2 = g-today and bankt.vtime < time
  then remtrz.valdt2 = remtrz.valdt2 + 1.
  end.
  end.
  else
  remtrz.valdt2 = remtrz.valdt1.



  if remtrz.rbank = "TXB00" then receiver  = "o".
                            else receiver  = "u".

  find first ptyp where ptyp.sender = "n" and ptyp.receiver = receiver
     no-lock no-error .
  if avail ptyp then remtrz.ptype = ptyp.ptype.


  find bankl where bankl.bank = remtrz.sbank no-lock no-error.
  if not available bankl then do: bell. undo. return. end.
  remtrz.scbank = bankl.cbank.

  assign remtrz.info[6] = "TRXGEN P"
	 remtrz.info[9] = string(remtrz.rdt)
  	 remtrz.info[10] = "".

  remtrz.t_sqn = trim(s-t-sqn).

  find first bankl where bankl.bank = remtrz.sbank no-lock no-error.
  if avail bankl then do:
  remtrz.ordins[1] = substr(bankl.name,1,34).
  remtrz.ordins[2] = substr(bankl.name,35,35).
  remtrz.ordins[3] = substr(bankl.name,70,35).
  remtrz.ordins[4] = "KAZAKHSTAN".
  end.

  remtrz.ordcst[1] = remtrz.ord.

  find first aaa where aaa.aaa = trim(remtrz.racc) no-lock no-error.
  if avail aaa then do:
   find first cif where cif.cif = aaa.cif no-lock no-error.
   if avail cif then do:

     find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.

     if avail  sub-cod and sub-cod.ccode = "0" then do:
      find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(302)
                          and tarif2.stat = 'r' no-lock no-error .
       if avail tarif2 then do:

         remtrz.svccgr = 302.
         remtrz.svcrc = remtrz.tcrc.

         run comiss.
       end.
      end.
   end.
   end.

  remtrz.jh1 = 0.
  remtrz.jh2 = ?.

  remtrz.bn[1] = s-bn.
  remtrz.bn[3] = " /RNN/" + s-bnrnn.

  remtrz.ben[1] = remtrz.bn[1] + remtrz.bn[3].

  remtrz.rcvinfo[1] = "".
  remtrz.ba = remtrz.racc.

  v-bb = trim(remtrz.bb[1]) + " " + trim(remtrz.bb[2]) + " " + trim(remtrz.bb[3]).

  remtrz.actins[1] = "/" + substr(v-bb,1,34).
  remtrz.actins[2] = substr(v-bb,35,35).
  remtrz.actins[3] = substr(v-bb,70,35).
  remtrz.actins[4] = substr(v-bb,105,35).

  remtrz.actinsact = remtrz.rbank.

  remtrz.detpay[1] = substring(s-nplin, 1, 70).
  remtrz.detpay[2] = substring(s-nplin, 71, 70).
  remtrz.detpay[3] = substring(s-nplin, 141, 70).
  remtrz.detpay[4] = substring(s-nplin, 211, 70).

  create sub-cod.
  update sub-cod.acc = s-remtrz
  	 sub-cod.sub = "rmz"
  	 sub-cod.d-cod = "eknp"
  	 sub-cod.ccode = "eknp"
 	 sub-cod.rcode = s-kod + "," + s-kbe + "," + s-knp.

  create que.
  que.remtrz = remtrz.remtrz.
  que.pid = "DIRIN".
  remtrz.remtrz = que.remtrz .
  que.ptype = remtrz.ptype.
  que.con = "W".
  que.dp = today.
  que.tp = time.
  que.df = today.
  que.tf = time.
  que.dw = today.
  que.tw = time.
  que.pvar = " , , , , ,".
  que.pri = 29999 .
end.

return remtrz.remtrz.



