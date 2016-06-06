/* DPK_ps.p
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

/* DPK_ps.p
   формирование RMZ из модуля поребительского кредитования

   22.04.2003 nadejda - списано из пенсионных платежей
*/

{global.i}
{pk.i}

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

{get-kod.i}
{pk-sysc.i}


{lgps.i new}
m_pid = "DPK".

def new shared var s-remtrz like bank.remtrz.remtrz.

def var s-error as char.
def var v-sbank as char.
def var v-rcbank as char.
def var v-rbank as char.
def var v-rnn as char.
def var ben as char.
def var r-acc as char.

def var v-weekbeg as int.
def var v-weekend as int.
def var clecod  as cha.
def var lbnstr as cha.
def var v-err as cha.
def var num as cha extent 100.
def var v-pri as cha.
def var v-ret as cha.
def var v-acc like bank.remtrz.sacc.
def var v-bb as cha.
def var v-ba as cha.
def var v-ben as cha.
def var v-det as cha.
def var v-chg as cha.
def var i as int.
def var receiver as cha.
def var sender   as cha.
def var v-string as cha.
def var v-ref as cha .
def var v-crc like bank.remtrz.fcrc.
def var v-amt like bank.remtrz.amt.
def var v-ord like bank.remtrz.ord.
def var v-date as date.
def var v-bank like bank.bankl.bank.
def var v-reterr as int initial 0.
def var acode like bank.crc.code.
def var bcode like bank.crc.code.
def buffer t-bankl for bank.bankl.
def buffer tcrc for bank.crc.
def buffer tgl for bank.gl.
def var ok as log initial false.
def var v-cif as char.
def var v-plnum as char init "".
def var cc as char.
def var v-knp as char init "720".
def var v-irsp as char init "0".
def var v-secop as char init "0".
def buffer xaaa for aaa.
def var vbal as decimal.
def var v-timclear as integer.
def var v-clnkod as char init "19".
def var v-partnname as char.
def var v-partnrnn as char.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

v-text = "".

find sysc where sysc.sysc = "clecod" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  v-text = " Нет CLECOD записи в sysc файле ! ".
  run lgps.
  return.
end.
clecod = sysc.chval.

find sysc where sysc.sysc = "LBNSTR" no-lock  no-error.
if not avail sysc then do:
  v-text  =  " Нет LBNSTR записи в sysc файле ! ".
  run lgps.
  return.
end.
lbnstr = sysc.chval.

find first bankl where bankl.bank = s-ourbank no-lock.

v-pri = "n".
v-chg = "BEN".

v-acc = pkanketa.aaa.
v-cif = pkanketa.cif.
v-amt = pkanketa.sumout.

find first aaa where aaa.aaa = v-acc no-lock no-error.
vbal = aaa.cbal - aaa.hbal - v-amt.
if vbal < 0 then do:
  message skip " Нехватка средств." skip " Счет" v-acc "сумма" string(v-amt)
     skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

find codfr where codfr.codfr = "pkpartn" and codfr.code = pkanketa.partner no-lock no-error.
if not avail codfr then do:
  message skip " Предприятие-партнер с кодом" pkanketa.partner "не найдено!"
     skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

if codfr.name[4] = "" or num-entries(codfr.name[4], "|") < 6 then do:
  message skip " Нет реквизитов предприятия-партнера или неполные реквизиты!"
     skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

/* разобрать реквизиты по отдельным данным */
v-partnname = entry(1, codfr.name[4], "|").
v-partnrnn = entry(2, codfr.name[4], "|").
v-irsp = entry(3, codfr.name[4], "|").
v-secop = entry(4, codfr.name[4], "|").
r-acc = entry(5, codfr.name[4], "|").
v-rbank = entry(6, codfr.name[4], "|").

find first bankl where bankl.bank = v-rbank no-lock no-error.
if not avail bankl then do:
  message skip " Не найден код банка" v-rbank "!" skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.
v-bb = bankl.name.
v-rcbank = substr(bankl.cbank,1,9).

/* создание REMTRZ */

v-ref = s-credtype + "/" + trim(string(s-pkankln)).
v-string = string(day(pkanketa.rdt),"99") + string(month(pkanketa.rdt),"99") + substr(string(year(pkanketa.rdt),"9999"),3,2).

find remtrz where remtrz.sbank = s-ourbank and
  remtrz.sqn = v-cif + ".DPK." + v-string + "." + v-ref
  no-lock no-error.

if avail remtrz then do:
  message skip " Платеж SQN =" v-cif + ".DPK." + v-string + "." + v-ref "уже обработан!" skip
         " Референс платежа REMTRZ = " remtrz.remtrz
         skip(1) view-as alert-box button ok title " ОШИБКА ".
  return.
end.

