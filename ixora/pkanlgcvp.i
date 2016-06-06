/* pkanlgcvp.i
- * MODULE
        ПотребКредит
 * DESCRIPTION
        Анализ данных ГЦВП о пенсионных отчислениях плательщика
 * RUN
        
 * CALLER
        pkkritlib.p, pkimgcvp.p, pkgcvprep.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.x.1
 * AUTHOR
        29.12.2003 nadejda
 * CHANGES
        21.01.2004 nadejda - параметр допустимого отклонения суммы от средней брать из pksysc
        22.01.2004 nadejda - вывод в отчете отклонений от среднего
        27.01.2004 nadejda - если больше 2 предприятий-плательщиков -> всегда кредком
        29.01.2004 nadejda - сумма за месяц берется не с 1 по 31 чисол месяца, а по текущей дате минус 1 месяц, 2 месяца...
                             максимальное отклонение в отчете показывается или delta1 или delta - если нет delta1
        04.08.2004 sasco   - исправил поиск ответа из ГЦВП
        17.09.2004 saltanat - включила расчет количества работодателей и общей суммы чистого дохода
        18/10/2004 madiar,saltanat  - исправили расчет дат
        13/05/2005 madiar  - для второй проверки - изменил стандартное отклонение
        17/05/2005 madiar  - справочники для коэффициентов расчета (10,27) - разные для разных s-credtype
        03/04/2006 madiar  - для анализа используется только часть платежей, а на печать выводятся все
        04/04/2006 madiar  - подправил выбор кол-ва месяцев для анализа
*/
       
def var v-delta as decimal no-undo init 0.5.  /* допустимое отклонение суммы платежа от средней суммы - 50% */
def var v-delta_s as decimal no-undo init 0.5.  /* допустимое отклонение суммы платежа отклоненных платежей от средней суммы - 50% */
if s-ourbank = 'txb00' then v-delta_s = 0.6.
def var v-entry as inte no-undo.    /*разделитель ; */
def var v-entry1 as inte no-undo.   /*разделитель | */
def var i as inte no-undo.
def var v-str as char no-undo.
def var v-header as char no-undo.
def var v-kred as integer no-undo.
def var v-sumdohod as decimal no-undo.
def var v-kolmc as integer no-undo.
def var v-ansexist as logical no-undo init no.
def var v-ansfull as logical no-undo init no.
def var v-anssts as char no-undo init "".
def var v-qdt as date no-undo.
def var v-filename as char no-undo.
def var v-dohod as decimal no-undo.
def var v-vichet as decimal no-undo.
def var v-maxdelta as decimal no-undo.
def var v-day as integer no-undo.
def var v-mc as integer no-undo.
def var v-god as integer no-undo.
def var v-kolrab as inte no-undo init 0.
def var v-chdox  as deci no-undo init 0.
def var ny as integer no-undo.
def var v-cdt as date no-undo.

def temp-table t-ansgcvp no-undo
  field num as integer
  field rnn as char
  field sum as decimal
  field paydt as date
  field payname as char
  field fond as char
  field delta as decimal decimals 2 init -1
  field delta1 as decimal decimals 2 init -1
  field mcdt as date
  field anlz as logical init no
  index num is primary unique num
  index dat mcdt
  index paydt paydt
  index rnn rnn.

def temp-table t-ansgcvp_full no-undo like t-ansgcvp.

def buffer b-ansgcvp for t-ansgcvp.

def temp-table t-mcs no-undo
  field dt as date
  field sum as decimal
  field delta as decimal decimals 2 init -1
  field delta1 as decimal decimals 2 init -1
  index dat is primary unique dt.

def temp-table t-defres no-undo like t-ansgcvp.

def temp-table t-result no-undo
  field rnn as char
  field kred as integer
  field sumavg as decimal
  field sumdohod as decimal
  field delta as decimal decimals 2
  index main is primary unique kred sumdohod DESC rnn.


v-kred = 1.
v-sumdohod = 0.
v-ansexist = no.
v-ansfull = no.
v-anssts = "". /* статус не определен */

v-entry = num-entries(p-gcvptxt, ";").
v-ansexist = (v-entry > 1). /* был ли принят ответ ГЦВП */

