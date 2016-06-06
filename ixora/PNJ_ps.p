/* PNJ_ps.p
 * MODULE
        Платежная система
 * DESCRIPTION
       Формирование пенсионного RMZ
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
        06.01,2003 nadejda  - изменено формирование 1 и 2 даты валютирования:
                              1 дата ставится g-today,
                              2 - как в свифтовке, но если прошло время клиринга - дата следующего опердня по запросу
        10.11.2003 nadejda  - при проставлении 2-й даты валютирования проверяется еще и текущий день (вдруг он позже опердня)
        12.05.2004 nadejda  - если отказались от перевода 2-й даты вал-ия на след.день - поменять транспорт на гросс
        13.05.2004 nadejda  - сообщение про несовпадение валюты написала более понятно
        18.12.2005 tsoy     - добавил время создания платежа.
        30.06.2005 marinav - снятие специнструкции
        09.09.2005 saltanat - Включила проверку рнн по филиалам клиента.
        03.11.2006 u00777   - Изменено время создания платежа на время ввода дебет. части платежа.
        12/04/2010 galina - фин.мониторинг платежей >=7000000 тенге
        22/07/2010 galina - добавила парметр kfmprt_cre
        01.02.2011 marinav - изменения в связи с переходом на БИН/ИИН
        12.04.2011 k.gitalov - добавил сохранение в RMZ id офицера загрузившего файл в ixora
        28/04/2012 evseev - логирование значения aaa.hbal
        13.07.2012 Lyubov - перекомпиляция
        25.07.2012 evseev - ТЗ-1233 ТЗ-1461
        11/06/2013 Luiza  - ТЗ 1299 нельзя менять дату отправляем Гроссом
*/
{kfm.i "new"}
def input-output parameter v-viewdt2 as logical.
def input-output parameter v-chngdt2 as logical.

{chbin.i}

def shared var f-name as cha.
def shared var v-lbin as cha .
def shared var v-lbina as cha .
def shared var v-ok as log .
def shared var s-remtrz like bank.remtrz.remtrz .

def shared var who_cre as char.

def var s-error as char.
def var v-sbank as char.
def var v-rcbank as char.
def var v-rbank as char.
def var v-rnn as char.
def var ben as char.
def var r-acc as char.

def new shared var v-weekbeg as int.
def new shared var v-weekend as int.
def new shared var clecod  as cha.
def new shared var lbnstr as cha .
def new shared var ourbank as cha.
def new shared var v-err as cha .
def new shared var num as cha extent 100 .
def new shared var v-pri as cha .
def new shared var v-ret as cha .
def new shared var v-acc like bank.remtrz.sacc.
def new shared var v-bb as cha .
def new shared var v-ba as cha .
def new shared var v-ben as cha .
def new shared var v-det as cha .
def var v-det1 as cha .
def new shared var v-chg as cha .
def new shared var v-field  as cha extent 50 .
def new shared var receiver as cha.
def new shared var sender   as cha.
def new shared var i as int .
def new shared var blok4 as log initial false .
def new shared var rep as cha initial "0".
def new shared var irep as int initial 0.
def new shared var v-string as cha .
def new shared var v-ref as cha  .
def new shared var v-crc like bank.remtrz.fcrc .
def new shared var v-amt like bank.remtrz.amt.
def new shared var v-ord like bank.remtrz.ord.
def new shared var v-date as date .
def new shared var v-bank like bank.bankl.bank .
def new shared var tmp as cha .
def new shared var v-reterr as int initial 0.
def new shared var acode like bank.crc.code.
def new shared var bcode like bank.crc.code.
def new shared buffer t-bankl for bank.bankl.
def new shared buffer tcrc for bank.crc.
def new shared buffer tgl for bank.gl.
def new shared var ok as log initial false .
def var v-cif as char.
def var v-plnum as char init "".
def var cc as char.
def var v-knp as char init "000".
def var v-irso as char init "0".
def var v-irsp as char init "0".
def var v-secoo as char init "0".
def var v-secop as char init "0".
def buffer xaaa for aaa.

def var v-timclear as integer.
def var v-rtim as int format "zzzzz9" init 0 no-undo. /*Время создания платежа*/