do on error undo :

  create remtrz.
  remtrz.rtim = time.

  run n-remtrz.

  remtrz.remtrz = s-remtrz.
  remtrz.cover = 1.
  remtrz.t_sqn = s-remtrz.
  remtrz.rdt = today.
  remtrz.valdt1 = g-today.
  remtrz.valdt2 = g-today.
  remtrz.sacc = v-acc .
  remtrz.tcrc = v-crc.
  remtrz.payment = v-amt.
  remtrz.dracc = v-acc .
  remtrz.drgl = aaa.gl.
  remtrz.fcrc = 1.
  remtrz.amt = v-amt.
  remtrz.jh1   = ?.
  remtrz.jh2 = ?.
  remtrz.ord = trim(pkanketa.name) + " /RNN/" + pkanketa.rnn.

  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "DPK_ps.p 203", "1", "", "").
  end.
  /*"Приобретение " + get-pksysc-char("pkgoal") + " : " + trim (pkanketa.goal) + ", согласно " + trim(pkanketa.billnom) */

  remtrz.bb[1]  = substr(v-bb,1,35).
  remtrz.bb[2]  = substr(v-bb,36,35).
  remtrz.bb[3]  = substr(v-bb,71,70).

  find first bankl where bankl.bank = v-rcbank no-lock no-error.
  if avail bankl then do :
    remtrz.actins[1]  = substr(bankl.name,1,35).
    remtrz.actins[2]  = substr(bankl.name,36,35).
  end.

  ben = trim(v-partnname) + " /RNN/" + v-partnrnn.
  remtrz.bn[1] = substr(ben,1,60).
  remtrz.bn[2] = substr(ben,61,60).
  remtrz.bn[3] = substr(ben,121,60).

  remtrz.ba = r-acc.
  remtrz.bi = v-chg.

  remtrz.margb = 0.
  remtrz.margs = 0.

  remtrz.svca   = 0.
  remtrz.svcaaa = "".
  remtrz.svcmarg = 0.
  remtrz.svcp = 0.
  remtrz.svcrc = 0.
  remtrz.svccgl = 0.
  remtrz.svcgl = 0.
