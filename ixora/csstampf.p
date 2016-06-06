/* csstampf.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Штамповка кассовых проводок с работой через ЭК
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
        18/08/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES

                22/08/2012 Luiza - добавила проверку валюты при переводе сдачи
                10/12/2012 k.gitalov - изменения по ТЗ 1603
*/

{global.i}
{cm18_abs.i}

define input parameter p-jh as integer no-undo.
define input parameter p-nomer as character no-undo.
define output parameter p-errmsg as character no-undo.
define output parameter p-rez as logic no-undo.


p-errmsg = ''.
p-rez = false.

find first jh where jh.jh = p-jh no-lock no-error.
find first jl where jl.jh = p-jh no-lock no-error.
if not available jh or not available jl then
do:
    p-errmsg = "ЭК: Проводка " + string(p-jh) + " не найдена!".
    return.
end.

find first jl where jl.gl = 100500 and jl.jh = p-jh no-lock no-error.
if not available jl then
do:
    p-errmsg = "ЭК: В проводке " + string(p-jh) + " нет линий по счету 100500!".
    return.
end.

if jh.sts <> 5 then
do:
    p-errmsg = "ЭК: Статус проводки " + string(p-jh) + " не 5!".
    return.
end.

define temp-table wrk no-undo
    field dc  as character
    field crc as integer
    field amt as decimal
    index idx is primary dc descending crc.

define buffer b-wrk for wrk.

define variable coun           as integer   no-undo.
define variable v-type         as integer   no-undo.
define variable v-type1        as integer   no-undo.
define variable v-type3        as integer   no-undo.
define variable rez            as logi      no-undo.
define variable rez1           as logi      no-undo.
define variable rez2           as logi      no-undo.
define variable rez3           as logi      no-undo. /* результат при возрате денег при 15 операции */
define variable rez4           as logi      no-undo. /* результат при изъятии денег при 15 операции */
define variable rez5           as logi      no-undo. /* результат при возрате денег при 16 операции */
define variable rez6           as logi      no-undo init false. /* второй параметр при откате, не анализируем */

define variable v-sum          as decimal   no-undo.
define variable v-sum1         as decimal   no-undo.
define variable v-sum2         as decimal   no-undo.
define variable v-crc          as integer   no-undo.
define variable v-crc1         as integer   no-undo.
define variable v-id           as character no-undo.
define variable v-dispensedAmt as decimal   no-undo.
define variable v-acceptedAmt  as decimal   no-undo.
define variable v-auxOut       as decimal   extent 10.

define variable rcode          as integer   no-undo.
define variable deliver        as decimal extent 4  no-undo. /*сдача*/
define variable crcdeliver     as integer extent 4  no-undo. /*валюта сдачи*/
define variable p-proc         as integer   no-undo.
define variable p-jh2          as integer   no-undo.
define variable v-arp          as character no-undo.
define variable i              as int no-undo.


rez = false.
rez1 = false.
rez2 = false.
coun = 0.
for each jl where jl.jh = p-jh and jl.gl = 100500 no-lock:
    find first wrk where wrk.crc = jl.crc /*and wrk.dc = jl.dc*/ no-error.
    if not available wrk then
    do:
        create wrk.
        assign
            wrk.crc = jl.crc
            wrk.dc  = jl.dc.
    end.
    wrk.amt = wrk.amt + jl.dam - jl.cam.
end.

for each wrk.
    if absolute(wrk.amt) = 0 then delete wrk.
    else coun = coun + 1.
end.

if coun > 2 then
do:
    p-errmsg = "ЭК: В проводке " + string(p-jh) + " более двух операций с ЭК!".
    return.
end.

v-crc = 0.
v-sum = 0.
v-crc1 = 0.
v-sum1 = 0.
v-sum = 0.

if coun = 1 then
do:
    find first wrk.
    if wrk.amt > 0 then v-type = 4. /* прием наличных */
    else v-type = 3. /* выдача наличных */
    v-crc = wrk.crc.
    v-sum = absolute(wrk.amt).
end.
else
do:
    find first wrk.
    find last b-wrk.
    v-crc = wrk.crc.
    v-sum = absolute(wrk.amt).
    if wrk.amt > 0 then v-type = 4. else v-type = 3.
    v-crc1 = b-wrk.crc.
    v-sum1 = absolute(b-wrk.amt).
    if b-wrk.amt > 0 then v-type1 = 4. else v-type1 = 3.
end.

run to_screen("video","").

if coun = 1 then
do:

    rez1 = false.
    run smart_trx(g-ofc,p-jh,v-type,v-crc,v-sum,output v-dispensedAmt,output v-acceptedAmt,input-output v-auxOut,output rez1).
    if not rez1 then
    do:
        run to_screen("","").
        p-errmsg = "Ошибка обращения к ЭК! Проводка " + string(p-jh) + " не отштампована!".
        return.
    end.
    if v-acceptedAmt <> 0 then SetCashOfc(v-type,v-crc,p-nomer,g-today,v-acceptedAmt).
    if v-dispensedAmt <> 0 then do:
     if (v-type = 4 and v-dispensedAmt < 0) or v-type = 3 then do: deliver[1] = v-dispensedAmt. crcdeliver[1] = v-crc. end.
     else SetCashOfc(v-type,v-crc,g-ofc,g-today,v-dispensedAmt).
    end.
end.

