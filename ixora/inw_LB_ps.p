/* inw_LB_ps.p
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
        19.08.2003 nadejda - добавлены индексы во временные таблицы
        25.03.2004 nadejda - сделана обработка любого счета ARP, а не только для счета ГК карточников
        20.10.2004 tsoy    - список файлов теперь не в переменной а во временной таблице
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        18.12.2005 tsoy     - добавил время создания платежа.
        04.08.2005 u00121  - remtrz.rdt теперь ставится значение g-today, раньше принималось значение today
        30/01/08 marinav - если Гросс то cover = 2, если клиринг,то cover = 1
        19/03/08 marinav - убраны message, запускается в виде процесса ПС
        01/10/2008 madiyar - номер документа теперь не берется из поля :21:
        12/11/2008 marinav - в назн платежа добавила + " " + v-acc.
        02.06.10  marinav - добавила t-102.rem = 'already exist'. если 102 платеж прогрузился повторно
        10.06.10 marinav - проверка на наш банк получатель
        07.07.2010 marinav - изменился формат поля //LA/
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН
        15/02/2013 Luiza - ТЗ № закоментировала запись ключевых слов в детали платежа
        19/08/2013 galina - ТЗ1871 добавила обработку платежей по СМЭП
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа

*/

def shared temp-table t-qin
   field fname as char.

def var pnrj as log init false.
def var dsd as int .
def var s-irs as cha .
def var r-irs as cha .
def var s-seco as cha .
def var r-seco as cha .
def var v-knp102 as cha .
def var v-knp as cha .
def var ifl as int .
def shared var f-name as cha .
def var ok1 as log init true.
def var daynum as cha .
def shared var v-lbin as cha .
def shared var v-lbina as cha .
def new shared var oi-name as char.
def var second21 as log init false .
def var v-oks as log init false .
def var fou as log initial false .
def var id as int .
def var v-ii as int .
def var v-rmz like remtrz.remtrz .
def var m-typ as cha .
def shared var v-ok as log .
def var v-ret as cha .
def var tradr as cha .
def var v-sqn as cha .
def var v-sqn21 as cha .
def var exitcod as cha .
def var v-log as cha format "x(40)" .
def var v-date as date .
def frame f-log with overlay centered 10 down row 5
    no-label title "Processing .." .
def var r-bank like bankl.bank .
def var s-bank like bankl.bank .
def var sb-bank like bankl.bank .
def var sc-bank like bankl.bank.
def var sc-bank53 like bankl.bank init "".
def var s-error as cha .
def var sc-bank54 like bankl.bank init "".
def var sc-bank56 like bankl.bank init "".
def var v-cif like cif.cif .
def var rep as cha initial "0".
def var irep as int initial 0.
def var blok4 as log initial false .
def var blokA as log initial false .
def var v-ref as cha  .
def var v-crc like remtrz.fcrc .
def var v-amt like remtrz.amt.
def var v-ord like remtrz.ord.
def var v-info as cha .
def new shared var v-ordins as cha init "".
def var v-acc like remtrz.sacc.
def var oldbb as cha .
def var v-bb as cha .
def var v-bbbic as cha .
def var v-ba as cha .
def var v-ba1 as cha .
def var v-ben as cha .
def var v-det as cha .
def var v-det102 as cha .
def var v-chg as cha init "BEN".
def var v-info9 as cha .
def var tmp as cha .
def shared stream prot .
def var i as int .
def var num as cha extent 100 .
def var v-string as cha .
def var impok as log initial false .
def var ok as log initial false .
def var acode like crc.code.
def var bcode like crc.code.
def var c-acc as cha .
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
def var ourcode as cha.
def var v-sender like remtrz.sbank .
def var t-pay like remtrz.payment.
def buffer tgl for gl.
def buffer t2gl for gl.
def var b as int.
def var s as int.
def var sender   as cha.
def var v-field  as cha .
def var receiver as cha.
def var v-err as cha .
def new shared var s-remtrz like remtrz.remtrz .
def var v-reterr as int initial 0 .
def var qs as char format "x(12)".
def var t-count as int .
def var tot-n as int .
def var t-n as int .
def var t-summ like remtrz.amt  .
def var tot-summ like remtrz.amt .
def var t-totcount as int .
def var v-plnum as char.
def shared var g-today as date .
def shared var g-ofc as cha.
def var v-chief as char.
def var v-mainbk as char.
def var cc as char.
def var v-len as integer.
def var v-len1 as integer.
def shared var card-gl as char.
def var v-gro as char.

def temp-table wrmz
 field remtrz like remtrz.remtrz
 index remtrz is primary remtrz.

def temp-table mfo-s
    field ex-code as char format "x(9)"
    field in-code as char format "x(5)"
    index ex-code is primary ex-code.

{chbin.i}

for each bankl where bankl.bank begins "TXB" and bankl.bank <> "TXB00" no-lock:
   create mfo-s.
   in-code = bankl.bank.
   ex-code = bankl.crbank.
end.

 def var lbnstr as cha .
 find first sysc where sysc.sysc = "LBNSTR" no-lock no-error .
 if avail sysc then lbnstr = sysc.chval .
 {lgps.i new}
 v-text = "" .
 m_pid = "LBI" .
 v-ok = false .