/*для Фин.мониторинга*/
def var v-kfm as logi no-undo init no.
def var v-kfmrem as char no-undo.
def var v-oper as char no-undo.
def var v-cltype as char no-undo.
def var v-res as char no-undo.
def var v-res2 as char no-undo.
def var v-FIO1U as char no-undo.
def var v-publicf  as char no-undo.
def var v-OKED as char no-undo.
def var v-clnameF as char no-undo.
def var v-clnameU as char no-undo.
def var v-prtUD as char no-undo.
def var v-prtUdN as char no-undo.
def var v-prtUdIs as char no-undo.
def var v-prtUdDt as char no-undo.
def var v-opSumKZT as char no-undo.
def var v-num as inte no-undo.
def var v-operId as integer no-undo.
def var v-bdt as char no-undo.
def var v-bplace as char no-undo.
def var v-prtEmail as char no-undo.
def var v-prtFLNam as char no-undo.
def var v-prtFFNam as char no-undo.
def var v-prtFMNam as char no-undo.
def var v-prtOKPO  as char no-undo.
def var v-prtPhone as char no-undo.
def var v-cracc as char no-undo.
def buffer b-bankl for bankl.

def var op_kod as char.
def var s-aaa as char.


def var v-chkamt as decimal.

def var vbal like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vavl like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vhbal like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vfbal like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vcrline like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vcrlused like jl.dam format ">>>>>>>>>>>>>>9.99-".
def var vooo like aaa.aaa.
def buffer b1-aas for aas.
def var d_sm as decimal.

find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.

find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

{global.i }
{lgps.i }
{aas2his.i &db = "bank"}
v-text = "" .


find sysc where sysc.sysc = "clecod" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " Нет CLECOD записи в sysc файле ! ".
   run lgps.
   return .
end.
clecod = sysc.chval.

find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if not avail sysc then do:
   v-text  =  " Нет LBNSTR записи в sysc файле ! ".
   run lgps .
   return.
end.
lbnstr = sysc.chval .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " Нет OURBNK записи в sysc файле ! ".
   run lgps.
   return .
end.
ourbank = sysc.chval.

find first bankl where bankl.bank = ourbank no-lock .

find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " Нет PS_ERR записи в sysc файле ! ".
   run lgps.
   return .
end.
v-err = sysc.chval.

num = "".
if entry(1,f-name) <> "" then do :
   num[1] = entry(1,f-name) .
   num[2] = v-lbina + num[1] .
   substr(f-name,1,index(f-name,",")) = "" .
end .

v-pri = "n".
v-chg = "BEN".

input from value(num[2]) .
pause 0.

v-field = "".

repeat:
   import unformatted v-field[1] .
   if v-field[1] ne "" then leave.
end.

if not v-field[1] begins "\{" then do:
   s-error = "".
   do i = 1 to 50 :
      if v-field[i] ne "" then s-error = s-error + v-field[i] + " ".
   end.
   v-text = " LBARC ошибка sqn = " + string(num[1]) + " код завершения = " + s-error .
   message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
   return .
end.

repeat:
   v-field = "".
   import unformatted v-field[1] .
   if not ( v-field[1] begins ":") and not  blok4  then next .
   blok4 = true .
   if v-field[1] begins ":"  or  v-field[1] begins "-}" then do:
      rep = "0" . irep = 0 .
   end .
   i = 0 .
   v-string = "".
   repeat:
      i = i + 1 . if i > 50 then leave .
      if v-field[i] = "" then next .
      v-string = v-string + v-field[i] + " " .
   end.
   if v-string begins ":20:" then v-ref = substr(v-string,5) .
   else if v-string begins ":32A:" then do:
      if substr(v-string,6,2) eq  substr(string(year(today)),3,2) then cc = substr(string(year(today)),1,2).
      else if substr(v-string,6,2) lt  substr(string(year(today)),3,2) then cc = "20".
      if substr(v-string,6,2) gt  substr(string(year(today)),3,2) then cc = "19".
      v-date = date(int(substr(v-string,8,2)), int(substr(v-string,10,2)), int( cc + substr(v-string,6,2))) .
      tmp = (substr(v-string,12,3)) .
      if tmp = "lvl" then tmp = "ls" .
      find first crc where crc.code = tmp no-lock no-error .
      if not avail crc then  v-crc = 0. else v-crc = crc.crc .
      tmp = (substr(v-string,15)) .
      overlay (tmp,index(tmp,",")) = "." .
      v-amt = decimal(tmp).
   end. else if v-string begins ":50:" or rep = "50" then do:
      if rep = "0" then do:
         rep = "50" .
         v-ord  = (substr(v-string,5)) .
      end. else v-ord  = substr(v-ord,1,length(v-ord) - 1) + " " + v-string.
      if index(v-ord,"/IRS/") ne 0 and v-irso eq "0" then v-irso = substr(v-ord,index(v-ord,"/IRS/") + 5).
      if index(v-ord,"/SECO/") ne 0 and v-secoo eq "0" then v-secoo = substr(v-ord,index(v-ord,"/SECO/") + 6).
   end. else if v-string begins ":52b:" then v-sbank = substr(v-string,6).
   else if v-string begins ":54c:" then v-rcbank = substr(v-string,6,9) .
   else if v-string begins ":57b:" then v-rbank = substr(v-string,6) .
   else if v-string begins ":59:" or rep = "59" then do:
      if rep = "0" then do:
         rep = "59" .
         v-ben  = (substr(v-string,5)) .
      end. else v-ben  = substr(v-ben,1,length(v-ben) - 1) + " " + v-string .
      if index(v-ben,"/IRS/") ne 0 and v-irsp eq "0" then v-irsp = substr(v-ben,index(v-ben,"/IRS/") + 5).
      if index(v-ben,"/SECO/") ne 0 and v-secop eq "0" then v-secop = substr(v-ben,index(v-ben,"/SECO/") + 6).
   end. else if v-string begins ":70:" or rep = "70" then do:
      if rep = "0" then do:
         rep = "70" .
         v-det  = (substr(v-string,5)) .
      end. else v-det = substr(v-det,1,length(v-det) - 1) + " " + v-string .
      if index(v-det,"/NUM/") ne 0 and v-plnum eq "" then v-plnum = substr(v-det,index(v-det,"/NUM/") + 5).
      if index(v-det,"/KNP/") ne 0 and v-knp eq "000" then v-knp = substr(v-det,index(v-det,"/KNP/") + 5).
   end.
   if index(v-det,"/ASSIGN/") ne 0 then v-det1 = substr(v-det,index(v-det,"/ASSIGN/") + 8).
