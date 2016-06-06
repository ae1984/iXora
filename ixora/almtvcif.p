/* almtvcif.p
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
        07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки 
        30.07.03 kanat добавил новый параметр при вывзове commpl - ФИО плательщика если РНН = 000000000000
        12.04.04 kanat собираются все платежи со статусом 2 (0 - новый, 1 - зачисленый на АРП, 3 - зачисленная комиссия, 2 - отправленный платеж)
                       отправка будет делаться только с после зачисления комиссий с платежей
        18.05.05 kanat ЗАО поменял на АО 
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/

{get-dep.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

{comm-arp.i} /* Проверка остатка на АРП c заданной суммой */
{yes-no.i}
def shared var g-today as date.
def var dat as date.
def var uu as char.
def var tmp  as char.
def var tsum as decimal.
def var summa as deci.
def var v-users as char init "". 
def new shared var s-jh like jh.jh.
def var rcode as int.
def var rdes  as cha.
def var choice4 as logical init false.
def var selarp as char.
dat = g-today.

find first comm.txb where txb.txb = ourcode no-lock.
if ourcode = 0 then selarp = "498904301". else selarp = comm.txb.commarp.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
hide frame dataa.

for each almatv where dtfk = dat and state = 1 and almatv.deluid = ? and almatv.txb=ourcode:
    ACCUMULATE almatv.summfk (total).
end.

summa = (accum total almatv.summfk).

if summa <> 0 then do:
    for each almatv where dtfk = dat and state = 0 and almatv.deluid = ? and almatv.txb=ourcode break by uid :
        if first-of(uid) then v-users = "~n" + almatv.uid + v-users.
    end.
    if v-users <> "" then 
        if not yes-no("Внимание", "По следующим кассирам:" + 
        v-users + 
        "~nплатежи не зачислены на транзитный счет. Продолжить?") then return.
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
                 'АО "АЛМА ТВ"',              /* name       */
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

            for each almatv where dtfk = dat and state = 1 and almatv.deluid = ? and almatv.txb=ourcode:
                update almatv.state = 2.
            end.

        end.    
    end case.
end.
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.

/* Внутренняя транзакция (the one was later)
            s-jh = 0.
            run trxgen("ALX0005", "|",  
            string(summa) + "|" + 
            "498904301" + "|" + 
            "000467498" + "|" +
            "Платежи АЛМА-ТВ",
            "cif", "", output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do :
                message " Ошибка проводки rcode = " + string(rcode) + ":" +
                rdes + " " + string(s-jh). pause.
                return.
            end.    
            run vou_bank.
            run jl-stmp.
*/