find sysc where sysc.sysc = "clecod" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record CLECOD in sysc file !! ".
 run lgps.
 return .
end.
ourcode = sysc.chval.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " There isn't record OURBNK in sysc file !! ".
 run lgps.
 return .
end.
ourbank = sysc.chval.

create mfo-s.
mfo-s.in-code = ourbank.   /*TXB00*/
mfo-s.ex-code = ourcode.   /*MEOKKZKA*/

find first bankl where bankl.bank = ourbank no-lock no-error.

find sysc where sysc.sysc = "PS_ERR" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " There isn't record PS_ERR in sysc file !! ".
 run lgps.
 return .
end.
 v-err = sysc.chval.


for each t-qin.

  ifl = ifl + 1 .
  ok = true .
  num = "".
  num[1] = entry(2,t-qin.fname, " ") .
  num[2] = v-lbin + num[1] .
  ok = ok and ok1 .

 v-oks = true.
 ok1 = false .
 r-bank = "" .
 v-date = g-today .
 v-crc = 0 .
 v-amt = 0 .
 v-ref = "" .
 v-ord = "" .
 v-bb = "" .
 v-rmz = "" .
 v-ben = "" .
 v-ba = "" .
 v-ba1 = "" .
 v-det = "" .
 v-chg = "" .
 v-acc = "" .
 v-info = "" .
 v-info9 = "" .
 v-reterr = 0 .
 v-sqn21 = "" .
 v-plnum = "" .
 v-sqn = "" .
 second21 = false .
 blok4 = false .
 v-field = "x".
 v-ordins = "".
 v-knp102 = '000'.
 v-knp = '000'.
 s-irs = ' '.
 r-irs = ' '.
 v-chief = ''.
 v-mainbk = ''.
 s-seco = ' '.
 r-seco = ' '.
 pnrj = false .
 v-det102 = ""  .
 v-gro = "".

 for each wrmz .
  delete wrmz .
 end.


input through value("lbarc " + num[2] ) .
repeat while not(length(v-field) = 0 or  v-field begins "-}") :

v-knp   =   "000" .
v-plnum =   "" .
v-ordins = "".

