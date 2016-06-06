/* csstamp1.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Штамп пополнения ЭК
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
 * AUTHOR
        26/02/2011 marina
 * BASES
        BANK COMM
 * CHANGES
        23.02.2012 k.gitalov новая версия
        27.06.2012 k.gitalov добавил код валюты в список транзакций
        16/10/2012 Luiza добавила проверку проводки для соответств ЭК
*/

{mainhead.i}
{cm18_abs.i}

define variable v-nomer        like cslist.nomer no-undo.
define variable v-dispensedAmt as decimal   no-undo.
define variable v-acceptedAmt  as decimal   no-undo.
define variable v-Amount       as decimal   extent 10.
define variable v-rem          as character init "Пополнение электронного кассира N " no-undo .
define variable v_trx          as integer   no-undo.
define variable v-joudoc       as character format "x(10)" no-undo.
define variable v-kod          as character no-undo init "14".
define variable v-kbe          as character no-undo init "14".
define variable v-knp          as character no-undo init "890".
define variable v-ja           as logi      no-undo format "yes/no".
define variable v-select       as integer   no-undo.
define variable v_title        as character no-undo. /*наименование платежа */
define variable rez            as log.
define new shared variable s-jh           like jh.jh.
define variable s-ourbank      as character no-undo.
define variable rcode     as integer   no-undo.
define variable rdes      as character no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not available sysc or sysc.chval = "" then
do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).


define temp-table wrk_jh no-undo
    field crc          as integer
    field gl_deb       as character
    field acc_deb      as character
    field gl_cre       as character
    field acc_cre      as character
    field acc_cre_bal  as decimal
    field acc_cre_summ as decimal .

define query q_list for wrk_jh .
define browse b_list query q_list no-lock
    display wrk_jh.gl_deb   format "x(6)"  label "Дебет Г/К"
    wrk_jh.acc_deb  format "x(20)" label "Дебет АРП"
    wrk_jh.gl_cre   format "x(6)"  label "Кредит Г/К"
    wrk_jh.acc_cre  format "x(20)" label "Кредит АРП"
    wrk_jh.acc_cre_summ format ">>>,>>>,>>9.99" label "Сумма"
    GetCRC(wrk_jh.crc) format "x(3)" label "Валюта"
          with  4  DOWN  NO-ASSIGN  SEPARATORS  no-row-markers .


format
    v-joudoc label " Документ        " format "x(10)"  v_trx label "  ТРН " format "zzzzzzzzz"      skip
    v-nomer  label " Номер ЭК        "  skip
    "                                   ДАННЫЕ ПРОВОДКИ  "  skip
    b_list skip
    v-rem    label " Примечание      " format "x(50)" skip
    v-kod    label " Код             " format "x(2)" skip
    v-kbe    label " Кбе             " format "x(2)" skip
    v-knp    label " КНП             " format "x(3)" skip(1)

    v-ja     label " Штамповать транзакцию?   "
    with  side-labels centered row 7 title v_title width 92 frame f_main.

format s-jh label "Транзакция" with centered side-label frame vvv .
format s-jh label "Транзакция" with centered side-label frame vvv1 .

define query q-trx for joudoc,joudop,jh,jl.
define browse b-trx query q-trx
    display jh.party label "Документ " format "x(10)" jl.jh format "9999999" label "Транзакц"  jl.sts label "Статус" format "9"
    jl.rem[1] label "Описание " format "x(30)" jl.who label "Исполнитель" format "x(7)" GetCRC(jl.crc) label "Валюта" WITH  15 DOWN.
define frame f-trx b-trx  with overlay 1 column side-labels row 11 column 10 width 100 no-box.

on help of s-jh in frame vvv
    do:
            open query  q-trx for each joudoc where joudoc.whn = g-today no-lock, each joudop where joudop.docnum = joudoc.docnum and (joudop.type = "CSI1" or joudop.type = "CSI2"),
                each jh where jh.jh = joudoc.jh and jh.sts = 5 no-lock, each jl where jl.jh = jh.jh and (jl.trx = "jou0041" or jl.trx = "jou0066")
                and jl.dc = "D" no-lock.
        enable all with frame f-trx.
        wait-for return of frame f-trx
            focus b-trx in frame f-trx.
        s-jh = jh.jh.
        hide frame f-trx.
        display s-jh with frame vvv.
    end.
on help of s-jh in frame vvv1
    do:
            open query  q-trx for each joudoc where joudoc.whn = g-today no-lock, each joudop where joudop.docnum = joudoc.docnum and (joudop.type = "VSI1" or joudop.type = "VSI2"),
                each jh where jh.jh = joudoc.jh and jh.sts = 5 no-lock, each jl where jl.jh = jh.jh and (jl.trx = "jou0044" or jl.trx = "jou0067")
                and jl.dc = "C" no-lock.
        enable all with frame f-trx.
        wait-for return of frame f-trx
            focus b-trx in frame f-trx.
        s-jh = jh.jh.
        hide frame f-trx.
        display s-jh with frame vvv1.
    end.
on "END-ERROR" of frame f-trx
    do:
        hide frame f-trx no-pause.
    end.

v-select = 0.
run sel2 (" КОНТРОЛЬ ", "1. КОНТРОЛЬ ПОПОЛНЕНИЯ ЭК |2. КОНТРОЛЬ ВЫГРУЗКИ ЭК  |3. ВЫХОД ", output v-select).
if (v-select < 1) or (v-select > 2) then return.
if v-select = 1 then v_title = "Контроль пополнения ЭК ". else v_title = "Контроль выгрузки ЭК ".
s-jh = 0.
display v_title no-labels format "x(30)" with centered row 5 frame sss.

