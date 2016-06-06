/* vcrep4msg.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        вывод в файл МТ-114
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
 * BASES
         BANK COMM

 * AUTHOR
        06.05.2008 galina
 * CHANGES
        16.05.2008 galina   - строка /CODECALC/ повторяется в зависимости от количества форм расчетов
        18.08.2008 galina   - выбираем одну форму расчетов, указанную в платежном документе
        12/03/2009 galina   - выводим ОКПО центрального офиса
        10.12.2010 aigul    -  Для CODECALC 20 (ДрДок)- Вывод в REPORTMONTH дату платежа, а не дату регистрации
                            в NOTE для типа 20 - вывод примечания и даты регистрации
                            добавила в таблицу t-docs поле rdt
        11.01.2011 aigul    - в NOTE для типа 29 - вывод примечания и даты регистрации
        10.04.2011 damir    - новые переменные v-bin,v-iin,v-binben,v-iinben
                            bin,iin,binben,iinben во временную таблицу.
        28.04.2011 damir    - поставлены ключи. процедура chbin.i
        30.09.2011 damir    - добавлены:
                            1) Вывод информации в v-oper = "2", в v-oper = "1" вывод в полях RECK,RDATE,NEWPSNUMBER,NEWPSDATE информации.
        06.12.2011 damir    - добавил vcmtform_txb.i
        14.02.2012 aigul    - разбила на 3 строки по 100 символов поле NOTE
        05.07.2012 damir    - добавил vcmtform.i, переход на форматы с БИН и ИИН только они пустые.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
        09.10.2013 damir - Т.З. № 1670.
*/
{vc.i}
{global.i}
{vcmtform.i}
{vcshared4.i}
{srvcheck.i}

def var v-dir as char.
def var v-ipaddr as char.
def var v-exitcod as char.
def var v-text as char.
def var v-filename as char.
def var v-filename0 as char init "vcmsg.txt".
def var i as inte.

/* формирование телеграммы */
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
    v-dir = "C:/VC114/".
    v-ipaddr = "Administrator@`askhost`".
end.