repeat :

 v-field = "".
 import unformatted v-field .
 if v-field begins "-}" then leave .
 if v-field begins "\{2:" and  ( (substr(v-field,4,4) ne "O102") and (substr(v-field,4,4) ne "O100" ))  then do:
    v-oks = false.
    leave .
 end.

 if substr(v-field,4,4) eq "O100"  then  m-typ = "100" . else
 if substr(v-field,4,4) eq "O102"  then  m-typ = "102" .

 if substr(v-field,19,5) eq "GROSS" then  v-gro = "G". else
 if substr(v-field,19,5) eq "CLEAR" then  v-gro = "C". else
 if substr(v-field,19,5) eq "MEP00" then  v-gro = "S".

 if v-field begins ":" or v-field begins "-}" then do:
                rep = "0" .
                irep = 0 .
 end .
 v-string = v-field .

 if v-string begins ":21:" then do:

       /* marinav */
       create t-102.
       assign t-102.account = v-ba
              /*
              t-102.ndoc = int(substr(v-string,5))
              */
              t-102.rnn = substr(v-ben, index(v-ben,'/RNN/') + 5)
              t-102.fio = substr(v-ben, 1, index(v-ben,'/RNN/') - 1)
              t-102.kb = 0
              t-102.bud = no
              t-102.knp = v-knp102
              t-102.kod = '14'
              t-102.kbe = '19'
              t-102.nplin = v-det102 + " " + v-acc
              t-102.pid = '1P'
              t-102.prn = 0
              t-102.cov = 5
              t-102.date = g-today.

       if not second21 then do:
              v-sqn = fill(".",18) + substr(v-string,5).
              second21 = true .
              v-len = length(trim(v-sqn)) - 18.
        end.
        else do:
              v-sqn21 = fill(".",18) + substr(v-string,5).
              v-len = length(trim(v-sqn21)) - 18.
              leave .
        end.
 end.
 else
        if v-string begins ":20:" then do :
         if m-typ = "102" then do: v-rmz = substr(v-string,5,16) .
           v-len1 = length(trim(v-rmz)).
          end.
         else if m-typ = "100" then
         do:
          v-sqn = fill(".",18) + substr(v-string,5).
          v-rmz = substr(v-string,5,16) .
         end.
        end .
        else
            if v-string begins ":32B:" then do:
                 if v-sqn21 ne "" then v-sqn = v-sqn21 .
                 if v-len1  <= 22 - v-len  then substr(v-sqn,18 + v-len + 1,22 - v-len) = v-rmz.
                                           else substr(v-sqn,18 + v-len + 1,22 - v-len) =  substr(v-rmz,v-len1 - 22 + v-len + 1,22 - v-len).
                 substr(v-sqn,41,24) = substr(v-string,6) .

                 tmp = (substr(v-string,6,3)) .
                 if tmp = "lvl" then tmp = "ls" .
                 find first crc where crc.code = tmp no-lock no-error .
                 if not avail crc then  v-crc = 0 .
                                  else v-crc = crc.crc .
                 tmp = (substr(v-string,9)) .
                 substring(tmp,index(tmp,","),1) = "." .
                 v-amt = decimal(tmp).
                 find last t-102 where t-102.sum = 0 no-error.
                 t-102.sum = v-amt.
            end.
            else
                if v-string begins ":32A:" and m-typ = "100" then do:
                      substr(v-sqn,35,24) = substr(v-string,6) .
                      if substr(v-string,6,2) eq  substr(string(year(today)),3,2)
                          then cc = substr(string(year(today)),1,2).
                      else
                         if substr(v-string,6,2) lt  substr(string(year(today)),3,2) then cc = "20".

                      if substr(v-string,6,2) gt  substr(string(year(today)),3,2) then cc = "19".
                      v-date = date(int(substr(v-string,8,2)), int(substr(v-string,10,2)),
                      int(trim(cc)  +  substr(v-string,6,2))) .
                      tmp = (substr(v-string,12,3)) .
                      if tmp = "lvl" then tmp = "ls" .
                      find first crc where crc.code = tmp no-lock no-error .
                      if not avail crc then v-crc = 0 .
                                       else v-crc = crc.crc .
                      tmp = (substr(v-string,15)) .
                      substring(tmp,index(tmp,","),1) = "." .
                      v-amt = decimal(tmp).
                end.
                else
                     if v-string begins ":32A:" and m-typ = "102" then do:
                           v-date = date(int(substr(v-string,8,2)), int(substr(v-string,10,2)),
                           int( substr(string(year(today)),1,2) +
                           substr(v-string,6,2))) .
                           if pnrj then do:
                               tmp = (substr(v-string,15)) .
                               substring(tmp,index(tmp,","),1) = "." .
                               v-amt = decimal(tmp).
                           end.
                           for each wrmz, each remtrz where remtrz.remtrz = wrmz.remtrz exclusive-lock .
                              dsd = remtrz.valdt2 - remtrz.valdt1 .
                              remtrz.valdt1 = v-date .
                              remtrz.valdt2 = valdt1 + dsd  .

                              if pnrj then do:
                                  t-summ = t-summ - remtrz.amt + v-amt.
                                  remtrz.amt     = v-amt.
                                  remtrz.payment = v-amt.
                                  v-text = "Creating of the remtrz = " + remtrz.remtrz + " <-  SQN = " + string(num[1]) + "/mt" + m-typ + "/"
                                           + " <- " + s-bank + " " + " " + remtrz.sqn + " " + string(v-amt) + crc.code .
                                  put stream prot unformatted v-text skip .
                                  run lgps.
                              end.
                              delete wrmz.
                           end.
                     end.
                    else
                            if v-string begins ":50:" or rep = "50" then do:
                                   if rep = "0" then do:
                                       rep = "50" .
                                       v-ord = "" .
                                       if substr(v-string,5) begins "/D/" then v-acc = substr(v-string,8) .
                                                                          else v-acc = "REVERSE".
                                   end .
                                   else do :
                                       if v-string begins "/NAME/" then do :
                                            if trim(v-ord) = "" then v-ord = trim(substr(v-string,7)) .
                                                                else v-ord  = v-ord + " " + substr(v-string,7) .
                                       end.

                                       if v-string begins "/RNN/" then do :
                                            if trim(v-ord) = "" then v-ord = trim(substr(v-string,1)) .
                                                                else v-ord  = v-ord + " " + trim(substr(v-string,1)) .
                                       end.
                                       if v-string begins "/IDN/" then do :
                                            if trim(v-ord) = "" then v-ord = trim(substr(v-string,1)) .
                                                                else v-ord = v-ord + " " + trim(substr(v-string,1)) .
                                            v-ord = replace (v-ord, "IDN", "RNN").
                                       end.
                                       if v-string begins "/CHIEF/" then  v-chief  =  trim(substr(v-string,1)) .
                                       if v-string begins "/MAINBK/" then v-mainbk = trim(substr(v-string,1)) .
                                       if v-string begins "/IRS/" then    s-irs  = trim(substr(v-string,6,1)) .
                                       if v-string begins "/SECO/" then   s-seco = trim(substr(v-string,7)) .
                                   end .
                            end.
                            else
                                     if v-string begins ":52" or rep = "52" then do:
                                       if rep = "0" then do:
                                              i = index(substr(v-string,2),":").
                                              rep = "52" .
                                              s-bank  = trim(substr(v-string,i + 2)) .
                                        end .
                                        else
                                        s-bank  = s-bank + " " + trim(v-string) .
                                     end.
                                     if v-string begins ":53" or rep = "53" then do:
                                         if rep = "0" then do:
                                           i = index(substr(v-string,2),":").
                                           rep = "53" .
                                           sc-bank  = trim(substr(v-string,i + 2 , 9)) .
                                         end .
                                         else
                                         sc-bank = sc-bank + " " + trim(v-string) .
                                     end.

                                     else
                                            if v-string begins ":59:" or rep = "59" then do:
                                              if rep = "0" then do:
                                               rep = "59" .
                                               v-ben = "" .
                                               if substr(v-string,5,1) = "/" then
                                                v-ba = substr(v-string,6) .
                                               else
                                                v-ba = substr(v-string,5) .
                                                v-ba1 = v-ba .
                                              end .
                                              else do :
                                                if v-string begins "/NAME/" then do :
                                                  if trim(v-ben) = "" then v-ben = trim(substr(v-string,7)) .
                                                  else
                                                  v-ben  = v-ben + trim(substr(v-string,7)) .
                                                end.
                                               if v-string begins "/RNN/" then do :
                                                 if trim(v-ben) = "" then v-ben = trim(substr(v-string,1)) .
                                                                     else v-ben = v-ben + " " + trim(substr(v-string,1)) .
                                               end.
                                               if v-string begins "/IDN/" then do :
                                                    if trim(v-ben) = "" then v-ben = trim(substr(v-string,1)) .
                                                                        else v-ben = v-ben + " " + trim(substr(v-string,1)) .
                                                    v-ben = replace (v-ben, "IDN", "RNN").
                                               end.

                                               if v-string begins "/IRS/" then
                                                      r-irs  = trim(substr(v-string,6,1)) .
                                               if v-string begins "/SECO/" then
                                                      r-seco = trim(substr(v-string,7)) .
                                              end .
                                             end .
                                            else
                                                if v-string begins ":57" or rep = "57" then do:
                                                  if rep = "0" then do:
                                                      i = index(substr(v-string,2),":").
                                                      rep = "57" .
                                                      v-bb  = trim(substr(v-string,i + 2)) .
                                                   end .
                                                   else v-bb  = v-bb + " " + trim(v-string) .
                                                end.
                                                else
                                                       if v-string begins ":70:" or rep = "70" then do:
                                                          if rep = "0" then do:
                                                                rep = "70" .
                                                                v-det = trim(substr(v-string,5)) .
                                                                if index(v-det,"/NUM/") > 0 and v-plnum eq "" then v-plnum = substr(v-det,index(v-det,"/NUM/") + 5 ).
                                                          end.
                                                          else do:
                                                             v-det = v-det + " " + trim(v-string).
                                                             if index(v-det,"/NUM/") > 0 and v-plnum eq "" then v-plnum = substr(v-det,index(v-det,"/NUM/") + 5 ).
                                                             if index(v-det,"/KNP/") > 0 and v-knp = "000" then v-knp   = substr(v-det,index(v-det,"/KNP/") + 5, 3 ).
                                                             if index(v-det,"/ASSIGN/") > 0                then v-det   = substr(v-det,index(v-det,"/ASSIGN/") + 8 ).

                                                             if v-string begins "//FM/"  then t-102.bn[1] = substr(v-string, index(v-string,"//FM/") + 5 ).
                                                             if v-string begins "//NM/"  then t-102.bn[1] = t-102.bn[1] + " " + substr(v-string, index(v-string,"//NM/") + 5 ).
                                                             if v-string begins "//FT/"  then t-102.bn[1] = t-102.bn[1] + " " + substr(v-string, index(v-string,"//FT/") + 5 ).
                                                             if v-string begins "//LA/"  then t-102.racc = substr(v-string, index(v-string,"//LA/") + 5 ).
                                                             if v-string begins "//RNN/" then t-102.bnrnn = substr(v-string, index(v-string,"//RNN/") + 6 ).

                                                             if v-string begins "/FM/"  then t-102.bn[1] = substr(v-string, index(v-string,"/FM/") + 4 ).
                                                             if v-string begins "/NM/"  then t-102.bn[1] = t-102.bn[1] + " " + substr(v-string, index(v-string,"/NM/") + 4 ).
                                                             if v-string begins "/FT/"  then t-102.bn[1] = t-102.bn[1] + " " + substr(v-string, index(v-string,"/FT/") + 4 ).
                                                             if v-string begins "/LA/"  then t-102.racc = substr(v-string, index(v-string,"/LA/") + 4 ).
                                                             if v-string begins "/IDN/" then t-102.bnrnn = substr(v-string, index(v-string,"/IDN/") + 5 ).


                                                             if not second21 and m-typ = "102" then do:
                                                               v-knp102 = v-knp .
                                                               v-det102 = v-det .
                                                             end.
                                                          end .
                                                end.
 end.  /*  fields repeat   */

 if not v-oks then leave .

