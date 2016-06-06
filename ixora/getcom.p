/* getcom.p
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
 * BASES
        BANK COMM
 * CHANGES
        06/07/05 saltanat - Включила передачу параметра aaa.aaa в вызов функции getcomgl.
        05.07.2005 saltanat - Выборка льгот по счетам.
        22.06.2006 nataly  - добавила обработку кодов доходов расходов
        26/06/2006 madiyar - при погашении долга по комиссии счет сохраняется в поле aaop, не в aaa
        28/06/2006 madiyar - если bxcif.pref = yes, то комиссия снимается только со счета bxcif.aaa
        23.04.10 marinav - поле v-comacc расширено до 20 знаков
        18.04.2011 damir - списание коммисий, со счетов с которых был осуществлен перевод остатков пропускаем.
        02.04.2011 damir - добавил Комиссия в примечание trxgen
        20.10.2011 damir - корректировка списание коммисий, со счетов с которых был осуществлен перевод остатков.
        28.10.2011 damir - добавил доп.проверку при снятии комиссии.
        25.09.2012 Lyubov - Убрала слово "Долг" из примечания
        20/09/2013 Luiza - ТЗ 1916 проставление вида документа
*/

/*{operday.i}*/
{getcomgl.i}

/*22/02/06 nataly*/
{getdep.i}

/*22/02/06 nataly*/
def var v-tarif as char no-undo.
def var v-dep as char no-undo.
def var v-code as char no-undo.
def var v-gl like jl.gl no-undo.
def buffer 	bjl for jl.
/*22/02/06 nataly*/

def /*new*/ shared var g-ofc like ofc.ofc.
def /*new*/ shared var g-today as date.
def new shared var s-jh like jh.jh.
def var v-sum as decimal init 0.
def var v-sumcom as decimal init 0.
def var rcode as int.
def var rdes as char.
def var v-amt as deci.
def var v-amt1 as deci.
def var v-amt2 as deci.
def var v-pref as char init "".
def var v-comacc as char.
def var v-errstr as char.
def var v-cifcount as int.
def var v-debt as deci init 0.
def var v-rem as char.
def var i as int init 0.
def var lcom as logical.
def var logdir as char init "/data/log".
define stream rpt.
define stream err.
define buffer acrc for crc.

find first sysc where sysc = "STGLOG" no-lock no-error.
if avail sysc then logdir = sysc.chval.

/*
g-today = operday().
g-ofc = userid("bank").
*/

output stream rpt to
    value(logdir + "/com." + string(today, "99.99.99" ) +
    "." + replace(string(time, "HH:MM" ), ":" , ".") + ".prot").
output stream err to
    value(logdir + "/com." + string(today, "99.99.99" ) +
    "." + replace(string(time, "HH:MM" ), ":" , ".") + ".dolg").

find first cmp no-lock no-error.
put stream rpt unformatted cmp.name skip.
put stream err unformatted cmp.name skip.
put stream err unformatted
    "Дата: " string(today) " Время: " string(time, "hh:mm:ss")
    skip(1)
    "Долг по комиссии " string(g-today)
    skip(1)
    "Клиент   Код    Тариф      Оплачено          Долг " skip
    "=====================================================" skip.

put stream rpt unformatted
    "Дата: " string(today) " Время: " string(time, "hh:mm:ss")
    skip(1)
    "Протокол удержания комиссии за " string(g-today)
    skip(1)
    "Клиент Счет                  Код      Оплачено     Транзакция" skip
    "==============================================================" skip.

def var v-prc  as char.
def var v-pay  as deci.
def var vparam as char.
def var v-jh   as inte.
def var vdel   as char init "^".

