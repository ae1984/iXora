/* s-lontrx.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Погашение кредита, штрафов и комиссии
 * RUN

 * CALLER
        s-lontrx
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        26.02.2004 marinav
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       15/10/2004 madiyar - Добавились три новые комиссии
                            Списание на внебаланс (if s-ptype eq 9) - шаблон lon0048 поменял на новый шаблон lon0091
       30/11/2004 madiyar - Списание штрафов
       03/12/2004 madiyar - для номера проводки по погашению индексации - своя переменная s-jhind
                            Потерянные кредиты - три новые линии в шаблоне lon0091
       06/05/2005 madiyar - убрал просроченную индексацию
       10/06/2005 madiyar - в проводку по индексации пишутся другие примечания
       14/06/2005 madiyar - печать опер. ордера по проводке по индексации
       20/06/2005 madiyar - вылетала ошибка "не могу найти транзакцию" при печати ордера по погашению индексации, исправил
       21/06/2005 madiyar - если основная проводка без линий - удаляем и номеру транзакции s-jh присваиваем номер транзакции по индексации
       02.11.2005 dpuchkov добавил номер очереди
       07/03/2006 Natalya D. - добавила "Касса в пути".
       04.04.2006 Natalya D. - добавила счёта АРП по валюте кредита и по нац.валюте для кассы в пути
       04/05/06 marinav Увеличить размерность поля суммы
       13.07.2006 Natalya D. - добавлена проверка юзера на наличие у него пакета прав, разрешающих проведение транзакций
       24/02/09   marinav - добавлено погашение через ARP
       03/11/2009 madiyar - провизии в той же валюте, что и кредит, проводки по валютным кредитам без использования счета конвертации
       28/04/2010 madiyar - исправил ошибку при списании валютного кредита
       29/04/2010 madiyar - списание штрафов по валютным кредитом
       30/09/2010 madiyar - поправил погашение с транзитного счета
       03/12/2010 madiyar - восстановление возобн. остатка по КЛ при погашении транша
       10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
       19/03/2011 madiyar - новый шаблон списания кредита
       23/05/2011 madiyar - разбил на транзакционные блоки
       25/07/2012 dmitriy - погашение комиссии по годовой ставке
       26/07/2012 dmitriy - погашение комиссии по годовой ставке только для сотрудников банка
       16.10.2012 dmitriy - возможность погашать комиссию по годовой ставке без основного долга (ТЗ 1551)
*/

{global.i}
{s-lonliz.i}
{comm-txb.i}
def var ja-ne as log format "да/нет".
def var vou-count as int.
def shared var s-ptype as int.

def shared var s-lon like lon.lon.
def shared var s-crc like crc.crc.
def shared var ppay like lon.opnamt.
def shared var ipay like lon.opnamt.
def shared var l-crc like crc.crc.
def shared var s-acc like aaa.aaa.
def shared var s-rmz like remtrz.remtrz.
def shared var s-gl like gl.gl.
def shared var s-arp as char.
def shared var nc-arp as char.
def shared var l-arp as char.
def shared var ppay1 as decimal.
def shared var ipay1 as decimal.

def shared var v-amtod as dec.
def shared var v-intod as dec.
def shared var v-amtbl as dec.
def shared var v-payod as dec.
def shared var v-payiod as dec.
def shared var v-payiod1 as dec.
def shared var v-paybl as dec.
def shared var v-payod1 as dec.
def shared var v-paybl1 as dec.
define shared variable sds-pay as decimal.
define shared variable sds-pay1 as decimal.
define shared variable komcl-pay1 as decimal.
define shared variable komprcr-pay1 as decimal.
define shared variable komvacc-pay1 as decimal.
define shared variable komprod-pay1 as decimal.
def shared var v-pay20 as dec.
def shared var v-pay22 as dec.

def var v-templ as char.
def var v-param as char.
def var vdel as char initial "^".
def var rcode as int.
def var rdes as char.
def var jparr as char.
def shared var s-jh like jh.jh.
def shared var s-jhind like jh.jh. /* номер проводки по погашению индексации */
def shared var s-jhkom like jh.jh init 0. /* номер проводки по погашению комиссии по годовой ставке */