end.

input close .
pause 0.


if trim(v-sbank) ne trim(clecod) then do on error undo, return on stop undo ,return:
   v-text = " В поле 52В код другого банка - " + trim(v-sbank) + " вместо " + trim(clecod).
   message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
   v-reterr = 1.
   return.
end. else v-bank = ourbank.

v-acc = substr(v-ord,index(v-ord,"/D/") + 3,20).
if v-bin = no then v-rnn = substr(v-ord,index(v-ord,"/RNN/") + 5,12). else v-rnn = substr(v-ord,index(v-ord,"/IDN/") + 5,12).

find first aaa where aaa.aaa = v-acc no-lock no-error .
if avail aaa then do :
   find cif of aaa no-lock no-error .
   if not avail cif then do on error undo, return :
      v-text = " SQN = " + string(num[1]) + ". " + v-acc + "  код клиента не найден! ".
      message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
      v-reterr = 2 .
      return.
   end.
   if v-bin = no then do:
      if (trim(v-rnn) ne trim(cif.jss)) then do on error undo, return :
         find first clfilials where clfilials.cif = cif.cif and trim(clfilials.rnn) eq trim(v-rnn) no-lock no-error.
         if not avail clfilials then do:
            v-text = " SQN = " + string(num[1]) + ". " + v-acc + "  код клиента не найден или счет не является счетом клиента ! " .
            message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
            v-reterr = 2 .
            return.
         end.
      end.
   end. else do:
      if (trim(v-rnn) ne trim(cif.bin)) then do on error undo, return :
         find first clfilials where clfilials.cif = cif.cif and trim(clfilials.rnn) eq trim(v-rnn) no-lock no-error.
         if not avail clfilials then do:
            v-text = " SQN = " + string(num[1]) + ". " + v-acc + "  код клиента не найден или счет не является счетом клиента ! " .
            message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
            v-reterr = 2 .
            return.
         end.
      end.
   end.
   if aaa.crc ne v-crc  then do on error undo, return on stop undo ,return :
      v-text =  " SQN  = " + string(num[1]) + "."  + v-ref + "  валюта счета - " + string(aaa.crc) + " не равна валюте платежа - "+ string(v-crc) + " ! " .
      message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
      v-reterr = 3.
      return.
   end.
   v-cif = trim(cif.cif).

   /*Снять спец инструкцию со счета юр лица, если она конечно есть*/
   find last pay_ur where pay_ur.acc = trim(v-acc) and pay_ur.sum = v-amt and pay_ur.knp = v-knp and pay_ur.del = ? exclusive-lock no-error.
   if avail pay_ur then do:
      find first aas where aas.aaa = pay_ur.acc and aas.ln = pay_ur.ln  and aas.chkamt = pay_ur.sum exclusive-lock no-error.
      if avail aas then do:
           aas.payee  = aas.payee + ' Платеж проведен.'.
           op_kod = "D".
           aas.mn = substr(aas.mn,1,3) + "b5".
           s-aaa = aas.aaa.
           run aas2his.
           find first aaa where aaa.aaa = aas.aaa exclusive-lock.
           if avail aaa then do:
              run savelog("aaahbal", "PNJ_ps ; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - aas.chkamt) + " ; " + string(aas.chkamt)).
              aaa.hbal = aaa.hbal - aas.chkamt.
           end.
           delete aas.
           assign pay_ur.del = g-today  v-rtim = pay_ur.rtim. /*Время ввода дебет. части платежа u00777 03.11.2006*/
           release pay_ur.
      end.
   end.
   /*****/
   /*if aaa.craccnt <> "" then find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
   vbal = aaa.cbal - aaa.hbal +( if available xaaa then xaaa.cbal else 0 ) - v-amt.*/
   run aaa-bal777(aaa.aaa, output vbal, output vavl, output vhbal, output vfbal, output vcrline, output vcrlused, output vooo).
   d_sm = 0.
   if v-knp = "010" or v-knp = "012" or v-knp = "017" or v-knp = "019" then do:
       for each b1-aas where b1-aas.aaa = aaa.aaa and lookup(string(b1-aas.sta), "2,4,5,15,6,7,8,9,11,16,17") <> 0 or
                             b1-aas.aaa = aaa.aaa and b1-aas.mn = "30037" no-lock:
           d_sm = d_sm + b1-aas.chkamt.
       end.
   end.
   vavl = vavl + d_sm.
   run savelog("PNJ_ps.log", "369. " + aaa.aaa + " d_sm=" + string(d_sm) + " vavl=" + string(vavl) + " v-amt=" + string(v-amt) + " vavl<v-amt=" + string(vavl < v-amt)).

   /*if vbal < 0 then do:*/
   if vavl < v-amt then do:
      message skip " Нехватка средств." skip "Счет " + v-acc + " сумма " + string(v-amt) skip(1) view-as alert-box button ok title " ОШИБКА ".
      return.
   end.
end. else do :
   find first arp where arp.arp = v-acc no-lock no-error.
   if not avail arp then do :
      v-text = " SQN = " + string(num[1]) + ". " + v-acc + "  счет не найден в системе ! " .
      message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
      v-reterr = 4 .
      return.
   end. else do :
      if arp.crc ne v-crc  then do on error undo, return on stop undo ,return :
         v-text =  " SQN  = " + string(num[1]) + "."  + v-ref + "  валюта счета : " + string(v-crc) + " " + string(arp.crc) + " не равна валюте платежа ! " .
         message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
         v-reterr = 5.  /* v-crc ne arp.crc  */  .
         return.
      end.
     v-cif = trim(arp.cif).
   end.
end.

find first bankl where bankl.bank = v-rbank no-lock no-error.
if not avail bankl then do on error undo, return on stop undo ,return :
   v-text = " SQN = " + string(num[1]) + "."  + v-ref + " Не найден код банка " + v-rbank + " ! " .
   message skip v-text skip(1) view-as alert-box button ok title " ОШИБКА ".
   v-reterr = 5 .
   return.
end.
v-bb = bankl.name.

/* создание REMTRZ */
find remtrz where remtrz.sbank = ourbank  and remtrz.sqn   = v-cif + "." + trim(string(num[1])) + "." + trim(v-plnum) no-lock no-error .
if avail remtrz then do on error undo, return on stop undo ,return :
   message skip " SQN = " + string(num[1]) + "."  + v-ref + " уже обработан !" skip "REMTRZ   " remtrz.remtrz skip(1) view-as alert-box button ok title " ОШИБКА ".
   return .
end .

if v-rtim = 0 then v-rtim = time.

do on error undo :
  run n-remtrz.
  /*if v-amt >= 7000000 and (v-knp = '013' or v-knp = '015') then do:
      message "Перечисление добровольных пенсионных взносов ~nсуммой >= 7000000 тенге подлежат финансовому мониторингу!" view-as alert-box title 'ВНИМАНИЕ'.
      v-oper = '14'.
      run fm1.
      if not kfmres then return.
      if v-kfm then run kfmcopy(v-operId,s-remtrz,'fm',0).
  end.*/

  create remtrz .
  remtrz.rtim = v-rtim.
  remtrz.remtrz = s-remtrz .
  remtrz.cover = 1.
  remtrz.t_sqn = s-remtrz .
  remtrz.rdt = today .
  remtrz.valdt1 = g-today.
  if v-date >= g-today then remtrz.valdt2 = v-date. else remtrz.valdt2 = g-today.
  remtrz.sacc = v-acc  .
  remtrz.tcrc = v-crc .
  remtrz.payment = v-amt .
  remtrz.dracc = v-acc  .
  find first aaa where aaa.aaa = v-acc no-lock no-error .
  if avail aaa then remtrz.drgl = aaa.gl .
  else do :
    find first arp where arp.arp = v-acc no-lock no-error.
    remtrz.drgl = arp.gl .
  end.
  remtrz.fcrc = v-crc.
  remtrz.amt = v-amt.
  remtrz.jh1 = ?.
  remtrz.jh2 = ?.
  remtrz.ord =  substr(v-ord,index(v-ord,"/NAME/") + 6, index(substr(v-ord,index(v-ord,"/NAME/") + 6),"/") - 1) + "/RNN/" + v-rnn .
  if remtrz.ord = ? then do:
     run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "PNJ_ps.p 538", "1", "", "").
  end.
  remtrz.bb[1]  = "/" + substr(v-bb,1,35) .
  remtrz.bb[2]  = substr(v-bb,36,35) .
  remtrz.bb[3]  = substr(v-bb,71,70) .
  if v-rcbank ne "" then do:
     find first bankl where bankl.bank = substr(v-rcbank,1,9) no-lock no-error.
     if avail bankl then do :
        remtrz.actins[1]  = "/" + substr(bankl.name,1,35) .
        remtrz.actins[2]  = substr(bankl.name,36,35) .
     end.
  end.
  if v-bin = no then ben = trim(substr(v-ben,index(v-ben,"/NAME/") + 6)) + substr(v-ben,index(v-ben,"/RNN/"),17).
                else ben = trim(substr(v-ben,index(v-ben,"/NAME/") + 6)) + substr(v-ben,index(v-ben,"/IDN/"),17).
  remtrz.bn[1] = replace(substr(ben,1,60),"IDN","RNN") .
  remtrz.bn[2] = replace(substr(ben,61,60) ,"IDN","RNN").
  remtrz.bn[3] = replace(substr(ben,121,60),"IDN","RNN") .
  if v-ben begins "/D/" then r-acc = substr(v-ben,4,20). else r-acc = substr(v-ben,1,20).
  remtrz.ba = r-acc.
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
  if remtrz.svccgr ne 0 then run comiss .
  remtrz.cracc = "".
  remtrz.crgl = 0.
  remtrz.sbank = ourbank.
  remtrz.scbank = ourbank.
  find bankl where bankl.bank = remtrz.sbank no-lock no-error.
  if available bankl then do:
     remtrz.ordins[1] = bankl.name.
     remtrz.ordins[2] = bankl.addr[1].
     remtrz.ordins[3] = bankl.addr[2].
     remtrz.ordins[4] = bankl.addr[3].
  end.
  remtrz.sqn = v-cif + "." + trim(string(num[1])) + "." + trim(v-plnum).
  if v-rcbank = "" then v-rcbank = v-rbank.
  remtrz.rcbank = substr(v-rcbank,1,9).
  remtrz.rbank = v-rbank.
  remtrz.racc = r-acc .
  remtrz.outcode = 3 .
  find first bankl where bankl.bank = v-rcbank no-lock no-error.
  if not avail bankl then do:
     v-text = remtrz.remtrz + " Внимание ! Нет кода банка " + v-bank + "  ! " .
     run lgps .
     v-reterr = v-reterr + 8.
  end. else do :
     find first crc where crc.crc = remtrz.tcrc.  bcode = crc.code .
     find first bankt where bankt.cbank = bankl.cbank and bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
     if not avail bankt then do:
        v-text = remtrz.remtrz + " HOME " + " Внимание ! не найден корр.счет для " + bankl.cbank + " Валюта = " + bcode  .
        run lgps .
     end. else do :
        remtrz.valdt2 = remtrz.valdt2 + bankt.vdate .
        /* проверка на смену даты */
        find sysc where sysc.sysc = "psjtim" no-lock no-error.
        if avail sysc then v-timclear = sysc.inval. else v-timclear = bankt.vtime.
        /* 10.11.2003 nadejda - проверка на текущий день - вдруг он больше опердня */
        if remtrz.valdt2 = g-today and ((time > v-timclear) or (today > g-today)) then do:
           if v-viewdt2 then do:
              /*message skip " Время окончания приема клиринговых платежей" string(v-timclear, "HH:MM:SS") "уже прошло!"
                  skip " Изменить дату таких платежей на дату следующего опер.дня?"
                  skip(1) view-as alert-box button yes-no update v-chngdt2.*/
              message skip " Время окончания приема клиринговых платежей" string(v-timclear, "HH:MM:SS") "уже прошло! ~nСогласно Налоговому Кодексу РК оплата налогов и других обязательных платежей в бюджет, обязательных пенсионных взносов, социальных отчислений должны перечисляться в день совершения операций по списанию денег с банковского счета налогоплательщика. Платеж отправится гроссом." view-as alert-box.
              v-chngdt2 = no.
              v-viewdt2 = no.
           end.
           if v-chngdt2 then remtrz.valdt2 = remtrz.valdt2 + 1. /* поменять дату на следующий опердень - для клиринга */
                        else remtrz.cover = 2.                  /* а если клиринг кончился, а надо сегодня - отправим гроссом */
        end.
        repeat:
           find hol where hol.hol eq remtrz.valdt2 no-lock  no-error.
           if not available hol and weekday(remtrz.valdt2) ge v-weekbeg and  weekday(remtrz.valdt2) le v-weekend then leave.
           else remtrz.valdt2  = remtrz.valdt2 + 1.
        end.
        find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
        if t-bankl.nu = "u" then do:
           receiver = "u".
           remtrz.rsub = "cif".
        end. else do:
           receiver = "n" .
           remtrz.ba = "/" +  r-acc .
        end .
        remtrz.rcbank = t-bankl.bank .
        remtrz.raddr = t-bankl.crbank.
        remtrz.cracc = bankt.acc.
        if bankt.subl = "dfb" then do:
           find first dfb where dfb.dfb = bankt.acc no-lock no-error .
           if not avail dfb  then do:
              v-text = remtrz.remtrz + " Внимание ! Не найден корр.счет " + bankt.acc  + " для " + v-bank + " !" .
              run lgps .
              v-reterr = v-reterr + 125.
           end. else do:
              remtrz.crgl = dfb.gl.
              find tgl where tgl.gl = remtrz.crgl no-lock.
           end.
        end.
     end.
     if bankt.subl = "cif" then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
        if not avail aaa  then do:
           v-text = remtrz.remtrz + " Внимание ! Не найден LORO счет " + bankt.acc  + " для " + v-bank + " ! " .
           run lgps .
           v-reterr = v-reterr + 126.
        end. else do:
           remtrz.crgl = aaa.gl.
           find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
     end.
  end .
  find first bankl where bankl.bank = v-bank no-lock no-error.
  remtrz.rcvinfo[1] = remtrz.rcvinfo[1]  + "/PSJ/".
  remtrz.ref = (substring(trim(v-cif),1,6) + fill(" " , 6 - length(substring(trim(v-cif),1,6)))) +  "PNJP" + (substring(trim(v-ref),1,16)
               + fill(" ", 16 - length(substring(trim(v-ref),1,12)))) + (substring(trim(ourbank),1,12) + fill(" " , 16 - length(substring(trim(ourbank),1,12))))
               + (substring(trim(v-acc),1,10) + fill(" " , 10 - length(substring(trim(v-acc),1,10)))) + string(day(g-today),"99") + string(month(g-today),"99")
               + substr(string(year(g-today),"9999"),3,2) .
  if remtrz.rbank = ourbank then remtrz.rcbank = ourbank.
  if remtrz.rcbank = "" then remtrz.rcbank = remtrz.rbank .
  if remtrz.scbank = "" then remtrz.scbank = remtrz.sbank .
  find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
  if avail bankl then if bankl.nu = "u" then sender = "u". else sender = "n" .
  find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
  if avail bankl then if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .
  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
  find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver no-lock no-error .
  if avail ptyp then remtrz.ptype = ptyp.ptype. else remtrz.ptype = "N".
  remtrz.det[1] = substr(v-det1,1,35) .
  remtrz.det[2] = substr(v-det1,36,35) .
  remtrz.det[3] = substr(v-det1,71,35) .
  remtrz.det[4] = substr(v-det1,106,35) .
  if who_cre <> "" then do:
     create doc_who_create.
     doc_who_create.docno = s-remtrz.
     doc_who_create.who_cr = who_cre.
  end.
  remtrz.rwho = g-ofc .
  remtrz.source = m_pid .

  create sub-cod.
  sub-cod.d-cod = "eknp".
  sub-cod.ccode = "eknp".
  sub-cod.rdt = g-today.
  sub-cod.acc = remtrz.remtrz.
  sub-cod.sub = "rmz".
  sub-cod.rcod =  trim(v-irso) + trim(v-secoo) + "," + trim(v-irsp) + trim(v-secop) + "," + trim(v-knp).
  create que.
  que.remtrz = remtrz.remtrz.
  que.pid = m_pid.
  que.ptype = remtrz.ptype.
  if v-pri = "E" then que.pri = 9999 . else if v-pri = "U" then que.pri = 19999. else que.pri = 29999 .
  if v-reterr = 0 then  do:
     if remtrz.cracc = lbnstr then que.rcod = "3". else que.rcod = "0" .
  end. else do:
     que.rcod = "1".
     que.pvar = string(v-reterr).
  end.
  que.con = "F".
  que.dp = today.
  que.tp = time.
