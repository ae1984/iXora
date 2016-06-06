/* vcmsg111out.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
       Вывод МТ111
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK COMM
 * AUTHOR
       20.08.2008 galina
 * CHANGES
       05.09.2008 galina - добавила поле bankokpo во временную таблицу
       18/11/2008 galina - добавила поле repdate
                           обязательно выводим поля CODECALC, CURRENCY
                           не выводим сумму для закрытых ПС

       05/12/2008 galina - убрала двойной вывод строк для полей CODECALC, CURRENCY, вывела сумму конракта для не закрытого конракта
       09/01/2009 galina - убрала вывод нуля для полей SIGN, ESIGN для закрытых конрактов
                           убрала вывод пробелов для поля TERM для закрытых конрактов
       26/02/2009 galina - не выводим лишние поля для доплистов
       11.06.2009 galina - немного подкорректировала дату отчета
       29/10/2009 galina - не выводим рег.свидетельства, лицензии, свидетельства об уведомлении
       08/02/2010 galina - в вычисляемом курсе валютной оговорки выводим две цифры после запятой
       30/09/2010 galina - добавила "/" после ASFOUND и NRCOUNTRY в сообщение типа 2
       08/10/2010 galina - добавила примечание
       04/11/2010 galina - добавляем 0000 для ОКПО банка в ЦО
       09/11/2010 galina - перекомпиляция
       29/11/2010 aigul - вывод строк CCLAUSE и CCLAUSEDETAIL только по одному разу
       8/12/2010 aigul  - вывод измененной суммы CSUMM в ПсДлДс
       01.04.2011 aigul - вывод  CCLAUSE и CCLAUSEDETAIL по 1 разу для каждой валюты отличающей от валюты контракта
       19.04.2011 damir - добавлены bin,iin,bnkbin в t-ps.
                          v-bin,v-iin,v-bnkbin
       28.04.2011 damir - поставлены ключи. процедура chbin.i
       08.09.2011 damir - Добавил v-oper = '2' - изменение ранее направленой информации, добавил алгоритм вывода валютной оговорки в
                          v-oper = '1', старый был неправильный. Добавлены поля field - corrinfo, newval1, newval2, valplnew.
       30.09.2011 damir - добавил okpoprev в  temp-table t-ps.
       11.11.2011 damir - перекомпиляция
       06.12.2011 damir - убрал chbin.i, добавил vcmtform.i
       29.06.2012 damir - oper_type, внедрено Т.З. № 1355.
       04.07.2012 damir - v-MTviewbi, поля с БИНами и ИИНами есть, но они пустые.
       13.08.2013 damir - Внедрено Т.З. № 1559,1308..
       09.10.2013 damir - Т.З. № 1670.
       */
{vc.i}
{global.i}
{comm-txb.i}
{vc-crosscurs.i}
{vcmtform.i}
{vcshared5.i}
{srvcheck.i}

def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".

def var v-god as inte format "9999".
def var v-month as inte format "99".
def var v-day as inte format "99".
def var v-cursdoc as deci no-undo.
def var i as inte no-undo.
def var j as inte no-undo.
def var k as inte no-undo.
def var v-ctvalpl as char no-undo.
def var v-ctogval as char no-undo.
def var v-ctvalpl_int as inte no-undo.
def var v-valogdet as char.
def var tempstr as char.
def var v-ogov2 as char init "".
def var v-val2 as char init "".
def var v-num2 as char init "".
def var r2 as inte.
def var v-ogov as char init "".
def var v-val as char init "".
def var v-num as char init "".
def var r as inte.

v-god = year(g-today).
v-month = month(g-today).
v-day = day(g-today).

/* путь к каталогу исходящих телеграмм */
find vcparams where vcparams.parcode = "mtpathou" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mtpathou !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

if isProductionServer() then do:
    v-dir = vcparams.valchar.
    v-ipaddr = "Administrator@fs01.metrobank.kz".
end.
else do:
    v-dir = "C:/VC111/".
    v-ipaddr = "Administrator@`askhost`".
end.

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") + string(day(g-today), "99") + "/".

