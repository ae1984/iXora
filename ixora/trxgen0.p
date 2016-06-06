/* trxgen0.p
 * MODULE
        ГЕНРАТОР ТРАНЗАКЦИЙ
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

        22.11.2001 - by sasco - вывод спец. инструкции для кредитуемых счетов
        28.05.2002 - by sasco - проверка на блокировку счета 100100
        29.07.2002 - BY SASCO - обработка параметра "b" / "s" - безнал. курс
                                покупки / продажи налом
        14.10.2002 - by sasco - обработка карточек дебиторов
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        10/01/03 - by nataly  - если остаток по счету  после транзакции становится
                меньше нуля для нереверсивных  или > 0 для реверсивных,
                то транзакция не делается !!!!
                + добавлена проверка на ГК 499970, 359911 только для Алматы
        04.11.2003 sasco - Проверка контроля физ. лиц (trx-aaafiz.i)
        26/11/03 nataly добавлена обработка subledger SCU
        23/12/03 sasco переделал обработку дебиторов
        01/09/04 sasco русифицировал ошибки генератора транзакций
        05.08.05 dpuchkov добавил проверку на блокированные суммы для инкассовых распоряжений.
        13.08.05 dpuchkov добавил возможность проплаты пенсионных если есть ограничение за исключением платежей в бюджет
                          в связи с изменением в законодательстве.
        19/09/2005 u00121 Проверка количества разрешенных дебетовых проводок по биометрическому контролю
        27.09.2005 dpuchkov - добавил возможность проплаты социальных если есть ограничение в п 1.6.2.9 (Т.З.ї131)
        05.12.2005 dpuchkov - вынес knp в отдельную строку.
        18/04/06 nataly добавлена обработка subledger TSF
        26.05.06 dpuchkov - изменил возраст вносителя >=14 лет
        24.07.2006 Natalya D. - запись в таблицу curctrl поступлений на валютные счета клиентов.
        21.09.2006 Natalya D. - запись в таблицу curctrl вынесла в отдельную i-шку. (addtocurctrl.i)
        14/04/08 marinav - через кассу в пути беруться курсы rate[2] [3]
        08/04/2010 galina - снимаем приостновление по СО aas.sta = 17 для оплаты ИР
        07/06/2011 madiyar - добавил по кассе счет 100500
        30/11/2011 evseev - ТЗ-1208 отправка уведомлений
        01.12.2011 aigul - отправка уведомлений менеджерам
        21/12/2011 evseev - ТЗ-929. Оплата ИР с вал. счетов
        06.03.2012 aigul - добавила в рассылку
        28/04/2012 evseev - логирование значения aaa.hbal
        24.05.2012 evseev - изменения в trx-aaafiz.i
        27.06.2012 evseev - ТЗ-1233
        26.07.2012 evseev - ТЗ-1464
        23.08.2012 evseev - изменил адреса отправки уведомлений
        26/11/2012 Luiza  - подключила convgl.i  ТЗ 1374
        28/12/2012 madiyar - счет ГК 000001 заменяется на счет конвертации, соответствующий валюте и стороне проводки
        26/12/2012 evseev
*/


{global.i}
{chbin.i}
{chk12_innbin.i}

define input parameter trxcode as character.
define input parameter vdel as character.
define input parameter vparam as character.
define input parameter vsub as character.
define input parameter vhref as character.
run savelog("trxgen0" , trxcode + " ; " + vparam + " ; " + vsub + " ; " + vhref).

define output parameter rcode as integer.
define output parameter rdes as character.
define input-output parameter vjh as integer.
define new shared variable s-jh    as integer.
define            variable i       as integer.
define            variable k       as integer.
define            variable vpar    as character.
define            variable errlist as character extent 37.
define new shared temp-table tmpl like trxtmpl.
define new shared temp-table cdf like trxcdf.
define buffer btmpl for tmpl.
define            variable vgl       as integer.
define            variable vref      as integer.
define            variable vsign     as character.
define new shared variable jh-ref    as char .
define new shared variable jh-sub    as char .
define new shared variable hsts      as integer.
define new shared variable hparty    as character.
define new shared variable hpoint    as integer.
define new shared variable hdepart   as integer.
define new shared variable hsts-f    as character.
define new shared variable hparty-f  as character.
define new shared variable hpoint-f  as character.
define new shared variable hdepart-f as character.
define new shared variable hopt      as character.
define new shared variable hmult     as integer.
define new shared variable hopt-f    as character.
define new shared variable hmult-f   as character.
define buffer cas for sysc.
/*define buffer buy for sysc.
define buffer sel for sysc.*/
define variable N        as integer.
define variable crec     as recid.
define variable vdecpnt  like crc.decpnt.
define variable vrate    like trxtmpl.rate.
define variable vamt     like trxtmpl.amt.
define variable vcrc     like crc.crc.
define variable vmarg    like trxtmpl.amt.
define variable selbuy   as character.
define variable vdec     as integer.
define variable repl     as integer.
define variable nl       as integer.
define variable NN       as integer.
define variable vrem     as character.
define variable o        as integer.
define variable i-sta1   as integer   init 0.
define variable v-cod    as character.


define variable vcrc1    as integer.
define variable vcrc2    as integer.
define variable cas1     as logi.
define variable cas2     as logi.
define variable amt1     as decimal.
define variable amt2     as decimal.
define variable vrat1    as decimal   decimals 10.
define variable vrat2    as decimal   decimals 10.
define variable coef1    as integer.
define variable coef2    as integer.
define variable marg1    as decimal.
define variable marg2    as decimal.
define variable v-supusr as character init "bankadm,superman".
/*def var v-tempint as int.*/
def var v-tempstr as char.
def var v-rbank as char.
def var v-count as int.

def buffer buf-aas for aas.
def buffer buf-aaa1 for aaa.
def buffer buf-cif for cif.
def buffer buf-crc for crc.

define temp-table temp
    field gl  like gl.gl
    field crc like gl.crc
    field ost as decimal format 'zzzzzzzzzzzzzzzzzzzz9.99-'.

/*
errlist[18] = "Specified TRX code doesn't exist.".
errlist[19] = "Incorrect parameter list.".
errlist[20] = "Template error.".
errlist[28] = "G/L for specified level not defined.".
errlist[29] = "Unexpected end of parameter list.".
errlist[30] = "One or more extra params in paramlist.".
errlist[36] = "We don't buy this currency.".
errlist[37] = "We don't sell this currency.".
*/
errlist[18] = "Указанный шаблон не найден.".
errlist[19] = "Неправильный список параметров.".
errlist[20] = "Ошибка шаблона.".
errlist[28] = "Не определена Г/К для указанного уровня.".
errlist[29] = "Недостаточное количество параметров шаблона.".
errlist[30] = "Слишком много параметров для проводки.".
errlist[36] = "Банк не покупает эту валюту.".
errlist[37] = "Банк не продает эту валюту.".

find first sysc where sysc.sysc = "supusr" no-lock no-error.
if available sysc then v-supusr = sysc.chval.

find cas where cas.sysc = "cashgl" no-lock no-error.
/*find buy where buy.sysc = "buygl" no-lock no-error.
find sel where sel.sysc = "selgl" no-lock no-error.*/
{convgl.i "bank"}

jh-ref = vhref .
jh-sub = vsub .

find last trxtmpl where trxtmpl.code = trxcode no-lock no-error.
if not available trxtmpl then
do:
    rcode = 18.
    rdes = errlist[18] + ": " + trxcode + ".".
    return.
end.
else nl = trxtmpl.ln.

find trxhead where trxhead.code = integer(substring(trxtmpl.code,4))
    and trxhead.system = trxtmpl.system no-lock.

hopt = trxhead.opt.

/*1)Status*/
if trxhead.sts-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Status)-требуется.".
        return.
    end.
    hsts = integer(vpar) no-error.
    if error-status:error then
    do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Status)=" + vpar + "-нужен тип integer.".
        hsts = 0.
        return.
    end.
    hsts-f = "d".
end.
else
do:
    hsts = trxhead.sts.
    hsts-f = "d".
end.
/*2)Party*/
if trxhead.party-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Party)-требуется.".
        return.
    end.
    hparty = vpar.
    hparty-f = "d".
end.
else
do:
    hparty = trxhead.party.
    hparty-f = "d".
end.
/*3)Point*/
if trxhead.point-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Point)-требуется.".
        return.
    end.
    hpoint = integer(vpar) no-error.
    if error-status:error then
    do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Point)=" + vpar + "-нужен тип integer.".
        hpoint = 0.
        return.
    end.
    hpoint-f = "d".
end.
else
do:
    hpoint = trxhead.point.
    hpoint-f = trxhead.point-f.
end.
/*4)Depart*/
if trxhead.depart-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Depart)-требуется.".
        return.
    end.
    hdepart = integer(vpar) no-error.
    if error-status:error then
    do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Depart)=" + vpar + "-нужен тип integer.".
        hdepart = 0.
        return.
    end.
    hdepart-f = "d".
end.
else
do:
    hdepart = trxhead.depart.
    hdepart-f = trxhead.depart-f.
end.
/*4a)Multiplication coefficient*/
if trxhead.mult-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Repl)-требуется.".
        return.
    end.
    hmult = integer(vpar) no-error.
    if error-status:error then
    do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + "Nr." + string(i)
            + "(Repl)=" + vpar + "-нужен тип integer.".
        hmult = 0.
        return.
    end.
    hmult-f = "d".
end.
else
do:
    hmult = trxhead.mult.
    hmult-f = trxhead.mult-f.
end.

/*4b)Optimization parameter*/
if trxhead.opt-f = "r" then
do:
    i = i + 1.
    vpar = entry(i,vparam,vdel) no-error.
    if error-status:error then
    do:
        rcode = 29.
        rdes = errlist[rcode] + ":Tmpl" + trxcode
            + ",Nr." + string(i)
            + "(Opti)-требуется.".
        return.
    end.
    if vpar <> "+" or vpar <> "-" then
    do:
        rcode = 19.
        rdes = errlist[rcode] + ":Tmpl=" + trxcode
            + ",Nr." + string(i)
            + "(Opti)=" + vpar + "-'+' or '-' expected.".
        return.
    end.
    hopt = vpar.
    hopt-f = "d".
end.
else
do:
    hopt = trxhead.opt.
    hopt-f = trxhead.opt-f.
end.

