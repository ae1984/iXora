/* defhwide.i
 * MODULE
        Название модуля - Клиенты и счета
 * DESCRIPTION
        Описание - Выписка по клиентским счетам.Шапка шаблона.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл - dewide.p.
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25.06.2004 dpuchkov добавил реквизиты(БИК) в выписку согласно постановлению нац банка
        06.03.2012 damir - переход на новые форматы.
        05.05.2012 damir - уменьшил размер рисунка как в договорах 202 на 33, выравнивание по левому краю.
        11.07.2012 damir - добавил v-bin_bnk.
        17.09.2012 damir - Тестирование ИИН/БИН, внедрено Т.З. № 1379, убрал message "Будем печатать".
        26.12.2012 damir - Внедрено Т.З. 1624.
        28.05.2013 damir - Внедрено Т.З. № 1541.
*/

/* ---------------- Statement's Header Creating ----------------------- */
{comm-bik.i}

def var kll       as logi init yes.
def var ii        as inte.
def var iii       as inte init 5.
def var iiii      as inte.
def var kurprev   as deci init 0.
def var kurtek    as deci.
def var lastdt    as date init ?.
def var v-bin_bnk as char.
def var v-bik_bnk as char.

for each b-deals where b-deals.account = acc_list.aaa and ( b-deals.servcode = "lt" or b-deals.servcode = "st" ) and b-deals.d_date >= acc_list.d_from and
b-deals.d_date <= acc_list.d_to break by b-deals.d_date:
    lastdt = b-deals.d_date.
end.

find first cmp no-lock no-error.
find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
if avail sysc then v-bin_bnk = trim(sysc.chval).

find first bank.sysc where bank.sysc.sysc = "CLECOD" no-lock no-error.
if avail bank.sysc then v-bik_bnk = trim(bank.sysc.chval).

put cmp.name format "x(30)" at 1.
put "Изготовлен "  + string(today,"99/99/9999") + " " + string(time,"HH:MM:SS") at 90 format "x(30)".
run pwskip(0).
put "РНН " + trim(cmp.addr[2]) + "  " + trim(cmp.addr[3]) format "x(59)" at 1 .

put string(page_num,"zzzz9") format "x(5)" to 113 " лист" to 119.

run pwskip(0).
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then
find first point where point.point = integer( ofc.regno / 1000 - 0.5 ) no-lock no-error.
if available point then do:
    put point.name at 1. run pwskip(0).
    put trim(point.addr[1]) format "x(50)" at 1.

    find sysc where sysc.sysc = 'REKVP' no-lock no-error.
    if avail sysc and sysc.chval = "1" then do:
    /*бик*/
    run pwskip(0).
    put "БИК " + comm-bik()  format "x(59)" at 1 .
    /*бик*/
    end.
end.

if stmsts = "CPY" then put "ДУБЛИКАТ " at 90.
run pwskip(1).

/* put branch format "x(30)".*/

if stmsts = "INF" then put "СПРАВКА ПО ОБОРОТАМ СЧЕТА КЛИЕНТА        Nr. " at 35.
else put "В Ы П И С К А   П О   С Ч Е Т У  Nr. " at 40.
put trim(string(seq,"zzz9999")).
run pwskip(1).

put "с  " + string(acc_list.d_from,"99/99/9999") + nf6 + string(acc_list.d_to,"99/99/9999") format "x(60)" at 40.  run pwskip(1).

define variable custname as character.
run getcv("h-custname", output custname).
define variable h-cif as character.
run getcv("h-cif", output h-cif).

find first cif where cif.cif = trim(h-cif) no-lock no-error.
if acc_list.d_to < g-today then do:
    put trim(substring(custname,1,60)) format "x(60)" at 1. run pwskip(0).
    if trim(substring(custname,61,60)) <> "" then do:
        put trim(substring(custname,61,60)) format "x(60)" at 1.
        run pwskip(0).
    end.
    put nf8 at 1 h-cif at 15.
    run pwskip(0).