/* Changes by ja on 15/06/01 */
/*iban  определяем TXB по двум последним цифрам в номере счета v-bb */
 r-bank = "".
/*
 find first mfo-s where mfo-s.ex-code = trim(v-bb) no-lock no-error.
 if avail mfo-s then r-bank = mfo-s.in-code.
*/
 if trim(v-bb) ne ourcode then do:
     v-text = trim(v-bb) + " isn't ourbank. Loading aborted. " + trim(num[1]).
     put stream prot unformatted v-text skip .
     v-oks = false .
     next  .
 end.
 r-bank = "TXB" + substr(trim(v-ba),19,2).
/*iban*/

 if sc-bank ne "" then do :
 find first bankl where bankl.bank = sc-bank no-lock no-error .
 if not avail bankl then
 do:
     v-text = "CORBANK " + sc-bank + " wasn't found. ".
     run lgps.
     sc-bank = "" .
 end.
 end.

if v-ben begins "/RNN/" then
 v-ben = trim(substr(v-ben,18)) + trim(substr(v-ben,1,17)).
else
 v-ben = trim(v-ben).

if v-ord begins "/RNN/" then
  v-ord = trim(substr(v-ord,18)) + trim(substr(v-ord,1,17)).
  v-ord = trim(v-ord) .

if index(v-det,"/OPV/") > 0 and
   index(v-det,"/FM/") > 0 and
   index(v-det,"/NM/") > 0 and
   index(v-det,"/DT/") > 0 and v-sqn21 ne "" then
       v-sqn = substr(v-sqn,1,18) + (if trim(v-plnum) ne "" then string(v-plnum,"x(16)")
                                                            else substr(v-rmz,1,16) ) .
   else
       v-sqn = substr(v-sqn,1,18) + (if trim(v-plnum) ne "" then string(v-plnum,"x(16)")
                                                            else substr(v-rmz,1,16) )  + "." + substr(v-sqn,19).


