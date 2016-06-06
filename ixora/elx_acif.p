/* elx-acif.p
 * MODULE
        Elecsnet
 * DESCRIPTION
        Зачисление платежей на счет АЛМА-ТВ по проекту Элекснет
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-2-1-3-7-3
 * AUTHOR
        04.05.2006 dpuchkov
 * CHANGES
        26.05.2006 dpuchkov - добавил параметр dat при вызове процедуры commpl.
        21.06.2006 tsoy     - В связи с письмом Ксении убрал комиссию
        12.02.2007 id00004 добавил alias
*/

{get-dep.i}
{comm-txb.i}
def var ourbank as char         no-undo.
def var ourcode as integer      no-undo.
def var ourlist as char init '' no-undo.
ourbank = comm-txb().
ourcode = comm-cod().

{comm-arp.i} /* Проверка остатка на АРП c заданной суммой */
{yes-no.i}
def shared var g-today as date.
def var dat as date             no-undo.
def var uu as char              no-undo.
def var tmp  as char            no-undo.
def var tsum as decimal         no-undo.
def var summa as deci           no-undo.
def var v-users as char init "" no-undo. 
def new shared var s-jh like jh.jh.
def var rcode as int            no-undo.
def var rdes  as cha            no-undo.
def var choice4 as logical init false no-undo.
def var selarp as char          no-undo.
dat = g-today.

def var v-comiss as decimal decimals 2 no-undo.
def var v-sum    as decimal decimals 2 no-undo.


find first comm.txb where txb.txb = ourcode no-lock.
/*if ourcode = 0 then selarp = "011999230". else selarp = comm.txb.commarp. */


find last sysc where sysc.sysc = "ALMARP" no-lock no-error.
selarp = sysc.chval.


update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
hide frame dataa.

for each mobi-almatv where mobi-almatv.dt = dat and mobi-almatv.state = 1 no-lock:
    ACCUMULATE mobi-almatv.summ (total).
end.

summa = (accum total mobi-almatv.summ).


def var v-tarif as decimal init 0.
find first tarif2 where tarif2.num = '5' and tarif2.kod = '83' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then do:
   v-tarif = tarif2.proc.
end.
if v-tarif = 0 then do:
   message "Внимание: не настроены тарифы".
   return.
end.



v-comiss = round((summa * v-tarif / 100), 2).
v-comiss = 0.
summa = summa - v-comiss.


if summa <> 0 then do:

    MESSAGE "Сформировать платежку на сумму " summa " тенге." VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи Алма-ТВ" UPDATE choice3 as logical.
    case choice3:
        when false then return.
        when true  then do:

         REPEAT WHILE (not comm-arp(selarp,summa)) and (not choice4): 
              MESSAGE "Не хватает средств на счете " + selarp + "~nПопытаться еще раз ?"
              VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Проверка остатка" UPDATE choice4.
              case choice4:
                 when true then if comm-arp(selarp,summa) then leave. else choice4 = false.
                 otherwise return.
              end.
         end.

         display "Формируется п/п на сумму: " summa format "->,>>>,>>>,>>9.99" with no-labels centered frame fsm.
    
         tmp = 'За услуги кабельного телевидения, сумма ' + trim( string(summa,">>>>>>>>9.99") ) + 
               ' за ' + string(dat,"99.99.9999") + ' тенге, в тч НДС'.

        run commpl( 
                 1,
                 summa,
                 selarp,
                 "190501749",
                 "010467345",
                 0,                      /* KBK string(tcommpl.kb,"999999") */
                 no,                     /* MB or RB   */
                 'АО "АЛМА ТВ"',         /* name       */
                 "600900009200",         /* rnn_nk     */
                 "852",
                 "14",
                 "17",
                  tmp,
                 if ourcode = 0 then 'P' else '1P',
                  1, 
                  1, 
                  "", 
                  "",
                  dat).

          for each mobi-almatv where mobi-almatv.dt = dat and mobi-almatv.state = 1 exclusive-lock:
              mobi-almatv.state = 2.
          end.
for each mobi-almatv where dt = dat no-lock:
    ACCUMULATE mobi-almatv.summ (total).
end.



        end.    
    end case.
end.
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.