def var v-remind2 as char.
def var v-remind3 as char.

def var jane as log.
def var v-nxt as int.

def var i as int.
def var v-tmpl as int.

def var v-amtint as dec.
def var v-prdint as dec.
def var v-intnc  as dec.
def var v-intnc1  as dec.
def var v-intnc2  as dec.

def var v-buyamt as dec.
def var v-selamt as dec.
def var v-buyamt1 as dec.
def var v-selamt1 as dec.
def buffer b-ofc for ofc.
def buffer b-lon for lon.
define var v-chk as char.

def var v-payi1 as dec. /*  Оплата просроченных процентов из предоплаты */
def var v-payi2 as dec. /*  Оплата процентов из предоплаты */
def var v-payi3 as dec. /*  Оплата просроченных процентов из источника */
def var v-payi4 as dec. /*  Оплата процентов из источника */
def var v-payi5 as dec. /*  Оплата предоплаты процентов из источника */
def var v-payi6 as dec.

/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
def var OK as logi initial false.
/*ja - EKNP - 26/03/2002 */

find lon where lon.lon = s-lon no-lock no-error.
find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc and trxbal.lev = 2 no-lock no-error.
if available trxbal then v-amtint = trxbal.dam - trxbal.cam. else v-amtint = 0.

find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = lon.crc and trxbal.lev = 10 no-lock no-error.
if available trxbal then v-prdint = trxbal.cam - trxbal.dam. else v-prdint = 0.

find trxbal where trxbal.sub = "lon" and trxbal.acc = lon.lon and trxbal.crc = 1 and trxbal.lev = 11 no-lock no-error.
if available trxbal then v-intnc = trxbal.cam - trxbal.dam. else v-intnc = 0.

v-param = "".
if s-ptype = 1 then v-templ = "lon0078".
if s-ptype = 2 then do:
    v-param = l-arp + vdel.
    v-templ = "lon0121".
end.
if s-ptype = 3 and lon.crc = s-crc then do:
    v-param = s-acc + vdel.
    v-templ = "lon0079".
end.
if s-ptype = 3 and lon.crc <> s-crc then v-templ = "lon0080".  /*для штрафов и комиссий со счета*/
if s-ptype = 4 then v-templ = "lon0017".

if s-ptype = 5 and lon.crc = s-crc then do:
    v-param = s-acc + vdel.
    v-templ = "lon0126".
end.
if s-ptype = 5 and lon.crc <> s-crc then v-templ = "lon0127".  /*для штрафов и комиссий со счета*/

/*погашение комиссии по годовой ставке*/
def var v-templ-kom as char.
def var v-param-kom as char.
if s-ptype = 3 or s-ptype = 5 then do:
    v-templ-kom = "lon0135".
    v-param-kom = s-acc.

end.

/*из общего платежа вычесть оплату индексации*/
ipay = ipay - v-pay22.

v-payi5 = ipay - (v-amtint + v-payiod - v-prdint) .

if v-payi5 >= 0 then
v-payi6 = v-intod - v-payiod.
else v-payi6 = v-intod - v-payiod - v-payi5 .
if lon.crc <> 1 then do:
    find crc where crc.crc = lon.crc no-lock no-error.
    v-payi6 = v-payi6 * crc.rate[1] / crc.rate[9].
end.
v-payi6 = v-intnc - v-payi6.
if v-payi6 < 0 then v-payi6 = 0.

if v-payi5 >= v-prdint then do:
    v-payi5 = v-payi5 - v-prdint.
    v-payi1 = 0.
    v-payi2 = 0.
    v-payi3 = v-payiod.
    v-payi4 = ipay - v-payi3 - v-payi5.
end.
else do :
    if v-payi5 >= 0 then v-payi1 = v-prdint - v-payi5.
    else v-payi1 = v-prdint.
    v-payi5 = 0.
    if v-payi1 > v-payiod1 then do:
        v-payi2 = v-payi1 - v-payiod.
        v-payi1 = v-payiod.
    end.
    else v-payi2 = 0.
    v-payi3 = v-payiod - v-payi1.
    v-payi4 = ipay - v-payi3.