if v-reterr eq 0 and r-bank = ourbank then do:

 find first aaa where aaa.aaa = v-ba no-lock no-error .
 if avail aaa then find cif of aaa no-lock no-error .

 if not avail cif or not avail aaa then do:
   v-text = " SQN = " + string(num[1]) + " from " +  s-bank +
            "." +  v-ref + " -> " + v-ba + "  CIF or account does not exist !!! " .
   run lgps.
 end .
 else
       if aaa.crc ne v-crc  then do:
           v-text = " SQN = " + string(num[1]) + " from " + s-bank  + "." + v-ref +
                    "  account currency " + string(v-crc) + " " + string(aaa.crc)   + " is not equal payment currency !!!   " .
          run lgps.
       end.
end .

 find first remtrz where
   remtrz.sqn = v-sqn
   and remtrz.sbank = s-bank
   and remtrz.valdt1 = v-date
   no-lock  no-error .

 if avail remtrz then do:
      v-text = remtrz.remtrz + " <- " + v-sqn + " already exist " .
      put stream prot unformatted v-text skip .
      v-text = " Loading aborted. " + string(num[1]).
      put stream prot unformatted v-text skip .
      v-ok = false .
      for each t-102 where t-102.rem = ''.
          t-102.rem = 'already exist'.
          t-102.ff = yes.
      end.
      leave.
  /* return   . */
 end.

 if v-acc = "REVERSE" then do:
   v-text = " REVERSE <- " + v-sqn   .
   put stream prot unformatted v-text skip .
   v-text = " Loading aborted. " + string(num[1]).
   put stream prot unformatted v-text skip .
   v-ok = false .
   leave.
 /* return   . */
 end.