end.

if error-status:error then do:
  v-ok = false.
  return.
end.

ok = true.

v-text = "Автоматическая регистрация пенсионного платежа " + remtrz.remtrz +
         " <- SQN = " + string(num[1]) +
         " <- " + v-cif  + " " + remtrz.sqn + " тип=" + remtrz.ptype +
         " код завершения = " + que.rcod +  " -> " + remtrz.rbank +
         ", дата 2 " + string(remtrz.valdt2, "99/99/99").
run lgps.
v-ok = true.

if avail remtrz then release remtrz.
if avail sub-cod then release sub-cod.
if avail que then release que.


/*данные по клиенту*/
procedure defclparam.
  v-cltype = ''.
  v-res = ''.
  v-res2 = ''.
  v-publicf = ''.
  v-FIO1U = ''.
  v-OKED = ''.
  v-prtOKPO = ''.
  v-prtEmail = ''.
  v-prtPhone = ''.
  v-prtFLNam = ''.
  v-prtFFNam = ''.
  v-prtFMNam = ''.

  v-clnameU = ''.
  v-prtUD = ''.
  v-prtUdN = ''.
  v-prtUdIs = ''.
  v-prtUdDt = ''.
  v-bdt = ''.
  v-bplace = ''.

  if cif.type = 'B' then do:
     if cif.cgr <> 403 then v-cltype = '01'.
     if cif.cgr = 403 then v-cltype = '03'.
  end. else v-cltype = '02'.
  if cif.geo = '021' then do:
     v-res2 = '1'.
     v-res = 'KZ'.
  end. else v-res2 = '0'.
  find first cif-mail where cif-mail.cif = cif.cif no-lock no-error.
  if avail cif-mail then v-prtEmail = cif-mail.mail.
  v-prtPhone = cif.tel.
  if v-cltype = '01' then v-clnameU = trim(cif.prefix) + ' ' + trim(cif.name). else v-clnameU = ''.
  if v-cltype = '02' or v-cltype = '03' then do:
     if num-entries(cif.name,' ') > 0 then v-prtFLNam = entry(1,trim(replace(cif.name,'ИП',' ')),' ').
     if num-entries(cif.name,' ') >= 2 then v-prtFFNam = entry(2,trim(replace(cif.name,'ИП',' ')),' ').
     if num-entries(cif.name,' ') >= 3 then v-prtFMNam = entry(3,trim(replace(cif.name,'ИП',' ')),' ').
     if cif.geo = '021' then v-prtUD = '01'. else v-prtUD = '11'.
     if num-entries(cif.pss,' ') > 1 then v-prtUdN = entry(1,cif.pss,' '). else v-prtUdN = cif.pss.
     if num-entries(cif.pss,' ') >= 2 then v-prtUdDt = entry(2,cif.pss,' ').
     if num-entries(cif.pss,' ') >= 3 then v-prtUdIs = entry(3,cif.pss,' ').
     if num-entries(cif.pss,' ') > 3 then v-prtUdIs = entry(3,cif.pss,' ') + ' ' + entry(4,cif.pss,' ').
     find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "publicf" use-index dcod no-lock no-error .
     if avail sub-cod and sub-cod.ccode <> 'msc' then v-publicf = sub-cod.ccode.
     v-bdt = string(cif.expdt,'99/99/9999').
     v-bplace = cif.bplace.
  end.
  v-prtOKPO = cif.ssn.
  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-FIO1U = sub-cod.rcode.

  find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = "cln" and sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error .
  if avail sub-cod and sub-cod.ccode <> 'msc' then v-OKED = sub-cod.ccode.