/* без комиссии!
  if remtrz.svccgr ne 0 then
    run comiss.
*/
  remtrz.cracc = "".
  remtrz.crgl = 0.
  remtrz.sbank = s-ourbank.
  remtrz.scbank = s-ourbank.
  find bankl where bankl.bank = remtrz.sbank no-lock no-error.
  if available bankl then do:
    remtrz.ordins[1] = bankl.name.
    remtrz.ordins[2] = bankl.addr[1].
    remtrz.ordins[3] = bankl.addr[2].
    remtrz.ordins[4] = bankl.addr[3].
  end.

  remtrz.sqn = v-cif + ".DPK." + v-string + "." + v-ref.

  remtrz.rcbank = v-rcbank.
  remtrz.rbank = v-rbank.
  remtrz.racc = r-acc.
  remtrz.outcode = 3.

  find first bankl where bankl.bank = v-rcbank no-lock no-error.

  if not avail bankl then do:
    v-text = remtrz.remtrz + " Внимание ! Нет кода банка " + v-bank + " !".
    run lgps.
    v-reterr = v-reterr + 8.
  end.
  else do :
    find first bankt where bankt.cbank = v-rcbank and
        bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error.
    if not avail bankt then do:
      find first crc where crc.crc = remtrz.tcrc.
      bcode = crc.code.
      v-text = remtrz.remtrz + " HOME Внимание ! не найден корр.счет для " + v-rcbank + " Валюта = " + bcode.
      run lgps.
    end.
    else do :
      remtrz.valdt2 = remtrz.valdt2 + bankt.vdate.

      repeat:
        find hol where hol.hol eq remtrz.valdt2 no-lock  no-error.
        if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
           and  weekday(remtrz.valdt2) le v-weekend then leave.
        else remtrz.valdt2  = remtrz.valdt2 + 1.
      end.

      /* проверка на смену транспорта */
      v-timclear = bankt.vtime.
      if remtrz.valdt2 = g-today and v-timclear < time then do:
        remtrz.cover = 2.
      end.

      find first t-bankl where t-bankl.bank = v-rcbank no-lock.
      if t-bankl.nu = "u" then do:
        receiver = "u".
        remtrz.rsub = "cif".
      end.
      else do:
        receiver = "n".
        remtrz.ba = "/" +  r-acc.
      end.
      remtrz.rcbank = v-rcbank.
      remtrz.raddr = t-bankl.crbank.
      remtrz.cracc = bankt.acc.
      if bankt.subl = "dfb" then do:
        find first dfb where dfb.dfb = bankt.acc no-lock no-error.
        if not avail dfb then do:
          v-text = remtrz.remtrz + " Внимание ! Не найден корр.счет " + bankt.acc + " для " + v-bank + " !".
          run lgps.
          v-reterr = v-reterr + 125.
        end.
        else do:
          remtrz.crgl = dfb.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
      end.
    end.

    if bankt.subl = "cif" then do:
      find first aaa where aaa.aaa = bankt.acc no-lock no-error.
      if not avail aaa  then do:
        v-text = remtrz.remtrz + " Внимание ! Не найден LORO счет " + bankt.acc + " для " + v-bank + " !".
        run lgps.
        v-reterr = v-reterr + 126.
      end.
      else do:
        remtrz.crgl = aaa.gl.
        find tgl where tgl.gl = remtrz.crgl no-lock.
      end.
    end.
  end.

  find first bankl where bankl.bank = v-bank no-lock no-error.

  remtrz.rcvinfo[1] = remtrz.rcvinfo[1] + v-acc.
  remtrz.ref =
    (substr(trim(v-cif),1,6) +
    fill(' ' , 6 - length(substr(trim(v-cif),1,6))))
    +  'DPK' +
    (substr(trim(v-ref),1,12) +
    fill(' ' , 12 - length(substr(trim(v-ref),1,12))))
    +
    (substr(trim(s-ourbank),1,12) +
    fill(' ' , 12 - length(substr(trim(s-ourbank),1,12))))
    +
    (substr(trim(v-acc),1,10) +
    fill(' ' , 10 - length(substr(trim(v-acc),1,10))))
    + string(day(g-today),"99")
    + string(month(g-today),"99")
    + substr(string(year(g-today),"9999"),3,2).

  /* ptype determination  */
  if remtrz.rbank = s-ourbank then remtrz.rcbank = s-ourbank.

  if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank.
  if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank.

  find first bankl where bankl.bank = remtrz.scbank no-lock no-error.
  if avail bankl then
    if bankl.nu = "u" then sender = "u". else sender = "n".
  find first bankl where bankl.bank = remtrz.rcbank no-lock no-error.
  if avail bankl then
    if bankl.nu = "u" then receiver  = "u". else receiver  = "n".
  if remtrz.scbank = s-ourbank then sender = "o".
  if remtrz.rcbank = s-ourbank then receiver  = "o".
  find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
       no-lock no-error.
  if avail ptyp then remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".

  v-det = "Приобретение " + get-pksysc-char("pkgoal") + " : " + trim(pkanketa.goal) + ", согласно " + trim(pkanketa.billnom).

  remtrz.det[1] = substr(v-det,1,35).
  remtrz.det[2] = substr(v-det,36,35).
  remtrz.det[3] = substr(v-det,71,35).
  remtrz.det[4] = substr(v-det,106,35).

  remtrz.rwho = g-ofc.
  remtrz.source = m_pid.

  /* проверка на макс. сумму клиринга */
  if remtrz.cover = 1 then do:
    find sysc where sysc.sysc = "netgro" no-lock no-error.
    if avail sysc and remtrz.amt >= sysc.deval then remtrz.cover = 2.
  end.

  /* ЕКНП */
  v-clnkod = get-kodkbe (pkanketa.aaa, "").
  v-knp = string(get-pksysc-int ("knp")).

  create sub-cod.
  sub-cod.d-cod = "eknp".
  sub-cod.ccode = "eknp".
  sub-cod.rdt = g-today.
  sub-cod.acc = remtrz.remtrz.
  sub-cod.sub = "rmz".

  sub-cod.rcod =  v-clnkod + "," +
                  trim(v-irsp) + trim(v-secop) + "," +
                  trim(v-knp).

  find current pkanketa exclusive-lock.
  pkanketa.sernom = remtrz.remtrz.
  find current pkanketa no-lock.

  create que.
  que.remtrz = remtrz.remtrz.
  que.pid = m_pid.
  que.ptype = remtrz.ptype.
  if v-pri = "E" then
    que.pri = 9999.
  else
  if v-pri = "U" then
    que.pri = 19999.
  else
    que.pri = 29999.
  if v-reterr = 0 then  do:
    if remtrz.cracc = lbnstr then que.rcod = "3".
    else que.rcod = "0".
  end.
  else do:
    que.rcod = "1".
    que.pvar = string(v-reterr).
  end.
  que.con = "F".
  que.dp = today.
  que.tp = time.
end.

ok = true.

v-text = "Автоматическая регистрация платежа Департ.Потреб.кредит. " + remtrz.remtrz +
         " <- SQN = " + remtrz.sqn + " тип = " + remtrz.ptype +
         " код завершения = " + que.rcod +  " -> " + remtrz.rbank.
run lgps.

if avail remtrz then release remtrz.
if avail sub-cod then release sub-cod.
if avail que then release que.