if v-oks and not pnrj then do on error undo  :

     run n-remtrz.
     create remtrz .
            remtrz.rtim = time.
     assign remtrz.source = "LBI"
            remtrz.t_sqn = v-rmz
            remtrz.rdt = g-today  /*u00121 04/08/2005 было today*/
            remtrz.remtrz = s-remtrz
            remtrz.scbank = sc-bank
            remtrz.valdt1 = v-date
            remtrz.sacc = v-acc
            remtrz.tcrc = v-crc
            remtrz.payment = v-amt
            remtrz.fcrc = v-crc
            remtrz.amt = v-amt
            remtrz.jh1   = ?
            remtrz.jh2 = ?
            remtrz.ord = trim(v-ord) + v-chief + v-mainbk.
            if remtrz.ord = ? then do:
             run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "inw_LB_ps.p 636", "1", "", "").
            end.
    if v-gro = "G" then remtrz.cover = 2.
    if v-gro = "C" then remtrz.cover = 1. /*клиринг*/
    if v-gro = "S" then remtrz.cover = 6. /*СМЭП*/

     oldbb = v-bb .
     find bankl where bankl.bank = r-bank no-lock no-error.
       if avail bankl then v-bb = trim(bankl.name) + " " + trim(bankl.addr[1])
        + trim(bankl.addr[2]) + " " + trim (bankl.addr[3]).

     if v-bb ne "" then
     do:
      assign remtrz.bb[1]  = "/" + substr(v-bb,1,35)
             remtrz.bb[2]  = substr(v-bb,36,35)
             remtrz.bb[3]  = substr(v-bb,71,70)
             remtrz.actins[1]  = "/" + substr(v-bb,1,35)
             remtrz.actins[2]  = substr(v-bb,36,35)
             remtrz.actins[3]  = substr(v-bb,71,35)
             remtrz.actins[4]  = substr(v-bb,106,35) .
     end .
     v-bb = oldbb .
     assign remtrz.bn[1] = substr(v-ben,1,60)
            remtrz.bn[2] = substr(v-ben,61,60)
            remtrz.bn[3] = substr(v-ben,121,60) .

     /* Luiza закомент-ла if m-typ = "102" then v-det = v-det102 + v-det .*/
     assign remtrz.det[1] = substr(v-det,1,35)
            remtrz.det[2] = substr(v-det,36,35)
            remtrz.det[3] = substr(v-det,71,35)
            remtrz.det[4] = substr(v-det,106) .

   if index(v-det,"/OPV/") > 0 and
      index(v-det,"/FM/")  > 0 and
      index(v-det,"/NM/")  > 0 and
      index(v-det,"/DT/")  > 0 and v-sqn21 ne "" then pnrj = true  .

     v-det = "" .

     assign remtrz.rcvinfo[1] = substr(v-info,1,35)
            remtrz.rcvinfo[2] = substr(v-info,36,35)
            remtrz.rcvinfo[3] = substr(v-info,71,35)
            remtrz.rcvinfo[4] = substr(v-info,106,35)
            remtrz.rcvinfo[5] = substr(v-info,141,35)
            remtrz.rcvinfo[6] = substr(v-info,176,35)

            remtrz.ba =  v-ba1
            remtrz.bi = v-chg

            remtrz.margb = 0
            remtrz.margs = 0

            remtrz.svca   = 0
            remtrz.svcaaa = ""
            remtrz.svcmarg = 0
            remtrz.svcp = 0
            remtrz.svcrc = 0
            remtrz.svccgl = 0
            remtrz.svcgl = 0
            remtrz.dracc = ""
            remtrz.drgl = 0.

    if v-ordins = "" then do :
     if s-bank ne "" then do :
      find first bankl where bankl.bank = s-bank no-lock no-error.
      if avail bankl then
        v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " "
        + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
      else v-ordins = "".
     end.
    end.
    else do :    /*  v-ordins ne ""   */
     find first bankl where v-ordins = substr(bankl.bic,3)
         and substr(bankl.bic,3) ne "" no-lock no-error .
     if avail bankl then
       v-ordins = trim(bankl.name) + " " + trim(bankl.addr[1]) + " "
         + trim(bankl.addr[2]) + " " + trim(bankl.addr[3]).
     else do :
  /*     run stests1.
       if oi-name ne "" then v-ordins = oi-name.  */
     end.
    end.
    if v-ordins = "" then  do :  /* search in bint   */
      v-ordins = trim(qs).
 /*     run stests1.
      if oi-name ne "" then v-ordins = oi-name.     */
    end.

    assign remtrz.ordins[1] = substr(v-ordins,1,35)
           remtrz.ordins[2] = substr(v-ordins,36,35)
           remtrz.ordins[3] = substr(v-ordins,71,35)
           remtrz.ordins[4] = substr(v-ordins,106,35)

           remtrz.sqn = v-sqn  /* + ".." + v-ref*/
           remtrz.rcbank = "".

     /*
     remtrz.sqn = trim(ourbank) + "."  + remtrz.remtrz + ".." + v-ref.
     */

     if r-bank = "" then r-bank = ourbank.

     remtrz.rbank = r-bank.
     acode = "".
     remtrz.racc = v-ba .
     remtrz.outcode = 3 .
     if remtrz.valdt1 >= g-today then remtrz.valdt2 = remtrz.valdt1  .
                                 else remtrz.valdt2 = g-today .


   if s-bank eq "" and sc-bank = "" then  do:
      v-text = remtrz.remtrz +
      " WARNING !!! There is not SENDER BANK CODE and COR.BANK CODE! " .
      run lgps.
   end.

   else
   do:    /*  known sender */
    if s-bank ne "" then do :
     find first bankl where bankl.bank = s-bank no-lock no-error.
     if not avail bankl then do:
       v-text = remtrz.remtrz + " WARNING !!! There isn't BANKL for "
         + s-bank + "  !!! , 3 bit retcode = 1 " .
       run lgps .
       v-reterr = v-reterr + 8.  /*  */  .
     end.
     else remtrz.sbank = s-bank .
    end.  /* s-bank ne ""   */
    find first crc where crc.crc = remtrz.tcrc no-lock no-error.
    if avail crc then
    bcode = crc.code .
    if sc-bank ne "" then
       find first bankt where bankt.cbank = sc-bank and
       bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .
    else
       find first bankt where bankt.cbank = bankl.cbank and
       bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

    if not avail bankt then do:
      v-text = remtrz.remtrz + " LB " +
      " WARNING !!! There isn't BANKT " + sc-bank +
       " for CRC = " + bcode  +  " record !!!  " .
      run lgps .
      v-reterr = v-reterr + 16 .
    end.

    else do :        /* not error */
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.scbank = t-bankl.bank .
     remtrz.dracc = bankt.acc.

    /* проставление вида документа */
    find first sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = 'pdoctng' no-lock no-error.
    if not avail sub-cod then do:
        create sub-cod.
        sub-cod.sub = 'rmz'.
        sub-cod.acc = remtrz.remtrz.
        sub-cod.d-cod = 'pdoctng'.
        sub-cod.ccode = "20" /* Прочие зачисления */.
        sub-cod.rdt = g-today.
    end.
     sender = "n" .
     if bankt.subl = "dfb"
     then do:
          find first dfb where dfb.dfb = bankt.acc no-lock no-error .
      if not avail dfb  then do:
       v-text = remtrz.remtrz + " WARNING !!! There isn't DFB " +
       bankt.acc  + " for LB " +
       s-bank + "  !!!  " .
       run lgps .
       v-reterr = v-reterr + 125.  /*  */  .
      end.
      else
      do:
       remtrz.drgl = dfb.gl.
       find tgl where tgl.gl = remtrz.drgl no-lock.
      end.
     end.
     if bankt.subl = "cif"
     then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
        if not avail aaa  then do:
          v-text = remtrz.remtrz + " WARNING !!! There isn't AAA " +
              bankt.acc  + " for LB " + s-bank + "  !!!  " .
          run lgps .
          v-reterr = v-reterr + 126.  /*  */  .
        end.
        else do:
           remtrz.drgl = aaa.gl.
           find tgl where tgl.gl = remtrz.drgl no-lock.
        end.
     end.
    end .  /* not error */
    find first bankl where bankl.bank = s-bank no-lock no-error.
