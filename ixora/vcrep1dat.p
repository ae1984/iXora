/* vcrep1dat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 1 - отчет о платежах по контрактам, где нет рег/свид-ва
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER
        vcrepa13.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM TXB
 * AUTHOR
        28.04.2008 galina
 * CHANGES
        04.05.2008 galina - для контрактов типа 7 учитывать дату выдачи свидетельства об уведомлении
        19.05.2008 galina - не выводить в отчет закрытые контракты
        02/11/2009 galina - изменения по суммам согласно ТЗ 577 от 29/10/2009
                            добавила БИН
        02/11/2010 galina - добавила коды новые операции 16 и 17
                            добавила столбцы э/и и тип контракта
        14.12.2010 aigul - убрала проверку для поля ВОЗВРАТ
                           если экспорт и 02 - извещ, то Отправитель бенефициар
                           если импорт и 03 - поруч, то Отправитель наш клиент
        02.03.2011 aigul - добавила 1 тип контракта с кнп 740 или 8 группы суммой > 100 000 USD
        18.04.2011 aigul - исправила вывод страны у vcdocs.dntype = "03" на v-country = "KZ".
        16.05.2012 aigul - проверка даты платежа с датой СУ


*/


{vc.i}
def shared var g-ofc  like txb.ofc.ofc.
define shared var g-today  as date.
{vc-crosscurs_txb.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.

def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-country as char no-undo.
def var v-secek as char no-undo.
def var v-rnnben as char no-undo.
def var v-partner as char no-undo.
def var v-partnername as char no-undo.
def var v-countryben as char no-undo.
def var v-secekben as char no-undo.
def var v-locat as char no-undo.
def var v-locatben as char no-undo.
def var v-opertype as char no-undo.
def var v-clntype as integer no-undo.
def var v-note as char no-undo.
def var v-bin as char no-undo.
def var v-cursdoc-usd as deci no-undo.

def shared temp-table t-docs
  field dndate like vcdocs.dndate
  field docs like vcdocs.docs
  field opertype as char
  field sum like vcdocs.sum
  field name like txb.cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as char
  field rnn as char format "999999999999"
  field secek as char
  field country as char
  field rnnben as char format "999999999999"
  field secekben as char
  field countryben as char
  field strsum as char
  field locat as char
  field locatben as char
  field note as char
  field bin as char
  field expimp as char
  field cttype as char

  index main is primary dndate sum docs.

ct:
for each vccontrs where vccontrs.bank = p-vcbank and
(vccontrs.cttype = '13' or vccontrs.cttype = '7' or vccontrs.cttype = '4' or vccontrs.cttype = '5'
or vccontrs.cttype = '8' or vccontrs.cttype = '3' or vccontrs.cttype = '10' or vccontrs.cttype = '1') no-lock:
    /*if vccontrs.sts = 'C' then next ct.*/

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
    if not avail txb.cif then next.
    if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then v-clntype = 1.
    if (txb.cif.type = 'P' and txb.cif.cgr = 501) or (txb.cif.type = 'B' and txb.cif.cgr = 403) then v-clntype = 2.
    v-bin = trim(txb.cif.bin).
    if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.
    dc:
    for each vcdocs where vcdocs.contract = vccontrs.contract and
    (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
    vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte
    no-lock:
        /*if vccontrs.cttype = '7' then do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64")
            and vcrslc.dndate <= vcdocs.dndate
            no-lock no-error.
            if avail vcrslc then next ct.
        end.
        else do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and (vcrslc.dntype = "21" or vcrslc.dntype = "64")
            and vcrslc.lastdate >= vcdocs.dndate
            no-lock no-error.
            if avail vcrslc then next ct.
        end.*/
        if (vccontrs.cttype = '3' or vccontrs.cttype = '4' or vccontrs.cttype = '5'
        or vccontrs.cttype = '7' or  vccontrs.cttype = '8' or vccontrs.cttype = '10'
        or vccontrs.cttype = '13') then do:
            find last vcrslc where vcrslc.contract = vccontrs.contract and (/*vcrslc.dntype = "21" or*/ vcrslc.dntype = "64")
            no-lock no-error.
            if avail vcrslc and vcrslc.dndate <= vcdocs.dndate then next ct.
        end.
        run crosscurs(vcdocs.pcrc, 2, vcdocs.dndate, output v-cursdoc-usd).
        if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdocs.info[4].
        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if avail vcpartner then do:
            find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'secek'.
            /*определим код операции для конракта типа 7,5*/
            v-note = "".
            case vccontrs.cttype:
                when '5' then do:
                    if vcdocs.sum / v-cursdoc-usd <= 100000 then next dc.
                    else do:
                        v-opertype = '06'.
                        if v-clntype = 2 then v-note = cif.addr[2].
                        else v-note = vcdocs.info[1].
                    end.
                end.
                when '7' then do:
                    v-opertype = '03'.
                    if v-clntype = 2 then v-note = cif.addr[2].
                    else v-note = vcdocs.info[1].
                end.
                when '3' then do:
                    if vcdocs.sum / v-cursdoc-usd <= 100000 then next dc.
                    else do:
                        v-opertype = '16'.
                        if v-clntype = 2 then v-note = cif.addr[2].
                        else v-note = vcdocs.info[1].
                    end.
                end.
                when '10' then do:
                    if vcdocs.sum / v-cursdoc-usd <= 500000 then next dc.
                    else do:
                        v-opertype = '17'.
                        if v-clntype = 2 then v-note = cif.addr[2].
                        else v-note = vcdocs.info[1].
                    end.
                end.
                when '1' then do:
                    if vcdocs.knp = "740" or vcdocs.knp matches "8*" then do:
                        if vcdocs.sum / v-cursdoc-usd <= 100000 then next dc.
                        else do:
                            v-opertype = '16'.
                            if v-clntype = 2 then v-note = cif.addr[2].
                            else v-note = vcdocs.info[1].
                        end.
                    end.
                    else next.
                end.
            end case.
            if vccontrs.expimp = "i" then do:
            /*Определим код операции для остальных контрактов*/
                case vccontrs.cttype:
                    when '13' then do:
                        case v-clntype:
                            when 1 then do:
                                if vccontrs.ctsum / vccontrs.cursdoc-usd <= 100000  then next ct.
                                else v-opertype = '01'.
                            end.
                            when 2 then do:
                                if vcdocs.sum / v-cursdoc-usd <= 100000 then next dc.
                                else v-opertype = '13'.
                            end.
                        end case.
                        v-note = vcdocs.info[1].
                    end.
                    when '4' then do:
                        if vccontrs.ctsum / vccontrs.cursdoc-usd <= 100000 then next ct.
                        else do:
                           v-opertype = '04'.
                           if v-clntype = 2 then v-note = cif.addr[2].
                           else v-note = vcdocs.info[1].
                        end.
                    end.
                    when '8' then do:
                        if /*vccontrs.ctsum / vccontrs.cursdoc-usd*/ vcdocs.sum / v-cursdoc-usd  <= 500000 then next dc /*ct*/.
                        else v-opertype = '11'.
                        v-note = vcdocs.info[1].
                    end.
                end case.
            end.
            /*if vccontrs.expimp = "i" or (vccontrs.cttype = '7' and vcdocs.dntype = "03") then do:*/
            if vcdocs.dntype = "02" then do:
                /*если импорт и yes, то отправитель - бенефициар, получатель - наш*/
                /* if vcdocs.payret then do:*/
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-country = vcpartner.country.
                v-rnn = "".
                v-secek = vcpartner.info[2].
                if vcpartner.country = "KZ" then v-locat = "1".
                                            else v-locat = "2".
                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
                v-countryben = "KZ".
                if v-clntype = 1 then v-rnnben = txb.cif.ssn.
                if v-clntype = 2 then v-rnnben = txb.cif.jss.
                v-secekben = txb.sub-cod.ccode.
                /*end.*/
                /*если импорт и no, то отправитель - наш, получатель - бенефициар*/
                /*if vcdocs.payret = no then do:
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-country = "KZ" .
                if v-clntype = 1 then v-rnn = cif.ssn.
                if v-clntype = 2 then v-rnn = cif.jss.
                v-secek = txb.sub-cod.ccode.
                v-locat = substr (txb.cif.geo, 3, 1).
                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-countryben = vcpartner.country.
                v-rnnben = "".
                v-secekben = vcpartner.info[2].
                if vcpartner.country = "KZ" then v-locatben = "1".
                else v-locatben = "2".
                end.*/
            end.
            if vccontrs.expimp = "e" then do:
                /*Определим код операции для остальных контрактов*/
                case vccontrs.cttype:
                    when '13' then do:
                        case v-clntype:
                            when 1 then do:
                                if vccontrs.ctsum / vccontrs.cursdoc-usd <= 500000  then next ct.
                                else v-opertype = '02'.
                            end.
                            when 2 then do:
                                if vcdocs.sum / v-cursdoc-usd <= 500000 then next dc.
                                else v-opertype = '14'.
                            end.
                        end case.
                        v-note = vcdocs.info[1].
                    end.
                    when '4' then do:
                        if vccontrs.ctsum / vccontrs.cursdoc-usd <= 500000 then next ct.
                        else do:
                            v-opertype = '05'.
                            if v-clntype = 2 then v-note = cif.addr[2].
                            else v-note = vcdocs.info[1].
                        end.
                    end.
                    when '8' then do:
                        if /*vccontrs.ctsum / vccontrs.cursdoc-usd*/ vcdocs.sum / v-cursdoc-usd  <= 500000 then next /*ct*/ dc.
                        else v-opertype = '12'.
                        v-note = vcdocs.info[1].
                    end.
                end case.
            end.
            /*if vccontrs.expimp = "e" or (vccontrs.cttype = '7' and vcdocs.dntype = "02")then do:*/
            if vcdocs.dntype = "03" then do:
                /*если экспорт и yes, то отправитель - наш, получатель - бенефициар*/
                /*if vcdocs.payret then do:*/
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-country = "KZ".
                if v-clntype = 1 then v-rnn = cif.ssn.
                if v-clntype = 2 then v-rnn = cif.jss.
                v-secek = txb.sub-cod.ccode.
                v-locat = substr (txb.cif.geo, 3, 1).

                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                if vcpartner.country = "KZ" then v-locatben = "1".
                                            else v-locatben = "2".
                v-countryben = vcpartner.country.
                v-rnnben = "".
                v-secekben = vcpartner.info[2].
                /*end.*/
                /*если экспорт и no, то отправитель - бенефициар, получатель - наш*/
                /*if vcdocs.payret = no then do:
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-country = vcpartner.country.
                v-rnn = "".
                v-secek = vcpartner.info[2].
                if vcpartner.country = "KZ" then v-locat = "1".
                else v-locat = "2".
                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
                v-countryben = "KZ".
                if v-clntype = 1 then v-rnnben = cif.ssn.
                if v-clntype = 2 then v-rnnben = cif.jss.
                v-secekben = txb.sub-cod.ccode.
                end.*/
            end.
        end.
        else do:
          v-partnername = "".
          v-locatben = "".
          v-countryben = "".
          v-secekben = "".
        end.
        find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
        create t-docs.
        assign t-docs.dndate = vcdocs.dndate
        t-docs.opertype = v-opertype
        t-docs.sum = vcdocs.sum / 1000
        t-docs.name = v-name
        t-docs.partner = v-partnername
        t-docs.knp = vcdocs.knp
        t-docs.codval = txb.ncrc.code
        t-docs.rnn = v-rnn
        t-docs.locat = v-locat
        t-docs.locatben = v-locatben
        t-docs.note = v-note
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99"))
        t-docs.secek = v-secek
        t-docs.country = v-country
        t-docs.rnnben  = v-rnnben
        t-docs.secekben = v-secekben
        t-docs.countryben = v-countryben
        t-docs.docs = vcdocs.docs
        t-docs.bin = v-bin.
        t-docs.expimp = vccontrs.expimp.
        t-docs.cttype = vccontrs.cttype.
    end.
end.