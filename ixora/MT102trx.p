/* MT102trx.p
 * MODULE
     Операции   
 * DESCRIPTION
        Создаем платежи по мт102
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * BASES
        BANK            
 * AUTHOR
        18/05/2009 galina
 * CHANGES
*/

{global.i}

def input parameter v-fname as char no-undo.
def input parameter v-log as char no-undo.
def output parameter v-res as int no-undo.
def output parameter v-des as char no-undo.

v-res = 0.
v-des = ''.

def var vku-aaa as char. 

def new shared var s-jh like jh.jh.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def var v-arp as char no-undo.

def new shared temp-table t-mt no-undo
  field num as integer
  field sequence as char
  field id as char
  field id2 as char
  field str as char
  index idx is primary num.

def temp-table t-pay no-undo
  field rnn as char format "x(12)"
  field res as char
  field aaa like aaa.aaa
  field sum as deci
  field name as char
  field passign as char
  field spnpl as char.

def var sum1 as deci no-undo.
def var sum2 as deci no-undo.
def var v-bal as deci no-undo.

/*def var v-acc_kp as char no-undo.
def var v-rnn_kp as char no-undo.
def var v-bik_kp as char no-undo.
def var v-acc_txb as char no-undo.*/
def var v-rnn_txb as char no-undo.
def var v-bik_txb as char no-undo.

def var v-rnn as char no-undo.
def var v-aaa as char no-undo.
def var v-name as char no-undo.
def var v-spnpl as char no-undo.
def var v-assign as char no-undo.
def var v-cif as char no-undo.
def var v-crccode  as char no-undo.
def var v-resid as char no-undo.
def buffer b-mt for t-mt.
def var v_doc as char no-undo.

function v-val returns character (input v-seq as character, input v-id as character, input v-id2 as character, input v-name as character).
    def var v-valres as char no-undo.
    find first b-mt where b-mt.sequence = v-seq and b-mt.id = v-id and b-mt.id2 = v-id2 no-lock no-error.
    if avail b-mt then do:
      if v-name <> '' then do:
        if lookup(v-name,b-mt.str,'/') > 0 then
          if num-entries(b-mt.str,'/') > lookup(v-name,b-mt.str,'/') then v-valres = entry(lookup(v-name,b-mt.str,'/') + 1,b-mt.str,'/').
      end.
      else v-valres = entry(1,b-mt.str,'/').
    end.
    return (v-valres).
end function.

run MT102load(v-fname, output v-arp).


/*
for each t-mt no-lock:
displ t-mt.num t-mt.sequence format "x(1)" t-mt.id t-mt.id2 t-mt.str format "x(120)".
end.
*/

/*
v-acc_kp = v-val('A','50','','D'). -- транзитный счет в Казпочте --
v-rnn_kp = v-val('A','50','','RNN'). -- РНН Казпочта --
v-bik_kp = v-val('A','52B','',''). -- БИК Казпочта --
v-acc_txb = v-val('A','59','',''). -- транзитный счет в Тексаке --*/
v-rnn_txb = v-val('A','59','','RNN'). 
v-bik_txb = v-val('A','57B','',''). 
find first sysc where sysc.sysc = "clecod" no-lock no-error.
if not avail sysc then do:
  message " Нет записи ""clecod"" в sysc" view-as alert-box error.
  return.
end.
find first cmp no-lock no-error.
if not avail cmp then do:
  message "Нет записи в cmp" view-as alert-box error.
  return.
end. 

if trim(v-rnn_txb) <> cmp.addr[2] or trim(v-bik_txb) <> sysc.chval then do:
  v-res = 1. v-des = "Ошибка в реквизитах банка".
  return.
end.


sum1 = 0.
for each t-mt where t-mt.sequence = 'B' and t-mt.id = '32B' no-lock:
  sum1 = sum1 + deci(replace(substring(t-mt.str,4),',','.')).
end.
sum2 = deci(replace(substring(v-val('C','32A','',''),10),',','.')).

/*message string(sum1, ">>>,>>9.99") + " " + string(sum2, ">>>,>>9.99") view-as alert-box.*/

if sum1 <> sum2 then do:
  v-res = 2. v-des = "Несоответствие сумм платежей и итоговой суммы".
  return.
end.

v-crccode = substr(v-val('C','32A','',''),7,3). 
find first crc where crc.code = v-crccode no-lock no-error.
if not avail crc then do:
   v-res = 3. v-des = "Не найдена валюта " + v-crccode.
   return.
end.

v-assign = v-val('A','70','','ASSIGN').
v-spnpl = v-val('A','70','','KNP').


find first arp where arp.arp = v-arp no-lock no-error.
if not avail arp then do:
   v-res = 4. v-des = "Не найден транзитный счет " + v-arp.
   return.
end.

if arp.crc <> crc.crc then do:
   v-res = 5. v-des = "Валюта счета и платежа не совпадают".
   return.
end.

find first gl where gl.gl = arp.gl no-lock no-error.
if not avail gl then do:
   v-res = 6. v-des = "Не найден счет ГК " + string(arp.gl,'999999').
   return.
end.

/* проверка на наличие и достаточность средств на транзитном счете */
run lonbalcrc('arp',v-arp,g-today,"1",yes,1,output v-bal).
if gl.type <> "A" then  v-bal = - v-bal.
if v-bal < sum1 then do:
  v-res = 7. v-des = "Нехватка средств на транзитном счете, необходимо: " + trim(string(sum1,">>>,>>>,>>>,>>9.99")) + ", на счету: " + trim(string(v-bal,">>>,>>>,>>>,>>9.99")).
  return.
