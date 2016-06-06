/* vcrep13dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 13 - отчет о платежах по контрактам, где есть рег/свид-ва
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER
        vcrepa13.p
 * SCRIPT

 * INHERIT

 * MENU
        15.4.x.1
 * AUTHOR
        20.03.2003 nadejda
 * CHANGES
        22.08.2003 nadejda - изменения в связи с новой формой отчета от 11.08.2003 по письму НБ РК - добавлены признаки резидентства, сумма пойдет в тысячах
        04.09.2006 u00600  - добавила условие по свидетельству с уведомлением or vcrslc.dntype = "64" в 2 последних условия
        31.10.2006 u00600  - убрала проставление минус в сумме по vcdocs.payret
                             также наименование отправителя и бенефициара в зависимости от контракта (импорт, экспорт) и возврат-не возврат
                             по ТЗ ї505 от 30.10.2006
        29.04.2008 galina - выводим буквенный код валюты платежа
        19.05.2008 galina - не выводить в отчет закрытые контракты
        04.07.2008 galina - определине отправителя и получателя займа для финансовых займов (тип 6)
        08.08.2008 galina - определине отправителя и получателя займа для дог7оворов на открытие счетов (тип 7)
        09.04.2009 galina - изменила отправителя и получателя займа для финансовых займов (тип 6)
        14.12.2010 aigul - убрала проверку для поля ВОЗВРАТ
                           если экспорт и 02 - извещ, то Отправитель бенефициар
                           если импорт и 03 - поруч, то Отправитель наш клиент
        06.01.2011 aigul - добавила вывод сумм залогов, убрала проверку посл даты рег свид типов 21 и 64
        04.08.2011 aigul - если 02 - извещ, то Отправитель бенефициар
                           если 03 - поруч, то Отправитель наш клиент
        16.05.2012 aigul - проверка даты платежа с датой СУ
        03.07.2013 damir - Исправлена тех.ошибка.
*/