end.

v-param = string(ppay - v-payod - v-paybl - v-pay20) + vdel +
          v-param + lon.lon + vdel +
          string(v-payod) + vdel +
          string(v-paybl) + vdel +
          string(v-payi4) + vdel +
          string(v-payi3) + vdel +
          string(v-payi5) + vdel +
          string(v-payi2) + vdel +
          string(v-payi1) + vdel +
          string(v-payi6) .

if s-ptype = 9 then do:
    v-templ = "LON0145".

    find crc where crc.crc eq s-crc no-lock no-error.

    /*
    v-payod - проср од
    v-payiod - проср проценты
    v-intnc - содержимое 11го уровня
    */

    v-param = string(v-payod) + vdel + /* начисляем на 13 уровень - списанная основная сумма кредита */
              lon.lon. /* ссудный счет */

    v-param = v-param + vdel +
              s-glremx[1] + vdel +
              s-glremx[2] + vdel +
              s-glremx[3] + vdel +
              s-glremx[4] + vdel +
              s-glremx[5].

    /*
    v-intnc1 = 0.
    v-intnc2 = 0.
    if v-intnc > v-payiod then v-intnc1 = v-payiod.
    else do: v-intnc1 = v-intnc. v-intnc2 = v-payiod - v-intnc. end.
    */

    v-param = v-param + vdel +
              string(v-payiod) + vdel + /* начисляем на 14 уровень - списанные % */
              string(v-payod) + vdel + /* погашаем проср од провизиями */
              string(v-payiod) + vdel + /* Дт 36 Кт 9 */
              string(sds-pay) + vdel + string(sds-pay). /* штрафы */

    find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "kdlost" and sub-cod.ccode = '01' no-lock no-error.
    if avail sub-cod then v-param = v-param + vdel + string(v-payod) + vdel + string(v-payiod) + vdel + string(sds-pay).
    else v-param = v-param + vdel + '0' + vdel + '0' + vdel + '0'.

end.

if lookup(v-templ, "lon0080,lon0127") > 0 then v-param = string(sds-pay1) + vdel + s-acc + vdel + lon.lon + vdel + string(komprcr-pay1).

v-param = v-param + vdel +
          s-glremx[1] + vdel +
          s-glremx[2] + vdel +
          s-glremx[3] + vdel +
          s-glremx[4] + vdel +
          s-glremx[5].

if lookup (v-templ, "lon0078,lon0079,lon0126") > 0 then
              v-param = v-param + vdel +
                        string(sds-pay1) + vdel +
                        string(komcl-pay1) + vdel +
                        string(komprcr-pay1) + vdel +
                        string(komvacc-pay1) + vdel +
                        string(komprod-pay1).

if lookup (v-templ, "lon0121") > 0 then
              v-param = v-param + vdel +
                        string(sds-pay1) + vdel + nc-arp + vdel +
                        string(komcl-pay1) + vdel +
                        string(komprcr-pay1) + vdel + nc-arp + vdel +
                        string(komvacc-pay1) + vdel +
                        string(komprod-pay1).

/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
run usrrights.
if return-value = '1' then run trxsim("", v-templ, vdel, v-param, 4, output rcode, output rdes, output jparr).
else do:
    message "У Вас нет прав для создания транзакции!" view-as alert-box.
    return "exit".
end.
/*end*/

if rcode ne 0 then do:
    message rdes.
    pause.
    undo, return.
end.

/* ja - EKNP - 26/03/2002 --------------------------------------------*/
run Collect_Undefined_Codes(v-templ).

run Parametrize_Undefined_Codes(output OK).

if not OK then do:
    bell.
    message "Не все коды введены! Транзакция не будет создана!" view-as alert-box.
    return "exit".
end.

run Insert_Codes_Values(v-templ, vdel, input-output v-param).
/* ja - EKNP - 26/03/2002 --------------------------------------------*/

s-jh = 0.

/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/