/*   end.   sbank isn't our bank  */
   end .

 if r-bank eq "" or r-bank = "txb" then  do:
      v-text = remtrz.remtrz +
      " WARNING !!! There is not BENEFICIARY BANK CODE ! " .
      run lgps.
 end.
 else
 do:

/*  known RECEIVER  */

   find first bankl where bankl.bank = r-bank no-lock no-error.

   if not avail bankl then do:
      v-text = remtrz.remtrz + " WARNING !!! There isn't BANKL for
       LB  " +
      r-bank + "  !!! , 3 bit retcode = 1 " .
      run lgps .
      v-reterr = v-reterr + 8.  /*  */  .
   end.
   else
   if bankl.bank ne ourbank  then
    do  :
     find first crc where crc.crc = remtrz.tcrc no-lock no-error .
     if avail crc then
     bcode = crc.code .
     find first bankt where bankt.cbank = bankl.cbank and
     bankt.crc = remtrz.tcrc and bankt.racc = "1" no-lock no-error .

    if not avail bankt then do:
      v-text = remtrz.remtrz + " LB " +
      " WARNING !!! There isn't BANKT " + bankl.cbank +
       " for CRC = " + bcode  +  " record !!!  " .
      run lgps .
   /*   v-reterr = v-reterr + 16 .  */  .
    end.

    else do :        /* not error */
     if remtrz.valdt1 >= g-today then
     remtrz.valdt2 = remtrz.valdt1 + bankt.vdate .
     else
     remtrz.valdt2 = g-today + bankt.vdate .
     if remtrz.valdt2 = g-today and bankt.vtime < time
      then remtrz.valdt2 = remtrz.valdt2 + 1 .
     find first t-bankl where t-bankl.bank = bankt.cbank no-lock .
     remtrz.rcbank = t-bankl.bank .
     if t-bankl.nu = "u" then
     do:
      receiver = "u".
      remtrz.rsub = "cif".
     end.
     else do:
      receiver = "n" .
      remtrz.ba = "/" +  v-ba1 .
     end .
     remtrz.rcbank = t-bankl.bank .
     remtrz.raddr = t-bankl.crbank.
     remtrz.cracc = bankt.acc.
     if bankt.subl = "dfb"
        then do:
          find first dfb where dfb.dfb = bankt.acc no-lock no-error .
     if not avail dfb  then do:
      v-text = remtrz.remtrz + " WARNING !!! There isn't DFB " +
      bankt.acc  + " for LB " +
      r-bank + "  !!!  " .
      run lgps .
      v-reterr = v-reterr + 125.  /*  */  .
     end.
        else
        do:
          remtrz.crgl = dfb.gl.
          find tgl where tgl.gl = remtrz.crgl no-lock.
        end.
       end.
      if bankt.subl = "cif"
        then do:
        find first aaa where aaa.aaa = bankt.acc no-lock no-error .
   if not avail aaa  then do:
      v-text = remtrz.remtrz + " WARNING !!! There isn't AAA " +
      bankt.acc  + " for LB  " +
      r-bank + "  !!!  " .
      run lgps .
      v-reterr = v-reterr + 126.  /*  */  .
   end.
          else do:
           remtrz.crgl = aaa.gl.
           find tgl where tgl.gl = remtrz.crgl no-lock.
          end.
        end.
     end .  /* not error */
  end.     /* rbank isn't our bank */

   else
    do :
      assign remtrz.rcbank = r-bank
             remtrz.rsub = "cif"
             remtrz.raddr = "".
      remtrz.valdt2 = remtrz.valdt1 .
      receiver = "o".
      if remtrz.rsub ne "" then do:
       c-acc = remtrz.racc .
       if rsub = "cif" then do:
        find first aaa where aaa.aaa = c-acc and aaa.crc eq remtrz.tcrc no-lock no-error .
        find first arp where arp.arp = c-acc and arp.crc eq remtrz.tcrc  /*and string(arp.gl) = card-gl*/ no-lock no-error .
       if avail aaa then do:
       if aaa.sta eq "C" then do:
           v-text = remtrz.remtrz + " ERROR !!! Closed account aaa = " + c-acc.
           for each aas where aas.aaa = c-acc and aas.sic = "KM" no-lock .
            v-text = remtrz.remtrz + " ERROR !!! Account aaa = " + c-acc +
              " moved to " + aas.payee .
           end .
           run lgps .
           v-reterr = v-reterr + 8.
           /* aaa for rbank.racc  wasn't found */  .
          end.
          else do :  /*if sta <> "c"*/
           find tgl where tgl.gl = aaa.gl no-lock.
           remtrz.cracc = remtrz.racc .
           remtrz.crgl = tgl.gl.
          end .
        end.  /*if avail aaa */
        else do: /*not avail aaa*/
         if avail arp  then do:
           find t2gl where t2gl.gl = arp.gl no-lock.
           remtrz.cracc = remtrz.racc .
           remtrz.crgl = t2gl.gl. remtrz.rsub = "arp".
           v-text = remtrz.remtrz + " Счет-карточка ARP".
          run lgps.
         end .  /*if avail arp*/
        else do: /*not avail arp*/
          v-text = remtrz.remtrz + " ERROR !!! There isn't aaa = " +
           c-acc  + " record or account crc is not " +
           " payment crc . 5 bit retcode = 1 " .
          run lgps .
          /* v-reterr = v-reterr + 32. * aaa for rbank.racc  wasn't found */  .
        end.  /*not avail arp*/
       end. /*not avail aaa*/
       end.         /* if rsub = cif */
        else
        do:
          v-text = remtrz.remtrz + " RSUB ne CIF:   " + rsub + " " +
           c-acc  + " , 6 bit retcode = 1 " .
          run lgps .
          /* v-reterr = v-reterr + 64 .   */ .
        end.

      end.        /*  rsub ne "" */
        else
        do:
          v-text = remtrz.remtrz + " RSUB eq ? " +
           c-acc  + " , 7 bit retcode = 1 " .
          run lgps .
        /*  v-reterr = v-reterr + 128 .   */ .
        end.

   end .        /* end rbank = ourbank */