main:
for each bxcif  exclusive-lock transaction:
    if bxcif.amount = 0 then next main.
    /* Прочешем должников */
    bxcif.cnt = bxcif.cnt + 1.
    find first crc where crc.crc = bxcif.crc no-lock.
    lcom = true.
    v-amt1 = bxcif.amount.
    v-amt2 = 0.
    repeat while lcom:
        v-debt = 0.
        v-amt = 0.
        v-comacc = "".

        /*Дополнительная проверка по автоматическому переводу остатку средств*/
        find first aaaperost where aaaperost.cif = bxcif.cif and aaaperost.aaacif1 = bxcif.aaa no-lock no-error.
        if avail aaaperost then do:
            find first aaa where aaa.aaa = aaaperost.aaacif1 no-lock no-error.
            if avail aaa then do:
                v-pay = aaa.cbal - aaa.hbal. /*сумма доступного остатка*/
                if v-pay > 0 then do transaction:
                    vparam = string(v-pay) + vdel + "1" + vdel + aaa.aaa + vdel + "1" + vdel + aaaperost.aaacif2 + vdel +
                    "Перевод остатков".
                    v-jh = 0.
                    run trxgen("vnb0069", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                    if rcode = 0 then do: /*Если значение 0, то успешно*/
                        run trxsts(v-jh, 6, output rcode, output rdes). /*штампуем проводку*/
                    end.
                    for each jl where jl.jh = v-jh exclusive-lock.
                        jl.viddoc = "pdoctng,01". /* платежное поручение */
                    end.
                end.
            end.
        end.

        if bxcif.pref then
          run getacct (
          bxcif.cif,
          bxcif.aaa,
          bxcif.amount,
          bxcif.crc,
          output v-comacc,
          output v-sumcom,
          output v-debt
          ).
        else
          run getacct (
          bxcif.cif,
          /*if bxcif.crc = 1 then bxcif.aaa else */ "", /* Do not touch currency acc*/
          bxcif.amount,
          bxcif.crc,
          output v-comacc,
          output v-sumcom,
          output v-debt
          ).

        if v-comacc = "" then do:
            put stream err unformatted
                       bxcif.cif " "
                       bxcif.type format "x(4)" " "
                       bxcif.amount format ">>>>>9.99"  " "
                       crc.code " "
                       "     0.00" " "
                       crc.code " "
                       bxcif.amount format ">>>>>9.99"  " "
                       crc.code " "
                       "Не найдены счета." space bxcif.rem skip.
            next main.
        end.

        find first aaa where aaa.aaa = v-comacc no-lock.
        find first acrc where acrc.crc = aaa.crc no-lock.

        if v-sumcom > 0 then do:
            s-jh = 0.

            run trxgen("CIF0006", "|",
            string(v-sumcom) + "|" +
            v-comacc + "|"+
            getcomgl(aaa.aaa, bxcif.cif, bxcif.type) + "|" + "Комиссия " + bxcif.rem,
            "cif", "", output rcode, output rdes, input-output s-jh).

            /*22/02/06 nataly*/
             v-gl = integer(getcomgl(aaa.aaa, bxcif.cif, bxcif.type)).
             v-tarif = bxcif.type.
            {upd-cods.i}
            /*22/02/06 nataly*/

            if rcode ne 0 then do:
                put stream err unformatted
                       bxcif.cif space
                       bxcif.type format "x(4)" space
                       bxcif.amount format ">>>>>9.99" space
                       crc.code space
                       0 format ">>>>>9.99" space
                       crc.code space
                       bxcif.amount format ">>>>>9.99" space
                       crc.code space
                       "Ошибка проводки rcode = " + trim(string(rcode)) + ":" +
                       rdes + " Сумма " v-sumcom space s-jh
                       skip.
                next main.
            end.
            for each jl where jl.jh = s-jh: jl.sts = 5. end.
            for each jh where jh.jh = s-jh: jh.sts = 5. end.
            run jl-stmp.
            for each jl where jl.jh = v-jh exclusive-lock.
                jl.viddoc = "pdoctng,12". /* платежный ордер */
            end.
            put stream rpt unformatted /* В отчет */
                bxcif.cif space
                v-comacc format "x(20)" space
                bxcif.type format "x(5)" space
                v-sumcom * acrc.rate[1] / crc.rate[1] format ">>>>>>>>9.99"
                space
                crc.code space(5)
                s-jh space
                bxcif.rem skip.
        end.

        lcom = (v-debt > 0 and v-sumcom > 0).

        v-amt2 = v-amt2 + v-sumcom * acrc.rate[1] / crc.rate[1].
        if not lcom and v-debt <> 0 then
            put stream err unformatted
                   bxcif.cif space
                   bxcif.type format "x(4)" space
                   v-amt1 format ">>>>>9.99" space
                   crc.code space
                   v-amt2 format ">>>>>9.99" space
                   crc.code space
                   v-debt format ">>>>>9.99" space
                   crc.code space
                   "Нехватка средств." space bxcif.rem skip.
        if v-sumcom > 0 then do:
            assign bxcif.amount = v-debt
                   bxcif.jh = s-jh
                   bxcif.amopl = bxcif.amopl + v-sumcom * acrc.rate[1] / crc.rate[1]
                   bxcif.opl = g-today
                   bxcif.aaop = v-comacc.
        end.
    end.
    if bxcif.amount = 0 then delete bxcif.
end.

output stream rpt close.
output stream err close.