do transaction:

    run usrrights.
    if return-value = '1' then run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jh).
    else do:
        message "У Вас нет прав для создания транзакции!" view-as alert-box.
        return "exit".
    end.
    /*end*/

    if rcode ne 0 then do:
        message rdes.
        pause 10.
        undo, return.
    end.

    if ppay > 0 and lon.clmain <> '' and lon.trtype = 1 then do:
        find first b-lon where b-lon.lon = lon.clmain no-lock no-error.
        if avail b-lon then do:
            v-param = string (ppay) + vdel + lon.clmain.
            v-templ = "LON0137".
            find first loncon where loncon.lon = lon.clmain no-lock no-error.
            find first crc where crc.crc = lon.crc no-lock no-error.
            find first cif where cif.cif = lon.cif no-lock no-error.
            s-glremx[1] = "Создание возобн. дост. остатка КЛ, " + lon.clmain + " " + if avail loncon then loncon.lcnt else ''.
            s-glremx[1] = s-glremx[1] + " " + trim(string(ppay,">>>,>>>,>>>,>>>,>>>,>>9.99-")) + " " + crc.code +
                          " " + trim(trim(cif.prefix) + " " + trim(cif.name)) + " РНН " + cif.jss.
            v-param = v-param + vdel + s-glremx[1] + vdel + vdel + vdel + vdel.
            run trxgen (v-templ, vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            if rcode <> 0 then do:
                message rdes + " Ошибка создания возобн. дост. остатка КЛ!".
                pause 10.
            end.
        end.
    end.


    find first jl where jl.jh = s-jh no-error.
    if not available jl then do: /* создался только заголовок проводки, линий нет */
        find first jh where jh.jh = s-jh no-error.
        if avail jh then delete jh.
        s-jh = 0.
    end.
    else run lonresadd(s-jh).

    /* погашение индексации*/
    if v-pay20 > 0 or v-pay22 > 0 /*or v-pay23 > 0*/ then do:
        v-param = ''.
        if s-ptype eq 1 then v-templ = "lon0082".
        if s-ptype eq 2 then do:
            v-param = s-arp + vdel.
            v-templ = "lon0122".
        end.
        if s-ptype eq 3 then do:
            v-param = s-acc + vdel.
            v-templ = "lon0083".
        end.
        v-param = string(v-pay20) + vdel + v-param +
                  lon.lon + vdel +
                  /*string(v-pay21)*/ "0" + vdel +
                  string(v-pay22) + vdel +
                  /*string(v-pay23)*/ "0".

        if v-pay20 > 0 then v-remind2 = "Сумма погашаемой индексации ОД " + trim(string(v-pay20,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
        else v-remind2 = ''.

        if v-pay22 > 0 then v-remind3 = "Сумма погашаемой индексации %% " + trim(string(v-pay22,">>>,>>>,>>>,>>>,>>9.99-")) + " KZT".
        else v-remind3 = ''.

        v-param = v-param + vdel +
                  s-glremx[1] + vdel +
                  v-remind2 + vdel +
                  v-remind3 + vdel +
                  s-glremx[4] + vdel +
                  s-glremx[5].

        /*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
        run usrrights.
        if return-value = '1' then do:
            run trxsim("", v-templ, vdel, v-param, 4, output rcode, output rdes, output jparr).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
            run trxgen (v-templ, vdel, v-param, "lon" , lon.lon , output rcode, output rdes, input-output s-jhind).
            if rcode ne 0 then do:
                message rdes.
                pause 10.
                undo, return.
            end.
            run lonresadd(s-jhind).
        end.
        else do:
            message "У Вас нет прав для создания транзакции!" view-as alert-box.
            return "exit".
        end.
    end.
end. /* transaction */
/**/

if ppay-kom > 0 then do:
        /*------комиссия по годовой ставке ------------*/
        def buffer blons for lons.

        find first blons where blons.lon = lon.lon no-lock no-error.
        if avail blons then do:


        def buffer bjl for jl.
        def var v-code as char.
        def var v-dep as char.
        def var v-londog as char no-undo.
        def var bilance1 as deci.
        v-londog = ''.
        find first loncon where loncon.lon = lon.lon no-lock no-error.
        if avail loncon then v-londog = loncon.lcnt.

        find first cif where cif.cif = lon.cif no-lock no-error.
        find first crc where crc.crc = lon.crc no-lock no-error.
        find first aaa where aaa.aaa = s-acc no-lock no-error.
        {getdep.i}

        if v-templ-kom = "lon0135" then do:

            v-param-kom = string(ppay-kom) + vdel + s-acc + vdel +
            "Сумма погашаемой комиссии " + string(ppay-kom) + " " + crc.code + "" +
            vdel + "" +  vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel + "" + vdel .

            do transaction:
                run trxgen (v-templ-kom, vdel, v-param-kom, "lon" , lon.lon , output rcode, output rdes, input-output s-jhkom).
                {upd-dep.i}
            end.

            run lonbalcrc('lon',lon.lon, g-today,"1",yes,lon.crc,output bilance1).

            if rcode ne 0 then do:
              message rdes.
              pause 1000.
              next.
            end.

            find first lons where lons.lon = lon.lon exclusive-lock no-error.
            if avail lons then lons.amt = lons.amt - ppay-kom.
            find current lons no-lock.

            create lnscs.
            assign lnscs.lon = lon.lon
                   lnscs.sch = no
                   lnscs.stdat = g-today
                   lnscs.stval = ppay-kom.

            create lonsres.
            assign lonsres.lon = lon.lon
                   lonsres.restype = "p"
                   lonsres.fdt = g-today
                   lonsres.tdt = g-today
                   lonsres.od = bilance1
                   lonsres.prem = lons.prem
                   lonsres.amt = ppay-kom
                   lonsres.who = g-ofc.
        end.
        end.
        /*---------------------------------------------*/
end.

if s-jh = 0 and s-jhind > 0 then do:
    s-jh = s-jhind.
    s-jhind = 0.
end.

if s-jh = 0 and s-jhind = 0 and s-jhkom > 0 then do:
    s-jh = s-jhkom.
    s-jhkom = 0.
end.

find jh where jh.jh eq s-jh no-lock no-error.
if available jh then do:

    do transaction:

        if s-ptype = 4
        then do:
            find remtrz where remtrz.remtrz = s-rmz no-lock no-error.
            ja-ne = available remtrz.
            if ja-ne
            then do:
                find first que where que.remtrz = s-rmz no-lock no-error.
                if available que
                then do:
                    if remtrz.jh2 = s-jh and que.pid = "F"
                    then ja-ne = true.
                    else do:
                        run longoF(s-rmz,"LON",jh.jh,output ja-ne).
                    end.
                end.
            end.
            else do:
                bell.
                message "В операции не найден перевод !".
                pause.
                undo,return.
            end.
        end.

        if ppay - v-pay20 /*- v-pay21*/ > 0 then do:
            v-nxt = 0.
            for each lnsch where lnsch.lnn eq lon.lon no-lock:
                if lnsch.f0 = 0 and lnsch.flp > 0 then do:
                    if v-nxt < lnsch.flp then v-nxt = lnsch.flp.
                end.
            end.
            create lnsch.
            lnsch.lnn = lon.lon.
            lnsch.f0 = 0.
            lnsch.flp = v-nxt + 1.
            lnsch.schn = "   . ." + string(lnsch.flp,"zzzz").
            lnsch.paid = ppay - v-pay20 /*- v-pay21*/.
            lnsch.stdat = jh.jdt.
            lnsch.jh = jh.jh.
            lnsch.whn = g-today.
            lnsch.who = g-ofc.
        end.

        if ipay > 0 then do:
            v-nxt = 0.
            for each lnsci where lnsci.lni eq lon.lon no-lock :
                if lnsci.f0 eq 0 and lnsci.flp gt 0 then do:
                    if v-nxt lt lnsci.flp then v-nxt = lnsci.flp.
                end.
            end.
            create lnsci.
            lnsci.lni = lon.lon.
            lnsci.f0 = 0.
            lnsci.flp = v-nxt + 1.
            lnsci.schn = "   . ." + string(lnsci.flp,"zzzz").
            lnsci.paid-iv = ipay.
            lnsci.idat = jh.jdt.
            lnsci.jh = jh.jh.
            lnsci.whn = g-today.
            lnsci.who = g-ofc.
        end.

    end. /* transaction */

    /*Номер очереди*/
    if s-ptype = 1 or s-ptype = 2 then do transaction:
        find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
        if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/
            find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
            if not avail acheck then do:
                v-chk = "".
                v-chk = string(NEXT-VALUE(krnum)).
                create acheck.
                acheck.jh  = string(s-jh).
                acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                acheck.dt = g-today.
                acheck.n1 = v-chk.
                release acheck.
            end.
        end.
    end. /* transaction */
    /*Номер очереди*/



    /* pechat vauchera */
    ja-ne = no.
    vou-count = 1. /* kolichestvo vaucherov */
    do on endkey undo:
        message "Печатать ваучер ?" update ja-ne.
        if ja-ne then do:
            message "Сколько ?" update vou-count format "9" .
            if vou-count > 0 and vou-count < 10 then do:
                if s-jh > 0 then do:
                    find first jl where jl.jh = s-jh no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jh.
                        s-jh = jh.jh.

                        do i = 1 to vou-count:
                            if /*s-ptype = 1 or s-ptype = 2*/ s-jhkom = 0 then run vou_lon2(s-jh,'',1, "").
                            else run vou_lon3(s-jh,'',s-jhkom).
                        end.

                        find jh where jh.jh eq s-jh exclusive-lock.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5
                            then jl.sts = 5.
                        end.
                    end.  /* if available jl */
                    else do:
                        message "Не найдена транзакция " s-jh view-as alert-box.
                    end.
                end.

                /* опер.ордер по проводке с индексацией */
                if s-jhind > 0 then do:
                    find first jl where jl.jh = s-jhind no-error.
                    if available jl then do:
                        {mesg.i 0933} s-jhind.
                        do i = 1 to vou-count:
                            run vou_lon3(s-jhind,'1',s-jhkom).
                        end.
                        find jh where jh.jh eq s-jhind exclusive-lock.
                        if jh.sts < 5 then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5
                            then jl.sts = 5.
                        end.
                    end.  /* if available jl */
                    else do:
                        message "Не найдена транзакция " s-jhind view-as alert-box.
                    end.
                end. /* if s-jhind > 0 */
            end. /* if vou-count > 0 */
        end. /* if ja-ne */

        if lon.gua = "LK" then do on endkey undo:
            ja-ne = no.
            vou-count = 1.
            message "Печатать ордер-счет ?" update ja-ne.
            if ja-ne then do:
                message "Сколько ?" update vou-count.
                if vou-count > 0 and vou-count < 10 then do:
                    do i = 1 to vou-count:
                        run x-lonord.
                    end.
                end. /* if vou-count */
            end. /* if ja-ne */
        end.
    end.
    pause 0.
end.

/*ja - EKNP - 26/03/2002 -------------------------------------------*/
procedure Collect_Undefined_Codes.

    def input parameter c-templ as char.
    def var vjj as inte.
    def var vkk as inte.
    def var ja-name as char.

    for each w-cods:
        delete w-cods.
    end.
    for each trxhead where trxhead.system = substring (c-templ, 1, 3) and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:

        if trxhead.sts-f eq "r" then vjj = vjj + 1.

        if trxhead.party-f eq "r" then vjj = vjj + 1.

        if trxhead.point-f eq "r" then vjj = vjj + 1.

        if trxhead.depart-f eq "r" then vjj = vjj + 1.

        if trxhead.mult-f eq "r" then vjj = vjj + 1.

        if trxhead.opt-f eq "r" then vjj = vjj + 1.

        for each trxtmpl where trxtmpl.code eq c-templ no-lock:

            if trxtmpl.amt-f eq "r" then vjj = vjj + 1.

            if trxtmpl.crc-f eq "r" then vjj = vjj + 1.

            if trxtmpl.rate-f eq "r" then vjj = vjj + 1.

            if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.

            if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.

            if trxtmpl.dev-f eq "r" then vjj = vjj + 1.

            if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.

            if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.

            if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.

            if trxtmpl.cev-f eq "r" then vjj = vjj + 1.

            if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.

            repeat vkk = 1 to 5:
                if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
            end.

            for each trxcdf where trxcdf.trxcode = trxtmpl.code
                              and trxcdf.trxln = trxtmpl.ln:

                if trxcdf.drcod-f eq "r" then do:
                    vjj = vjj + 1.

                    find first trxlabs where trxlabs.code = trxtmpl.code
                                       and trxlabs.ln = trxtmpl.ln
                                       and trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.
                    create w-cods.
                    w-cods.template = c-templ.
                    w-cods.parnum = vjj.
                    w-cods.codfr = trxcdf.codfr.
                    w-cods.name = ja-name.
                end.

                if trxcdf.crcode-f eq "r" then do:
                    vjj = vjj + 1.

                    find first trxlabs where trxlabs.code = trxtmpl.code
                                       and trxlabs.ln = trxtmpl.ln
                                       and trxlabs.fld = trxcdf.codfr + "_Cr"
                                                            no-lock no-error.
                    if available trxlabs then ja-name = trxlabs.des.
                    else do:
                        find codific where codific.codfr = trxcdf.codfr no-lock no-error.
                        if available codific then ja-name = codific.name.
                        else ja-name = "Неизвестный кодификатор".
                    end.
                    create w-cods.
                    w-cods.template = c-templ.
                    w-cods.parnum = vjj.
                    w-cods.codfr = trxcdf.codfr.
                    w-cods.name = ja-name.
                end.
            end.
        end. /*for each trxtmpl*/
    end. /*for each trxhead*/

end procedure.

procedure Parametrize_Undefined_Codes.

  def var ja-nr as inte.
  def output parameter OK as logi initial false.
  def var jrcode as inte.
  def var saved-val as char.

  find first w-cods no-error.
  if not available w-cods then do:
    OK = true.
    return.
  end.

  {jabrew.i
   &start = " on help of w-cods.val in frame lon_cods do:
                  if w-cods.codfr = 'spnpl' then run uni_help1(w-cods.codfr,'4*').
                                            else run uni_help1(w-cods.codfr,'*').
              end.
              vkey = 'return'.
              key-i = 0. "

   &head = "w-cods"
   &headkey = "parnum"
   &where = "true"
   &formname = "lon_cods"
   &framename = "lon_cods"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
   &predisplay = " ja-nr = ja-nr + 1. "
   &display = "ja-nr /*w-cods.codfr*/ w-cods.name /*w-cods.what*/ w-cods.val"
   &highlight = "ja-nr"
   &postkey = "else if vkeyfunction = 'return' then do:
               valid:
               repeat:
                saved-val = w-cods.val.
                update w-cods.val with frame lon_cods.
                find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                if not available codfr or codfr.code = 'msc' then do:
                   bell.
                   message 'Некорректное значение кода! Введите правильно!'
                           view-as alert-box.
                   w-cods.val = saved-val.
                   display w-cods.val with frame lon_cods.
                   next valid.
                end.
                else leave valid.
               end.
                if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                  key-i = 0.
                  vkey = 'cursor-down^return'.
                end.
               end.
               else if keyfunction(lastkey) = 'GO' then do:
                   jrcode = 0.
                 for each w-cods:
                  find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                  if not available codfr or codfr.code = 'msc' then jrcode = 1.
                 end.
                 if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                 end.
                 else do: OK = true. leave upper. end.
               end."
   &end = "hide frame lon_cods.
           hide message."
}

end procedure.

procedure Insert_Codes_Values.

    def input parameter t-template as char.
    def input parameter t-delimiter as char.
    def input-output parameter t-par-string as char.
    def var t-entry as char.

    for each w-cods where w-cods.template = t-template break by w-cods.parnum:
        t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
        if ERROR-STATUS:error then t-par-string = t-par-string + t-delimiter + w-cods.val.
        else do:
            entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
            entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
        end.
    end.

end procedure.
/*ja - EKNP - 26/03/2002 ------------------------------------------*/