if v-ansexist then do:
  v-filename = entry(1, p-gcvptxt, ";").
  /* find first gcvp where gcvp.bank = s-ourbank and gcvp.nfile = v-filename no-lock no-error. ---- sasco Ошибочная строка*/
  find first gcvp where gcvp.bank = s-ourbank and gcvp.nfile = substr(v-filename, 5) no-lock no-error. /* Правильная строка */

  if avail gcvp then v-qdt = gcvp.rdt.
                else v-qdt = g-today.
  
  /* message v-qdt view-as alert-box buttons ok. */
  
  v-header = entry(2, p-gcvptxt, ";").
  v-entry1 = num-entries(v-header, "|").

  v-ansfull = (v-entry1 >= 8).  /* достаточно ли данных в первой строке ответа */
  if v-ansfull then do:
    v-anssts = entry(8, v-header, "|").  /* код возврата в ответе ГЦВП : 0 - все в порядке */

    if v-anssts = "0" then do:
      /* взять параметр величины допустимого отклонения от средней суммы - цифра в процентах от 0 до 100 */
      find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "gcvpot" no-lock no-error.
      if avail pksysc then v-delta = pksysc.inval / 100.

      /*
      find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "gcvpsr" no-lock no-error.
      if avail pksysc then v-kolmc = pksysc.inval.
                      else v-kolmc = 1.
      find first bookcod where bookcod.bookcod = "pkgcvptm" and bookcod.code = string(v-kolmc) no-lock no-error.
      if avail bookcod then v-kolmc = integer(bookcod.name).
                       else v-kolmc = 6.
      */
      find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "gcvpsr" no-lock no-error.
      if avail pksysc then v-kolmc = integer(pksysc.deval).
                      else v-kolmc = 6.
      
      /* message v-kolmc view-as alert-box buttons ok. */
      
      do i = 1 to v-kolmc:
        create t-mcs.
        
        if month(v-qdt) > i then do:
          v-mc = month(v-qdt) - i.
          v-god = year(v-qdt).
        end.
        else do:
          ny = i modulo 12.
          if month(v-qdt) > ny then v-mc = month(v-qdt) - ny.
          else v-mc = month(v-qdt) - ny + 12.
          if month(v-qdt) <= ny then v-god = year(v-qdt) - (i - ny) / 12 - 1.
          else v-god = year(v-qdt) - (i - ny) / 12.
        end.
        
        t-mcs.dt = date (v-mc, day(v-qdt), v-god) no-error.

        if error-status:error then do:
          run mondays (v-mc, v-god, output v-day).
          t-mcs.dt = date (v-mc, v-day, v-god).
        end.
      end.
      
      if s-credtype = '4' then find first bookcod where bookcod.bookcod = "pkankkt1" and bookcod.code = p-katjob no-lock no-error.
      else find first bookcod where bookcod.bookcod = "pkankkat" and bookcod.code = p-katjob no-lock no-error.
      if avail bookcod then do:
        v-dohod = integer (bookcod.info[3]).
        v-vichet = integer (bookcod.info[4]).
      end.
      else do:
        v-dohod = 10.
        v-vichet = 27.
      end.  
      
      repeat i = 3 to v-entry:
        v-str = entry(i, p-gcvptxt, ";").
        v-cdt = date(entry(1, v-str, "|")).
        
        find last t-mcs where t-mcs.dt <= v-cdt no-error.
        if avail t-mcs then do:
          create t-ansgcvp.
          assign t-ansgcvp.num = i - 2
                 t-ansgcvp.paydt = v-cdt
                 t-ansgcvp.rnn = entry(3, v-str, "|")
                 t-ansgcvp.payname = entry(2, v-str, "|")
                 t-ansgcvp.fond = entry(5, v-str, "|")
                 t-ansgcvp.sum = deci(entry(6, v-str, "|"))
                 t-ansgcvp.mcdt = t-mcs.dt.
                 t-ansgcvp.anlz = yes.
        end.
        else do:
          create t-ansgcvp_full.
          assign t-ansgcvp_full.num = i - 2
                 t-ansgcvp_full.paydt = v-cdt
                 t-ansgcvp_full.rnn = entry(3, v-str, "|")
                 t-ansgcvp_full.payname = entry(2, v-str, "|")
                 t-ansgcvp_full.fond = entry(5, v-str, "|")
                 t-ansgcvp_full.sum = deci(entry(6, v-str, "|")).
        end.
      end. /* repeat */
      
      for each t-ansgcvp break by rnn:
        if first-of(t-ansgcvp.rnn) then do:
          for each t-defres: delete t-defres. end.
        end.

        create t-defres.
        buffer-copy t-ansgcvp to t-defres.

        if last-of(t-ansgcvp.rnn) then do:
          create t-result.
          t-result.rnn = t-ansgcvp.rnn.

          /* возвращает КредКом и среднюю сумму отчислений */
          run defres (output t-result.kred, output t-result.sumavg).
          
          t-result.sumdohod = t-result.sumavg * v-dohod * (100 - v-vichet) / 100.

          v-maxdelta = 0.
          for each t-mcs:
            if t-mcs.delta1 > -1 then do:
               if v-maxdelta < t-mcs.delta1 then v-maxdelta = t-mcs.delta1.
            end.
            else if v-maxdelta < t-mcs.delta then v-maxdelta = t-mcs.delta.
          end.

          t-result.delta = v-maxdelta.

          for each b-ansgcvp where b-ansgcvp.rnn = t-ansgcvp.rnn break by b-ansgcvp.mcdt:
            if last-of (b-ansgcvp.mc) then do:
              find t-mcs where t-mcs.dt = b-ansgcvp.mcdt no-error.
              if avail t-mcs then do:
                b-ansgcvp.delta = t-mcs.delta.
                b-ansgcvp.delta1 = t-mcs.delta1.
              end.
            end.
          end.
          
        end.
      end.
      
      for each t-ansgcvp no-lock:
        create t-ansgcvp_full.
        buffer-copy t-ansgcvp to t-ansgcvp_full.
      end.
      
      for each t-result use-index main.
        v-kolrab = v-kolrab + 1.
        v-chdox  = v-chdox  + t-result.sumdohod.
      end.

      find first t-result use-index main no-error.
      if avail t-result then do:
        v-kred = t-result.kred.
        v-sumdohod = t-result.sumdohod.
      end.

      for each t-result. accumulate t-result.rnn (count). end.
      i = accum count t-result.rnn.
      if i > 2 then v-kred = 1.
    end.
  end.
