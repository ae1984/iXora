/* taxtrgen0.p
 * MODULE
     Коммунальные платежи 
 * DESCRIPTION
     Процедура зачисления налоговых платежей (Алматы special)
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
     16.04.03 pragma
 * CHANGES
     16.04.03 sasco Отправка с указанием РНН 
     31.07.03 kanat добавил новый параметр при вызове процедуры taxpl - ФИО плательщика, у которого РНН = 000000000000
     31.10.03 sasco при отправке формирование сводного реестра отправленных платежей 
     21.11.03 sasco убрал печать квитанций в Уральске
     29.12.03 kanat платежи за 31.12.2003 не отправляются
     29.01.04 kanat при формировании платежей КНП берется из tax.intval[1], если intval[1] пустой - то из taxnk.knp
     05.09.05 kanat добавил передачу параметров для таможенных платежей
     24/05/06 marinav - добавлен параметр даты факт приема платежа
     02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/

{deparp.i}
{get-dep.i}
{comm-txb.i}
{yes-no.i}
def var ourbank as char.
def var ourcode as integer.
def var ourlist as char.
ourbank = comm-txb().
ourcode = comm-cod().

define shared variable g-today as date.
define shared variable g-ofc as char.

def var dat as date initial today.
def var gr as integer initial 0.
def new shared var s-jh like jh.jh.
def var rcode as int.
def var rdes as char.
def var choice4 as logical init true.
def var choice  as logical init true.
def var choice1 as logical init false.
def var allok   as logical init false.
def var r-cover as integer.
def var v-users as char init "". 
def var i as int.
def var i_kolprn as integer.

define variable t-numtax as integer.
define variable t-sumtax as decimal.

define stream sout.

define temp-table tdocs
    field g like comm.tax.grp
    field dn like comm.tax.dnum
    field sm like comm.tax.sum
    field ud like comm.tax.uid
    field d like comm.tax.senddoc
    field dt like comm.tax.date
    field tx like comm.tax.txb.
    
define temp-table taccnt 
    field accnt like depaccnt.accnt
    field go as logical
    field cover as int init 1
    field num_taxes as integer initial 0
    field sum_taxes as decimal initial 0.0
    field name as char.
    
define temp-table ttax like comm.tax
    field accnt like depaccnt.accnt
    field rid as rowid.

def var i_knp as integer.

if month(g-today) = 12 and day(g-today) = 31 then do: 
  message "Запрещено отправлять казначейские платежи в последний день года!" view-as alert-box title "Happy New Year".
  return.
end.

    
dat = g-today.

update dat label "Укажите дату" with frame ddd.
hide frame ddd.



Message "Ищем незачисленные платежи во всех филиалах банка".

for each comm.txb where city = ourcode and comm.txb.visible and comm.txb.consolid no-lock.
  ourlist = ourlist + trim(string(comm.txb.txb,">9")) + ",".
end.
ourlist = substr(ourlist, 1, length(ourlist) - 1).

do i = 1 to num-entries (ourlist):
   find first comm.tax where comm.tax.duid = ? and comm.tax.date = dat and comm.tax.taxdoc = ? and
                             comm.tax.txb = int (entry(i, ourlist)) use-index datenum
                             no-lock no-error.
   if available comm.tax then do:
               /*
               if ourbank = "TXB01" then do:
                   MESSAGE "Есть платежи, не зачисленные на транз. счета!~nВы действительно хотите продолжить ?"
                   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Внимание" UPDATE choice1.
                   if not choice1 then return.
               end.
               else do :
               */
                    for each comm.tax no-lock where comm.tax.duid = ? and comm.tax.date = dat and
                             comm.tax.taxdoc = ? and lookup(trim(string(comm.tax.txb,">9")),ourlist ) > 0
                             break by comm.tax.uid:
                           if first-of(comm.tax.uid) then 
                              v-users = "~n" + comm.tax.uid + "(TXB" + string(comm.tax.txb,"99") + ")" + v-users.
                    end.

                    MESSAGE "Есть платежи, не зачисленные на транз. счета" +
                    "~nКассиры: " + v-users VIEW-AS ALERT-BOX TITLE "Внимание".
                    return.
   end.

end.

Message "Группируем платежи по департаментам".    

