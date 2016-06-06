/* 1sbtdat.p
 * MODULE
        Финансовые отчеты
 * DESCRIPTION
        Отчет 1-СБт - подборка данных по одному филиалу
 * RUN

 * CALLER
	1sbt.p or sh1sbt.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        18.02.2004 valery

 * CHANGES
        09.10.2006 u00600 - алиас "ast" заменен на "txb" для совместимости c r-brfilial.i
        07.07.10 marinav - исключила 4 июня
        16/08/2011 dmitriy - перенес GBP в группу свободноконвертируемой валюты
        05/10/2011 dmitriy - перенес AUD, SEK, CHF в группу свободноконвертируемой валюты
        29/02/2012 Lyubov - к СКВ относятся только AUD, SEK, CHF, GBP
        07.05.2012 Lyubov - исправила отчеты: для 5-СБ берутся валюты 1,2,3,4,6,7,8,9, для расшифровки - 2,3,6,7,8,9
        21.12.2012 Lyubov - ТЗ 1589, счет ГК 220431 уже был в выборке, но, т.к. это счета arp - добавила поиск по таблице arp
        31.10.2013 Lyubov - ТЗ 2170, разбивка arp счетов по группам физ. и юр.

*/

def input parameter p-bank as char.
def input parameter p-rep as logical. /*параметр для определения какой отчет вызвал: yes - 1СБт; no - расшифровка 1СБт*/

def shared var v-dtb as date.
def shared var v-dte as date.
/*u00600 def shared var v-bankname as char.*/
def shared var v-secek as char extent 2.

def var v-dt as date.
def var v-ostb0   as deci.
def var v-procb0  as deci.
def var v-oste0   as deci.
def var v-proce0  as deci.
def var v-ostb   as deci.
def var v-procb  as deci.
def var v-cr     as deci.
def var v-proccr as deci.
def var v-dr     as deci.
def var v-procdr as deci.
def var v-oste   as deci.
def var v-proce  as deci.

def var v-sum   as deci.
def var v-proc  as deci.
def var i as integer.
def var n as integer.
def var p as integer.

def var v-stroka as integer.
def var v-god as decimal.
def var v-mc as decimal.
def var v-days as integer.



def shared temp-table t-data
  field punkt as integer
  field clnsts as integer
  field sum as deci extent 3
  field sumfin as deci extent 3
  field proc as deci extent 3
  field procavg as deci extent 3
  index main is primary unique punkt clnsts
  index clnsts clnsts .


def temp-table t-accs
  field aaa as char
  field crc like txb.crc.crc
  field clnsts as integer
  index main is primary unique crc aaa.

def temp-table t-jl
  field jh like txb.jh.jh
  field ln like txb.jl.ln
  field jdt as date
  field crc like txb.crc.crc
  field gl like txb.gl.gl
  field acc like txb.jl.acc
  field dc as char
  field sum as decimal
  index main is primary unique acc dc gl jh ln.

hide message no-pause.
message p-bank " Начало обработки...".


def shared temp-table t-gl
  field gl like txb.gl.gl
  field glstr as char
  index main is primary unique gl.

for each t-gl:
  do v-dt = v-dtb to v-dte:
    for each txb.jl where txb.jl.jdt = v-dt and txb.jl.gl = t-gl.gl and ((lookup(string(jl.crc), "1,2,3,4,6,7,8,9") <> 0 and p-rep) or (lookup(string(jl.crc), "2,3,6,7,8,9") <> 0 and not p-rep)) no-lock use-index jdt:
      if  txb.jl.jdt = 06/04/10 and txb.jl.who = 'bankadm' and txb.jl.rem[1] = 'Перенос в связи с переходом на новый формат счета' then next.

      find txb.jh where txb.jh.jh = txb.jl.jh no-lock no-error.


      if (txb.jh.party begins "Storn") or
         (txb.jl.rem[1] begins "O/D PROTECT" or txb.jl.rem[1] begins "O/D PAYMENT") or
         txb.jl.lev <> 1 then next.


      create t-jl.
      assign t-jl.jh  = txb.jl.jh
             t-jl.ln  = txb.jl.ln
             t-jl.jdt = txb.jl.jdt
             t-jl.crc = txb.jl.crc
             t-jl.gl  = txb.jl.gl
             t-jl.acc = txb.jl.acc
             t-jl.dc  = txb.jl.dc
             t-jl.sum = if txb.jl.dc = "d" then txb.jl.dam else txb.jl.cam.

    end.
  end.
end.

hide message no-pause.
message p-bank " Проводки за период собраны...".