end.

procedure defres.
  def output parameter vp-kred as integer.
  def output parameter vp-sumavg as decimal.

  def var v-sumall as decimal.
  def var l as logical.
  def var n as integer.
  def var v-delta1 as decimal decimals 2.

  for each t-mcs. t-mcs.sum = 0. t-mcs.delta = -1. t-mcs.delta1 = -1. end.

  for each t-defres:
    find t-mcs where t-mcs.dt = t-defres.mcdt no-error.
    t-mcs.sum = t-mcs.sum + t-defres.sum.

    accumulate t-defres.sum (total).
  end.
  v-sumall = accum total t-defres.sum.

  vp-sumavg = v-sumall / v-kolmc.

  l = true.
  for each t-mcs:
    t-mcs.delta = absolute (t-mcs.sum - vp-sumavg) / vp-sumavg.
  end.
  l = not can-find (first t-mcs where t-mcs.delta > v-delta).

  if l then do:
    /* отчисления просто замечательно регулярные! */
    vp-kred = 0.
    return.
  end.

  /* отчисления не попадают по суммам - ищем три попадающих суммы и среднее остальных должно быть похоже на общее среднее */
  n = 0.
  v-sumall = 0.
  for each t-mcs:
    if t-mcs.delta > v-delta then do:
      n = n + 1.
      v-sumall = v-sumall + t-mcs.sum.
    end.
  end.

  v-delta1 = absolute (v-sumall / n - vp-sumavg) / vp-sumavg.
  for each t-mcs:
    if t-mcs.delta > v-delta then 
      t-mcs.delta1 = v-delta1.
  end.

  if n <= round (v-kolmc / 2, 1) and (v-delta1 <= v-delta_s) then do:
    vp-kred = 0.
    return.
  end.

  /* все проверили - нерегулярные отчисления */
  vp-kred = 1.

end.