if coun > 1 then
do:
    if wrk.dc = b-wrk.dc and v-crc = v-crc1 then
    do:
        rez1 = false.
        run smart_trx(g-ofc,p-jh,v-type,v-crc,v-sum + v-sum1,output v-dispensedAmt,output v-acceptedAmt,input-output v-auxOut,output rez1).
        if not rez1 then
        do:
            run to_screen("","").
            p-errmsg = "Ошибка обращения к ЭК! Проводка " + string(p-jh) + " не отштампована!".
            return.
        end.
        if v-acceptedAmt <> 0 then SetCashOfc(v-type,v-crc,p-nomer,g-today,v-acceptedAmt).
        if v-dispensedAmt <> 0 then do:
          if (v-type = 4 and v-dispensedAmt < 0) or v-type = 3 then do: deliver[2] = v-dispensedAmt. crcdeliver[2] = v-crc. end.
          else SetCashOfc(v-type,v-crc,g-ofc,g-today,v-dispensedAmt).
        end.
    end.

    /* если две операции-----------------------------------------------------------*/
    else
    do:
        /* первая операция------------------------------------------------------------*/
        rez1 = false.
        run smart_trx(g-ofc,p-jh,v-type,v-crc,v-sum,output v-dispensedAmt,output v-acceptedAmt,input-output v-auxOut,output rez1).
        if not rez1 then
        do:
            run to_screen("","").
            p-errmsg = "Ошибка обращения к ЭК! Проводка " + string(p-jh) + "№1 не отштампована!".
            return.
        end.
        if v-acceptedAmt <> 0 then SetCashOfc(v-type,v-crc,p-nomer,g-today,v-acceptedAmt).
        if v-dispensedAmt <> 0 then do:
          if (v-type = 4 and v-dispensedAmt < 0) or v-type = 3 then do: deliver[3] = v-dispensedAmt. crcdeliver[3] = v-crc. end.
          else SetCashOfc(v-type,v-crc,g-ofc,g-today,v-dispensedAmt).
        end.
        /* вторая операция------------------------------------------------------------*/
        rez2 = false.
        run smart_trx(g-ofc,p-jh,v-type1,v-crc1,v-sum1,output v-dispensedAmt,output v-acceptedAmt,input-output v-auxOut,output rez2).
        if not rez2 then
        do:
            run to_screen("","").
            p-errmsg = "Ошибка обращения к ЭК! Проводка " + string(p-jh) + "№2 не отштампована!".
            return.
        end.
        if v-acceptedAmt <> 0 then SetCashOfc(v-type1,v-crc1,p-nomer,g-today,v-acceptedAmt).
        if v-dispensedAmt <> 0 then do:
          if (v-type1 = 4 and v-dispensedAmt < 0) or v-type1 = 3 then do: deliver[4] = v-dispensedAmt. crcdeliver[4] = v-crc1. end.
          else SetCashOfc(v-type1,v-crc1,g-ofc,g-today,v-dispensedAmt).
        end.
    end.  /* else do*/
end.

run to_screen("","").

if (coun = 1 and rez1) or (coun > 1 and rez1 and rez2) then
do:

     do transaction:

        run trxsts( p-jh, 6 ,output rcode , output p-errmsg ).
        if rcode ne 0 then undo , return.
        find first jh where jh.jh = p-jh no-lock.
        run chgsts("jou", jh.party, "rdy").

        i = 1.
        do while i < 5:
            if deliver[i] <> 0  then do:
                rez1 = false.
                p-proc = 0.
                p-jh2 = 0.

                for each arp where arp.gl = 100500 and arp.crc = crcdeliver[i] no-lock.
                    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = p-nomer no-lock no-error.
                    if avail sub-cod then do:
                        v-arp = arp.arp.
                    end.
                end.

                if crcdeliver[i] = 1 then do:
                    do while p-jh2 = 0 :
                       run sel2("Перевод остатков/сдачи ","Пополнение текущего счета|Пополнение баланса (мобильная связь)|Выдача через кассу (100100)", output p-proc).
                        case p-proc:
                          when 1 then do: run surrend1(p-jh,abs(deliver[i]),v-arp,crcdeliver[i],output p-jh2).  end.
                          when 2 then do: run surrend2(p-jh,abs(deliver[i]),v-arp,output p-jh2).  end.
                          when 3 then do: run surrend3(p-jh,abs(deliver[i]),v-arp,crcdeliver[i],output p-jh2).  end.
                          otherwise do:
                            p-errmsg = "Ошибка выбора назначения перевода!~nПроводка " + string(p-jh) + "№2 не отштампована!".
                            undo , return.
                          end.
                        end case.
                    end.
                end.
                else do:
                    do while p-jh2 = 0 :
                       run sel2("Перевод остатков/сдачи ","Пополнение счета (открытого на счетах ГК 220520, 220620, 220720)|Выдача через кассу (100100)", output p-proc).
                        case p-proc:
                          when 1 then do: run surrend1(p-jh,abs(deliver[i]),v-arp,crcdeliver[i],output p-jh2).  end.
                          when 2 then do: run surrend3(p-jh,abs(deliver[i]),v-arp,crcdeliver[i],output p-jh2).  end.
                          otherwise do:
                            p-errmsg = "Ошибка выбора назначения перевода!~nПроводка " + string(p-jh) + "№2 не отштампована!".
                            undo , return.
                          end.
                        end case.
                    end.
                end.
                if p-jh2 = 0 then undo , return.
            end.
            i = i + 1.
        end. /* do while i < 5: */

        p-rez = true.
     end. /*transaction*/
end.