{vc.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.

def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-partner as char no-undo.
def var v-partnername as char no-undo.
def var v-locat as char no-undo.
def var v-locatben as char no-undo.


def shared temp-table t-docs
  field dndate like vcdocs.dndate
  field sum like vcdocs.sum
  field docs like vcdocs.docs
  field dnrslc like vcrslc.dnnum
  field name like txb.cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as char
  field ctnum like vccontrs.ctnum
  field ctdate like vccontrs.ctdate
  field rnn as char format "999999999999"
  field strsum as char
  field locat as char
  field locatben as char
  field note as char
  index main is primary dndate sum docs.

for each vccontrs where vccontrs.bank = p-vcbank no-lock:
    /*if vccontrs.sts = 'C' then next.*/
    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    /*if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.*/
    /*v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)). */
    if not trim(txb.cif.jss) begins "0000" then v-rnn = trim(txb.cif.jss).
    else v-rnn = "".
    /*v-locat = substr (txb.cif.geo, 3, 1).*/
    for each vcdocs where vcdocs.contract = vccontrs.contract and
    (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
    vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte
    no-lock:
        find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64")
        and vcrslc.dndate <= vcdocs.dndate no-lock no-error.
        if not avail vcrslc then next.
        if (vccontrs.cttype = '3' or vccontrs.cttype = '4' or vccontrs.cttype = '5'
        or vccontrs.cttype = '7' or  vccontrs.cttype = '8' or vccontrs.cttype = '10'
        or vccontrs.cttype = '13') then do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64")
            /*and vcrslc.lastdate >= vcdocs.dndate*/ no-lock no-error.
            if avail vcrslc and vcrslc.dndate > vcdocs.dndate then next.
        end.
                /*find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64") no-lock no-error.
                find txb.ppoint where txb.ppoint.depart = integer(txb.cif.jame) mod 1000 no-lock no-error.
                message skip " Обнаружен платеж с просроченным рег.свид-вом!" skip
                " Банк " vccontrs.bank " " txb.ppoint.name skip
                " Клиент " vccontrs.cif v-name skip
                " Контракт " vccontrs.ctnum " от " vccontrs.ctdate skip
                " Последнее рег.св-во " vcrslc.dnnum " от " vcrslc.dndate skip
                "      срок действия по " vcrslc.lastdate
                skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
            end.*/
        if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdocs.info[4].
        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if avail vcpartner then do:
            if vcdocs.dntype = "03" then do:
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locat = substr (txb.cif.geo, 3, 1).
                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                if vcpartner.country = "KZ" then v-locatben = "1".
                else v-locatben = "2".
            end.
            if vcdocs.dntype = "02" then do:
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                if vcpartner.country = "KZ" then v-locat = "1".
                else v-locat = "2".
                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
            end.
            /*для конратов на открытие счета*/
            if vccontrs.cttype = "7" then do:
                if vcdocs.dntype = "02" then do:
                    /*if vcdocs.payret = no then do:*/
                    v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                    if vcpartner.country = "KZ" then v-locat = "1".
                    else v-locat = "2".
                    v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                    v-locatben = substr (txb.cif.geo, 3, 1).
                end.
                if vcdocs.dntype = "03" then do:
                    /*if vcdocs.payret = no then do:*/
                    v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                    v-locat = substr (txb.cif.geo, 3, 1).
                    v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                    if vcpartner.country = "KZ" then v-locatben = "1".
                    else v-locatben = "2".
                end.
            end.
        end.
        else do:
            v-partnername = "".
            v-locatben = "".
        end.
        find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.

        create t-docs.
        t-docs.dndate = vcdocs.dndate.
        t-docs.sum = vcdocs.sum / 1000.
        t-docs.docs = vcdocs.docs.
        if avail vcrslc then t-docs.dnrslc = vcrslc.dnnum.
        t-docs.name = v-name.
        t-docs.partner = v-partnername.
        t-docs.knp = vcdocs.knp.
        t-docs.codval = txb.ncrc.code.
        t-docs.ctnum = vccontrs.ctnum.
        t-docs.ctdate = vccontrs.ctdate.
        t-docs.rnn = v-rnn.
        t-docs.locat = v-locat.
        t-docs.locatben = v-locatben.
        t-docs.note = vcdocs.info[1].
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
    end.
    /*для конратов с залогами*/
    for each vcdolgs where vcdolgs.contract = vccontrs.contract and
    (vcdolgs.dntype = "26" or vcdolgs.dntype = "27") and
    vcdolgs.dndate >= v-dtb and vcdolgs.dndate <= v-dte
    no-lock:
        find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64")
        /*and vcrslc.lastdate >= vcdolgs.dndate*/
        no-lock no-error.
        if not avail vcrslc then do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64") no-lock no-error.
            find txb.ppoint where txb.ppoint.depart = integer(txb.cif.jame) mod 1000 no-lock no-error.
            message skip " Обнаружен платеж с просроченным рег.свид-вом!" skip
            " Банк " vccontrs.bank " " txb.ppoint.name skip
            " Клиент " vccontrs.cif v-name skip
            " Контракт " vccontrs.ctnum " от " vccontrs.ctdate skip
            " Последнее рег.св-во " vcrslc.dnnum " от " vcrslc.dndate skip
            "      срок действия по " vcrslc.lastdate
            skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
        end.
        if vcdolgs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdocs.info[4].
        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if avail vcpartner then do:
            if vcdolgs.dntype = "26" then do:
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locat = substr (txb.cif.geo, 3, 1).
                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                if vcpartner.country = "KZ" then v-locatben = "1".
                else v-locatben = "2".
            end.
            if vcdolgs.dntype = "27" then do:
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                if vcpartner.country = "KZ" then v-locat = "1".
                else v-locat = "2".
                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
            end.
        end.
        else do:
            v-partnername = "".
            v-locatben = "".
        end.
        find txb.ncrc where txb.ncrc.crc = vcdolgs.pcrc no-lock no-error.
        create t-docs.
        assign t-docs.dndate = vcdolgs.dndate
        t-docs.sum = vcdolgs.sum / 1000
        t-docs.docs = vcdolgs.dolgs.
        if avail vcrslc then t-docs.dnrslc = vcrslc.dnnum.
        t-docs.name = v-name.
        t-docs.partner = v-partnername.
        t-docs.knp = vcdolgs.knp.
        t-docs.codval = txb.ncrc.code.
        t-docs.ctnum = vccontrs.ctnum.
        t-docs.ctdate = vccontrs.ctdate.
        t-docs.rnn = v-rnn.
        t-docs.locat = v-locat.
        t-docs.locatben = v-locatben.
        t-docs.note = vcdolgs.info[1].
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99")).
    end.

end.