end.
 
def stream rep.
output stream rep to value(v-log) append.

for each t-mt where t-mt.sequence = 'B' and t-mt.id <> '21' and t-mt.id <> '32B' no-lock:
  /*displ t-mt.sequence format "x(1)" t-mt.id t-mt.id2 t-mt.str format "x(79)".*/
  v-rnn = v-val('B','70',t-mt.id2,'RNN').
  v-aaa = v-val('B','70',t-mt.id2,'LA').
  v-name = v-val('B','70',t-mt.id2,'FM') + " " + v-val('B','70',t-mt.id2,'NM') + " " + v-val('B','70',t-mt.id2,'FT').
  
  
 /* message 'v-rnn ' +  v-rnn + ';v-aaa ' +  v-aaa + ';v-name ' +  v-name + ';v-assign ' +  v-assign + ';v-arp ' +  v-arp  + ';v-spnpl ' +  v-spnpl view-as alert-box. */
  if entry(1,v-name, ' ') <> 'КОМИССИЯ' then do:
     
        v-cif = ''.
        find first cif where cif.jss = v-rnn no-lock no-error.
        if avail cif then do:
          v-cif = cif.cif.
          if substr(cif.geo,3,1) = "1" then 
          v-resid = '1'.
          else v-resid = '2'.
        end.
      
      
        if v-rnn = '' then do:
          put stream rep unformatted "error - пустой РНН, ФИО " + v-name + " Счет " + v-aaa skip.
          v-res = 8.
          next.
        end.
      
        if v-cif = '' then do:
          put stream rep unformatted "error - не найдена клиентская запись, РНН " + v-rnn + " ФИО " + v-name + " Счет " + v-aaa + " ... пропускаем" skip.
          v-res = 9.
          next.
        end.
      
        find first aaa where aaa.aaa = v-aaa and aaa.cif = v-cif no-lock no-error.
        if not avail aaa then do:
          put stream rep unformatted "error - не найден текущий счет " + v-aaa + " для перевода, РНН " + v-rnn + " ФИО " + v-name + " ... пропускаем" skip.
          v-res = 10.
          next.
        end.
  end.
  if entry(1,v-name, ' ') = 'КОМИССИЯ' then do:
    find first arp where arp.arp = v-arp no-lock no-error.
    if not avail arp then do:
      put stream rep unformatted "error - не найден транзитный счет " + v-arp + " для перевода косиссии банка ... пропускаем" skip.
      v-res = 11.
      next.
    end.
    v-resid = '1'.
  end.
  create t-pay.
  t-pay.rnn = v-rnn.
  t-pay.aaa = v-aaa. 
  t-pay.sum = deci(replace(substring(v-val('B','32B',t-mt.id2,''),4),',','.')).
  t-pay.name = v-name.
  t-pay.passign = trim(v-assign).
  t-pay.spnpl = v-spnpl.
  t-pay.res = v-resid.
end. /* for each t-mt */


/*v-res = 0. v-des = "".*/

for each t-pay no-lock:
  v-param = ''.
  v-param = '' + vdel +
            string(t-pay.sum) + vdel +
            string(crc.crc) + vdel +
            v-arp  + vdel + t-pay.aaa + vdel.
  if t-pay.rnn <> '' then do:
    v-param = v-param + "тр.счет (зачисление зп) " + v-arp + " -> тек.счет " + t-pay.aaa. 
    v-param = v-param + vdel + t-pay.res + vdel + t-pay.spnpl. 
  end. 
  if t-pay.rnn = '' then do:
    v-param = v-param + "Комиссия банка " + v-arp + " -> счет комиссии " + t-pay.aaa.
    v-param = v-param + vdel + t-pay.res + vdel + t-pay.res + vdel + t-pay.spnpl. 
  end.  
            

  s-jh = 0.
  if t-pay.rnn <> '' then
  run trxgen ("jou0033", vdel, v-param, "cif", t-pay.aaa, output rcode, output rdes, input-output s-jh).
  if t-pay.rnn = '' then run trxgen ("jou0036", vdel, v-param, "arp", t-pay.aaa, output rcode, output rdes, input-output s-jh).
  if rcode > 0 then assign v-res = rcode v-des = rdes.
  if s-jh = 0 then do:
    put stream rep unformatted "error - payment " t-pay.rnn format "x(12)" " " t-pay.aaa " " string(t-pay.sum,">>>,>>>,>>>,>>>,>>9.99") " " t-pay.name ", описание ошибки"   rdes skip.
    next.
  end.  
  
  run jou. 
  v_doc = return-value.
  find first jh where jh.jh = s-jh exclusive-lock.
  jh.party = v_doc.
                
  if jh.sts < 6 then jh.sts = 6.
  for each jl of jh:
    if jl.sts < 6 then jl.sts = 6.
  end.
  find current jh no-lock.
  
  if rcode = 0 then put stream rep unformatted "        payment номер документа " v_doc " РНН " t-pay.rnn format "x(12)" " Счет " t-pay.aaa " Сумма " trim(string(t-pay.sum,">>>,>>>,>>>,>>>,>>9.99")) " ФИО " t-pay.name ", " t-pay.passign skip.
  else put stream rep unformatted "error - payment РНН" t-pay.rnn format "x(12)" " Счет " t-pay.aaa " Сумма " trim(string(t-pay.sum,">>>,>>>,>>>,>>>,>>9.99")) " ФИО" t-pay.name ", " t-pay.passign " : " rdes skip.
end.

output stream rep close.

