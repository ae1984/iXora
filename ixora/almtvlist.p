/* almtvlist.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        АлмаТВ - список платежей
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
     База в г. Алматы, 3.2.10.3 и 3.1.5.2
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     KOVAL настройка для филиалов                                              
     19.06.2003 kanat Добавил печать чека при создании платежа
     09.08.2003 kanat Добавил автоматическую печать чека КС при приеме квитанции
     22.09.2003 sasco Удалять платежи могут только менеджеры из sysc."COMDEL".chval
     23.10.2003 sasco Нельзя удалять AlmaTV Для state > 0
     12.04.2004 kanat добавил вывод комиссий с платежей
     13.04.2004 kanat подправил итоги с учетом комиссий
     10.02.2005 kanat изменил формирование списка платежей
*/

{get-dep.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

def shared var g-today as date.
def input parameter alldoc as logical.
def var rid as rowid.
def var dat as date.

define variable docdnum as int.
define variable docuid as char.
define buffer talmatv for almatv.

def var s_rid as char.
def var s_payment as char.
def var s_service as char.

def var totalc as decimal.

dat = g-today.
update dat label "Укажите дату" with centered side-label frame fdat.
hide frame fdat.

define variable candel as log.

candel = yes.
find sysc where sysc.sysc = "COMDEL" no-lock no-error.
if available sysc then if lookup (userid("bank"), sysc.chval) = 0 then candel = no.

/*
find first almatv where date = dat no-lock no-error.
if not available almatv then current-value(alsd) = 0.
*/
def var totalt as dec.

/*
def var totald as dec.
def var course as dec.
find first crc where crc = 2 no-lock no-error. course = rate[1].
*/
DEFINE QUERY q1 FOR almatv.
def browse b1 
    query q1 no-lock
    display 
        string(get-dep(uid, dtfk),"99") format "99999" label "СПФ" 
        left-trim(string(ndoc,">>>>>>>9")) format "x(8)" label "No контр." 
        almatv.f format "x(15)" label "Фамилия"
        address  format "x(10)" label "Адрес"
        Summfk format "->>>>>>>9.99" label "Сумма" 
        cursfk format ">>>>>9.99" label "Комис."
        with 14 down title "Платежи АЛМА TV" no-labels. 

DEFINE BUTTON bedt LABEL "Просмотр".        
DEFINE BUTTON bnew LABEL "Создать".
DEFINE BUTTON bbks LABEL "БКС".
DEFINE BUTTON bdel LABEL "Удалить".
DEFINE BUTTON bprn LABEL "Печать".
DEFINE BUTTON bext LABEL "Выход".
DEFINE BUTTON bacc LABEL "Итог".

def frame f1 
    b1 
    skip
    space(15)
    bedt
    bnew
    bbks 
    bdel
    bprn
    bacc.

ON CHOOSE OF bedt IN FRAME f1
    do:
        run almtvin (dat,false, rowid(almatv)).              
        b1:refresh().
    end.


ON CHOOSE OF bbks IN FRAME f1
    do:
    s_rid = string(almatv.Ndoc).

    s_payment = s_rid + "#" + 'За услуги Алма ТВ' + "#" + string(almatv.summfk) + "#" + string(almatv.cursfk) + "#" + "0" + "#" + "KZT".

    run bks(s_payment,"NO").
    b1:refresh().
    end.



ON CHOOSE OF bnew IN FRAME f1
    do:
        run almtvin (dat,true, rowid(almatv)).


    if return-value <> "" then do:
    find first almatv where rowid(almatv) = to-rowid(return-value) no-lock no-error.
    if avail almatv then do:
    s_rid = string(almatv.Ndoc).
    s_payment = s_rid + "#" + 'За услуги Алма ТВ' + "#" + string(almatv.summfk) + "#" + string(almatv.cursfk) + "#" + "0" + "#" + "KZT".
    run bks(s_payment,"NO").
    end.
    end.


        if return-value <> "" then do:
            open query q1 for each almatv where dtfk = dat and 
            (alldoc or uid = userid("bank")) and almatv.txb=ourcode and almatv.deluid = ? no-lock.
            get last q1.
            reposition q1 to rowid to-rowid(return-value) no-error.
            b1:refresh().
        end.
    end.

ON CHOOSE OF bdel IN FRAME f1 
    do:
       if not available almatv then leave.
       if almatv.state > 0 then do:
          message "Сначала отмените зачисление~nна транзитный счет!!!" view-as alert-box title 'Нельзя удалить'.
          leave.
       end.
       else do: /* state = 0 */
       MESSAGE "Удалить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Платеж АЛМА TV" UPDATE choice as logical.
        case choice:
          when true then do:
            rid = rowid(almatv).
            find talmatv where rowid (talmatv) = rid no-lock no-error.
            docdnum = almatv.accnt.
            docuid = almatv.uid.

            {comdelpay.i
             &tbl = "almatv"
             &tbldate = "dtfk"
             &tbluid = "uid"
             &tbldnum = "accnt"
             &tblwhy = "delwhy"
             &tblwdnum = "deldnum"
             &tbldeluid = "deluid"
             &tbldeldate = "deldate"

             &whylist = "2,4"

             &tblrnn = "ndoc"
             &tblsum = "summfk"

             &exceptRNN = " chval edate etim euid ndoc f io address "
             &exceptALL = " chval edate etim euid "
             &exceptSUM = " chval edate etim euid summfk "

             &wherebuffer = " TRUE "

             &whereSum   = " almatv.ndoc = buftable.ndoc and 
                             almatv.summfk <> buftable.summfk and 
                             almatv.f = buftable.f and
                             almatv.io = buftable.io and
                             almatv.address = buftable.address and
                             almatv.accnt = buftable.accnt "
             
             &whereRNN = " TRUE "
             
             &whereAll = " TRUE "
             
             &olddate = "dat"
             &oldtxb = "ourcode"
             &olduid = "docuid"
             &olddnum = "docdnum"

             &where = " almatv.accnt = talmatv.accnt and almatv.summfk = talmatv.summfk and almatv.ndoc = talmatv.ndoc "
            }
            

            FIND almatv WHERE ROWID(almatv) = rid EXCLUSIVE-LOCK.
            update almatv.dtfk = ?
                   almatv.deluid = userid("bank")
                   almatv.deltime = time.

            release almatv.
            open query q1 for each almatv where almatv.dtfk = dat and
                        (alldoc or almatv.uid = userid("bank")) and almatv.txb = ourcode and almatv.deluid = ? no-lock.
            b1:refresh().

          end.
         end case.
         end. /* state = 0 */   
    end.

ON CHOOSE OF bprn IN FRAME f1
    do:
        run almtvprn (rowid(almatv)).
    end.

ON CHOOSE OF bacc IN FRAME f1
do:
    rid = rowid(almatv).
    FOR each almatv where almatv.dtfk = dat and
        (alldoc or almatv.uid = userid("bank")) and almatv.txb = ourcode and almatv.deluid = ? no-lock:
        ACCUMULATE almatv.summfk (TOTAL COUNT).
        ACCUMULATE almatv.cursfk (TOTAL).
    END.
/*
    FOR each almatv where dtfk = dat and
        (alldoc or uid = userid("bank")) no-lock:
        ACCUMULATE round(summfk * course, 0) (TOTAL).
    END.
    totald=(accum total summfk).
*/
    totalt = (accum total almatv.summfk).
    totalc = (accum total almatv.cursfk).

    MESSAGE "Количество платежей: " (accum count almatv.summfk) skip 
            "Hа сумму: " totalt skip
            "Комиссия: " totalc skip
            "Всего: " totalt + totalc skip
        VIEW-AS ALERT-BOX MESSAGE BUTTONS OK
        TITLE "Платежи АЛМА TV" .
    find almatv where rowid(almatv) = rid.
    
end.

open query q1 for each almatv where almatv.dtfk = dat and 
    (alldoc or almatv.uid = userid("bank")) and almatv.txb = ourcode and almatv.deluid = ? no-lock.
ENABLE all WITH centered FRAME f1.
b1:SET-REPOSITIONED-ROW(14, "CONDITIONAL").
APPLY "VALUE-CHANGED" TO BROWSE b1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