if v-select  = 1 then update s-jh label "Транзакция" with frame vvv .
else update s-jh label "Транзакция" with frame vvv1 .


find jh where jh.jh eq s-jh no-lock no-error.
find first jl where jl.jh = jh.jh no-error .

if not available jl then
do:
    message " Транзакция не найдена " view-as alert-box.
    return.
end.
find first joudoc where joudoc.jh = jh.jh no-lock no-error.
if not available joudoc then
do:
    message "не найден jou документ" view-as alert-box.
    return.
end.
find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
if not available joudop then
do:
    message "не найдена запись в таблице joudop" view-as alert-box.
    return.
end.
if v-select  = 1 and joudop.type <> "CSI1" and joudop.type <> "CSI2" then
do:
    message " Документ не относится к типу пополнение электронного кассира" view-as alert-box.
    undo, return.
end.
if v-select = 2 and joudop.type <> "VSI1" and joudop.type <> "VSI2" then
do:
    message " Документ не относится к типу выгрузка электронного кассира" view-as alert-box.
    undo, return.
end.
if jl.sts = 6 then
do:
    message " Транзакция уже отштампована! " view-as alert-box.
    return.
end.


find first jl where jl.jh = s-jh and jl.gl = 100500 no-lock no-error.
if available jl then assign v-rem = jl.rem[1].

v-joudoc = jh.party.
display v-joudoc with frame f_main.

v-nomer = joudop.doc1.
find first csofc where csofc.ofc = g-ofc no-lock no-error.
if not available csofc or csofc.nomer <> v-nomer then do:
    message " Эта проводка для "  + v-nomer + "! " view-as alert-box.
    return.
end.
v-rem = joudoc.remark[1].
v_trx = joudoc.jh.

run CreateTransForJH(joudoc.jh, output rez).
if not rez then
do:
    hide frame f_main no-pause.
    return.
end.

    open query q_list for each wrk_jh .
display v-joudoc v_trx v-nomer b_list  v-rem v-kod v-kbe v-knp with frame f_main.

update  v-ja with frame f_main.

if v-ja then
do :
    /* Здесь отправить запрос в ЭК на пересчет и прием суммы !!!!!!!!!!!! */
    find first jl where jl.jh = s-jh and jl.gl = 100500 no-lock no-error.
    if not available jl then
    do:
        message "Проводка не найдена!" view-as alert-box.
        return.
    end.
    rez = false.
    if jl.dc = 'd' /* загрузка сейфа */ then
    do:
        run smart_trx(g-ofc,s-jh,4,jl.crc,jl.dam,output v-dispensedAmt,output v-acceptedAmt,input-output v-Amount,output rez).
        if rez then
        do:

            if v-acceptedAmt <> 0 then SetCashOfc(4,jl.crc,v-nomer,g-today,v-acceptedAmt).
            if v-dispensedAmt <> 0 then SetCashOfc(4,jl.crc,g-ofc,g-today,v-dispensedAmt).

             run trxsts(s-jh,6,output rcode, output rdes).
             if rcode <> 0 then do:
                message rdes view-as alert-box.
                undo.
             end.
            message "Проводка" s-jh " отштампована" view-as alert-box.
            find current jh no-lock.
        end.
        if rez = false then
        do:
            message "Ошибка обращения к ЭК! Проводка " + string(s-jh) + " не отштампована!" view-as alert-box.
            return.
        end.
    end.
    else
    do: /* jl.dc = 'c' выгрузка сейфа  */
        run smart_trx(g-ofc,s-jh,10,0,0,output v-dispensedAmt,output v-acceptedAmt,input-output v-Amount,output rez).
        if rez  then
        do:

            if v-Amount[1] <> 0 then SetCashOfc(10,1,v-nomer,g-today, v-Amount[1]).
            if v-Amount[2] <> 0 then SetCashOfc(10,2,v-nomer,g-today, v-Amount[2]).
            if v-Amount[3] <> 0 then SetCashOfc(10,3,v-nomer,g-today, v-Amount[3]).
            if v-Amount[4] <> 0 then SetCashOfc(10,4,v-nomer,g-today, v-Amount[4]).

             run trxsts(s-jh,6,output rcode, output rdes).
             if rcode <> 0 then do:
                message rdes view-as alert-box.
                undo.
             end.

            message "Проводка" s-jh " отштампована" view-as alert-box.
            return.
        end.
        else
        do:
            message "Ошибка обращения к ЭК! Проводка " + string(s-jh) + " не отштампована!" view-as alert-box.
            return.
        end.
    end. /* jl.dc = 'c' выгрузка сейфа  */
end.
else
do:
    hide frame f_main no-pause.
    return.
end.

procedure CreateTransForJH:
    define input  parameter s-jh as integer.
    define output parameter v-ret as log.
    define variable i-count as integer.
    define buffer b-jl for jl.
    for each jl where jl.jh = s-jh no-lock:
        i-count = i-count + 1.
    end.
    if i-count = 0 then
    do:
        v-ret = false.
        return.
    end.
    for each jl where jl.jh = s-jh no-lock by jl.ln:
        if jl.dc = 'D' then
        do:
            create wrk_jh.
            wrk_jh.crc = jl.crc.
            wrk_jh.gl_deb = string(jl.gl).
            wrk_jh.acc_deb = jl.acc.
            find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock.
            wrk_jh.gl_cre = string(b-jl.gl).
            wrk_jh.acc_cre = b-jl.acc.
            wrk_jh.acc_cre_summ = b-jl.cam.
        end.
    end.
    v-ret = true.
end procedure.