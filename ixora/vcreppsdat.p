/* vcreppsdat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Сборка временной таблицы оформленных паспортов сделок за период
 * RUN
        vcrepps.p, vcrep14dat.p vcrepall.p 
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.3.5, 15.4.x.2
 * AUTHOR
        20.12.2002 nadejda
 * CHANGES
        10.02.2004 nadejda - доплисты выдаются и в сводке считаются полной суммой, поскольку из Приложения 14 их убрали, 
                             а в отчете валютчикам полезнее видеть все ДЛ и все суммы
        13.02.2004 nadejda - добавлен параметр вызова - суммы всех доплисты показывать или только изменившиеся, поскольку таки не убрали их из Приложения 14!
        17.02.2004 nadejda - изменен сбор документов - не по дате документа, а по дате регистрации в ПРАГМЕ
        17.02.2004 tsoy - добавлены поля outcorr и reciver в таблицу t-psa
        08.07.2004 saltanat - включен shared переменная v-contrtype и переменная v-contractnum, 
                              нужны для деления контрактов типа "1" и "5".
        17.01.2005 saltanat - включена передаваемая переменная p-contrvid, определяющая нужный вид контракта(активный или закрытый) 
*/


{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.
def input parameter p-all as logical.
def input parameter p-contrtype as char.
def input parameter p-contrvid  as char.

def shared temp-table t-psa 
  field ps like vcps.ps
  field dntype like vcps.dntype
  field dndate like vcps.dndate
  field psnum as char
  field crc like vcps.ncrc
  field crckod as char
  field sum like vcps.sum
  field sumdelta like vcps.sum
  field sumusd like vcps.sum
  field info as char
  field cifname as char
  field depart as integer
  field rnn as char
  field contrnum as char
  field ctei as char
  field partname as char
  field outcorr  as char
  field reciver  as char
  field regdate  like vcps.dndate
  field rname    as char
  field cname    as char.


def shared temp-table t-svodps
  field ei like vccontrs.expimp
  field kolps as integer init 0
  field kolpskzt as integer init 0
  field sumps as deci init 0
  field sumpskzt as deci init 0
  field koldl as integer init 0
  field koldlkzt as integer init 0
  field sumdl as deci init 0
  field sumdlkzt as deci init 0
  index main is primary ei.

def shared var v-dtb as date.
def shared var v-dte as date.
def shared var v-cursusd as deci.
def shared var v-dtcurs as date.
def shared var v-reptype as char.

def var v-cifname as char.
def var v-partname as char.
def var v-rnn as char.
def var v-depart as integer.
def var v-sum as deci.
def var v-sumall as deci.
def var v-sumdelta as deci.
def var v-yes as logical.
def var v-docs as char.
def var v-docsname as char.
def var i as integer.
def var l as logical.
def var v-cnt as integer.

def buffer b-ps for vcps.

v-docs = "".
v-docsname = "".
for each txb.codfr where txb.codfr.codfr = "vcdoc" and index("s", txb.codfr.name[5]) > 0 no-lock:
  v-docs = v-docs + txb.codfr.code + ",".
  v-docsname = v-docsname + txb.codfr.name[1] + ",".
end.

for each vccontrs where vccontrs.bank = p-vcbank use-index main no-lock break by vccontrs.cif:

  if first-of(vccontrs.cif) then do:
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.   
    v-cifname = trim(trim(txb.cif.sname) + " " + trim(txb.cif.prefix)).
    v-rnn = string(txb.cif.jss, "999999999999").
    v-depart = integer(txb.cif.jame) mod 1000.
  end. 

  if lookup(vccontrs.cttype,p-contrtype) <= 0 then next.
  /*if p-contrtype = "exp" and vccontrs.cttype <> "5" then next.*/

  if p-depart <> 0 and v-depart <> p-depart then next.
  
  if v-reptype <> "A" and vccontrs.expimp <> v-reptype then next.

  case p-contrvid:
       when 'A' then if vccontrs.sts begins "c" and vccontrs.udt <= v-dtb then next.
       when 'C' then if not vccontrs.sts begins "c" then next.
  end case.

  find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
  if avail vcpartners then 
    v-partname = trim(trim(vcpartners.name) + " " + trim(vcpartner.formasob)).
  else v-partname = "".

  c-vcps:
  for each vcps where vcps.contract = vccontrs.contract no-lock:

    if not (vcps.rdt >= v-dtb and vcps.rdt <= v-dte) then next c-vcps.

    v-yes = (vcps.dntype = "01").
    v-sum = vcps.sum / vcps.cursdoc-con.
    if v-yes then do:
      v-sumdelta = v-sum.
    end.
    else do:
      find last b-ps where b-ps.contract = vccontrs.contract and ((b-ps.rdt < vcps.rdt) or 
           ((b-ps.rdt = vcps.rdt) and ((b-ps.dntype = "01") or 
           ((b-ps.dntype <> "01") and ((b-ps.dnnum < vcps.dnnum) or 
           ((b-ps.dnnum = vcps.dnnum) and (b-ps.ps < vcps.ps))))))) 
           no-lock no-error.                                                                    
      if avail b-ps then do:
        v-sumdelta = v-sum - (b-ps.sum / b-ps.cursdoc-con).
        v-yes = v-sumdelta <> 0.
      end.
      else 
        message skip "Обнаружен доп.лист без паспорта сделки !" skip(1)
          "Клиент " + vccontrs.cif + " " + v-cifname skip
          "контракт " + vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999")
          skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
    end.

/*    if v-yes then do:*/
      create t-psa.
      t-psa.ps = vcps.ps.
      t-psa.dndate = vcps.rdt.
      t-psa.dntype = vcps.dntype.
      if vcps.dntype = "01" then
        t-psa.crc = vcps.ncrc.
      else
        t-psa.crc = vccontrs.ncrc.
      t-psa.contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
      t-psa.ctei = vccontrs.expimp.
      t-psa.cifname = v-cifname.
      t-psa.depart = v-depart.
      t-psa.rnn = v-rnn.
      t-psa.psnum = entry(lookup(vcps.dntype, v-docs), v-docsname) + " : " + vcps.dnnum.
      t-psa.partname = v-partname.
      find txb.ncrc where txb.ncrc.crc = t-psa.crc no-lock no-error.
      t-psa.crckod = string(txb.ncrc.stn).
      t-psa.sum = v-sum. 
      t-psa.sumdelta = v-sumdelta. 
      t-psa.info = vcps.dnnote[5].

      t-psa.outcorr = vcps.info[1].
      t-psa.reciver = vcps.info[2].

      t-psa.regdate = vcps.dndate.
     
        
      find txb.ofc where ofc.ofc = vcps.rwho no-lock no-error.

      if avail ofc then do:
         t-psa.rname  = ofc.name.
      end.

      find txb.ofc where ofc.ofc = vcps.cwho no-lock no-error.

      if avail ofc then do:
         t-psa.cname = ofc.name.
      end.


      if vcps.ncrc = 2 then t-psa.sumusd = t-psa.sum.
      else do:
        find last txb.ncrchis where txb.ncrchis.crc = t-psa.crc and 
            txb.ncrchis.rdt <= v-dtcurs no-lock no-error. 
        t-psa.sumusd = (t-psa.sum * txb.ncrchis.rate[1]) / v-cursusd.
      end.
/*    end.*/
  end.
end.


for each t-psa break by t-psa.ctei by t-psa.dntype by t-psa.crc:
  if first-of(t-psa.ctei) then do:
    create t-svodps.
    t-svodps.ei = t-psa.ctei.
  end.

  accumulate t-psa.sum (sub-count by t-psa.ctei by t-psa.dntype by t-psa.crc).
  accumulate t-psa.sum (sub-total by t-psa.ctei by t-psa.dntype by t-psa.crc).

  if t-psa.sumdelta <> 0 then do:
    accumulate t-psa.sumdelta (sub-count by t-psa.ctei by t-psa.dntype by t-psa.crc).
    accumulate t-psa.sumdelta (sub-total by t-psa.ctei by t-psa.dntype by t-psa.crc).
  end.

  if last-of(t-psa.crc) then do:
    if p-all then do:
      v-sum = accum sub-total by t-psa.crc t-psa.sum.
      v-cnt = accum sub-count by t-psa.crc t-psa.sum.
    end.
    else do:
      v-sum = accum sub-total by t-psa.crc t-psa.sumdelta.
      v-cnt = accum sub-count by t-psa.crc t-psa.sumdelta.
    end.
    

    if t-psa.crc <> 2 then do:
      find last txb.ncrchis where txb.ncrchis.crc = t-psa.crc and 
         txb.ncrchis.rdt <= v-dtcurs no-lock no-error. 
      v-sum = (v-sum * txb.ncrchis.rate[1]) / v-cursusd.
    end.

    find t-svodps where t-svodps.ei = t-psa.ctei.
    if t-psa.dntype = "01" then do:
      t-svodps.kolps = t-svodps.kolps + v-cnt.
      t-svodps.sumps = t-svodps.sumps + v-sum.
      if t-psa.crc = 1 then do:
        t-svodps.kolpskzt = t-svodps.kolpskzt + v-cnt.
        t-svodps.sumpskzt = t-svodps.sumpskzt + v-sum.
      end.
    end.
    else do:
      t-svodps.koldl = t-svodps.koldl + v-cnt.
      t-svodps.sumdl = t-svodps.sumdl + v-sum.
      if t-psa.crc = 1 then do:
        t-svodps.koldlkzt = t-svodps.koldlkzt + v-cnt.
        t-svodps.sumdlkzt = t-svodps.sumdlkzt + v-sum.
      end.
    end.
  end.
end.