end.
else do:
    put substring(custname,1,60) format "x(60)" at 1. put "ВНИМАНИЕ!" at 87.
    run pwskip(0).
    if trim(substring(custname,61,60)) <> "" then do:
        put trim(substring(custname,61,60)) format "x(40)" at 1.
        put "ОБОРОТЫ ТЕКУЩЕГО ДНЯ ПО СЧЕТУ " to 75.
        run pwskip(0).
        put "ЯВЛЯЮТСЯ ТОЛЬКО ИНФОРМАЦИЕЙ!" at 77.
        run pwskip(0).
    end.
    else do:
        put nf8 at 1 h-cif at 15.
        put "ОБОРОТЫ ТЕКУЩЕГО ДНЯ ПО СЧЕТУ " to 75.
        /*  run pwskip(0).         */
        put "ЯВЛЯЮТСЯ ТОЛЬКО ИНФОРМАЦИЕЙ!" at 77.
        run pwskip(0).
    end.
end.

find first b-deals where b-deals.account = acc_list.aaa and
b-deals.d_date >= acc_list.d_from and b-deals.d_date <= acc_list.d_to no-lock no-error.

/*if lookup(s-cif,v-VipClient) > 0 and avail b-deals and b-deals.crc <> 1 then input from value(v-inputfile_2).
else input from value(v-inputfile_1).*/

if avail b-deals and b-deals.crc <> 1 then input from value(v-inputfile_1).
else input from value(v-inputfile_1).

repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*Dateformirovan*" then do:
            v-str = replace(v-str,"Dateformirovan",string(today,"99/99/9999")).
            next.
        end.
        if v-str matches "*Namebank*" then do:
            if v-nbankru <> "" then v-str = replace(v-str,"Namebank",trim(v-nbankru)).
            else v-str = replace(v-str,"Namebank",'АО "ForteBank"').
            next.
        end.
        if v-str matches "*bank_rnn*" then do:
            if v-bin then do:
                if acc_list.d_to ge v-bin_rnn_dt then v-str = replace(v-str,"bank_rnn","").
                else v-str = replace(v-str,"bank_rnn",trim(cmp.addr[2])).
            end.
            else v-str = replace(v-str,"bank_rnn",trim(cmp.addr[2])).
            next.
        end.
        if v-str matches "*bank_bin*" then do:
            if v-bin_bnk <> "" then v-str = replace(v-str,"bank_bin",trim(v-bin_bnk)).
            else v-str = replace(v-str,"bank_bin",'Не найден в sysc').
            next.
        end.
        if v-str matches "*bank_bik*" then do:
            if v-bik_bnk <> "" then v-str = replace(v-str,"bank_bik",trim(v-bik_bnk)).
            else v-str = replace(v-str,"bank_bik",'Не найден в sysc').
            next.
        end.
        if v-str matches "*Datefrom*" then do:
            if acc_list.d_from <> ? then v-str = replace(v-str,"Datefrom",string(acc_list.d_from,"99/99/9999")).
            else v-str = replace(v-str,"Datefrom",'').
            next.
        end.
        if v-str matches "*Datedue*" then do:
            if acc_list.d_to <> ? then v-str = replace(v-str,"Datedue",string(acc_list.d_to,"99/99/9999")).
            else v-str = replace(v-str,"Datedue",'').
            next.
        end.
        if v-str matches "*Bankclienpartner*" then do:
            if custname <> "" then v-str = replace(v-str,"Bankclienpartner",trim(substring(custname,1,60)) + trim(substring(custname,61,60))).
            else v-str = replace(v-str,"Bankclienpartner",'').
            next.
        end.
        if v-str matches "*Rnn_client*" then do:
            if v-bin then do:
                if acc_list.d_to ge v-bin_rnn_dt then v-str = replace(v-str,"Rnn_client","").
                else v-str = replace(v-str,"Rnn_client",trim(cif.jss)).
            end.
            else v-str = replace(v-str,"Rnn_client",trim(cif.jss)).
            next.
        end.
        if v-str matches "*Acc_client*" then do:
            if acc_list.aaa <> "" then v-str = replace(v-str,"Acc_client",acc_list.aaa + "&nbsp;&nbsp;" + crccode).
            else v-str = replace(v-str,"Acc_client",'').
            next.
        end.
        if v-str matches "*InnBnn_client*" then do:
            if cif.bin <> "" then v-str = replace(v-str,"InnBnn_client",trim(cif.bin)).
            else v-str = replace(v-str,"InnBnn_client",'').
            next.
        end.
        if v-str matches "*dataposlplatezh*" then do:
            if lastdt <> ? then v-str = replace(v-str,"dataposlplatezh",string(lastdt,"99/99/9999") + "&nbsp;г.").
            else v-str = replace(v-str,"dataposlplatezh",'').
            next.
        end.
        if v-str matches "*BNNRNN*" then do:
            if v-bin then do:
                if acc_list.d_to ge v-bin_rnn_dt then v-str = replace(v-str,"BNNRNN","").
                else v-str = replace(v-str,"BNNRNN","РНН").
            end.
            else v-str = replace(v-str,"BNNRNN","РНН").
            next.
        end.
        if v-str matches "*INNBNN*" then do:
            v-str = replace(v-str,"INNBNN","ИИН/БИН").
            next.
        end.
        if v-str matches "*LSD:*" then do:
            if v-bin then do:
                if acc_list.d_to ge v-bin_rnn_dt then v-str = replace(v-str,"LSD:","").
                else v-str = replace(v-str,"LSD:","РНН:").
            end.
            else v-str = replace(v-str,"LSD:","РНН:").
            next.
        end.
        if v-str matches "*WEH*" then do:
            v-str = replace(v-str,"WEH","БИН").
            next.
        end.
        leave.
    end.
    put stream v-out unformatted v-str skip.
