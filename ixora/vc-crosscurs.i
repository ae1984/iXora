/* vc-crosscurs.i
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
        29.06.2012 damir - if avail ncrc.
*/

procedure valid-curs.
    def input parameter p-crc as integer.
    def input parameter p-dt as date.
    def output parameter vp-c as decimal format ">>>>>>9.99<<<<".

    def var vp-rec as recid.
    def buffer b-his for ncrchis.

    find last ncrchis where ncrchis.crc = p-crc and ncrchis.rdt <= p-dt no-lock no-error.
    /* валидность курса */
    /* если найден ненулевой курс на данную дату - хорошо */
    /* валюты с 1 по 12 и введено после 16/12/99 - хорошо */
    /* валюты после 15 и дата после записи с 0 - хорошо */
    if (avail ncrchis and ncrchis.rdt = p-dt and ncrchis.rate[1] > 0) or
    (p-crc >=1 and p-crc <= 12 and avail ncrchis and ncrchis.whn >= 12/16/99) or
    (p-crc >= 15 and avail ncrchis and can-find(first b-his where b-his.crc = p-crc and b-his.rate[1] = 0 and b-his.rdt <= p-dt)) then do:
        vp-c = ncrchis.rate[1].
    end.
    else do:
        if avail ncrchis then vp-c = ncrchis.rate[1].
        find ncrc where ncrc.crc = p-crc no-lock no-error.

        /* запросить курс */
        /*if avail ncrc then message " Введите курс валюты " ncrc.code " на " p-dt " " update vp-c.*/
        if vp-c < 0 then vp-c = 0.
        if vp-c > 0 then do transaction:
            if not avail ncrchis or ncrchis.rdt <> p-dt then do:
                /* создать запись в истории за этот день */
                create ncrchis.
                assign ncrchis.rdt = p-dt
                ncrchis.crc = p-crc.
                if avail ncrc then
                assign
                ncrchis.des = ncrc.des
                ncrchis.stn = ncrc.stn
                ncrchis.sts = ncrc.sts
                ncrchis.prefix = ncrc.prefix
                ncrchis.code = ncrc.code
                ncrchis.decpnt = ncrc.decpnt
                ncrchis.rate[9] = ncrc.rate[9].
                assign
                ncrchis.who = g-ofc
                ncrchis.whn = today
                ncrchis.tim = time
                ncrchis.regdt = g-today.
            end.
            vp-rec = recid(ncrchis).
            find ncrchis where vp-rec = recid(ncrchis) exclusive-lock no-error.
            ncrchis.rate[1] = vp-c.
            release ncrchis.
        end.
    end.
end.

function valid-euro returns logical (p-crc as integer, p-dt as date).
    /* DEM, FRF, ITL, DKK работали только до 07/01/02 */
    find ncrc where ncrc.crc = p-crc no-lock no-error.
    if avail ncrc and ncrc.prefix <> "" and date(entry(2, ncrc.prefix)) <= p-dt then do:
        message skip "Валюта " ncrc.code " после " entry(2, ncrc.prefix) " не действительна!" skip(1)
        "Выберите другую валюту !" skip view-as alert-box button ok title " ВНИМАНИЕ ! ".
        return true.
    end.
    return false.
end.


procedure crosscurs.
    def input parameter p-crcdoc as integer.
    def input parameter p-crcbase as integer.
    def input parameter p-cursdt as date.
    def output parameter vp-curs as deci.

    def var vp-cursdoc as decimal.
    def var vp-cursbas as decimal.

    if p-crcdoc = p-crcbase then vp-curs = 1.
    else do:
        if valid-euro(p-crcbase, p-cursdt) then do: vp-curs = 0. return. end.
        if valid-euro(p-crcdoc, p-cursdt) then do: vp-curs = 0. return. end.

        if p-crcbase = 1 then vp-cursbas = 1.
        else do:
            run valid-curs(p-crcbase, p-cursdt, output vp-cursbas).
            if vp-cursbas = 0 then do:
                find ncrc where ncrc.crc = p-crcbase no-lock no-error.
                if avail ncrc then message skip "Требуется ввод курса валюты aaa " ncrc.code " на " p-cursdt " !" skip
                view-as alert-box button ok title " ВНИМАНИЕ ! ".
                return.
            end.
        end.

        if p-crcdoc = 1 then vp-cursdoc = 1.
        else do:
            run valid-curs(p-crcdoc, p-cursdt, output vp-cursdoc).
            if vp-cursdoc = 0 then do:
                find ncrc where ncrc.crc = p-crcdoc no-lock no-error.
                if avail ncrc then message skip "Требуется ввод курса валюты aaa " ncrc.code " на " p-cursdt " !" skip
                view-as alert-box button ok title " ВНИМАНИЕ ! ".
                return.
            end.
        end.

        vp-curs = vp-cursbas / vp-cursdoc. /* vp-cursdoc / vp-cursbas. */
    end.
end.