end .  /* known receiver   */

   find first cif where cif.cif = aaa.cif no-lock no-error .
   if avail cif then do:
     find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error .

     if avail  sub-cod and sub-cod.ccode = "0" then do:
      find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(302)
                          and tarif2.stat = 'r' no-lock no-error .
       if avail tarif2 then do:
         remtrz.svccgr = 302.
         remtrz.svcrc = remtrz.tcrc .
         run comiss .
       end.
      end.
   end.


  remtrz.ref = trim(num[1]) + "/" + m-typ .

  if m-typ = "102" then do:
   create wrmz .
   wrmz.remtrz = remtrz.remtrz .
  end.

  if remtrz.sbank = "" then remtrz.sbank = remtrz.scbank.
  sender = "n".
  find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
  if avail bankl then
  if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .
  else receiver = "" .
  if remtrz.scbank = ourbank then sender = "o" .
  if remtrz.rcbank = ourbank then receiver  = "o" .
  find first ptyp where ptyp.sender = sender and ptyp.receiver = receiver
     no-lock no-error .
  if avail ptyp then remtrz.ptype = ptyp.ptype.
  else remtrz.ptype = "N".

  if v-knp = "000" and m-typ = "102" then v-knp = v-knp102 .

  create sub-cod.
  assign sub-cod.acc = remtrz.remtrz
         sub-cod.sub = "rmz"
         sub-cod.d-cod = 'eknp'
         sub-cod.ccode = 'eknp'
         sub-cod.rcod = s-irs + s-seco + "," + r-irs + r-seco + "," + v-knp .

 if not pnrj then do:
  v-text = "Creating of the remtrz = " + remtrz.remtrz +
  " <-  SQN = " + string(num[1]) + "/mt" + m-typ + "/"
  + " <- " + s-bank + " " + " " + remtrz.sqn +
  " retcode = " + string(v-reterr)  .
  put stream prot unformatted v-text skip .
  run lgps.
 end.


 create que.
 assign que.remtrz = remtrz.remtrz
        que.pid = m_pid
        que.rcid = recid(remtrz)
        que.ptype = remtrz.ptype.
 if v-reterr = 0 then
  que.rcod = string(v-reterr).
 else
 do:
  que.rcod = "1".
  que.pvar = string(v-reterr).
 end.
 if remtrz.scbank = "" then
    que.rcod = "1".
 assign que.con = "W"
        que.dp = today
        que.tp = time
        que.pri = 29999 .
 ok1 = true  .
 t-count = t-count + 1 .
 t-summ = t-summ + v-amt.

for each t-102 where t-102.rem = ''.
    t-102.rem = s-remtrz.
end.

end.   /*    do on error undo    */

end.      /*  second  repeat */
input close.


end.   /*  1st repeat for  */

if ok then
 do:
  v-log = "    Loaded  :" + string(t-count)  + " msgs, " +  trim(string(t-summ,"zzzzzzzzzzzzzzzz9.99")) + " KZT" .
  put stream prot unformatted v-log skip  .
/*  down 1 with frame f-log .
  display v-log with frame f-log .
*/
  tot-summ = tot-summ + t-summ .
  tot-n = tot-n + t-count .
 end .

put stream prot unformatted "Total : " + string(t-count) + " Tot-amt : " +  string(tot-summ) skip .
v-ok = true .