for each t-gl:
  for each txb.aaa where txb.aaa.gl = t-gl.gl and ((lookup(string(aaa.crc), "1,2,3,4,6,7,8,9") <> 0 and p-rep) or (lookup(string(aaa.crc), "2,3,6,7,8,9") <> 0 and not p-rep)) no-lock:
    if aaa.regdt > v-dte then next.
    if txb.aaa.sta = "c" and txb.aaa.cltdt < v-dtb then next.
    if not p-rep and txb.aaa.crc = 1 then next. /*если вызывается из расшифровки 1СБт, то тенге нам не нужно*/
    /* нерезиденты в отчете не нужны */
    find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
    if substr(txb.cif.geo, 3, 1) <> "1" then next.

    /* нужны только клиенты с определенные секторами экономики, указанными в настройке отчета */
    find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and
         txb.sub-cod.acc = txb.aaa.cif no-lock no-error.
    if avail txb.sub-cod then do:
      i = lookup(txb.sub-cod.ccode, v-secek[1]).
      if i > 0 then i = 1.
      else do:
        i = lookup(txb.sub-cod.ccode, v-secek[2]).
        if i > 0 then i = 2.
      end.
    end.
    else i = 0.  /* неизвестный сектор экономики не обрабатываем */

    if i = 0 then next.

    do transaction on error undo, return:
      create t-accs.
      assign t-accs.aaa = txb.aaa.aaa
             t-accs.clnsts = i
             t-accs.crc = txb.aaa.crc.
    end.
  end.
  for each txb.arp where txb.arp.gl = t-gl.gl and ((lookup(string(txb.arp.crc), "1,2,3,4,6,7,8,9") <> 0 and p-rep) or (lookup(string(txb.arp.crc), "2,3,6,7,8,9") <> 0 and not p-rep)) no-lock:
    if arp.rdt > v-dte then next.
    if not p-rep and txb.arp.crc = 1 then next. /*если вызывается из расшифровки 1СБт, то тенге нам не нужно*/
    if txb.arp.gl = 220331 then i = 1.
    if txb.arp.gl = 220431 then i = 2.
    if txb.arp.gl = 222110 then next.
    do transaction on error undo, return:
      create t-accs.
      assign t-accs.aaa = txb.arp.arp
             t-accs.clnsts = i
             t-accs.crc = txb.arp.crc.
    end.
  end.
  hide message no-pause.
  message p-bank " Счета " t-gl.gl " собраны...".
end.


hide message no-pause.
message p-bank " Окончание обработки...".