do i = 1 to num-entries (ourlist):
for each comm.tax where comm.tax.duid = ? and comm.tax.date = dat and comm.tax.senddoc = ? and 
         comm.tax.taxdoc <> ? and comm.tax.txb = int (entry(i, ourlist)) no-lock:
    create ttax.
    buffer-copy comm.tax to ttax.

    if comm.tax.txb=ourcode then ttax.accnt = deparp(get-dep(comm.tax.uid, dat)).
                            else do:
                                   find first comm.txb where comm.txb.txb = ourcode and comm.txb.visible and comm.txb.consolid no-lock.
                                   ttax.accnt = comm.txb.taxarp.
                            end.
    ttax.rid = rowid(comm.tax).
end.
end.


for each depaccnt no-lock:
    find first taccnt where taccnt.accnt = depaccnt.accnt no-error.
    if avail taccnt then do:
        find first ppoint where ppoint.poin = 1 and ppoint.depart = depaccnt.depart no-lock.
        taccnt.name = taccnt.name + ", " + ppoint.name.
    end.
    else if can-find(first ttax where ttax.accnt = depaccnt.accnt no-lock) 
        then do:
        create taccnt.
        taccnt.accnt = depaccnt.accnt.
        taccnt.go = true.
        find first ppoint where ppoint.point = 1 and ppoint.depart = depaccnt.depart no-lock.
        taccnt.name = ppoint.name.
    end.
end.
                                                           
find first taccnt no-lock no-error.
if not available taccnt then do:
    MESSAGE "Нет неотправленных платежей."
    VIEW-AS ALERT-BOX
    TITLE "Внимание".
    return.
end.
                
define query q1 for taccnt.

define browse b1
    query q1
    displ 
    taccnt.go    format '*/ ' no-label          /* был значок – */
    taccnt.accnt label "Счет"
    taccnt.name  format 'x(58)' label "СПФ"
    with 10 down title "Отметьте счета (ENTER) и нажмите F1 для продолжения".

define frame fr1
    b1
    with no-labels view-as dialog-box.

on return of b1 in frame fr1 do:
    taccnt.go = not taccnt.go.
    b1:refresh().
end.

open query q1 for each taccnt.    

ENABLE all with frame fr1.
WAIT-FOR go of frame fr1.

/* -- - - - - - - - - - - - - - - - -*/

for each ttax:
 if can-find(first taccnt where taccnt.accnt = ttax.accnt and not taccnt.go no-lock) then delete ttax.
end.

/* -- - - - - - - - - - - - - - - - -*/

find first ttax no-lock no-error.
if not available ttax then do:
    MESSAGE "Счета не выбраны." VIEW-AS ALERT-BOX TITLE "Внимание". return.
end.

/* -- - - - - - - - - - - - - - - - -*/

for each ttax break by ttax.accnt:

  ACCUMULATE ttax.sum (sub-total by ttax.accnt).

  if last-of(ttax.accnt) and (accum sub-total by ttax.accnt ttax.sum) > 0 then 
  do:
  
    hide frame fsm.

    allok = false.

    REPEAT WHILE (allok <> TRUE) or choice4 <> false: 

       find first arp where arp = ttax.accnt no-lock no-error.
       if avail arp then 
           if (arp.cam[1] - arp.dam[1]) >= (accum sub-total by ttax.accnt ttax.sum) 
               then do: allok = true. leave. 
                   end.
               else do:
                   allok = false.
                   MESSAGE "Не хватает средств на " + arp.arp + "~nНа счете" + 
                   string(arp.cam[1] - arp.dam[1],"->>>,>>>,>>>,>>9.99") + 
                   ",~n а платеж на " + string(accum sub-total by ttax.accnt ttax.sum,"->>>,>>>,>>>,>>9.99") +
                   "~nПопытаться еще раз ?"
                   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                   TITLE "Налоговый платеж" UPDATE choice4.
     
                   if choice4 then AllOk = false.
                              else leave.
               end. /* arp */

    end. /* repeat */

    MESSAGE "Сформировать п/п на сумму: " + string(accum sub-total by ttax.accnt ttax.sum,"->>>,>>>,>>>,>>9.99") + "?"
             VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
             TITLE " Платежное поручение: " update choice.

    find first taccnt where taccnt.accnt = ttax.accnt no-error.

    if choice4 = true and choice = true then taccnt.go = yes. 
                                        else taccnt.go = no.

    if time < 51300 then r-cover = 1. /* SCLEAR00 */
                    else r-cover = 2. /* SGROSS00 */

    if r-cover = 2 and taccnt.go then if not yes-no ("", "Отправить сумму с тр.счета " + ttax.accnt + 
                                             "~nпо ГРОССУ? ~n(Если НЕТ - то след. днем по КЛИРИНГУ)") then r-cover = 1.

    taccnt.cover = r-cover.

  end. /* last-of () */