end.
input close.

/*if crc.crc <> 1 and (acc_list.d_to - acc_list.d_from) > 10 then
run yn('Будем печатать ?', 'Внимание!Вы задали длинный период', 'распечатка курсов может занять', 'несколько листов', output kll).*/
if kll then do:
    case  crc.crc:
        when 1  then run pwskip(0).
        otherwise do:
            ii=1.
            iiii=1.
            put skip(1).
            put "Валюта: " + crc.des format 'x(40)' at 1 skip.
            if acc_list.d_from = acc_list.d_to then do:
                if crc.regdt = acc_list.d_from then put "Курс:   " + string(crc.rate[1],">>>9.99") format "x(35)" at 1 .
                else do:
                    find last crchis where crchis.regdt <= acc_list.d_from and crchis.crc = crc.crc no-lock  no-error.
                    if available crchis then put "Курс: " + string(crchis.rate[1],">>>9.99") format "x(35)" at 1 .
                end.
            end.
            else do:
                put "Курс:  " at 1.
                for each crchis where crchis.regdt >= acc_list.d_from and crchis.regdt <= acc_list.d_to and crchis.crc = crc.crc :
                    kurtek = crchis.rate[1].
                    if ii = ( iii * iiii ) and kurtek <> kurprev then do:
                        put string(crchis.rate[1],">>>9.99") + " (" +     string(crchis.regdt,"99/99/9999") +  ")" format "x(22)" at 8.
                        kurprev=crchis.rate[1].
                        iiii = iiii + 1.
                    end.
                    else if kurtek <> kurprev then do:
                        put string(crchis.rate[1],">>>9.99") + " (" + string(crchis.regdt,"99/99/9999") + ")" format "x(22)" .
                        kurprev=crchis.rate[1].
                        ii = ii + 1.
                    end.
                end.
            end.
        end.
    end.   /*  case  */
end.   /*Ответ - будем печатать */

run pwskip(1).

/* ------------------------------------------------------------------- */