for each t-accs break by t-accs.clnsts by t-accs.crc:
  if first-of(t-accs.crc) then do:
    v-ostb0   = 0.
    v-procb0  = 0.
    v-oste0   = 0.
    v-proce0  = 0.
    v-cr     = 0.
    v-proccr = 0.
    v-dr     = 0.
    v-procdr = 0.
  end.

  /* найти проводки по счету за период */
  for each t-jl where t-jl.acc = t-accs.aaa no-lock use-index main break by t-jl.dc:
    if t-jl.crc = 1 then v-sum = t-jl.sum.
                    else run crc2kzt (t-jl.crc, t-jl.jdt, t-jl.sum, output v-sum).

    accumulate v-sum (sub-total by t-jl.dc).

    find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= t-jl.jdt no-lock no-error.
    if avail txb.aab and txb.aab.rate > 0 then do:
      v-proc = v-sum * txb.aab.rate.
    end.
      accumulate v-proc (sub-total by t-jl.dc).


    if last-of (t-jl.dc) then do:
      if t-jl.dc = "c" then do:
        v-cr = v-cr + (accum sub-total by t-jl.dc v-sum).
        v-proccr = v-proccr + (accum sub-total by t-jl.dc v-proc).
      end.
      else do:
        v-dr = v-dr + (accum sub-total by t-jl.dc v-sum).
        v-procdr = v-procdr + (accum sub-total by t-jl.dc v-proc).
      end.
    end.
  end.

    /* остатки на начало */
    find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt < v-dtb no-lock no-error.
    if avail txb.aab and txb.aab.bal > 0 then do:
        v-ostb0 = v-ostb0 + txb.aab.bal.
        v-procb0 = v-procb0 + txb.aab.bal * txb.aab.rate.
    end.
    else do:
        find last txb.histrxbal where txb.histrxbal.acc = t-accs.aaa and txb.histrxbal.subled = 'arp' and txb.histrxbal.dt < v-dtb no-lock no-error.
        if avail txb.histrxbal then do:
            v-ostb0 = v-ostb0 + txb.histrxbal.cam - txb.histrxbal.dam.
            v-procb0 = v-procb0 + txb.histrxbal.cam - txb.histrxbal.dam.
        end.
    end.

    /* остатки на конец */
    find last txb.aab where txb.aab.aaa = t-accs.aaa and txb.aab.fdt <= v-dte no-lock no-error.
    if avail txb.aab and txb.aab.bal > 0 then do:
        v-oste0 = v-oste0 + txb.aab.bal.
        v-proce0 = v-proce0 + txb.aab.bal * txb.aab.rate.
    end.
    else do:
        find last txb.histrxbal where txb.histrxbal.acc = t-accs.aaa and txb.histrxbal.subled = 'arp' and txb.histrxbal.dt <= v-dte no-lock no-error.
        if avail txb.histrxbal then do:
            v-oste0 = v-oste0 + txb.histrxbal.cam - txb.histrxbal.dam.
            v-proce0 = v-proce0 + txb.histrxbal.cam - txb.histrxbal.dam.
        end.
    end.


  if last-of(t-accs.crc) then do:

   if p-rep then
   do:
    /************************определение остатков и групп для 1СБт***********************************/
    if t-accs.crc = 1 then do:
      v-ostb   = v-ostb0.  /*Остатки на начало*/
      v-procb  = v-procb0.  /*ставка вознаграждения на начало*/
      v-oste   = v-oste0.  /*остатки на конец*/
      v-proce  = v-proce0. /*ставка вознаграждния на конец*/

      n = 1.
    end.
    else do:
      run crc2kzt (t-accs.crc, v-dtb - 1, v-ostb0, output v-ostb).
      run crc2kzt (t-accs.crc, v-dtb - 1, v-procb0, output v-procb).
      run crc2kzt (t-accs.crc, v-dte, v-oste0, output v-oste).
      run crc2kzt (t-accs.crc, v-dte, v-proce0, output v-proce).

      if t-accs.crc = 2 or t-accs.crc = 3 /**/ then n = 2.
      if t-accs.crc = 4 or t-accs.crc = 6 or t-accs.crc = 7 or t-accs.crc = 8 or t-accs.crc = 9  then n = 3. /*message t-accs.crc t-jl.sum. pause. end.*/
    end.
   end.
   else
   do:
    /*********************определение остатков и групп для расшифровки 1СБт**************************/
      run crc2kzt (t-accs.crc, v-dtb - 1, v-ostb0, output v-ostb).
      run crc2kzt (t-accs.crc, v-dtb - 1, v-procb0, output v-procb).
      run crc2kzt (t-accs.crc, v-dte, v-oste0, output v-oste).
      run crc2kzt (t-accs.crc, v-dte, v-proce0, output v-proce).

      if t-accs.crc = 2 then n = 1.
      if t-accs.crc = 3 then n = 2.
      if t-accs.crc = 6 or t-accs.crc = 7 or t-accs.crc = 8 or t-accs.crc = 9 then do: n = 3. message t-accs.crc t-jl.sum. pause. end.
   end.
    /************************************************************************************************/
    /************************************************************************************************/


    do p = 1 to 4 transaction on error undo, return:
      find t-data where t-data.punkt = p and t-data.clnsts = t-accs.clnsts no-error.
      if not avail t-data then do:
        create t-data.
        assign t-data.punkt = p
               t-data.clnsts = t-accs.clnsts.

      end.

      case p :
        when 1 then do:
          t-data.sum[n] = t-data.sum[n] + v-ostb.
          t-data.proc[n] = t-data.proc[n] + v-procb.
        end.
        when 2 then do:
          t-data.sum[n] = t-data.sum[n] + v-cr.
          t-data.proc[n] = t-data.proc[n] + v-proccr.
        end.
        when 3 then do:
          t-data.sum[n] = t-data.sum[n] + v-dr.
          t-data.proc[n] = t-data.proc[n] + v-procdr.
        end.
        when 4 then do:
          t-data.sum[n] = t-data.sum[n] + v-oste.
          t-data.proc[n] = t-data.proc[n] + v-proce.
        end.
      end case.
    end.

  end.
end.


hide message no-pause.
message p-bank " Обработка закончена".


/* u00600
find first txb.cmp no-lock no-error.
v-bankname = txb.cmp.name.*/


/**************************************************************************************/


procedure crc2kzt.
  def input parameter        c-from    like txb.crc.crc.
  def input parameter        c-date    as date.
  def input parameter        v-from    as decimal decimals 2
                                       format "->>,>>>,>>>,>>>,>>9.99".
  def output parameter       v-to      as decimal decimals 2
                                       format "->>,>>>,>>>,>>>,>>9.99".

  find last txb.crchis where txb.crchis.rdt <= c-date and txb.crchis.crc = c-from no-lock no-error.
  if avail txb.crchis then v-to = v-from * txb.crchis.rate[1].
                      else v-to = 0.

end procedure.