if substr(v-dir, length(v-dir), 1) <> "/" then v-dir = v-dir + "/".
v-dir = v-dir + substr(string(year(g-today), "9999"), 3, 2) + string(month(g-today), "99") +
string(day(g-today), "99") + "/".

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
    for each t-docs no-lock:
        {vcmsgparam_new.i &msg = "114"}
        if (t-docs.ctformrs = "20" or t-docs.ctformrs = "29") then do:
            v-text = "/REPORTMONTH/" + string(month(t-docs.dndate),'99') + string(year(t-docs.dndate),'9999').
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "/REPORTMONTH/" + string(v-month, "99") + string(v-god, "9999").
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = no then do:
            v-text = "/BANKOKPO/" + string(trim(cmp.addr[3]),'99999999').
            put stream rpt unformatted v-text skip.
        end.
        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "/BANKOKPO/".
                put stream rpt unformatted v-text skip.

                if t-docs.bnkbin <> "" then do:
                    v-text = "/BANKBIN/" + t-docs.bnkbin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "/BANKBIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                v-text = "/BANKOKPO/" + string(trim(cmp.addr[3]),'99999999').
                put stream rpt unformatted v-text skip.

                v-text = "/BANKBIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "/PSNUMBER/" + t-docs.psnum.
        put stream rpt unformatted v-text skip.

        v-text = "//PSDATE/" + string(day(t-docs.psdate),'99') + string(month(t-docs.psdate),'99') + string(year(t-docs.psdate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "/OPER/" + v-oper.
        put stream rpt unformatted v-text skip.

        if t-docs.numobyaz <> "" then do:
            v-text = "/INFNUM/" + t-docs.numobyaz.
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "/INFNUM/".
            put stream rpt unformatted v-text skip.
        end.

        v-text = "/NAME/" + substr(t-docs.name, 1, 100).
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            if (length(t-docs.okpo) < 12 and integer(t-docs.okpo) > 0) then t-docs.okpo = t-docs.okpo + fill("0", 12 - length(t-docs.okpo)).
            v-text = "//OKPO/" + t-docs.okpo.
            put stream rpt unformatted v-text skip.

            v-text = "//RNN/" + t-docs.rnn.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "//OKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/".
                put stream rpt unformatted v-text skip.

                if t-docs.bin <> "" then do:
                    v-text = "//BIN/" + t-docs.bin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//BIN/".
                    put stream rpt unformatted v-text skip.
                end.
                if t-docs.iin <> "" then do:
                    v-text = "//IIN/" + t-docs.iin.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//IIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                v-text = "//OKPO/" + t-docs.okpo.
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/" + t-docs.rnn.
                put stream rpt unformatted v-text skip.

                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.

                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//SIGN/"  + t-docs.clntype.
        put stream rpt unformatted v-text skip.

        v-text = "//COUNTRY/"  + t-docs.country.
        put stream rpt unformatted v-text skip.

        v-text = "//REGION/" + t-docs.region.
        put stream rpt unformatted v-text skip.

        v-text = "//RESIDENT/" + t-docs.locat.
        put stream rpt unformatted v-text skip.

        v-text = "/BNAME/" + t-docs.partner.
        put stream rpt unformatted v-text skip.

        if v-bin = no then do:
            if (length(t-docs.okpoben) < 12 and integer(t-docs.okpoben) > 0) then t-docs.okpoben = t-docs.okpoben + fill("0", 12 - length(t-docs.okpoben)).
            v-text = "//BOKPO/" + t-docs.okpoben.
            put stream rpt unformatted v-text skip.

            v-text = "//BRNN/" + t-docs.rnnben.
            put stream rpt unformatted v-text skip.
        end.

        if v-bin = yes then do:
            if v-MTviewbi = yes then do:
                v-text = "//BOKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//BRNN/".
                put stream rpt unformatted v-text skip.

                if t-docs.binben <> "" then do:
                    v-text = "//BBIN/" + t-docs.binben.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//BBIN/".
                    put stream rpt unformatted v-text skip.
                end.
                if t-docs.iinben <> "" then do:
                    v-text = "//BIIN/" + t-docs.iinben.
                    put stream rpt unformatted v-text skip.
                end.
                else do:
                    v-text = "//BIIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.
            else do:
                v-text = "//BOKPO/" + t-docs.okpoben.
                put stream rpt unformatted v-text skip.

                v-text = "//BRNN/" + t-docs.rnnben.
                put stream rpt unformatted v-text skip.

                v-text = "//BBIN/".
                put stream rpt unformatted v-text skip.

                v-text = "//BIIN/".
                put stream rpt unformatted v-text skip.
            end.
        end.

        v-text = "//BSIGN/" + t-docs.typeben.
        put stream rpt unformatted v-text skip.

        v-text = "//BCOUNTRY/"  + t-docs.countryben.
        put stream rpt unformatted v-text skip.

        v-text = "//BREGION/" + t-docs.regionben.
        put stream rpt unformatted v-text skip.

        v-text = "//BRESIDENT/" + t-docs.locatben.
        put stream rpt unformatted v-text skip.

        v-text = "/PAYDATE/" + string(day(t-docs.dndate), '99') + string(month(t-docs.dndate),'99') + string(year(t-docs.dndate),'9999').
        put stream rpt unformatted v-text skip.

        v-text = "//SUMM/" + replace(t-docs.strsum,'.',',').
        put stream rpt unformatted v-text skip.

        v-text = "//CURR/" + t-docs.codval.
        put stream rpt unformatted v-text skip.

        v-text = "//CODECALC/" + t-docs.ctformrs.
        put stream rpt unformatted v-text skip.

        v-text = "//INOUT/" + t-docs.inout.
        put stream rpt unformatted v-text skip.

        if t-docs.datenewps <> ? then do:
            v-text = "/NEWPSDATE/" + string(day(t-docs.datenewps), '99') + string(month(t-docs.datenewps),'99') + string(year(t-docs.datenewps),'9999').
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "/NEWPSDATE/".
            put stream rpt unformatted v-text skip.
        end.
        if t-docs.numnewps <> "" then do:
            v-text = "//NEWPSNUMBER/" + t-docs.numnewps.
            put stream rpt unformatted v-text skip.
        end.
        else do:
            v-text = "//NEWPSNUMBER/".
            put stream rpt unformatted v-text skip.
        end.

        if (t-docs.ctformrs = "20" or t-docs.ctformrs = "29")then do:
            v-text = "/NOTE/" + t-docs.note + " Документ, подтверждающий исполнение обязательств, предоставлен в Банк " +  string(t-docs.rdt, "99/99/99").
            put stream rpt unformatted substr(v-text,1,100) skip.
            if substr(v-text,101,100) <> "" then put stream rpt unformatted substr(v-text,101,100) skip.
            if substr(v-text,201,100) <> "" then put stream rpt unformatted substr(v-text,201,100) skip.
        end.
        else do:
            v-text = "/NOTE/" + t-docs.note.
            put stream rpt unformatted v-text skip.
        end.
        {vcmsgend.i &msg = "114"}
    end.
end.

if v-oper = '2' then do:
    for each t-dc no-lock:
        if t-dc.dtcorrect - t-dc.rdt > 180 then do:
            {vcmsgparam_new.i &msg = "114"}

            run EmptyMT.

            {vcmsgend.i &msg = "114"}
        end.
        else do:
            {vcmsgparam_new.i &msg = "114"}

            v-text = "/REPORTMONTH/" + string(v-month, "99") + string(v-god, "9999").
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
                    v-text = "/BANKOKPO/" + string(trim(cmp.addr[3]),'99999999').
                    put stream rpt unformatted v-text skip.

                    v-text = "/BANKBIN/".
                    put stream rpt unformatted v-text skip.
                end.
            end.

            v-text = "/PSNUMBER/" + trim(t-dc.psnum).
            put stream rpt unformatted v-text skip.

            if t-dc.psdate <> ? then do:
                v-text = "//PSDATE/" + string(day(t-dc.psdate), '99') + string(month(t-dc.psdate),'99') + string(year(t-dc.psdate),'9999').
                put stream rpt unformatted v-text skip.
            end.
            else do:
                v-text = "//PSDATE/".
                put stream rpt unformatted v-text skip.
            end.

            v-text = "/OPER/" + v-oper.
            put stream rpt unformatted v-text skip.

            v-text = "/INFNUM/" + trim(t-dc.numobyaz).
            put stream rpt unformatted v-text skip.

            v-text = "/NAME/" + trim(t-dc.NAME).
            put stream rpt unformatted v-text skip.

            if v-bin then do:
                v-text = "//OKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//RNN/".
                put stream rpt unformatted v-text skip.

                v-text = "//BIN/".
                put stream rpt unformatted v-text skip.

                v-text = "//IIN/".
                put stream rpt unformatted v-text skip.
            end.

            v-text = "//SIGN/".
            put stream rpt unformatted v-text skip.

            v-text = "//COUNTRY/" + trim(t-dc.COUNTRY).
            put stream rpt unformatted v-text skip.

            v-text = "//REGION/".
            put stream rpt unformatted v-text skip.

            v-text = "//RESIDENT/".
            put stream rpt unformatted v-text skip.

            v-text = "/BNAME/" + trim(t-dc.BNAME).
            put stream rpt unformatted v-text skip.

            if v-bin then do:
                v-text = "//BOKPO/".
                put stream rpt unformatted v-text skip.

                v-text = "//BRNN/".
                put stream rpt unformatted v-text skip.

                v-text = "//BBIN/".
                put stream rpt unformatted v-text skip.

                v-text = "//BIIN/".
                put stream rpt unformatted v-text skip.
            end.

            v-text = "//BSIGN/".
            put stream rpt unformatted v-text skip.

            v-text = "//BCOUNTRY/" + trim(t-dc.BCOUNTRY).
            put stream rpt unformatted v-text skip.

            v-text = "//BREGION/".
            put stream rpt unformatted v-text skip.

            v-text = "//BRESIDENT/".
            put stream rpt unformatted v-text skip.

            if t-dc.PAYDATE <> "" then v-text = "/PAYDATE/" + string(day(date(t-dc.PAYDATE)), '99') + string(month(date(t-dc.PAYDATE)),'99') + string(year(date(t-dc.PAYDATE)),'9999').
            else v-text = "/PAYDATE/".
            put stream rpt unformatted v-text skip.

            if deci(t-dc.SUMM) <> 0 then v-text = "//SUMM/" + trim(replace(t-dc.SUMM,'.',',')).
            else v-text = "//SUMM/".
            put stream rpt unformatted v-text skip.

            v-text = "//CURR/" + trim(t-dc.CURR).
            put stream rpt unformatted v-text skip.

            v-text = "//CODECALC/" + trim(t-dc.CODECALC).
            put stream rpt unformatted v-text skip.

            v-text = "//INOUT/" + trim(t-dc.INOUT).
            put stream rpt unformatted v-text skip.

            v-text = "/NEWPSDATE/".
            put stream rpt unformatted v-text skip.

            v-text = "//NEWPSNUMBER/".
            put stream rpt unformatted v-text skip.

            v-text = "/NOTE/" + trim(t-dc.corr).
            put stream rpt unformatted v-text skip.

            {vcmsgend.i &msg = "114"}
        end.
    end.
end.

if s-empty then do:
    {vcmsgparam_new.i &msg = "114"}

    run EmptyMT.

    {vcmsgend.i &msg = "114"}
end.

procedure EmptyMT:
    v-text = "/REPORTMONTH/".
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

    v-text = "/PSNUMBER/".
    put stream rpt unformatted v-text skip.

    v-text = "//PSDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "/OPER/".
    put stream rpt unformatted v-text skip.

    v-text = "/INFNUM/".
    put stream rpt unformatted v-text skip.

    v-text = "/NAME/".
    put stream rpt unformatted v-text skip.

    if v-bin then do:
        v-text = "//OKPO/".
        put stream rpt unformatted v-text skip.

        v-text = "//RNN/".
        put stream rpt unformatted v-text skip.

        v-text = "//BIN/".
        put stream rpt unformatted v-text skip.

        v-text = "//IIN/".
        put stream rpt unformatted v-text skip.
    end.

    v-text = "//SIGN/".
    put stream rpt unformatted v-text skip.

    v-text = "//COUNTRY/".
    put stream rpt unformatted v-text skip.

    v-text = "//REGION/".
    put stream rpt unformatted v-text skip.

    v-text = "//RESIDENT/".
    put stream rpt unformatted v-text skip.

    v-text = "/BNAME/".
    put stream rpt unformatted v-text skip.

    if v-bin then do:
        v-text = "//BOKPO/".
        put stream rpt unformatted v-text skip.

        v-text = "//BRNN/".
        put stream rpt unformatted v-text skip.

        v-text = "//BBIN/".
        put stream rpt unformatted v-text skip.

        v-text = "//BIIN/".
        put stream rpt unformatted v-text skip.
    end.

    v-text = "//BSIGN/".
    put stream rpt unformatted v-text skip.

    v-text = "//BCOUNTRY/".
    put stream rpt unformatted v-text skip.

    v-text = "//BREGION/".
    put stream rpt unformatted v-text skip.

    v-text = "//BRESIDENT/".
    put stream rpt unformatted v-text skip.

    v-text = "/PAYDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//SUMM/".
    put stream rpt unformatted v-text skip.

    v-text = "//CURR/".
    put stream rpt unformatted v-text skip.

    v-text = "//CODECALC/".
    put stream rpt unformatted v-text skip.

    v-text = "//INOUT/".
    put stream rpt unformatted v-text skip.

    v-text = "/NEWPSDATE/".
    put stream rpt unformatted v-text skip.

    v-text = "//NEWPSNUMBER/".
    put stream rpt unformatted v-text skip.

    v-text = "/NOTE/".
    put stream rpt unformatted v-text skip.
end procedure.