/*Transaction template parametrisation.*/
repeat repl = 1 to hmult:
    v-count = 0.
    for each trxtmpl where trxtmpl.code = trxcode no-lock:
        v-count = v-count + 1.
        create tmpl.
        if repl = 1 then tmpl.ln = trxtmpl.ln.
        else tmpl.ln = trxtmpl.ln + (repl - 1) * nl.
        tmpl.code = trxtmpl.code.
        tmpl.system = trxtmpl.system.
        /*5)Amount*/
        if trxtmpl.amt-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(Amt)-требуется.".
                return.
            end.
            tmpl.amt = decimal(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(Amt)=" + vpar + "-нужен тип decimal.".
                return.
            end.
            tmpl.amt-f = "d".
        end.
        else
        do:
            tmpl.amt = trxtmpl.amt.
            NN = integer(substr(trxtmpl.amt-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.amt-f = string(NN,"9999") + substring(trxtmpl.amt-f,2,1).
            end.
            else tmpl.amt-f = trxtmpl.amt-f.
        end.
        /*6)Currency*/
        if trxtmpl.crc-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(CRC)-требуется.".
                return.
            end.
            tmpl.crc = integer(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(CRC)=" + vpar + "-нужен тип integer.".
                return.
            end.
            tmpl.crc-f = "d".
        end.
        else
        do:
            tmpl.crc = trxtmpl.crc.
            tmpl.crc-f = trxtmpl.crc-f.
        end.
        /*7)Rate*/
        if trxtmpl.rate-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(Rate)-требуется.".
                return.
            end.
            tmpl.rate = decimal(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(Rate)=" + vpar + "-нужен тип decimal.".
                return.
            end.
            tmpl.rate-f = "d".
        end.
        else
        do:
            tmpl.rate = trxtmpl.rate.
            NN = integer(substr(trxtmpl.rate-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.rate-f = string(NN,"9999") + substring(trxtmpl.rate-f,2,1).
            end.
            else tmpl.rate-f = trxtmpl.rate-f.
        end.
        /*8)Debet G/L*/
        if trxtmpl.drgl-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(DR-GL)-требуется.".
                return.
            end.
            tmpl.drgl = integer(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(DR-GL)=" + vpar + "-нужен тип integer.".
                return.
            end.
            tmpl.drgl-f = "d".
        end.
        else
        do:
            tmpl.drgl = trxtmpl.drgl.
            NN = integer(substr(trxtmpl.drgl-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.drgl-f = string(NN,"9999") + substring(trxtmpl.drgl-f,2,1).
            end.
            else tmpl.drgl-f = trxtmpl.drgl-f.
        end.

        /*9)Debet subledger type*/
        if trxtmpl.drsub-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(DR-SUB)-требуется.".
                return.
            end.
            tmpl.drsub = vpar.
            if tmpl.drsub = ? then tmpl.drsub = "".
            tmpl.drsub-f = "d".
        end.
        else
        do:
            tmpl.drsub = trxtmpl.drsub.
            NN = integer(substr(trxtmpl.drsub-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.drsub-f = string(NN,"9999") + substring(trxtmpl.drsub-f,2,1).
            end.
            else tmpl.drsub-f = trxtmpl.drsub-f.
        end.
        /*9a)Debet subledger level*/
        if trxtmpl.dev-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(Dev)-требуется.".
                return.
            end.
            tmpl.dev = integer(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(Dev)=" + vpar + "-нужен тип integer.".
                return.
            end.
            tmpl.dev-f = "d".
        end.
        else
        do:
            tmpl.dev = trxtmpl.dev.
            NN = integer(substr(trxtmpl.dev-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.dev-f = string(NN,"9999") + substring(trxtmpl.dev-f,2,1).
            end.
            else tmpl.dev-f = trxtmpl.dev-f.
        end.
        /*10)Debet account*/
        if trxtmpl.dracc-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(DR-ACC)-требуется.".
                return.
            end.
            tmpl.dracc = vpar.
            if tmpl.dracc = ? then tmpl.dracc = "".
            tmpl.dracc-f = "d".
        end.
        else
        do:
            tmpl.dracc = trxtmpl.dracc.
            NN = integer(substr(trxtmpl.dracc-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.dracc-f = string(NN,"9999") + substring(trxtmpl.dracc-f,2,1).
            end.
            else tmpl.dracc-f = trxtmpl.dracc-f.
        end.
        /*11)Credit G/L*/
        if trxtmpl.crgl-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(CR-GL)-требуется.".
                return.
            end.
            tmpl.crgl = integer(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(CR-GL)=" + vpar + "-нужен тип integer.".
                return.
            end.
            tmpl.crgl-f = "d".
        end.
        else
        do:
            tmpl.crgl = trxtmpl.crgl.
            NN = integer(substr(trxtmpl.crgl-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.crgl-f = string(NN,"9999") + substring(trxtmpl.crgl-f,2,1).
            end.
            else tmpl.crgl-f = trxtmpl.crgl-f.
        end.
        /*12)Credit subledger type*/
        if trxtmpl.crsub-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(CR-SUB)-требуется.".
                return.
            end.
            tmpl.crsub = vpar.
            if tmpl.crsub = ? then tmpl.crsub = "".
            tmpl.crsub-f = "d".
        end.
        else
        do:
            tmpl.crsub = trxtmpl.crsub.
            NN = integer(substr(trxtmpl.crsub-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.crsub-f = string(NN,"9999") + substring(trxtmpl.crsub-f,2,1).
            end.
            else tmpl.crsub-f = trxtmpl.crsub-f.
        end.
        /*12a)Credit subledger level*/
        if trxtmpl.cev-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(Cev)-требуется.".
                return.
            end.
            tmpl.cev = integer(vpar) no-error.
            if error-status:error then
            do:
                rcode = 19.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr." + string(i)
                    + "(Cev)=" + vpar + "-нужен тип integer.".
                return.
            end.
            tmpl.cev-f = "d".
        end.
        else
        do:
            tmpl.cev = trxtmpl.cev.
            NN = integer(substr(trxtmpl.cev-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.cev-f = string(NN,"9999") + substring(trxtmpl.cev-f,2,1).
            end.
            else tmpl.cev-f = trxtmpl.cev-f.
        end.
        /*13)Credit account*/
        if trxtmpl.cracc-f = "r" then
        do:
            i = i + 1.
            vpar = entry(i,vparam,vdel) no-error.
            if error-status:error then
            do:
                rcode = 29.
                rdes = errlist[rcode] + ":Tmpl=" + trxcode
                    + ",Ln=" + string(tmpl.ln)
                    + ",Re=" + string(repl)
                    + ",Nr=" + string(i)
                    + "(CR-ACC)-требуется.".
                return.
            end.
            tmpl.cracc = vpar.
            if tmpl.cracc = ? then tmpl.cracc = "".
            tmpl.cracc-f = "d".
        end.
        else
        do:
            tmpl.cracc = trxtmpl.cracc.
            NN = integer(substr(trxtmpl.cracc-f,1,1)) no-error.
            if not error-status:error then
            do:
                NN = NN + (repl - 1) * nl.
                tmpl.cracc-f = string(NN,"9999") + substring(trxtmpl.cracc-f,2,1).
            end.
            else tmpl.cracc-f = trxtmpl.cracc-f.
        end.

        /* ------  22.11.2001 sasco - если надо, то выводит спец. инструкции ------ */
        if tmpl.cracc <> "" and lookup(g-ofc, v-supusr) = 0 /* суперюзерам ничего не сообщаем ! */
            then
        do:
            if can-find(first aas where aas.aaa = tmpl.cracc no-lock)
                then
            do:
                display "На счет наложены специальные инструкции:" skip with frame aash.
                for each aas where aas.aaa = tmpl.cracc no-lock:
                    display aas.payee no-labels skip with frame aasl.
                end.
                pause 20.
                hide frame aash.
                hide frame aasl.
            end.
            pause 0.
        end.
        /* ------  22.11.2001       ----------------------------------------------- */

        /* - - - - - - - - - - - - - - - - - - - - - - - - */


        /* ------  30/11/2011 evseev       ----------------------------------------------- */
        /*evseev*/
        if tmpl.cracc <> "" then
        do:
            find first buf-aas where buf-aas.aaa = tmpl.cracc and lookup(string(buf-aas.sta), "4,5,15,6,7,8,9") <> 0 and buf-aas.ln <> 7777777  no-lock no-error.
            /*"11,2,4,5,15,6,7,8,9,16,17,0,3,1"*/
            if avail buf-aas then
            do:
                find first buf-aaa1 where buf-aaa1.aaa = buf-aas.aaa no-lock no-error.
                if avail buf-aaa1 then
                do:
                    find first buf-crc where buf-crc.crc = buf-aaa1.crc no-lock no-error.
                    if avail buf-crc then
                    do:
                        find first buf-cif where buf-cif.cif = buf-aaa1.cif no-lock no-error.
                        if avail buf-cif then
                        do:
                            run mail("id00787@metrocombank.kz", "BANK <abpk@metrocombank.kz>",
                                "Поступление средств на заблокированный счет TRXGEN",
                                "Поступила сумма  " + string(tmpl.amt) + " " + buf-crc.code + ", " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aas.aaa,
                                "", "", "").

                            find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                            if avail sysc then
                               run mail("oper.dep@fortebank.com; " + entry(5, sysc.chval, "|"), "BANK <abpk@metrocombank.kz>",
                                "Поступление средств на заблокированный счет",
                                "Поступила сумма  " + string(tmpl.amt) + " " + buf-crc.code + ", " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aas.aaa,
                                "", "", "").
                            else
                               run mail("oper.dep@fortebank.com", "|"), "BANK <abpk@metrocombank.kz>",
                                "Поступление средств на заблокированный счет",
                                "Поступила сумма  " + string(tmpl.amt) + " " + buf-crc.code + ", " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aas.aaa,
                                "", "", "").
                        end.
                    end.
                end.
            end.
        end.
        /*evseev*/





        /* 28/05/2002 sasco - check if 100100 is blocked   */
        if (tmpl.drgl = cas.inval) or (tmpl.crgl = cas.inval)
            then
        do:
            find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
            if not available sysc then
            do:
                create sysc.
                update sysc.sysc = 'CASVOD'
                    sysc.loval = no
                    sysc.daval = g-today
                    sysc.des = "Признак блокировки свода кассы".
            end.
            if sysc.daval <> g-today then
            do:
                find sysc where sysc.sysc = 'CASVOD' no-error.
                sysc.daval = g-today.
                sysc.loval = no.
            end.
            if sysc.loval = yes then
            do:
                message "Свод кассы завершен, исполнение проводки невозможно на счет " + string(cas.inval)
                    view-as alert-box.
                rcode = 101.
                rdes = "Счет Г/К "  + string(cas.inval)  +  " заблокирован " + string (g-today).
                return.
            end.
        end.
        /* - - - - - - - - - - - - - - - - - - - - - - - - */

        /*14)Remarks*/
        do k = 1 to 5:
            if trxtmpl.rem-f[k] = "r" then
            do:
                i = i + 1.
                vpar = entry(i,vparam,vdel) no-error.
                if error-status:error then
                do:
                    rcode = 29.
                    rdes = errlist[rcode] + ":Tmpl=" + trxcode
                        + ",Ln=" + string(tmpl.ln)
                        + ",Re=" + string(repl)
                        + ",Nr=" + string(i)
                        + "(Rem[" + string(k) + "])-требуется.".
                    return.
                end.
                tmpl.rem[k] = vpar.
                tmpl.rem-f[k] = "d".
            end.
            else
            do:
                tmpl.rem[k] = trxtmpl.rem[k].
                tmpl.rem-f[k] = trxtmpl.rem-f[k].
            end.
        end.
        /*Codificators temp-table records creation according to templates*/
        for each trxcdf where trxcdf.trxcode = trxtmpl.code
            and trxcdf.trxln = trxtmpl.ln:
            create cdf.
            cdf.trxcode = trxcdf.trxcode.
            cdf.trxln = tmpl.ln.
            cdf.codfr = trxcdf.codfr.
            if trxcdf.drcod-f = "d" or trxcdf.drcod-f = "" then
            do:
                cdf.drcod = trxcdf.drcod.
                cdf.drcod-f = trxcdf.drcod-f.
            end.
            else
            do:
                if trxcdf.drcod-f = "r" then
                do:
                    i = i + 1.
                    vpar = entry(i,vparam,vdel) no-error.
                    if error-status:error then
                    do:
                        rcode = 29.
                        rdes = errlist[rcode] + ":Tmpl=" + trxcode
                            + ",Ln=" + string(tmpl.ln)
                            + ",Re=" + string(repl)
                            + ",Nr=" + string(i)
                            + "Codific." + trxcdf.codfr
                            + "DrCode - требуется".
                        return.
                    end.
                    cdf.drcod = vpar.
                    if cdf.drcod = ? then cdf.drcod = "".
                    cdf.drcod-f = "d".
                end.
                else
                do:
                    cdf.drcod = trxcdf.drcod.
                    NN = integer(substr(trxcdf.drcod-f,1,1)) no-error.
                    if not error-status:error then
                    do:
                        NN = NN + (repl - 1) * nl.
                        cdf.drcod-f = string(NN,"9999") + substring(trxcdf.drcod-f,2,1).
                    end.
                    else cdf.drcod-f = trxcdf.drcod-f.
                end.
            end.
            if trxcdf.crcode-f = "d" or trxcdf.crcode-f = "" then
            do:
                cdf.crcod = trxcdf.crcod.
                cdf.crcode-f = trxcdf.crcode-f.
            end.
            else
            do:
                if trxcdf.crcode-f = "r" then
                do:
                    i = i + 1.
                    vpar = entry(i,vparam,vdel) no-error.
                    if error-status:error then
                    do:
                        rcode = 29.
                        rdes = errlist[rcode] + ":Tmpl=" + trxcode
                            + ",Ln=" + string(tmpl.ln)
                            + ",Re=" + string(repl)
                            + ",Nr=" + string(i)
                            + "Codific." + trxcdf.codfr
                            + " CrCode - требуется".
                        return.
                    end.
                    cdf.crcod = vpar.
                    if cdf.crcod = ? then cdf.crcod = "".
                    cdf.crcode-f = "d".
                end.
                else
                do:
                    cdf.crcod = trxcdf.crcod.
                    NN = integer(substr(trxcdf.crcode-f,1,1)) no-error.
                    if not error-status:error then
                    do:
                        NN = NN + (repl - 1) * nl.
                        cdf.crcode-f = string(NN,"9999") + substring(trxcdf.crcode-f,2,1).
                    end.
                    else cdf.crcode-f = trxcdf.crcode-f.
                end.
            end.
        end.


        if v-bin then do:
           run savelog('trxgen0',string(v-count) + ' - cracc ' + tmpl.cracc + ' - dracc ' + tmpl.dracc ).
           find first buf-aaa1 where buf-aaa1.aaa = tmpl.cracc no-lock no-error.
           if avail buf-aaa1 then do:
              if lookup(string(buf-aaa1.gl),'220310,220420,220430,220520,220530,220620,220720,221510,221710,221910') > 0 then do:
                 find first buf-cif where buf-cif.cif = buf-aaa1.cif no-lock no-error.
                 if avail buf-cif then do:
                    if not (lookup(string(buf-aaa1.gl),'220620,220720,221510,221710,221910') > 0 and trim(buf-cif.geo) = '022') then do:
                        if trim(buf-cif.bin) = '' then do:
                           /*find first bin where bin.rnn = buf-cif.jss no-lock no-error.
                           if not avail bin then do:*/
                              run savelog('trxgen0','-------' + tmpl.cracc + ' отсутствует ИИН/БИН').
                              if lookup(g-ofc, v-supusr) = 0 then message "Транзакция невозможна!  У  " + buf-cif.cif + " отсутствует ИИН/БИН" view-as alert-box.
                              rcode = 102.
                              rdes = " У  " + buf-cif.cif + " отсутствует ИИН/БИН".

                              find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                              if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                              run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                              run mail("id00787@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").


                              return.
                           /*end.*/
                        end.
                        if trim(buf-cif.bin) <> '' and chk12_innbin(buf-cif.bin) = no then do:
                            run savelog('trxgen0','-------' + tmpl.cracc + ' ошибка в ключе ИИН/БИН').
                            if lookup(g-ofc, v-supusr) = 0 then message "Транзакция невозможна!  У  " + buf-cif.cif + " ошибка в ключе ИИН/БИН" view-as alert-box.
                            rcode = 102.
                            rdes = " У  " + buf-cif.cif + " ошибка в ключе ИИН/БИН".

                            find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                            if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                            run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                            run mail("id00787@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").

                            return.
                        end.
                    end.
                 end.
              end.
           end.
           find first buf-aaa1 where buf-aaa1.aaa = tmpl.dracc no-lock no-error.
           if avail buf-aaa1 then do:
              if lookup(string(buf-aaa1.gl),'220310,220420,220430,220520,220530,220620,220720,221510,221710,221910') > 0 then do:
                  find first buf-cif where buf-cif.cif = buf-aaa1.cif no-lock no-error.
                  if avail buf-cif then do:
                     if not (lookup(string(buf-aaa1.gl),'220620,220720,221510,221710,221910') > 0 and trim(buf-cif.geo) = '022') then do:
                         if trim(buf-cif.bin) = '' then do:
                            /*find first bin where bin.rnn = buf-cif.jss no-lock no-error.
                            if not avail bin then do:*/
                               run savelog('trxgen0','-------' + tmpl.dracc + ' отсутствует ИИН/БИН').
                               if lookup(g-ofc, v-supusr) = 0 then message "Транзакция невозможна!  У  " + buf-cif.cif + " отсутствует ИИН/БИН" view-as alert-box.
                               rcode = 102.
                               rdes = " У  " + buf-cif.cif + " отсутствует ИИН/БИН".

                               find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                               if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                               run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                               run mail("id00787@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с отсутствием ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").

                               return.
                            /*end.*/
                         end.
                         if trim(buf-cif.bin) <> '' and chk12_innbin(buf-cif.bin) = no then do:
                             run savelog('trxgen0','-------' + tmpl.dracc + ' ошибка в ключе ИИН/БИН').
                             if lookup(g-ofc, v-supusr) = 0 then message "Транзакция невозможна!  У  " + buf-cif.cif + " ошибка в ключе ИИН/БИН" view-as alert-box.
                             rcode = 102.
                             rdes = " У  " + buf-cif.cif + " ошибка в ключе ИИН/БИН".

                             find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
                             if avail sysc then run mail(entry(5, sysc.chval, "|"), "<BIN@metrocombank.kz>","ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                             run mail("oper.dep@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").
                             run mail("id00787@fortebank.com", "<BIN@metrocombank.kz>", "ИИН/БИН не верный", "Операция не возможна в связи с неверным ИИН/БИН " + buf-cif.cif + ", " + trim(buf-cif.prefix) + " " + trim(buf-cif.name) + ", " + buf-aaa1.aaa , "", "","").

                             return.
                         end.
                     end.
                  end.
              end.
           end.
        end.

    end. /*For each trxtmpl*/
end. /*Repeat mult*/

i = i + 1.
vpar = entry(i,vparam,vdel) no-error.
if error-status:error = false and vpar <> "" then
do:
    rcode = 30.
    rdes = errlist[rcode] + ":Tmpl=" + trxcode
        + ",Nr=" + string(i)
        + "(???)=" + vpar + "-лишнее.".
    return.
end.


/*******************************************************/
/*Transaction template parameter's automatic evaluation*/
/*******************************************************/

if hsts-f <> "d" then
do:
    run stsauto.
    if rcode > 0 then return.
end.
if hparty-f <> "d" then
do:
    run partyauto.
    if rcode > 0 then return.
end.
if hpoint-f <> "d" then
do:
    run pointauto.
    if rcode > 0 then return.
end.
if hdepart-f <> "d" then
do:
    run departauto.
    if rcode > 0 then return.
end.

for each temp.
    delete temp.
end.

for each tmpl: /* AUTO */



    if tmpl.amt-f <> "d" then
    do:
        run amtauto.
        if rcode > 0 then return.
    end.
    if tmpl.rate-f <> "d" then
    do:
        run rateauto.
        if rcode > 0 then return.
    end.
    if tmpl.crc-f <> "d" then
    do:
        run crcauto.
        if rcode > 0 then return.
    end.

    /* подстановка корректных счетов конвертации */
    if tmpl.drgl-f = "d" and tmpl.drgl = 1 then tmpl.drgl = getConvGL(tmpl.crc,"D").
    if tmpl.crgl-f = "d" and tmpl.crgl = 1 then tmpl.crgl = getConvGL(tmpl.crc,"C").
    /* подстановка корректных счетов конвертации - end */

    if tmpl.drgl-f <> "d" then
    do:
        run drglauto.
        if rcode > 0 then return.
    end.
    if tmpl.drsub-f <> "d" then
    do:
        run drsubauto.
        if rcode > 0 then return.
    end.
    if tmpl.dracc-f <> "d" then
    do:
        run draccauto.
        if rcode > 0 then return.
    end.
    if tmpl.crgl-f <> "d" then
    do:
        run crglauto.
        if rcode > 0 then return.
    end.
    if tmpl.crsub-f <> "d" then
    do:
        run crsubauto.
        if rcode > 0 then return.
    end.
    if tmpl.cracc-f <> "d" then
    do:
        run craccauto.
        if rcode > 0 then return.
    end.
    repeat o = 1 to 5:
        if tmpl.rem-f[o] <> "d" then
        do:
            run remauto.
            if rcode > 0 then return.
        end.
    end.

    for each cdf where cdf.trxcode = tmpl.code
        and cdf.trxln = tmpl.ln:
        if cdf.drcod-f <> "d" and cdf.drcod-f <> "" then
        do:
            run drcodeauto.
            if rcode > 0 then return.
        end.
        if cdf.crcode-f <> "d" and cdf.crcode-f <> "" then
        do:
            run crcodeauto.
            if rcode > 0 then return.
        end.
    end.



    /*------------------- 08/04/2003 - kanat - Проверка лимита по суммам по дебетовым операциям по счетам клиентов -------------------------*/

    define variable output_choice as logical.
    define variable s_acc_send    as character.
    define variable d_sum_dracc   as decimal.

    if tmpl.drsub = 'CIF' then
    do:
        s_acc_send = tmpl.dracc.
        d_sum_dracc = tmpl.amt.

        find first debet_restr where debet_restr.aaa = s_acc_send
            use-index aaa_index no-lock no-error.

        if available debet_restr then
        do:
            run sumin(s_acc_send, d_sum_dracc, output output_choice).
            if output_choice then
            do:
                if g-ofc = 'bankadm' then
                do:
                    rcode = 0.
                    rdes = "По счету CIF " + string(tmpl.dracc) + " дебетовые обороты превышают заданный лимит по счету".
                    return.
                end.
                else
                do:
                    rcode = 102.
                    rdes = "По счету CIF " + string(tmpl.dracc) + " дебетовые обороты превышают заданный лимит по счету".
                    return.
                end.
            end.
        end.
    end.

    /*--------------------------------------------------------------------------------------------------------------------------------------*/

    /*u00121 13/09/2005*Проверка количества разрешенных дебетовых проводок по биометрическому контролю*************************************************************/
    define variable o-res          as log init true.
    define variable bio_scan_dracc as log init false. /*u00121 13/09/05*/
    if tmpl.drsub = 'CIF' and not bio_scan_dracc then
    do:
        run bioconjh(input tmpl.dracc, output o-res). /*u00121 13/09/2005*/
        if not o-res then
        do:
            rcode = 102.
            rdes = "Клиент на биометрическом контроле!Нет разрешенных проводок!!!Операция прекращена! ".
            return.
        end.
        else
            bio_scan_dracc = true.
    end.
    /*u00121 13/09/2005********************************************************************************************************************************************/


    /* ------------------09/01/03 nataly Проверка остатка счета на >=0 --------------------

    if lookup(g-ofc, v-supusr) = 0  then do:  /* транзакции суперюзеров не проверяем! */

     def var v-dam as decimal init 0.
     def var v-cam as decimal init 0.
     def var v-ost as decimal init 0.


     /* 1). ДЕБЕТ проверка остатка счета на >= 0   после совершения транзакции */
     find gl where gl.gl = tmpl.drgl  no-lock no-error.
     if gl.subled = ""  and not isConvGL(gl.gl) /*gl.gl <> sel.inval*/  and gl.gl <> 499970 and gl.gl <> 359911  then do:

     find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.drgl) and d-cod  = 'gldic'  no-lock no-error.
     if available sub-cod  then do:

     find temp where temp.gl = tmpl.drgl and temp.crc = tmpl.crc  no-error.
     if not available temp then do:

    /*and sub-cod.ccode = 'msc'*/
     for each jl where jl.gl =  tmpl.drgl and jl.crc = tmpl.crc and jl.jdt = g-today no-lock.
         v-dam = v-dam + jl.dam.
         v-cam = v-cam + jl.cam.
     end.

     find glbal where glbal.gl = tmpl.drgl  and glbal.crc = tmpl.crc  no-lock no-error.

     if available glbal then do:
      find crc where crc.crc = tmpl.crc no-lock no-error.
      if gl.type = 'A' or  gl.type = 'E'  then  v-ost = glbal.bal  + (v-dam - v-cam) + tmpl.amt.
      else v-ost = glbal.bal  + (v-cam - v-dam) - tmpl.amt.
     end. /*if available glbal*/
     end. /*if no temp*/
     else do:
       if gl.type = 'A' or  gl.type = 'E' then  temp.ost =  temp.ost  + tmpl.amt.
        else temp.ost = temp.ost - tmpl.amt.
        v-ost = temp.ost.
     end.

      /*message '1-1 ' tmpl.ln tmpl.drgl tmpl.crgl v-ost. pause 400.*/
       if v-ost < 0 and  sub-cod.ccode = 'msc' then do:
         message "Транзакция невозможна!" skip
        "  Остаток по нереверсивному счету ГК " + string(tmpl.drgl) +
        " становится = "  + string(v-ost) + "  " +  string(crc.code) +  "  !"
         view-as alert-box.
         rcode = 102.
         rdes = "На счете Г/К " + string(tmpl.drgl) + "  остаток =  "
         + string(v-ost) + "  " +  string(crc.code) .
         return.
      end.
      if v-ost > 0 and  sub-cod.ccode <> 'msc' then do:
         message "Транзакция невозможна!" skip
        "  Остаток по реверсивному счету ГК " + string(tmpl.drgl) +
        " становится = "  + string(v-ost) + "  " +  string(crc.code) +  "  !"
         view-as alert-box.
         rcode = 102.
         rdes = "На счете Г/К " + string(tmpl.drgl) + "  остаток =  "
         + string(v-ost) + "  " +  string(crc.code) .
         return.
      end.
      /*корректировка остатков после транзакции*/
        if not available temp then do:
          create temp. temp.gl = tmpl.drgl.  temp.crc = tmpl.crc. temp.ost = v-ost.
        end.
      /*корректировка остатков после транзакции*/
      /*message '1-2 ' temp.gl temp.ost. pause 400.*/
     end.  /*sub-cod*/
    end. /* gl.subled = "" */

      v-dam = 0. v-cam = 0. v-ost = 0.
     /* 2). КРЕДИТ проверка остатка счета на >= 0  после совершения транзакции */
     find gl where gl.gl = tmpl.crgl  no-lock no-error.
     if gl.subled = ""  and not isConvGL(gl.gl) /* gl.gl <> sel.inval*/ and gl.gl <> 499970 and gl.gl <> 359911  then do:

     find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.crgl) and d-cod  = 'gldic' no-lock  no-error .
     if available sub-cod then do:

     find temp where temp.gl = tmpl.crgl and temp.crc = tmpl.crc no-error.
     if not available temp then do:

     for each jl where jl.gl =  tmpl.crgl and jl.crc = tmpl.crc and jl.jdt = g-today no-lock.
         v-dam = v-dam + jl.dam.
         v-cam = v-cam + jl.cam.
     end.

     find glbal where glbal.gl = tmpl.crgl  and glbal.crc = tmpl.crc  no-lock no-error.

     if available glbal then do:
      find crc where crc.crc = tmpl.crc no-lock  no-error.
      if gl.type = 'A' or  gl.type = 'E'  then  v-ost = glbal.bal  + (v-dam - v-cam) - tmpl.amt.
      else v-ost = glbal.bal  + (v-cam - v-dam) + tmpl.amt.
     end. /*if available glbal*/
    end. /*no temp*/
     else do:
       if gl.type = 'A' or  gl.type = 'E' then  temp.ost =  temp.ost  - tmpl.amt.
        else temp.ost = temp.ost + tmpl.amt.
        v-ost = temp.ost.
     end.

    /*   message '2-1 '  tmpl.ln tmpl.drgl tmpl.crgl v-ost . pause 400.*/
       if v-ost < 0 and  sub-cod.ccode = 'msc' then do:
         message "Транзакция невозможна!" skip
        "  Остаток по нереверсивному счету ГК " + string(tmpl.crgl) +
        " становится = "  + string(v-ost) + "  " +  string(crc.code) +  "  !"
         view-as alert-box.
         rcode = 102.
         rdes = "На счете Г/К " + string(tmpl.crgl) + "  остаток =  "
         + string(v-ost) + "  " +  string(crc.code) .
         return.
      end.
       if v-ost > 0 and sub-cod.ccode <> 'msc' then do:
         message "Транзакция невозможна!" skip
        "  Остаток по реверсивному счету ГК " + string(tmpl.crgl) +
        " становится = "  + string(v-ost ) + "  " +  string(crc.code) +  "  !"
         view-as alert-box.
         rcode = 102.
         rdes = "На счете Г/К " + string(tmpl.crgl) + "  остаток =  "
         + string(v-ost) + "  " +  string(crc.code) .
         return.
      end.
      /*корректировка остатков после транзакции*/
        if not available temp then do:
          create temp. temp.gl = tmpl.crgl.  temp.crc = tmpl.crc. temp.ost = v-ost.
        end.
      /*корректировка остатков после транзакции*/
       /*message '2-2 '  temp.gl temp.ost . pause 400.*/
     end.  /*sub-cod*/
    end. /* gl.subled = "" */

    end.  /* lookup(g-ofc, v-supusr) = 0 */

     ------------------09/01/03 nataly--------------------*/


    release temp.

end. /*  for each tmpl AUTO */




for each tmpl:
    if tmpl.amt = 0 and tmpl.amt-f = "d" then delete tmpl.
end.

/* ---------23/11/2002 nataly - проверка если счет ГК закрыт ---------     */
find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.drgl) and d-cod  = 'clsa'  no-error.
if available sub-cod and sub-cod.ccode = '10' then
do:
    message "Транзакция невозможна!  Счет ГК " + string(tmpl.drgl) + " закрыт!"
        view-as alert-box.
    rcode = 102.
    rdes = "Счет Г/К " + string(tmpl.drgl) + " закрыт ".
    return.
end.

find sub-cod where sub-cod.sub = 'gld' and sub-cod.acc = string(tmpl.crgl) and d-cod  = 'clsa'  no-error.
if available sub-cod and sub-cod.ccode = '10' then
do:
    message "Транзакция невозможна!  Счет ГК " + string(tmpl.crgl) + " закрыт!"
        view-as alert-box.
    rcode = 102.
    rdes = "Счет Г/К " + string(tmpl.crgl) + " закрыт ".
    return.
end.
/* --------- 23/11/2002    ------------------------------------------------*/


/*
find first tmpl no-error .
if not avail tmpl then do:
          rcode = 999.
          rdes = "Error. Empty parameters ".
          return.
end.
*/

/* sasco - проверим, есть ли в проводке карточка дебитора */
/* если есть - переменные is-debitor = yes                */
/*                        is-active  = yes/no             */
/*                        re-open    = yes/no             */
/*                        deb-ost    = debls.ost          */
/*                        deb-damcam = tmpl.amt           */
/*                        v-grp      = debls.grp          */
/*                        v-ls       = debls.ls           */

if lookup(g-ofc, v-supusr) = 0 then
do:

  /* проверка контроля физ. лиц старшим менеджером */
  {trx-aaafiz.i}

  /* обработка дебиторов */
  {trx-debhist.i "new shared"}
  {trx-debcheck.i}

end.

run trxchk1(output rcode, output rdes).
if rcode > 0 then return.

/*********ДОБАВЛЕНО**********************************/

define variable t-sum as decimal init 0.
define buffer b1-aas for aas.
define buffer b2-aas for aas.
define buffer buf-aaar for aaar.
define buffer buf-aaa for aaa.
define variable x-other  as integer.
define variable qq       as character.
define variable v-allknp as character.
define variable v-dracc as character.

v-allknp = "911,921,931,941,951,961,912,922,932,942,952,962,913,923,933,943,953,963,914,924,934,944,954,964".

x-other = 0.
t-sum = 0.
/*пропускаем все кроме бюджетных*/
define buffer b-tmpl for tmpl.
define temp-table tmp_chnt
    field acc like aaa.aaa
    field sm  as decimal.
for each tmp_chnt:
    delete tmp_chnt.
end.

define temp-table tmp_sumaas
    field aaa like aaa.aaa
    field sum  as decimal.
for each tmp_sumaas:
    delete tmp_sumaas.
end.


for each tmpl no-lock where tmpl.amt > 0:
    v-dracc = tmpl.dracc.
    find aaa where aaa.aaa = v-dracc exclusive-lock no-error.
    if not available aaa then
    do:
        find last buf-aaar where buf-aaar.a1 = vhref and buf-aaar.a7 = tmpl.dracc no-lock no-error.
        if available buf-aaar then
        do:
            find aaa where aaa.aaa = buf-aaar.a5 exclusive-lock no-error.
            if available aaa then v-dracc = buf-aaar.a5.
        end.
    end.

    if available aaa then
    do:

        find last tmp_chnt where tmp_chnt.acc = v-dracc no-lock no-error.
        if available tmp_chnt then next.
        else
        do:
            create tmp_chnt.
            tmp_chnt.acc = v-dracc.
            tmp_chnt.sm.
        end.

        /* Обработка инкассовых прочих */
        find last aaar where aaar.a1 = vhref no-lock no-error.
        if not available aaar then
        do:
            for each b-tmpl no-lock where b-tmpl.amt > 0:
                find first remtrz where remtrz.remtrz = vhref no-lock  no-error.
                if avail remtrz then
                do:
                    qq = "0".
                    find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                    if avail sub-cod then find last b2-aas where b2-aas.aaa = v-dracc and lookup(string(b2-aas.sta), "15,9") <> 0 and
                                                 b2-aas.knp = substr(sub-cod.rcode, 7, 3) and decimal(b2-aas.docprim) >= remtrz.amt no-lock no-error.
                    if avail b2-aas and avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), v-allknp) <> 0  then
                    do:
                        i-sta1 = 0.
                        find last b2-aas where b2-aas.aaa = b-tmpl.dracc and b2-aas.sta = 2 no-lock no-error.
                        if avail b2-aas then
                        do:
                            find last b2-aas where b2-aas.aaa = b-tmpl.dracc and lookup(string(b2-aas.sta), "11,16") <> 0 no-lock no-error.
                            if avail b2-aas then i-sta1 = 1.
                        end.
                        if i-sta1 <> 1 then
                        do:
                            for each b2-aas where b2-aas.aaa = b-tmpl.dracc and lookup(string(b2-aas.sta), "15,9,2,11,16") <> 0 no-lock:
                                tmp_chnt.sm = tmp_chnt.sm + b2-aas.chkamt.
                            end.
                            for each b1-aas where b1-aas.aaa = v-dracc and lookup(string(b1-aas.sta), "4,5,6,7,8") <> 0 no-lock:
                                tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt /* - decimal(b1-aas.docprim) */.
                            end.
                        end.
                        x-other = 1.
                    end.
                end.
            end.
        end.

        /*if x-other = 0 then
        do:
            /* кроме бюд и пенс */
            find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 11 no-lock no-error.
            if available b1-aas then
            do:   /*and tmpl.cracc <> "000080900" */
                find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 2 no-lock no-error.
                if not available b1-aas then
                do:
                    if vhref begins "rmz" then
                    do:
                        find first remtrz where remtrz.remtrz = vhref no-lock  no-error.
                        find last aaar where aaar.a1 = vhref no-lock no-error.
                        if not available aaar and available remtrz then
                        do:
                            find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and
                                                     sub-cod.d-cod = "eknp" use-index dcod  exclusive-lock no-error.
                            if available sub-cod and (lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017") <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "PSJ")*/ or
                               lookup(substr(sub-cod.rcode, 7, 3), v-allknp) <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "TAX"*/ ) then
                            do:
                                /*Разблокировка*/
                                for each b1-aas where b1-aas.aaa = v-dracc and lookup(string(b1-aas.sta), "11,16,17") <> 0 no-lock:
                                    tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                                end.
                                /* также снимаем все инкассовые */
                                for each b1-aas where b1-aas.aaa = v-dracc and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                                    tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                                end.
                            end.
                        end.
                    end.
                end.
            end.
            else
            do:
                /*кроме бюджетных */
                find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 2 no-lock no-error.
                if available b1-aas then
                do:   /*and tmpl.cracc <> "000080900" */
                    find last b1-aas where b1-aas.aaa = aaa.aaa and lookup(string(b1-aas.sta), "11,16,17") <> 0 no-lock no-error.
                    if not available b1-aas then
                    do:
                        if vhref begins "rmz" then
                        do:
                            find last aaar where aaar.a1 = vhref no-lock no-error.
                            find first remtrz where remtrz.remtrz = vhref no-lock  no-error.
                            if not available aaar and available remtrz then
                            do:
                                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and
                                                         sub-cod.d-cod = "eknp" use-index dcod  exclusive-lock no-error.
                                if available sub-cod and lookup(substr(sub-cod.rcode, 7, 3), v-allknp) <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "TAX" */ then
                                do:
                                    /*Разблокировка*/
                                    for each b1-aas where b1-aas.aaa = v-dracc and b1-aas.sta = 2 no-lock:
                                        tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.

                /* кроме пенсионных */
                find last b1-aas where b1-aas.aaa = aaa.aaa and (b1-aas.sta = 16 or b1-aas.sta = 17) no-lock no-error.
                find last b2-aas where b2-aas.aaa = aaa.aaa and b2-aas.sta = 2 no-lock no-error.
                if not available b2-aas then
                do:
                    if available b1-aas then
                    do:   /*and tmpl.cracc <> "000080900" */
                        if vhref begins "rmz" then
                        do:
                            find first remtrz where remtrz.remtrz = vhref no-lock  no-error.
                            find last aaar where aaar.a1 = vhref no-lock no-error.
                            if not available aaar and available remtrz then
                            do:
                                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and
                                                         sub-cod.d-cod = "eknp" use-index dcod exclusive-lock no-error.
                                if available sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017") <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "PSJ" */ then
                                do:
                                    /*Разблокировка*/
                                    for each b1-aas where b1-aas.aaa = v-dracc and (b1-aas.sta = 16 or b1-aas.sta = 17) no-lock:
                                        tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                                    end.
                                end.
                            end.
                        end.
                    end.
                end.
                /* также снимаем все инкассовые */
                if tmp_chnt.sm > 0 then
                do:
                    for each b1-aas where b1-aas.aaa = v-dracc and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                        tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                    end.
                end.
                else
                    if tmp_chnt.sm = 0 then
                    do:
                        find last aaar where aaar.a1 = vhref no-lock no-error.
                        if not available aaar then
                        do:
                            find first remtrz where remtrz.remtrz = vhref no-lock no-error.
                            if available remtrz then
                            do:
                                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and
                                                         sub-cod.d-cod = "eknp" use-index dcod  exclusive-lock no-error.
                                if available sub-cod and lookup(substr(sub-cod.rcode, 7, 3), v-allknp) <> 0 then
                                do:
                                    i-sta1 = 0.
                                    find last b2-aas where b2-aas.aaa = b-tmpl.dracc and b2-aas.sta = 2 no-lock no-error.
                                    if available b2-aas then
                                    do:
                                        find last b2-aas where b2-aas.aaa = b-tmpl.dracc and lookup(string(b2-aas.sta), "11,16,17") <> 0 no-lock no-error.
                                        if available b2-aas then i-sta1 = 1.
                                    end.
                                    if i-sta1 <> 1 then
                                    do:
                                        for each b1-aas where b1-aas.aaa = v-dracc and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                                            tmp_chnt.sm = tmp_chnt.sm + b1-aas.chkamt.
                                        end.
                                    end.
                                end.
                            end.
                        end.
                    end.
            end.
        end.*/

        /*  aaa.hbal = aaa.hbal - t-sum. */
        if tmp_chnt.sm <= aaa.hbal and tmp_chnt.sm > 0 then
        do:
            run savelog("aaahbal", "trxgen0 1546; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
            aaa.hbal = aaa.hbal - tmp_chnt.sm.
            run savelog ("k2ink", aaa.aaa + "HBALMINUS" + string(tmp_chnt.sm)).
        end.
        else
        do:
            if tmp_chnt.sm > aaa.hbal then tmp_chnt.sm = 0.
        end.
    end.
end.
/***************************************/


/*  define stream str1.
    output stream str1 to value ("/data/9/export/testx.txt"). */





/*  Обработка инкассовых обязательных разморозка */
find last aaar where aaar.a1 = vhref no-lock no-error.
if available aaar then
do:
    for each tmp_chnt:
        delete tmp_chnt.
    end.

    for each tmpl no-lock where tmpl.amt > 0:
        if tmpl.dracc = aaar.a5 or (aaar.a7 <> '' and tmpl.dracc = aaar.a7)  then
        do: /*RMZ и счет совпадают разблокируем*/
            find last tmp_chnt where tmp_chnt.acc = aaar.a5 no-lock no-error.
            if available tmp_chnt then next.
            else
            do:
                create tmp_chnt.
                tmp_chnt.acc = aaar.a5.
                tmp_chnt.sm = 0.
            end.

            for each b2-aas where b2-aas.aaa = aaar.a5 and lookup(string(b2-aas.sta), "2,4,5,15,6,7,8,9,11,16,17") <> 0 or
                                  b2-aas.aaa = aaar.a5 and b2-aas.mn = "30037" no-lock:
                tmp_chnt.sm = tmp_chnt.sm + b2-aas.chkamt.
            end.
            find last aaa where aaa.aaa = aaar.a5 exclusive-lock no-error.
            if available aaa and tmp_chnt.sm > 0 then
            do:
                if tmp_chnt.sm <= aaa.hbal then
                do:
                    run savelog("aaahbal", "trxgen0 1595; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
                    aaa.hbal = aaa.hbal - tmp_chnt.sm.
                    run savelog ("k2ink", aaa.aaa + "HBALMINUS1").
                end. else run savelog("aaahbal", "trxgen0 1598; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(tmp_chnt.sm) + " ; не было разморозки.").

            end.
        end.
    end.
end. else do:
    if vhref begins "rmz" then do:
       find first sub-cod where sub-cod.acc = vhref and sub-cod.d-cod = 'eknp' no-lock no-error.
       /*v-tempint = 0. v-tempint = TRUNCATE(int(entry(3,sub-cod.rcode)) / 100,0) no-error.*/
       v-tempstr = "". v-tempstr = entry(3,sub-cod.rcode) no-error.
       find first remtrz where remtrz.remtrz = vhref no-lock  no-error.
       v-rbank = "". v-rbank = remtrz.rbank no-error.
       if (v-tempstr begins "9" and v-rbank = "KKMFKZ2A") or v-tempstr = "010"  or v-tempstr = "012"  or v-tempstr = "017"  or v-tempstr = "019"  then do:
            for each tmp_sumaas:
                delete tmp_sumaas.
            end.
            for each tmpl no-lock where tmpl.amt > 0:
                /*run savelog("test", "1605; " + tmpl.dracc + " ; " + string(tmpl.amt) + " ; " + string(vhref) ).*/
                find last tmp_sumaas where tmp_sumaas.aaa = tmpl.dracc no-lock no-error.
                if available tmp_sumaas then
                    next.
                else do:
                    create tmp_sumaas.
                    tmp_sumaas.aaa = tmpl.dracc.
                    tmp_sumaas.sum = 0.
                end.
                for each b2-aas where b2-aas.aaa = tmpl.dracc and lookup(string(b2-aas.sta), "2,4,5,15,6,7,8,9,11,16,17") <> 0 or
                                      b2-aas.aaa = tmpl.dracc and b2-aas.mn = "30037" no-lock:
                    tmp_sumaas.sum = tmp_sumaas.sum + b2-aas.chkamt.
                end.
                find last aaa where aaa.aaa = tmpl.dracc exclusive-lock no-error.
                if available aaa and tmp_sumaas.sum > 0 then do:
                    if tmp_sumaas.sum <= aaa.hbal then do:
                        run savelog("aaahbal", "trxgen0 1630; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal - tmp_sumaas.sum) + " ; " + string(tmp_sumaas.sum)).
                        aaa.hbal = aaa.hbal - tmp_sumaas.sum.
                    end. else run savelog("aaahbal", "trxgen0 1633; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(tmp_sumaas.sum) + " ; не было разморозки.").
                end.

            end.
       end.
    end.
end.
/* Обработка инкассовых */

/*********ДОБАВЛЕНО**********************************/


/*Проверка запрета операции*/
define variable v-dep as integer.
define buffer b4-aaa for aaa.
define buffer b4-lgr for lgr.
if lookup(g-ofc, v-supusr) = 0 then
do:
    for each tmpl no-lock where tmpl.amt > 0:
        find last b4-aaa where b4-aaa.aaa = tmpl.dracc no-lock no-error.
        if available b4-aaa then
        do:
            find last b4-lgr where b4-lgr.lgr = b4-aaa.lgr no-lock no-error.
            if b4-lgr.led = "TDA" then
            do:

                find last cif where cif.cif = b4-aaa.cif no-lock no-error.
                if available cif then
                do:
                    find last pipl where pipl.cif = b4-aaa.cif no-lock no-error.
                    if available pipl  then
                    do:
                        if ((g-today - cif.expdt) / 365) < 14 and cif.name <> "" then
                        do:
                            run sel2 (" Параметры ", " Вноситель | Вкладчик", output v-dep).
                            if v-dep = 2 then
                            do:
                                rcode = 17.
                                rdes = "Запрет операции. Вкладчик является несовершеннолетним!" .
                                return.
                            end.
                        end.
                        if ((g-today - cif.expdt) / 365) >= 14 and cif.name <> "" then
                        do:
                            run sel2 (" Параметры ", " Вноситель | Вкладчик | ВЫХОД", output v-dep).
                            if v-dep = 1  then
                            do:
                                rcode = 17.
                                rdes = "Запрет операции. Вкладчик является совершеннолетн. Вноситель не может снять деньги!" .
                                return.
                            end.
                        end.
                    end.
                end.

            end.
        end.
    end.
end.
/*Проверка запрета операции*/



do transaction:
    rcode = 0.
    if trxcode ne "CIF0007" then
        run trxbal(output rcode, output rdes).
    if rcode > 0 then return.

    s-jh = vjh.
    run trxjlgen(output rcode, output rdes).
    if rcode > 0 then return.
    vjh = s-jh.

    /* sasco - если есть карточка дебитора, */
    /* то создать историю движений в debhis */
    /* и изменить статус и остаток в debls  */


    if lookup(g-ofc, v-supusr) = 0 then
    do:
        {trx-debmon.i}
        run trx-debhist.
    end.

    /*********ДОБАВЛЕНО**********************************/
    /* Обработка инкассовых снятие с внебаланса */
    if available aaar then
    do:
        for each tmpl no-lock where tmpl.amt > 0:
            if tmpl.dracc = aaar.a5 or (aaar.a7 <> '' and tmpl.dracc = aaar.a7) then
            do: /*RMZ и счет совпадают разблокируем*/
                find last aaa where aaa.aaa = aaar.a5 exclusive-lock no-error.
                if available aaa then
                do:
                    find last tmp_chnt where tmp_chnt.acc = aaar.a5 no-lock no-error.
                    if available tmp_chnt and tmp_chnt.sm > 0 then
                    do:
                        run savelog ("k2ink", aaa.aaa + "HBALPLUS").
                        run savelog("aaahbal", "trxgen0 1696; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
                        aaa.hbal = aaa.hbal + tmp_chnt.sm.
                        tmp_chnt.sm = 0.
                        run inktrx(vhref, aaar.a2, decimal(aaar.a3), aaar.a5).
                    end.
                    /*               aaa.hbal = aaa.hbal + t-sum. */
                    t-sum = 0.
                end.
            end.
        end.
    end.
    /* Обработка инкассовых прочих */
    else
    do:
        for each tmpl no-lock where tmpl.amt > 0:
            find first remtrz where remtrz.remtrz = vhref  no-lock  no-error.
            if available remtrz  then
            do:
                qq = "0".
                find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
                if available sub-cod then
                    find last b2-aas where b2-aas.aaa = tmpl.dracc and lookup(string(b2-aas.sta), "15,9") <> 0 and b2-aas.knp = substr(sub-cod.rcode, 7, 3) and decimal(b2-aas.docprim) >= remtrz.amt no-lock no-error.


                if available b2-aas and available sub-cod and lookup(substr(sub-cod.rcode, 7, 3), v-allknp) <> 0 then
                do:
                    find last aaa where aaa.aaa = tmpl.dracc exclusive-lock no-error.
                    if available aaa then
                    do:
                        find last tmp_chnt where tmp_chnt.acc = tmpl.dracc no-lock no-error.
                        if available tmp_chnt and tmp_chnt.sm > 0 then
                        do:
                            run savelog ("k2ink", aaa.aaa + "HBALPLUS1").
                            run savelog("aaahbal", "trxgen0 1729; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
                            aaa.hbal = aaa.hbal + tmp_chnt.sm.
                            tmp_chnt.sm = 0.
                            run inktrx(vhref, b2-aas.fnum, remtrz.amt, aaa.aaa).
                        end.
                        t-sum = 0.
                    end.
                end.
                else
                do:
                    find aaa where aaa.aaa = tmpl.dracc exclusive-lock no-error.
                    if available aaa then
                    do:
                        find last tmp_chnt where tmp_chnt.acc = tmpl.dracc no-lock no-error.
                        if available tmp_chnt and tmp_chnt.sm > 0 then
                        do:
                            run savelog ("k2ink", aaa.aaa + "HBALPLUS2").
                            run savelog("aaahbal", "trxgen0 1746; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
                            aaa.hbal = aaa.hbal + tmp_chnt.sm.
                            tmp_chnt.sm = 0.
                        end.
                    end.
                end.
            end.
            else
            do:
                find aaa where aaa.aaa = tmpl.dracc exclusive-lock no-error.
                if available aaa then
                do:
                    find last tmp_chnt where tmp_chnt.acc = tmpl.dracc no-lock no-error.
                    if available tmp_chnt and tmp_chnt.sm > 0 then
                    do:
                        run savelog ("k2ink", aaa.aaa + "HBALPLUS3").
                        run savelog("aaahbal", "trxgen0 1762; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + tmp_chnt.sm) + " ; " + string(tmp_chnt.sm)).
                        aaa.hbal = aaa.hbal + tmp_chnt.sm.
                        tmp_chnt.sm = 0.
                    end.
                end.
            end.
        end.

        for each tmpl no-lock where tmpl.amt > 0:
            /*run savelog("test", "1812; " + tmpl.dracc + " ; " + string(tmpl.amt) + " ; " + string(vhref) ).*/
            find aaa where aaa.aaa = tmpl.dracc exclusive-lock no-error.
            if available aaa then do:
                find last tmp_sumaas where tmp_sumaas.aaa = tmpl.dracc no-lock no-error.
                if available tmp_sumaas and tmp_sumaas.sum > 0 then do:
                    run savelog("aaahbal", "trxgen0 1818; " + aaa.aaa + " ; " + string(aaa.hbal) + " ; " + string(aaa.hbal + tmp_sumaas.sum) + " ; " + string(tmp_sumaas.sum)).
                    aaa.hbal = aaa.hbal + tmp_sumaas.sum.
                    tmp_sumaas.sum = 0.
                end.
            end.
        end.

    end.
/*добавлено*/

{addtocurctrl.i}

end. /*не менялось*/


/*************************************************************/
/*               Auto evaluation procedures                  */
/*************************************************************/
/*1)Status*/
procedure stsauto.
    hsts = 0.
    hsts-f = "d".
end procedure.

/*2)Party*/
procedure partyauto.
    hparty = "".
    hparty-f = "d".
end procedure.

/*3)Point*/
procedure pointauto.
    find ofc where ofc.ofc = g-ofc no-lock.
    hpoint = integer(ofc.regno) / 1000 - 0.5.
    hpoint-f = "d".
end procedure.

/*4)Depart*/
procedure departauto.
    find ofc where ofc.ofc = g-ofc no-lock.
    hdepart = integer(ofc.regno) - hpoint * 1000.
    hdepart-f = "d".
end procedure.

/*5)Amount*/
procedure amtauto.
    if tmpl.rate-f <> "d" then run rateauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.crc-f <> "d" then run crcauto.
    N = integer(substring(tmpl.amt-f,1,4)).
    vsign = substring(tmpl.amt-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then
    do:
        rcode = 20.
        rdes = errlist[rcode] + " - amtauto (линия ссылки не найдена).".
        return.
    end.
    if tmpl.amt-f <> "d" then run amtauto.
    if tmpl.rate-f <> "d" then run rateauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.crc-f <> "d" then run crcauto.
    vrate = tmpl.rate.
    vamt = tmpl.amt.
    vcrc = tmpl.crc.
    if isConvGL(tmpl.crgl) /* tmpl.crgl = buy.inval*/ then
    do:
        selbuy = "buy".
        vcrc1 = vcrc.
        amt1 = vamt.
        cas1 = false.
        if tmpl.drgl = cas.inval or tmpl.drgl = 100200 or tmpl.drgl = 100500 then cas1 = true.
        find tmpl where recid(tmpl) = crec.
        vcrc2 = tmpl.crc.
        cas2 = false.
        if tmpl.crgl = cas.inval or tmpl.crgl = 100200 or tmpl.crgl = 100500 then cas2 = true.
    end.
    else if isConvGL(tmpl.drgl) /* tmpl.drgl = sel.inval*/ then
        do:
            selbuy = "sel".
            vcrc2 = vcrc.
            amt2 = vamt.
            cas2 = false.
            if tmpl.crgl = cas.inval or tmpl.crgl = 100200 or tmpl.crgl = 100500 then cas2 = true.
            find tmpl where recid(tmpl) = crec.
            vcrc1 = tmpl.crc.
            cas1 = false.
            if tmpl.drgl = cas.inval or tmpl.drgl = 100200 or tmpl.drgl = 100500 then cas1 = true.
        end.
        else selbuy = "".
    find tmpl where recid(tmpl) = crec.
    find crc where crc.crc = tmpl.crc no-lock.
    vdecpnt = crc.decpnt.
    find crc where crc.crc = vcrc no-lock.
    if vsign = "" and ( vcrc1 > 0 or vcrc2 > 0 ) then
    do:
        if amt1 = 0 then
        do:
            run conv(vcrc1,vcrc2,cas1,cas2,input-output tmpl.amt,input-output amt2,
                output vrat1, output vrat2, output coef1, output coef2,
                output marg1, output marg2).
            tmpl.rate = vrat1 / coef1.
            tmpl.rate-f = "d".
            find first tmpl where tmpl.ln = N no-error.
            tmpl.rate = vrat2 / coef2.
            tmpl.rate-f = "d".
            find tmpl where recid(tmpl) = crec.
        end.
        else
        do:
            run conv(vcrc1,vcrc2,cas1,cas2,input-output amt1,input-output tmpl.amt,
                output vrat1, output vrat2, output coef1, output coef2,
                output marg1, output marg2).
            tmpl.rate = vrat2 / coef2.
            tmpl.rate-f = "d".

            find first tmpl where tmpl.ln = N no-error.
            tmpl.rate = vrat1 / coef1.
            tmpl.rate-f = "d".
            find tmpl where recid(tmpl) = crec.
        end.
        /*      tmpl.amt = round(vamt * vrate / tmpl.rate, vdecpnt).*/
        tmpl.amt-f = "d".
    end.
    else
    do:
        if selbuy = "buy" then
        do:
            vmarg =
                round(vamt * (crc.rate[1] / crc.rate[9] - vrate), vdecpnt).
        end.
        else if selbuy = "sel" then
            do:
                vmarg =
                    round(vamt * (vrate - crc.rate[1] / crc.rate[9]), vdecpnt).
            end.
            else if vsign ne "M" and vsign ne "B" and vsign ne "S" and vsign ne "Z" then
                do: /* by sasco -> b for NAL */
                    rcode = 20.
                    rdes = errlist[rcode] + " - amtauto (ошибка позиции).".
                    return.
                end.
        if vmarg > 0 and vsign = "+" then tmpl.amt = vmarg.
        else if vmarg < 0 and vsign = "-" then tmpl.amt = - vmarg.
        tmpl.amt-f = "d".
        if vsign = "M"
            then
        do:
            find crc where crc.crc = tmpl.crc no-lock.
            tmpl.amt =  round(vamt * vrate / ( crc.rate[1] / crc.rate[9] ) ,
                  crc.decpnt) .

        /*   display vrate vamt crc.rate  . pause  . */
        end.

        /* sasco */
        if vsign = "B"
            then
        do:
            find crc where crc.crc = tmpl.crc no-lock.

            /* покупка валюты */
            tmpl.amt =  round(vamt * vrate / ( crc.rate[2] / crc.rate[9] ), crc.decpnt) .
        end.

        if vsign = "S"
            then
        do:
            find crc where crc.crc = tmpl.crc no-lock.

            /* продажа валюты */
            /*        tmpl.amt =  round(vamt / vrate * ( crc.rate[3] / crc.rate[9] ), crc.decpnt) . */
            tmpl.amt =  round(vamt * vrate / ( crc.rate[3] / crc.rate[9] ), crc.decpnt) .
        end.

        if vsign = "Z" then   tmpl.amt = vamt.

    end.
end procedure.

procedure rateauto.
    /*     if tmpl.system <> "FEX" then do:
           rcode = 20.
           rdes = errlist[rcode] + " - rateauto (system not FEX).".
           return.
         end.
    */
    if tmpl.crc-f <> "d" then run crcauto.
    if tmpl.drgl-f <> "d" then run drglauto.
    if tmpl.crgl-f <> "d" then run crglauto.
    if tmpl.rate-f = "M" then
    do:
        find crc where crc.crc = tmpl.crc no-lock.
        tmpl.rate = crc.rate[1] / crc.rate[9].
        return .
    end.

    /* 24.07.2002, sasco - нал. курс */
    if tmpl.rate-f = "b" then
    do:
        find crc where crc.crc = tmpl.crc no-lock.
        tmpl.rate = crc.rate[2] / crc.rate[9].
        return.
    end.

    if tmpl.rate-f = "s" then
    do:
        find crc where crc.crc = tmpl.crc no-lock.
        /*       tmpl.rate = crc.rate[3] / crc.rate[9]. */
        tmpl.rate = crc.rate[3] / crc.rate[9].
        return.
    end.


    if tmpl.rate-f = "a" then
    do:
        find crc where crc.crc = tmpl.crc no-lock.
        if isConvGL(tmpl.crgl)  /* tmpl.crgl = buy.inval*/ then
        do:
            if tmpl.drgl = cas.inval or tmpl.drgl = 100200 or tmpl.drgl = 100500 then
            do:
                tmpl.rate = crc.rate[2] / crc.rate[9].
                tmpl.rate-f = "d".
                if tmpl.rate = 0 then
                do:
                    rcode = 36.
                    rdes = errlist[rcode] + ":" + crc.code + "(касса).".
                    return.
                end.
            end.
            else
            do:
                tmpl.rate = crc.rate[4] / crc.rate[9].
                tmpl.rate-f = "d".
                if tmpl.rate = 0 then
                do:
                    rcode = 36.
                    rdes = errlist[rcode] + ":" + crc.code + ".".
                    return.
                end.
            end.
        end.
        else if isConvGL(tmpl.drgl)   /* tmpl.drgl = sel.inval*/ then
            do:
                if tmpl.crgl = cas.inval or tmpl.crgl = 100200 or tmpl.crgl = 100500 then
                do:
                    tmpl.rate = crc.rate[3] / crc.rate[9].
                    tmpl.rate-f = "d".
                    if tmpl.rate = 0 then
                    do:
                        rcode = 37.
                        rdes = errlist[rcode] + ":" + crc.code + "(касса).".
                        return.
                    end.
                end.
                else
                do:
                    tmpl.rate = crc.rate[5] / crc.rate[9].
                    tmpl.rate-f = "d".
                    if tmpl.rate = 0 then
                    do:
                        rcode = 37.
                        rdes = errlist[rcode] + ":" + crc.code + ".".
                        return.
                    end.
                end.
            end.
            else
            do:
                rcode = 20.
                rdes = errlist[rcode] + " - rateauto (ошибка позиции).".
                return.
            end.
    end. /*tmpl.rate-f = "a"*/
    else
    do:
        N = integer(tmpl.rate-f).
        if tmpl.amt-f <> "d" then run amtauto.
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - rateauto (линия ссылки не найдена).".
            return.
        end.
        if tmpl.amt-f <> "d" then run amtauto.
        if tmpl.rate-f <> "d" then run rateauto.
        vrate = tmpl.rate.
        vamt = tmpl.amt.
        find tmpl where recid(tmpl) = crec.
        tmpl.rate = vrate * vamt / tmpl.amt.
        tmpl.rate-f = "d".
    end.

end procedure.

/*6)Currency*/
procedure crcauto.
    if tmpl.drsub-f <> "d" then run drsubauto.
    if tmpl.dracc-f <> "d" then run draccauto.
    if tmpl.drsub <> "" then run trxcrcacc(tmpl.drsub, tmpl.dracc).
    if tmpl.crsub-f <> "d" then run crsubauto.
    if tmpl.cracc-f <> "d" then run craccauto.
    if tmpl.crsub <> "" then run trxcrcacc(tmpl.crsub, tmpl.cracc).
    if tmpl.drsub = "" and tmpl.crsub = "" then
    do:
        rcode = 20.
        rdes = errlist[rcode] + " валюта <- счет."
            + "Линия=" + string(tmpl.ln,"99").
        return.
    end.
end procedure.

/*8)Debet G/L*/
procedure drglauto.
    define variable vsign as character.
    if tmpl.drgl-f = "a" then
    do:
        if tmpl.dracc-f <> "d" then run draccauto.
        if tmpl.dracc = "" then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " drgl <- счет(Дб).".
            return.
        end.
        else
        do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            if tmpl.drsub = "" then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " drgl <- счет(Дб).".
                return.
            end.
            else
            do:
                run trxglacc(tmpl.drsub, tmpl.dracc, tmpl.dev, output vgl).
                if rcode = 0 then tmpl.drgl = vgl.
            end.
        end.
    end.
    else
    do:
        N = integer(substring(tmpl.drgl-f,1,4)).
        vsign = substring(tmpl.drgl-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - drglauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "+" then
        do:
            if tmpl.drgl-f <> "d" then run drglauto.
            vgl = tmpl.drgl.
        end.
        else
        do:
            if tmpl.crgl-f <> "d" then run crglauto.
            vgl = tmpl.crgl.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.drgl = vgl.
        tmpl.drgl-f = "d".
    end.
end procedure.

procedure drsubauto.
    define variable vsub as character.
    if tmpl.drsub-f = "a" then
    do:
        if tmpl.drgl-f <> "d" then run drglauto.
        find gl where gl.gl = tmpl.drgl no-lock no-error.
        if available gl then
        do:
            tmpl.drsub = gl.subled.
            tmpl.drsub-f = "d".
        end.
        else
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Субсчет <- Г/К(Дб).".
            return.
        end.
    end.
    else
    do:
        N = integer(substring(tmpl.drsub-f,1,4)).
        vsign = substring(tmpl.drsub-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - drsubauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "+" then
        do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            vsub = tmpl.drsub.
        end.
        else
        do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            vsub = tmpl.crsub.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.drsub = vsub.
        tmpl.drsub-f = "d".
    end.
end procedure.

procedure draccauto.
    define variable vacc as character.
    N = integer(substring(tmpl.dracc-f,1,4)).
    vsign = substring(tmpl.dracc-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then
    do:
        rcode = 20.
        rdes = errlist[rcode] + " - draccauto (линия ссылки не найдена).".
        return.
    end.
    if vsign = "+" then
    do:
        if tmpl.dracc-f <> "d" then run draccauto.
        vacc = tmpl.dracc.
    end.
    else
    do:
        if tmpl.cracc-f <> "d" then run craccauto.
        vacc = tmpl.cracc.
    end.
    find tmpl where recid(tmpl) = crec.
    tmpl.dracc = vacc.
    tmpl.dracc-f = "d".
end procedure.

/*8)Credit G/L*/
procedure crglauto.
    if tmpl.crgl-f = "a" then
    do:
        if tmpl.cracc-f <> "d" then run craccauto.
        if tmpl.cracc = "" then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Г/К(Кр) <- счет(Кр).".
            return.
        end.
        else
        do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            if tmpl.crsub = "" then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " Г/К(Кр) <- счет(Кр).".
                return.
            end.
            else
            do:
                run trxglacc(tmpl.crsub, tmpl.cracc, tmpl.cev, output vgl).
                if rcode = 0 then tmpl.crgl = vgl.
            end.
        end.
    end.
    else
    do:
        N = integer(substring(tmpl.crgl-f,1,4)).
        vsign = substring(tmpl.crgl-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - crglauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "+" then
        do:
            if tmpl.crgl-f <> "d" then run crglauto.
            vgl = tmpl.crgl.
        end.
        else
        do:
            if tmpl.drgl-f <> "d" then run drglauto.
            vgl = tmpl.drgl.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.crgl = vgl.
        tmpl.crgl-f = "d".
    end.
end procedure.

procedure crsubauto.
    define variable vsub as character.
    if tmpl.crsub-f = "a" then
    do:
        if tmpl.crgl-f <> "d" then run crglauto.
        find gl where gl.gl = tmpl.crgl no-lock no-error.
        if available gl then
        do:
            tmpl.crsub = gl.subled.
            tmpl.crsub-f = "d".
        end.
        else
        do:
            rcode = 20.
            rdes = errlist[rcode] + " субсчет <- Г/К(Кр).".
            return.
        end.
    end.
    else
    do:
        N = integer(substring(tmpl.crsub-f,1,4)).
        vsign = substring(tmpl.crsub-f,5,1).
        crec = recid(tmpl).
        find first tmpl where tmpl.ln = N no-error.
        if not available tmpl then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - crsubauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "+" then
        do:
            if tmpl.crsub-f <> "d" then run crsubauto.
            vsub = tmpl.crsub.
        end.
        else
        do:
            if tmpl.drsub-f <> "d" then run drsubauto.
            vsub = tmpl.drsub.
        end.
        find tmpl where recid(tmpl) = crec.
        tmpl.crsub = vsub.
        tmpl.crsub-f = "d".
    end.
end procedure.

procedure craccauto.
    define variable vacc as character.
    N = integer(substring(tmpl.cracc-f,1,4)).
    vsign = substring(tmpl.cracc-f,5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then
    do:
        rcode = 20.
        rdes = errlist[rcode] + " - craccauto (линия ссылки не найдена).".
        return.
    end.
    if vsign = "+" then
    do:
        if tmpl.cracc-f <> "d" then run craccauto.
        vacc = tmpl.cracc.
    end.
    else
    do:
        if tmpl.dracc-f <> "d" then run draccauto.
        vacc = tmpl.dracc.
    end.
    find tmpl where recid(tmpl) = crec.
    tmpl.cracc = vacc.
    tmpl.cracc-f = "d".
end procedure.

procedure trxcrcacc.
    define input parameter vsub as character.
    define input parameter vacc as character.
    if vsub = "arp" then
    do:
        find arp where arp.arp = vacc no-lock no-error.
        if available arp then
        do:
            tmpl.crc = arp.crc.
            tmpl.crc-f = "d".
        end.
        else
        do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                + ";счет=" + vacc + "Линия="
                + string(tmpl.ln,"99") + ";валюта <- счет.".
            return.
        end.
    end.
    else if vsub = "ast" then
        do:
            find ast where ast.ast = vacc no-lock no-error.
            if available ast then
            do:
                tmpl.crc = ast.crc.
                tmpl.crc-f = "d".
            end.
            else
            do:
                rcode = 20.
                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                    + ";счет=" + vacc + "Линия="
                    + string(tmpl.ln,"99") + ";валюта <- счет.".
                return.
            end.
        end.
        else if vsub = "cif" then
            do:
                find aaa where aaa.aaa = vacc no-lock no-error.
                if available aaa then
                do:
                    tmpl.crc = aaa.crc.
                    tmpl.crc-f = "d".
                end.
                else
                do:
                    rcode = 20.
                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                        + ";счет=" + vacc + "Линия="
                        + string(tmpl.ln,"99") + ";валюта <- счет.".
                    return.
                end.
            end.
            else if vsub = "dfb" then
                do:
                    find dfb where dfb.dfb = vacc no-lock no-error.
                    if available dfb then
                    do:
                        tmpl.crc = dfb.crc.
                        tmpl.crc-f = "d".
                    end.
                    else
                    do:
                        rcode = 20.
                        rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                            + ";счет=" + vacc + "Линия="
                            + string(tmpl.ln,"99") + ";валюта <- счет.".
                        return.
                    end.
                end.
                else if vsub = "eps" then
                    do:
                        find eps where eps.eps = vacc no-lock no-error.
                        if available eps then
                        do:
                            tmpl.crc = eps.crc.
                            tmpl.crc-f = "d".
                        end.
                        else
                        do:
                            rcode = 20.
                            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                + ";счет=" + vacc + "Линия="
                                + string(tmpl.ln,"99") + ";валюта <- счет.".
                            return.
                        end.
                    end.
                    else if vsub = "fun" then
                        do:
                            find fun where fun.fun = vacc no-lock no-error.
                            if available fun then
                            do:
                                tmpl.crc = fun.crc.
                                tmpl.crc-f = "d".
                            end.
                            else
                            do:
                                rcode = 20.
                                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                    + ";счет=" + vacc + "Линия="
                                    + string(tmpl.ln,"99") + ";валюта <- счет.".
                                return.
                            end.
                        end.  /*26/11/03 nataly*/
                        else if vsub = "scu" then
                            do:
                                find scu where scu.scu = vacc no-lock no-error.
                                if available scu then
                                do:
                                    tmpl.crc = scu.crc.
                                    tmpl.crc-f = "d".
                                end.
                                else
                                do:
                                    rcode = 20.
                                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                        + ";счет=" + vacc + "Линия="
                                        + string(tmpl.ln,"99") + ";валюта <- счет.".
                                    return.
                                end.
                            end.  /*26/11/03 nataly*/
                            else if vsub = "tsf" then
                                do:
                                    find tsf where tsf.tsf = vacc no-lock no-error.
                                    if available tsf then
                                    do:
                                        tmpl.crc = tsf.crc.
                                        tmpl.crc-f = "d".
                                    end.
                                    else
                                    do:
                                        rcode = 20.
                                        rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                            + ";счет=" + vacc + "Линия="
                                            + string(tmpl.ln,"99") + ";валюта <- счет.".
                                        return.
                                    end.
                                end.  /*18/04/06 nataly*/
                                else if vsub = "lcr" then
                                    do:
                                        find lcr where lcr.lcr = vacc no-lock no-error.
                                        if available lcr then
                                        do:
                                            tmpl.crc = lcr.crc.
                                            tmpl.crc-f = "d".
                                        end.
                                        else
                                        do:
                                            rcode = 20.
                                            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                + ";счет=" + vacc + "Линия="
                                                + string(tmpl.ln,"99") + ";валюта <- счет.".
                                            return.
                                        end.
                                    end.
                                    else if vsub = "lon" then
                                        do:
                                            find lon where lon.lon = vacc no-lock no-error.
                                            if available lon then
                                            do:
                                                tmpl.crc = lon.crc.
                                                tmpl.crc-f = "d".
                                            end.
                                            else
                                            do:
                                                rcode = 20.
                                                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                    + ";счет=" + vacc + "Линия="
                                                    + string(tmpl.ln,"99") + ";валюта <- счет.".
                                                return.
                                            end.
                                        end.
                                        else if vsub = "ock" then
                                            do:
                                                find ock where ock.ock = vacc no-lock no-error.
                                                if available ock then
                                                do:
                                                    tmpl.crc = ock.crc.
                                                    tmpl.crc-f = "d".
                                                end.
                                                else
                                                do:
                                                    rcode = 20.
                                                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                        + ";счет=" + vacc + "Линия="
                                                        + string(tmpl.ln,"99") + ";валюта <- счет.".
                                                    return.
                                                end.
                                            end.
end procedure.

procedure trxglacc.
    define input parameter vsub as character.
    define input parameter vacc as character.
    define input parameter vlev as integer.
    define output parameter vgl as integer.
    if vsub = "arp" then
    do:
        find arp where arp.arp = vacc no-lock no-error.
        if available arp then
        do:
            if vlev = 1 then vgl = arp.gl.
            else
            do:
                find trxlevgl where trxlevgl.gl = arp.gl
                    and trxlevgl.level = vlev no-lock no-error.
                if available trxlevgl then vgl = trxlevgl.glr.
                else
                do:
                    rcode = 28.
                    rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                        + string(vlev,"z9") + "; Г/К(1) = " + string(arp.gl,"999999") + ".".
                    return.
                end.
            end.
        end.
        else
        do:
            rcode = 20.
            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                + ";счет=" + vacc + "Линия="
                + string(tmpl.ln,"99") + ";Г/К <- счет.".
            return.
        end.
    end.
    else if vsub = "ast" then
        do:
            find ast where ast.ast = vacc no-lock no-error.
            if available ast then
            do:
                if vlev = 1 then vgl = ast.gl.
                else
                do:
                    find trxlevgl where trxlevgl.gl = ast.gl
                        and trxlevgl.level = vlev no-lock no-error.
                    if available trxlevgl then vgl = trxlevgl.glr.
                    else
                    do:
                        rcode = 28.
                        rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                            + string(vlev,"z9") + "; Г/К(1) = " + string(ast.gl,"999999") + ".".
                        return.
                    end.
                end.
            end.
            else
            do:
                rcode = 20.
                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                    + ";счет=" + vacc + "Линия="
                    + string(tmpl.ln,"99") + ";Г/К <- счет.".
                return.
            end.
        end.
        else if vsub = "cif" then
            do:
                find aaa where aaa.aaa = vacc no-lock no-error.
                if available aaa then
                do:
                    if vlev = 1 then vgl = aaa.gl.
                    else
                    do:
                        find trxlevgl where trxlevgl.gl = aaa.gl
                            and trxlevgl.level = vlev no-lock no-error.
                        if available trxlevgl then vgl = trxlevgl.glr.
                        else
                        do:
                            rcode = 28.
                            rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                + string(vlev,"z9") + "; Г/К(1) = " + string(aaa.gl,"9999999") + ".".
                            return.
                        end.
                    end.
                end.
                else
                do:
                    rcode = 20.
                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                        + ";счет=" + vacc + "Линия="
                        + string(tmpl.ln,"99") + ";Г/К <- счет.".
                    return.
                end.
            end.
            else if vsub = "dfb" then
                do:
                    find dfb where dfb.dfb = vacc no-lock no-error.
                    if available dfb then
                    do:
                        if vlev = 1 then vgl = dfb.gl.
                        else
                        do:
                            find trxlevgl where trxlevgl.gl = ast.gl
                                and trxlevgl.level = vlev no-lock no-error.
                            if available trxlevgl then vgl = trxlevgl.glr.
                            else
                            do:
                                rcode = 28.
                                rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                    + string(vlev,"z9") + "; Г/К(1) = " + string(dfb.gl,"999999") + ".".
                                return.
                            end.
                        end.
                    end.
                    else
                    do:
                        rcode = 20.
                        rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                            + ";счет=" + vacc + "Линия="
                            + string(tmpl.ln,"99") + ";Г/К <- счет.".
                        return.
                    end.
                end.
                else if vsub = "eps" then
                    do:
                        find eps where eps.eps = vacc no-lock no-error.
                        if available eps then
                        do:
                            if vlev = 1 then vgl = eps.gl.
                            else
                            do:
                                find trxlevgl where trxlevgl.gl = eps.gl
                                    and trxlevgl.level = vlev no-lock no-error.
                                if available trxlevgl then vgl = trxlevgl.glr.
                                else
                                do:
                                    rcode = 28.
                                    rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                        + string(vlev,"z9") + "; Г/К(1) = " + string(eps.gl,"999999") + ".".
                                    return.
                                end.
                            end.
                        end.
                        else
                        do:
                            rcode = 20.
                            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                + ";счет=" + vacc + "Линия="
                                + string(tmpl.ln,"99") + ";Г/К <- счет.".
                            return.
                        end.
                    end.

                    else if vsub = "fun" then
                        do:
                            find fun where fun.fun = vacc no-lock no-error.
                            if available fun then
                            do:
                                if vlev = 1 then vgl = fun.gl.
                                else
                                do:
                                    find trxlevgl where trxlevgl.gl = fun.gl
                                        and trxlevgl.level = vlev no-lock no-error.
                                    if available trxlevgl then vgl = trxlevgl.glr.
                                    else
                                    do:
                                        rcode = 28.
                                        rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                            + string(vlev,"z9") + "; Г/К(1) = " + string(fun.gl,"999999") + ".".
                                        return.
                                    end.
                                end.
                            end.
                            else
                            do:
                                rcode = 20.
                                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                    + ";счет=" + vacc + "Линия="
                                    + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                return.
                            end.
                        end.
                        /*26/11/03 nataly*/
                        else if vsub = "scu" then
                            do:
                                find scu where scu.scu = vacc no-lock no-error.
                                if available scu then
                                do:
                                    if vlev = 1 then vgl = scu.gl.
                                    else
                                    do:
                                        find trxlevgl where trxlevgl.gl = scu.gl
                                            and trxlevgl.level = vlev no-lock no-error.
                                        if available trxlevgl then vgl = trxlevgl.glr.
                                        else
                                        do:
                                            rcode = 28.
                                            rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                                + string(vlev,"z9") + "; Г/К(1) = " + string(scu.gl,"999999") + ".".
                                            return.
                                        end.
                                    end.
                                end.
                                else
                                do:
                                    rcode = 20.
                                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                        + ";счет=" + vacc + "Линия="
                                        + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                    return.
                                end.
                            end.  /*26/11/03 nataly*/
                            /*20/04/06 nataly*/
                            else if vsub = "tsf" then
                                do:
                                    find tsf where tsf.tsf = vacc no-lock no-error.
                                    if available tsf then
                                    do:
                                        if vlev = 1 then vgl = tsf.gl.
                                        else
                                        do:
                                            find trxlevgl where trxlevgl.gl = tsf.gl
                                                and trxlevgl.level = vlev no-lock no-error.
                                            if available trxlevgl then vgl = trxlevgl.glr.
                                            else
                                            do:
                                                rcode = 28.
                                                rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                                    + string(vlev,"z9") + "; Г/К(1) = " + string(tsf.gl,"999999") + ".".
                                                return.
                                            end.
                                        end.
                                    end.
                                    else
                                    do:
                                        rcode = 20.
                                        rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                            + ";счет=" + vacc + "Линия="
                                            + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                        return.
                                    end.
                                end.  /*20/04/06 nataly*/

                                else if vsub = "lcr" then
                                    do:
                                        find lcr where lcr.lcr = vacc no-lock no-error.
                                        if available lcr then
                                        do:
                                            if vlev = 1 then vgl = lcr.gl.
                                            else
                                            do:
                                                find trxlevgl where trxlevgl.gl = lcr.gl
                                                    and trxlevgl.level = vlev no-lock no-error.
                                                if available trxlevgl then vgl = trxlevgl.glr.
                                                else
                                                do:
                                                    rcode = 28.
                                                    rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                                        + string(vlev,"z9") + "; Г/К(1) = " + string(lcr.gl,"999999") + ".".
                                                    return.
                                                end.
                                            end.
                                        end.
                                        else
                                        do:
                                            rcode = 20.
                                            rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                + ";счет=" + vacc + "Линия="
                                                + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                            return.
                                        end.
                                    end.
                                    else if vsub = "lon" then
                                        do:
                                            find lon where lon.lon = vacc no-lock no-error.
                                            if available lon then
                                            do:
                                                if vlev = 1 then vgl = lon.gl.
                                                else
                                                do:
                                                    find trxlevgl where trxlevgl.gl = lon.gl
                                                        and trxlevgl.level = vlev no-lock no-error.
                                                    if available trxlevgl then vgl = trxlevgl.glr.
                                                    else
                                                    do:
                                                        rcode = 28.
                                                        rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                                            + string(vlev,"z9") + "; Г/К(1) = " + string(lon.gl,"999999") + ".".
                                                        return.
                                                    end.
                                                end.
                                            end.
                                            else
                                            do:
                                                rcode = 20.
                                                rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                    + ";счет=" + vacc + "Линия="
                                                    + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                                return.
                                            end.
                                        end.

                                        else if vsub = "ock" then
                                            do:
                                                find ock where ock.ock = vacc no-lock no-error.
                                                if available ock then
                                                do:
                                                    if vlev = 1 then vgl = ock.gl.
                                                    else
                                                    do:
                                                        find trxlevgl where trxlevgl.gl = ock.gl
                                                            and trxlevgl.level = vlev no-lock no-error.
                                                        if available trxlevgl then vgl = trxlevgl.glr.
                                                        else
                                                        do:
                                                            rcode = 28.
                                                            rdes = errlist[rcode] + " Субсчет = " + vsub + "; уровень = "
                                                                + string(vlev,"z9") + "; Г/К(1) = " + string(ock.gl,"999999") + ".".
                                                            return.
                                                        end.
                                                    end.
                                                end.
                                                else
                                                do:
                                                    rcode = 20.
                                                    rdes = trim(errlist[rcode]) + ":Субсчет=" + vsub
                                                        + ";счет=" + vacc + "Линия="
                                                        + string(tmpl.ln,"99") + ";Г/К <- счет.".
                                                    return.
                                                end.
                                            end.
end procedure.

procedure remauto.
    define variable vsign as character.
    N = integer(substring(tmpl.rem-f[o],1,4)).
    vsign = substring(tmpl.rem-f[o],5,1).
    crec = recid(tmpl).
    find first tmpl where tmpl.ln = N no-error.
    if not available tmpl then
    do:
        rcode = 20.
        rdes = errlist[rcode] + " - rem (линия ссылки не найдена).".
        return.
    end.
    if tmpl.rem-f[o] <> "d" then run remauto.
    vrem = tmpl.rem[o].
    find tmpl where recid(tmpl) = crec.
    tmpl.rem[o] = vrem.
    tmpl.rem-f[o] = "d".
end procedure.

/*10)Debit code auto*/
procedure drcodeauto.
    define variable vsign  as character.
    define variable vcodfr as character.
    define variable vcod   as character.
    define variable vN0    as integer.
    define variable vcif   like cif.cif.
    if cdf.drcod-f = "a" then
    do:
        if cdf.codfr <> "secek" and cdf.codfr <> "locat" then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб).".
            return.
        end.
        if tmpl.drsub-f <> "d" then run drsubauto.
        if tmpl.drsub <> "cif" and tmpl.drsub <> "lon" and tmpl.drsub <> "arp"
            then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                + tmpl.drsub + ").".
            return.
        end.
        if tmpl.dracc-f <> "d" then run draccauto.
        if tmpl.drsub <> "arp" then
        do:
            if tmpl.drsub = "cif" then
            do:
                find aaa where aaa.aaa = tmpl.dracc no-lock no-error.
                if available aaa then find cif where cif.cif = aaa.cif no-lock no-error.
                if available cif then vcif = cif.cif.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                        + tmpl.dracc + ").".
                    return.
                end.
            end.
            else
            do:
                find lon where lon.lon = tmpl.dracc no-lock no-error.
                if available lon then find cif where cif.cif = lon.cif no-lock no-error.
                if available cif then vcif = cif.cif.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                        + tmpl.dracc + ").".
                    return.
                end.
            end.
            if cdf.codfr = "secek" then
            do:
                find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek"
                    and sub-cod.acc = vcif no-lock no-error.
                if available sub-cod and sub-cod.ccode <> "msc" then
                do:
                    cdf.drcod = sub-cod.ccode.
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Дб(secek) <- счет(Дб)("
                        + vcif + ")- secek не опред.".
                    return.
                end.
            end.
            if cdf.codfr = "locat" then
            do:
                if cif.geo <> "" and cif.geo <> ? then
                do:
                    if substring(cif.geo,3,1) = "1" then cdf.drcod = "1".
                    else cdf.drcod = "2".
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Дб(locat) <- счет(Дб)("
                        + vcif + ") - GEO не опред.".
                    return.
                end.
            end.
        end.
        else
        do:
            find arp where arp.arp = tmpl.dracc no-lock no-error.
            if not available arp then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " Код-Дб(" + cdf.codfr + ") <- счет(Дб)("
                    + "arp " + tmpl.dracc + ").".
                return.
            end.
            if cdf.codfr = "secek" then
            do:
                find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "secek"
                    and sub-cod.acc = tmpl.dracc no-lock no-error.
                if available sub-cod and sub-cod.ccode <> "msc" then
                do:
                    cdf.drcod = sub-cod.ccode.
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Дб(secek) <- счет(Дб)(arp("
                        + tmpl.dracc + ")) - secek не опред.".
                    return.
                end.
            end.
            else if cdf.codfr = "locat" then
                do:
                    if arp.geo <> "" and arp.geo <> ? then
                    do:
                        if substring(arp.geo,3,1) = "1" then cdf.drcod = "1".
                        else cdf.drcod = "2".
                    end.
                    else
                    do:
                        rcode = 20.
                        rdes = errlist[rcode] + " Код-Дб(locat) <- счет(Дб)(arp("
                            + tmpl.dracc + ")) - GEO не опред.".
                        return.
                    end.
                end.
        end.
        cdf.drcod-f = "d".
    end. /*cdf.drcod-f = "a"*/
    else
    do:
        vN0 = cdf.trxln.
        N = integer(substring(cdf.drcod-f,1,4)).
        vsign = substring(cdf.drcod-f,5,1).
        vcodfr = cdf.codfr.
        crec = recid(cdf).
        find first cdf where cdf.trxln = N and cdf.codfr = vcodfr no-error.
        if not available cdf then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - drcodeauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "-" then
        do:
            if cdf.crcode-f <> "d" then run crcodeauto.
            vcod = cdf.crcod.
        end.
        else
        do:
            if cdf.trxln = vN0 then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " - drcodeauto (Ссылки на себя запрещены.).".
                return.
            end.
            if cdf.drcod-f <> "d" then run drcodeauto.
            vcod = cdf.drcod.
        end.
        find cdf where recid(cdf) = crec.
        cdf.drcod = vcod.
        cdf.drcod-f = "d".
    end.
end procedure.

/*11)Credit code auto*/
procedure crcodeauto.
    define variable vsign  as character.
    define variable vcodfr as character.
    define variable vcod   as character.
    define variable vN0    as integer.
    define variable vcif   like cif.cif.
    if cdf.crcode-f = "a" then
    do:
        if cdf.codfr <> "secek" and cdf.codfr <> "locat" then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр).".
            return.
        end.
        if tmpl.crsub-f <> "d" then run crsubauto.
        if tmpl.crsub <> "cif" and tmpl.crsub <> "lon" and tmpl.crsub <> "arp"
            then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                + tmpl.crsub + ").".
            return.
        end.
        if tmpl.cracc-f <> "d" then run craccauto.
        if tmpl.crsub <> "arp" then
        do:
            if tmpl.crsub = "cif" then
            do:
                find aaa where aaa.aaa = tmpl.cracc no-lock no-error.
                if available aaa then find cif where cif.cif = aaa.cif no-lock no-error.
                if available cif then vcif = cif.cif.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                        + tmpl.cracc + ").".
                    return.
                end.
            end.
            else
            do:
                find lon where lon.lon = tmpl.cracc no-lock no-error.
                if available lon then find cif where cif.cif = lon.cif no-lock no-error.
                if available cif then vcif = cif.cif.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                        + tmpl.cracc + ").".
                    return.
                end.
            end.
            if cdf.codfr = "secek" then
            do:
                find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "secek"
                    and sub-cod.acc = vcif no-lock no-error.
                if available sub-cod and sub-cod.ccode <> "msc" then
                do:
                    cdf.crcod = sub-cod.ccode.
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Кр(secek) <- счет(Кр)("
                        + vcif + ")- secek не опред.".
                    return.
                end.
            end.
            if cdf.codfr = "locat" then
            do:
                if cif.geo <> "" and cif.geo <> ? then
                do:
                    if substring(cif.geo,3,1) = "1" then cdf.crcod = "1".
                    else cdf.crcod = "2".
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Кр(locat) <- счет(Кр)("
                        + vcif + ") - GEO не опред.".
                    return.
                end.
            end.
        end.
        else
        do:
            find arp where arp.arp = tmpl.cracc no-lock no-error.
            if not available arp then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " Код-Кр(" + cdf.codfr + ") <- счет(Кр)("
                    + "arp " + tmpl.cracc + ").".
                return.
            end.
            if cdf.codfr = "secek" then
            do:
                find sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "secek"
                    and sub-cod.acc = tmpl.cracc no-lock no-error.
                if available sub-cod and sub-cod.ccode <> "msc" then
                do:
                    cdf.crcod = sub-cod.ccode.
                end.
                else
                do:
                    rcode = 20.
                    rdes = errlist[rcode] + " Код-Кр(secek) <- счет(Кр)(arp("
                        + tmpl.cracc + ")) - secek не опред.".
                    return.
                end.
            end.
            else if cdf.codfr = "locat" then
                do:
                    if arp.geo <> "" and arp.geo <> ? then
                    do:
                        if substring(arp.geo,3,1) = "1" then cdf.crcod = "1".
                        else cdf.crcod = "2".
                    end.
                    else
                    do:
                        rcode = 20.
                        rdes = errlist[rcode] + " Код-Кр(locat) <- счет(Кр)(arp("
                            + tmpl.cracc + ")) - GEO не опред.".
                        return.
                    end.
                end.
        end.
        cdf.crcode-f = "d".
    end. /*cdf.crcode-f = "a"*/
    else
    do:
        vN0 = cdf.trxln.
        N = integer(substring(cdf.crcode-f,1,4)).
        vsign = substring(cdf.crcode-f,5,1).
        vcodfr = cdf.codfr.
        crec = recid(cdf).
        find first cdf where cdf.trxln = N and cdf.codfr = vcodfr no-error.
        if not available cdf then
        do:
            rcode = 20.
            rdes = errlist[rcode] + " - crcodeauto (линия ссылки не найдена).".
            return.
        end.
        if vsign = "-" then
        do:
            if cdf.drcod-f <> "d" then run drcodeauto.
            vcod = cdf.drcod.
        end.
        else
        do:
            if cdf.trxln = vN0 then
            do:
                rcode = 20.
                rdes = errlist[rcode] + " - drcodeauto (Ссылки на себя запрещены.).".
                return.
            end.
            if cdf.crcode-f <> "d" then run crcodeauto.
            vcod = cdf.crcod.
        end.
        find cdf where recid(cdf) = crec.
        cdf.crcod = vcod.
        cdf.crcode-f = "d".
    end.
end procedure.