end procedure.

/*заполняем форму для фин.мониторинга*/
procedure fm1.
  def var v-knp2 as char.
  def var v-resben as char.
  def var v-resbenC as char.
  def var v-resben2 as char.
  def var v-rcbank2 as char.
  def var v-rcbankbik as char.
  def var v-bennameU  as char no-undo.
  def var v-bennameF  as char no-undo.
  def var v-benFAM as char no-undo.
  def var v-benNAM as char no-undo.
  def var v-benM as char no-undo.
  def var v-benrnn as char no-undo.
  def var v-bentype as char no-undo.
  def var v-sumkzt as char no-undo.
  def var v-racc as char no-undo.

  find first codfr where codfr.codfr = 'kfmCrc' and codfr.name[2] = '1' no-lock no-error.
  v-benFAM = ''.
  v-benNAM = ''.
  v-benM = ''.
  v-bennameU = ''.
  v-bennameF = ''.
  if v-secop <> '9' then do:
     v-bennameU = entry(1,trim(substr(v-ben,index(v-ben,"/NAME/") + 6)),'/').
     v-bentype = '01'.
  end.
  if v-secop = '9' then do:
     v-bentype = '02'.
     v-bennameF = entry(1,trim(substr(v-ben,index(v-ben,"/NAME/") + 6)),'/').
     if num-entries(v-bennameF) > 0 then v-benFAM = entry(1,v-bennameF).
     if num-entries(v-bennameF) >= 2 then v-benNAM = entry(2,v-bennameF).
     if num-entries(v-bennameF) >= 3 then v-benM = entry(3,v-bennameF).
  end.
  v-knp2 = v-knp.
  if v-irsp <> '1' then v-resben2 = '0'.
  if v-irsp = '1' then v-resben2 = '1'.
  if v-resben2 = '1' then v-resbenC = 'KZ'.
  v-sumkzt = ''.
  run kfmoperh_cre('01','01',s-remtrz,v-oper,v-knp,'2',codfr.code,trim(string(v-amt,'>>>>>>>>>>>>9.99')),v-sumkzt,'','','','','','','','',v-kfmrem, output v-operId).
  find first aaa where aaa.aaa = v-acc no-lock no-error.
  find first cif where cif.cif = aaa.cif no-lock no-error.
  run defclparam.
  find first cmp no-lock no-error.
  find first sysc where sysc.sysc = 'CLECOD' no-lock no-error.
  v-num = 0.
  v-num = v-num + 1.
  run kfmprt_cre(v-operId,v-num,'01','02','57',v-res2,v-res,v-cltype,v-publicf,'',v-acc,cmp.name,trim(sysc.chval),'KZ','','','','',v-clnameU,v-FIO1U,cif.jss,v-prtOKPO,v-OKED,cif.bin,v-prtFLNam,v-prtFFNam,v-prtFMNam,v-prtPhone,v-prtEmail,v-prtUD,v-prtUdN,'',v-prtUdIs,v-prtUdDt,v-bdt,v-bplace,cif.addr[1],cif.addr[2],'','01').
  v-num = v-num + 1.
  v-resben = 'KZ'.
  v-rcbank2 = ''.
  v-rcbankbik = ''.
  v-cracc = ''.
  find first bankl where bankl.bank = substr(v-rbank,1,9) no-lock no-error.
  if avail bankl then do:
     v-rcbankbik = trim(bankl.cbank).
     find first bankt where bankt.cbank = bankl.cbank and bankt.crc = 1 and bankt.racc = "1" no-lock no-error .
     if avail bankt then v-cracc = bankt.acc.
     find first b-bankl where b-bankl.bank = bankl.cbank no-lock no-error.
     if avail b-bankl then v-rcbank2 = b-bankl.name.
  end.
  if substr(v-rcbankbik,1,9) matches "TXB*" then do:
     find first txb where txb.consolid and txb.bank = substr(v-rcbank,1,9) no-lock no-error.
     if avail txb then v-rcbankbik = txb.mfo.
     v-rcbankbik = ''.
  end.
  v-racc = ''.
  if v-ben begins "/D/" then v-racc = substr(v-ben,4,9). else v-racc = substr(v-ben,1,9).
  v-benrnn = entry(3,substr(v-ben,index(v-ben,"/RNN/"),17),'/').
  run kfmprt_cre(v-operId,v-num,'01','01','05',v-resben2,v-resbenC,v-bentype,'','',v-racc,v-bb,v-rbank,v-resben,v-cracc,v-rcbank2,v-rcbankbik,'',v-bennameU,'',v-benrnn,'','','',v-benFAM,v-benNAM,v-benM,'','','','','','','','','','','','','02').
  run kfmoper_cre(v-operId).
  v-kfm = yes.
end procedure.