/* проверка существования каталога за сегодняшнее число */
output to sendtest.
put "Ok".
output close .

input through value("scp -q sendtest " + v-ipaddr + ":" + v-dir + ";echo $?" ).
repeat :
    import v-exitcod.
end.

unix silent rm -f sendtest.

if v-exitcod <> "0" then do :
  message skip " Не найден каталог " + replace(v-dir, "/", "\\")
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.

find first cmp no-lock no-error.

if v-oper = '1' then do:
    for each t-ps no-lock:
        {vcmsgparam_new.i &msg = "111"}
        if t-ps.repdate <> ? then do:
            v-text = "/REPORTDATE/" +  string(day(t-ps.repdate),'99') + string(month(t-ps.repdate),'99') + string(year(t-ps.repdate),'9999').
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "/REPORTDATE/".
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "/BANKOKPO/".
                put stream rpt unformatted v-text skip.

                if t-ps.bnkbin <> "" then do:
                    v-text = "/BANKBIN/" + t-ps.bnkbin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "/BANKBIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                v-text = "/BANKOKPO/".
                if length(t-ps.bankokpo) < 12 then v-text = v-text + t-ps.bankokpo + '0000'.
                else v-text = v-text + t-ps.bankokpo.
                put stream rpt unformatted v-text skip.

                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/OPER/" + t-ps.oper.
        put stream rpt unformatted v-text skip.

        v-text = "/PREVNUMBER/".
        put stream rpt unformatted v-text skip.

        v-text = "//PREVDATE/".
        put stream rpt unformatted v-text skip.

        if t-ps.okpoprev <> "" then do:
            v-text = "//PREVBANKOKPO/" + t-ps.okpoprev.
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "//PREVBANKOKPO/".
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            v-text = "//PREVBANKBIN/".
            put stream rpt unformatted v-text skip.
        end.

        v-text = "/PSNUMBER/" + t-ps.psnum.
        put stream rpt unformatted v-text skip.

        v-text = "//PSDATE/" +  string(day(t-ps.psdate),'99') + string(month(t-ps.psdate),'99') + string(year(t-ps.psdate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "/NAME/" + substr(t-ps.cifname, 1, 100).
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            if (integer(t-ps.cif_rfkod1) > 0 and length(t-ps.cif_rfkod1) < 12) then do:
                t-ps.cif_rfkod1 = t-ps.cif_rfkod1 + fill("0", 12 - length(t-ps.cif_rfkod1)).
                v-text = "//OKPO/" + t-ps.cif_rfkod1.
            end.
            else if (integer(t-ps.cif_rfkod1) = 0) then v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-ps.cif_jss.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "//OKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/".
                put stream rpt unformatted v-text skip.

                if t-ps.bin <> "" then do:
                    v-text = "//BIN/" + t-ps.bin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.
                end.
                if t-ps.iin <> "" then do:
                    v-text = "//IIN/" + t-ps.iin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                if (integer(t-ps.cif_rfkod1) > 0 and length(t-ps.cif_rfkod1) < 12) then do:
                    t-ps.cif_rfkod1 = t-ps.cif_rfkod1 + fill("0", 12 - length(t-ps.cif_rfkod1)).
                    v-text = "//OKPO/" + t-ps.cif_rfkod1.
                end.
                else if (integer(t-ps.cif_rfkod1) = 0) then v-text = "//OKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/" + t-ps.cif_jss.
                put stream rpt unformatted v-text skip.

                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.

                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/" + replace(string(t-ps.cif_type),'0','').
        put stream rpt unformatted v-text skip.

        v-text = "//REGION/" + t-ps.cif_region.
        put stream rpt unformatted v-text skip.

        v-text = "//PFORM/" + t-ps.cifprefix.
        put stream rpt unformatted v-text skip.

        v-text = "//EISIGN/" + replace(string(t-ps.ctexpimp),'0','').
        put stream rpt unformatted v-text skip.

        v-text = "/CONTRACT/" + t-ps.ctnum.
        put stream rpt unformatted v-text skip.

        if t-ps.ctdate <> ? then
        v-text = "//CDATE/" + string(day(t-ps.ctdate),'99') + string(month(t-ps.ctdate),'99') + string(year(t-ps.ctdate),'9999').
        else v-text = "//CDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "//CURRENCY/".
        put stream rpt unformatted v-text skip.

        if t-ps.ctclosedt = ? and t-ps.ctsum > 0 then v-text = "//CSUMM/" + replace(trim(string(t-ps.ctsum, '>>>>>>>>>>>>9.99')),'.',',').
        else v-text = "//CSUMM/".
        put stream rpt unformatted v-text skip.

        v-text = "//CCURR/" + t-ps.ctncrc.
        put stream rpt unformatted v-text skip.

        v-text = "//CCLAUSE/".
        put stream rpt unformatted v-text skip.
        v-text = "//CCLAUSEDETAIL/".
        put stream rpt unformatted v-text skip.

        v-text = "//CLASTDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "/NRNAME/" + t-ps.partner_name.
        put stream rpt unformatted v-text skip.

        v-text = "//NRCOUNTRY/" + t-ps.partner_country.
        put stream rpt unformatted v-text skip.

        if trim(t-ps.ctterm) <> "" then v-text = "/TERM/" + string(t-ps.ctterm,'999.99').
        else v-text = "/TERM/".
        put stream rpt unformatted v-text skip.

        v-text = "/CODECALC/".
        put stream rpt unformatted v-text skip.

        v-text = "/ADDSHEET/" + t-ps.psnum_19.
        put stream rpt unformatted v-text skip.

        if t-ps.psdate_19 <> ? then v-text = "//ASDATE/" + string(day(t-ps.psdate_19),'99') + string(month(t-ps.psdate_19),'99') + string(year(t-ps.psdate_19),'9999').
        else v-text = "//ASDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "//ASFOUND/".
        put stream rpt unformatted v-text skip.

        if t-ps.ctclosedt <> ? then v-text = "/CLOSEDATE/" + string(day(t-ps.ctclosedt),'99') + string(month(t-ps.ctclosedt),'99') + string(year(t-ps.ctclosedt),'9999').
        else v-text = "/CLOSEDATE/".
        put stream rpt unformatted v-text skip.

        v-text = "//CLOSEFOUND/" + t-ps.ctclosereas.
        put stream rpt unformatted v-text skip.

        put stream rpt unformatted "/NOTE/".
        if trim(t-ps.note) <> '' then do:
            j = length(t-ps.note).
            i = 1.
            repeat:
                put stream rpt unformatted trim(caps(substr(t-ps.note,i,100))) SKIP.
                j = j - 100.
                if j <= 0 then leave.
                i = i + 100.
            end.
        end.
        else put stream rpt unformatted skip.

        {vcmsgend.i &msg = "111"}
    end.
end.

if v-oper = '2' then do:
    for each t-dc no-lock:
        if t-dc.dtcorrect - t-dc.ctregdt > 180 then do:
            {vcmsgparam_new.i &msg = "111"}

            run EmptyMT.

            {vcmsgend.i &msg = "111"}
        end.
        else do:
            {vcmsgparam_new.i &msg = "111"}

            v-text = "/REPORTDATE/" + string(v-day,'99') + string(v-month,'99') + string(v-god,'9999').
            put stream rpt unformatted v-text skip.

            if v-bin then do:
                if v-MTviewbi = yes then do:
                    v-text = "/BANKOKPO/".
                    put stream rpt unformatted v-text skip.

                    if t-dc.bnkbin <> "" then do:
                        v-text = "/BANKBIN/" + t-dc.bnkbin.
                        put stream rpt unformatted v-text skip.
                    end.
                    else do:
                        v-text = "/BANKBIN/".
                        put stream rpt unformatted v-text skip.
                    end.
                end.
                else do:
                    v-text = "/BANKOKPO/".
                    if length(cmp.addr[3]) < 12 then v-text = v-text + cmp.addr[3] + '0000'.
                    else v-text = v-text + cmp.addr[3].
                    put stream rpt unformatted v-text skip.

                    v-text = "/BANKBIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.

            v-text = "/OPER/" + v-oper.
            put stream rpt unformatted v-text skip.

            v-text = "/PREVNUMBER/".
            put stream rpt unformatted v-text skip.

            v-text = "//PREVDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "//PREVBANKOKPO/".
            put stream rpt unformatted v-text skip.

            if v-bin then do:
                v-text = "//PREVBANKBIN/".
                put stream rpt unformatted v-text skip.
            end.

            v-text = "/PSNUMBER/" + trim(t-dc.psnum).
            put stream rpt unformatted v-text skip.

            v-text = "//PSDATE/" + string(day(t-dc.psdate),'99') + string(month(t-dc.psdate),'99') + string(year(t-dc.psdate),'9999').
            put stream rpt unformatted v-text skip.

            v-text = "/NAME/".
            put stream rpt unformatted v-text skip.

            if v-bin then do:
                if v-MTviewbi = yes then do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/".
                    put stream rpt unformatted v-text skip.

                    if t-dc.bin <> "" then do:
                        v-text = "//BIN/" + t-dc.bin.
                        put stream rpt unformatted v-text skip.
                    end.
                    else do:
                        v-text = "//BIN/".
                        put stream rpt unformatted v-text skip.
                    end.
                    if t-dc.iin <> "" then do:
                        v-text = "//IIN/" + t-dc.iin.
                        put stream rpt unformatted v-text skip.
                    end.
                    else do:
                        v-text = "//IIN/".
                        put stream rpt unformatted v-text skip.
                    end.
                end.
                else do:
                    v-text = "//OKPO/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//RNN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.

                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.

            v-text = "//SIGN/".
            put stream rpt unformatted v-text skip.

            v-text = "//REGION/".
            put stream rpt unformatted v-text skip.

            v-text = "//PFORM/".
            put stream rpt unformatted v-text skip.

            v-text = "//EISIGN/" + trim(t-dc.EISIGN).
            put stream rpt unformatted v-text skip.

            v-text = "/CONTRACT/" + trim(t-dc.CONTRACT).
            put stream rpt unformatted v-text skip.

            if t-dc.CDATE <> "" then v-text = "//CDATE/" + string(day(date(t-dc.CDATE)),'99') + string(month(date(t-dc.CDATE)),'99') + string(year(date(t-dc.CDATE)),'9999').
            else v-text = "//CDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "//CURRENCY/".
            put stream rpt unformatted v-text skip.

            if deci(t-dc.CSUMM) <> 0 then v-text = "//CSUMM/" + trim(replace(trim(t-dc.CSUMM),'.',',')).
            else v-text = "//CSUMM/".
            put stream rpt unformatted v-text skip.

            v-text = "//CCURR/" + trim(t-dc.CCURR).
            put stream rpt unformatted v-text skip.

            v-text = "//CCLAUSE/".
            put stream rpt unformatted v-text skip.

            v-text = "//CCLAUSEDETAIL/".
            put stream rpt unformatted v-text skip.

            if t-dc.CLASTDATE <> "" then v-text = "//CLASTDATE/" + string(day(date(t-dc.CLASTDATE)),'99') + string(month(date(t-dc.CLASTDATE)),'99') + string(year(date(t-dc.CLASTDATE)),'9999').
            else v-text = "//CLASTDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "/NRNAME/" + trim(t-dc.NRNAME).
            put stream rpt unformatted v-text skip.

            v-text = "//NRCOUNTRY/" + trim(t-dc.NRCOUNTRY).
            put stream rpt unformatted v-text skip.

            if trim(t-dc.TERM_) <> "" then v-text = "/TERM/" + string(t-dc.TERM_,'999.99').
            else v-text = "/TERM/".
            put stream rpt unformatted v-text skip.

            v-text = "/CODECALC/".
            put stream rpt unformatted v-text skip.

            v-text = "/ADDSHEET/".
            put stream rpt unformatted v-text skip.

            v-text = "//ASDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "//ASFOUND/".
            put stream rpt unformatted v-text skip.

            if t-dc.CLOSEDATE <> "" then v-text = "/CLOSEDATE/" + string(day(date(t-dc.CLOSEDATE)),'99') + string(month(date(t-dc.CLOSEDATE)),'99') + string(year(date(t-dc.CLOSEDATE)),'9999').
            else v-text = "/CLOSEDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "//CLOSEFOUND/" + trim(t-dc.CLOSEFOUND).
            put stream rpt unformatted v-text skip.

            put stream rpt unformatted "/NOTE/".
            if trim(t-dc.note) <> '' then do:
                j = length(t-dc.note).
                i = 1.
                repeat:
                    put stream rpt unformatted trim(caps(substr(t-dc.note,i,100))) SKIP.
                    j = j - 100.
                    if j <= 0 then leave.
                    i = i + 100.
                end.
            end.
            else put stream rpt unformatted skip.

            {vcmsgend.i &msg = "111"}
        end.
    end.
end.

if s-empty then do:
    {vcmsgparam_new.i &msg = "111"}

    run EmptyMT.

    {vcmsgend.i &msg = "111"}
end.

procedure EmptyMT:
    v-text = "/REPORTDATE/".
    put stream rpt unformatted v-text skip.

    if v-bin then do:
        if v-MTviewbi = yes then do:
            v-text = "/BANKOKPO/".
            put stream rpt unformatted v-text skip.

            if avail t-dc and t-dc.bnkbin <> "" then do:
                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.
        else do:
            v-text = "/BANKOKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "/BANKBIN/".
            put stream rpt unformatted v-text skip.
        end.
    end.

    v-text = "/OPER/".
    put stream rpt unformatted v-text skip.

    v-text = "/PREVNUMBER/".
    put stream rpt unformatted v-text skip.

    v-text = "//PREVDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//PREVBANKOKPO/".
    put stream rpt unformatted v-text skip.

    if v-bin then do:
        v-text = "//PREVBANKBIN/".
        put stream rpt unformatted v-text skip.
    end.

    v-text = "/PSNUMBER/".
    put stream rpt unformatted v-text skip.

    v-text = "//PSDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "/NAME/".
    put stream rpt unformatted v-text skip.

    if v-bin then do:
        if v-MTviewbi = yes then do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            if avail t-dc and t-dc.bin <> "" then do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.
            end.
            if avail t-dc and t-dc.iin <> "" then do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.
        else do:
            v-text = "//OKPO/".
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/".
            put stream rpt unformatted v-text skip.

            v-text = "//BIN/".
            put stream rpt unformatted v-text skip.

            v-text = "//IIN/".
            put stream rpt unformatted v-text skip.
        end.
    end.

    v-text = "//SIGN/".
    put stream rpt unformatted v-text skip.

    v-text = "//REGION/".
    put stream rpt unformatted v-text skip.

    v-text = "//PFORM/".
    put stream rpt unformatted v-text skip.

    v-text = "//EISIGN/".
    put stream rpt unformatted v-text skip.

    v-text = "/CONTRACT/".
    put stream rpt unformatted v-text skip.

    v-text = "//CDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//CURRENCY/".
    put stream rpt unformatted v-text skip.

    v-text = "//CSUMM/".
    put stream rpt unformatted v-text skip.

    v-text = "//CCURR/".
    put stream rpt unformatted v-text skip.

    v-text = "//CCLAUSE/".
    put stream rpt unformatted v-text skip.

    v-text = "//CCLAUSEDETAIL/".
    put stream rpt unformatted v-text skip.

    v-text = "//CLASTDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "/NRNAME/".
    put stream rpt unformatted v-text skip.

    v-text = "//NRCOUNTRY/".
    put stream rpt unformatted v-text skip.

    v-text = "/TERM/".
    put stream rpt unformatted v-text skip.

    v-text = "/CODECALC/".
    put stream rpt unformatted v-text skip.

    v-text = "/ADDSHEET/".
    put stream rpt unformatted v-text skip.

    v-text = "//ASDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//ASFOUND/".
    put stream rpt unformatted v-text skip.

    v-text = "/CLOSEDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//CLOSEFOUND/".
    put stream rpt unformatted v-text skip.

    v-text = "/NOTE/".
    put stream rpt unformatted v-text.
end procedure.

hide all no-pause.

unix silent rm -f value(v-filename0).