end.  /* for each */

/* -- - - - - - - - - - - - - - - - -*/


for each ttax:
 if can-find(first taccnt where taccnt.accnt = ttax.accnt and not taccnt.go no-lock) then delete ttax.
end.

/* -- - - - - - - - - - - - - - - - -*/


display "ЖДИТЕ..."  with no-labels centered frame fsm.  pause 0.

    /* кол-во ордеров */
    i_kolprn = 0.

find first ttax no-error.
if not available ttax then do:
   hide frame fsm. pause 0.
   return.
end.

for each ttax:

    find first comm.taxnk where comm.taxnk.rnn = ttax.rnn_nk use-index rnn no-lock no-error.
    find taccnt where taccnt.accnt = ttax.accnt no-error.
    taccnt.num_taxes = taccnt.num_taxes + 1.
    taccnt.sum_taxes = taccnt.sum_taxes + ttax.sum.


    /* kanat - теперь КНП вводится пользователем либо берется из справочника налоговых комитетов - 911 */

    if ttax.intval[1] <> 0 then 
       i_knp = ttax.intval[1].
       else
       i_knp = integer(taxnk.knp).
  
    run taxpl
       (ttax.grp,
        ttax.sum,
        ttax.accnt,
        string(comm.taxnk.bik,"999999999"),
        string(comm.taxnk.iik,"999999999"),
        string(ttax.kb,"999999"),
        ttax.bud,
        comm.taxnk.name, 
        ttax.rnn_nk,
        i_knp, /* 900 */
        integer(comm.taxnk.kod), /* 14  */
        integer(comm.taxnk.kbe), /* 11  */
        trim(ttax.info),
        if ourcode = 0 then trim(comm.taxnk.que) else "1P",    /* SG  */
        i_kolprn, 
        taccnt.cover,
        ttax.rnn,
        ttax.chval[1],
        ttax.date).

        pause 0.

     create tdocs.
     assign tdocs.g = ttax.grp 
            tdocs.dn = ttax.dnum
            tdocs.sm = ttax.sum
            tdocs.ud = ttax.uid
            tdocs.tx = ttax.txb
            tdocs.dt = ttax.date
            tdocs.d = return-value.    

end.    /* for each */

/* sasco - вывод краткого реестра для отдела контроля */
output stream sout to ttax.log.
find ofc where ofc.ofc = g-ofc no-lock no-error.
put stream sout unformatted CAPS (ofc.name) "/" g-ofc "/   " g-today ",  " string (time, "HH:MM:SS") skip(2)
                            "    Отправленные налоговые платежи за " dat skip(1).
for each taccnt where taccnt.go:
    put stream sout unformatted "Счет: " taccnt.accnt 
                                " Платежей: " taccnt.num_taxes format "zzzzzz9" 
                                " на сумму: " taccnt.sum_taxes format ">>>>>>>>>>>9.99" 
                                skip.

    t-numtax = t-numtax + taccnt.num_taxes.
    t-sumtax = t-sumtax + taccnt.sum_taxes.
end.
put stream sout unformatted skip (2) 
                "ИТОГО: " t-numtax format "zzzzzzz9" " платежей  на сумму " t-sumtax format ">>>>>>>>>>>9.99" skip(4).

output stream sout close.
unix silent prit ttax.log.
unix silent rm ttax.log.

/* -- - - - - - - - - - - - - - - - -*/


for each ttax, comm.tax where rowid(comm.tax) = ttax.rid:
    find first tdocs  where tdocs.g = ttax.grp and
                            tdocs.dn = ttax.dnum and
                            tdocs.sm = ttax.sum and
                            tdocs.ud = ttax.uid and 
                            tdocs.dt = ttax.date and 
                            tdocs.tx = ttax.txb no-error.
    assign comm.tax.senddoc = tdocs.d no-error.
end.
            
hide frame fsm. pause 0.

