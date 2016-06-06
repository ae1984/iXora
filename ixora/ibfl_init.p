/* ibfl_init.p
 * MODULE
        ИБФЛ
 * DESCRIPTION
        Соник-сервис для инициализации клиента ИБФЛ
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
        13/05/2013 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        24/09/2013 zhassulan - техническая доработка (ссудный счет + филиал)
*/

define input parameter p-cif as character no-undo.
define output parameter p-replyText as character.
define output parameter p-err as character no-undo.

define variable v-sqn     as integer   no-undo.
define variable KOF       as character no-undo.
define variable issuedt   as date      no-undo.
define variable issuer    as character no-undo.
define variable i         as integer   no-undo.
define variable v-str     as character no-undo.
define variable v-fname   as character no-undo.
define variable v-lname   as character no-undo.
define variable v-mname   as character no-undo.
define variable r-phone   as character no-undo.
define variable v-maincard as character no-undo.
define variable is_debit as character no-undo.

{ibfl.i}

define variable s-ourbank as character no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not available txb.sysc or txb.sysc.chval = "" then
do:
    display " There is no record OURBNK in bank.sysc file !!".
    return.
end.
s-ourbank = trim(txb.sysc.chval).


find first txb.cif where txb.cif.cif = p-cif no-lock no-error.
if not available txb.cif then
do:
    p-err = "Не найден указанный код клиента!".
    message "ERR: ibfl_init -> no cif (" + p-cif + ')'.
    return.
end.
p-replyText = "<?xml version=""1.0"" encoding=""UTF-8""?>".
v-sqn = 1000. /* next-value(msgid,ib).*/
p-replyText = p-replyText + "<organization message_id=""" + string(v-sqn) + """>".


p-replyText = p-replyText + "<info name=""" + info_name_replacer (trim(txb.cif.name)) + """>".
p-replyText = p-replyText + "<entity>P</entity>".
p-replyText = p-replyText + "<ext_id>" + txb.cif.cif + "</ext_id>".
p-replyText = p-replyText + "<contract_num>" + txb.cif.cif + "</contract_num>".
p-replyText = p-replyText + "<contract_date>" + string(substr(string(txb.cif.regdt),1,2))  + '.' + string(substr(string(txb.cif.regdt),4,2)) + '.' + string(year(txb.cif.regdt)) + "</contract_date>".
p-replyText = p-replyText + "<address>" + string(trim(replace(replace((txb.cif.addr[1]), "'", ""), '"', ''))) +  "</address>".
find last txb.sysc where txb.sysc.sysc = "citi" no-lock no-error.
if available txb.sysc then p-replyText = p-replyText + "<city>" + string(txb.sysc.chval) + "</city>".
else p-replyText = p-replyText + "<city>" + "</city>".
p-replyText = p-replyText + "<phone>" + string(txb.cif.tel) + "</phone>".
p-replyText = p-replyText + "<fax>" + string(txb.cif.fax) +  "</fax>".
p-replyText = p-replyText + "<email>" + string(txb.cif.mail) + "</email>".

KOF = substr(txb.cif.geo,3,1).
find first txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "secek" no-lock no-error.
if available txb.sub-cod then KOF = KOF + txb.sub-cod.ccode.
p-replyText = p-replyText + "<code>" + KOF + "</code>".

if substr(txb.cif.geo,3,1) = "1" then p-replyText = p-replyText + "<is_resident>1</is_resident>".
else p-replyText = p-replyText + "<is_resident>0</is_resident>".

p-replyText = p-replyText + "<responsible_person></responsible_person>".
p-replyText = p-replyText + "<lock_word> Не задано </lock_word>".
p-replyText = p-replyText + "<comments>" + string(txb.cif.attn) + "</comments>".
p-replyText = p-replyText + "<certificate>" + "</certificate>".
p-replyText = p-replyText + "<certificate_issuer>" + "</certificate_issuer>".
p-replyText = p-replyText + "<certificate_issue_date>22.05.2013</certificate_issue_date>". /* жестко зашиваем дату - отрабатывает проверка по формату на стороне ИБ */
p-replyText = p-replyText + "<director_name>" + "</director_name>".
p-replyText = p-replyText + "<director_position>" + "</director_position>".
p-replyText = p-replyText + "<bin>" + txb.cif.bin + "</bin>".
p-replyText = p-replyText + "</info>".

/* ------------------------------------------------ */

p-replyText = p-replyText + "<accounts>".

/*Текущие и депозитные*/
for each txb.aaa where txb.aaa.cif = txb.cif.cif and txb.aaa.sta <> "C" no-lock:
    if length(txb.aaa.aaa) < 15 then next.
    find last txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.
    if txb.lgr.led = "DDA" or txb.lgr.led = "SAV" or txb.lgr.led = "CDA" or txb.lgr.led = "TDA" then
    do:




        p-replyText = p-replyText + "<account code=""" + string(txb.aaa.aaa) + """>".
        is_debit = "1". /*по умолчанию*/
        if lookup(txb.lgr.lgr, "A38,A39,A40,A01,A04,А28,A19,A20,A21,A25,A26,A27,A34,A35,A36,А31,А32,А33,A22,A23,A24") > 0 then
        do:
            /*Это депозит*/
            if txb.lgr.led = "TDA" and txb.lgr.tlimit[3] = 0 and not ((txb.lgr.feensf <> 1  and txb.lgr.feensf <> 2 and txb.lgr.feensf <> 3 and txb.lgr.feensf <> 6 and txb.lgr.feensf <> 4 and txb.lgr.feensf <> 5 and txb.lgr.feensf <> 7 ) and lookup(txb.lgr.lgr, "A38,A39,A40") = 0) then
            do:
               /*Депозит не является сберегательным с изъятием*/
               is_debit = "0".
            end.
            else is_debit = "1".
            p-replyText = p-replyText + "<type>3</type>". /*Депозит*/
        end.
        else do:
          if (txb.aaa.lgr = "138" or txb.aaa.lgr = "139" or txb.aaa.lgr = "140") and txb.aaa.gl = 220430 then p-replyText = p-replyText + "<type>2</type>". /*Карт счет*/
          else p-replyText = p-replyText + "<type>0</type>". /*Текущий счет*/
        end.


        p-replyText = p-replyText + "<debit_type>" + is_debit + "</debit_type>".
        p-replyText = p-replyText + "<aux_acc></aux_acc>".


        find last txb.crc where txb.crc.crc = txb.aaa.crc no-lock no-error.
        if available txb.crc then p-replyText = p-replyText + "<currency>" + txb.crc.code + "</currency>".
        else
        do:
            message "В справочнике валют не найдена валюта с кодом " + string(txb.aaa.crc) + ", клиент=" + txb.cif.cif + ", счет=" + txb.aaa.aaa.
            p-replyText = p-replyText + "<currency></currency>".
        end.

        p-replyText = p-replyText + "<create_date>" + string(substr(string(txb.aaa.regdt),1,2)) + '.' + string(substr(string(txb.aaa.regdt),4,2)) + '.' + string(year(txb.aaa.regdt))  + "</create_date>".

        if txb.aaa.sta = "C" then p-replyText = p-replyText + "<status>0</status>".
        else p-replyText = p-replyText + "<status>1</status>".

        find first txb.sysc where txb.sysc.sysc = "clecod" no-lock no-error.
        if available txb.sysc then p-replyText = p-replyText + "<bic>" + trim(txb.sysc.chval) + "</bic>".
        else
        do:
            message "В настройках не найден БИК банка (" + s-ourbank + ")".
            p-replyText = p-replyText + "<bic></bic>".
        end.

        p-replyText = p-replyText + "<comments>Не задано</comments>".

        if (txb.aaa.lgr = "138" or txb.aaa.lgr = "139" or txb.aaa.lgr = "140") and txb.aaa.gl = 220430 then
        do:
            for each pccards where pccards.aaa = txb.aaa.aaa and pccards.cif = txb.aaa.cif no-lock:
                p-replyText = p-replyText + "<card num=""" + pccards.pcard + """".
                if pccards.sup = no then do: p-replyText = p-replyText + " major=""true"" >". v-maincard = pccards.pcard. end.
                else p-replyText = p-replyText + " major=""false"" >".
                p-replyText = p-replyText + "<status>" + pccards.sts + "</status>". /*(OK – активная, Closed – неактивная, Do (Do not Honor) или Local (PickUp Local) – неактивная) */
                p-replyText = p-replyText + "<type>" + GetCardType(pccards.pctype) + "</type>". /*(E – Electron, C – Classic, G – Gold, I – Infinite, B – Business) */
                p-replyText = p-replyText + "<holder>" + pccards.namelat + "</holder>".
                if pccards.expdt <> ? then p-replyText = p-replyText + "<exp_date>" + string(pccards.expdt,"99/99/9999") + "</exp_date>".
                else p-replyText = p-replyText + "<exp_date>01.01.1900</exp_date>".
                p-replyText = p-replyText + "</card>".
            end.

        end.

        p-replyText = p-replyText + "</account>".
    end.
end.

/*Ссудные счета*/

for each txb.lon where txb.lon.cif = txb.cif.cif and txb.lon.sts <> 'C' no-lock:
        p-replyText = p-replyText + "<account code=""" + string(txb.lon.lon) + substring(s-ourbank,4,2) + """>".

        is_debit="0".
        p-replyText = p-replyText + "<debit_type>" + is_debit + "</debit_type>".
        p-replyText = p-replyText + "<aux_acc>" + txb.lon.aaa + "</aux_acc>".

        p-replyText = p-replyText + "<type>1</type>".

        find last txb.crc where txb.crc.crc = txb.lon.crc no-lock no-error.
        if available txb.crc then p-replyText = p-replyText + "<currency>" + txb.crc.code + "</currency>".
        else
        do:
            message "В справочнике валют не найдена валюта с кодом " + string(txb.lon.crc) + ", клиент=" + txb.cif.cif + ", счет=" + txb.lon.lon.
            p-replyText = p-replyText + "<currency></currency>".
        end.

        p-replyText = p-replyText + "<create_date>" + string(substr(string(txb.lon.opndt),1,2)) + '.' + string(substr(string(txb.lon.opndt),4,2)) + '.' + string(year(txb.lon.opndt))  + "</create_date>".
        p-replyText = p-replyText + "<status>1</status>".

        find first txb.sysc where txb.sysc.sysc = "clecod" no-lock no-error.
        if available txb.sysc then p-replyText = p-replyText + "<bic>" + trim(txb.sysc.chval) + "</bic>".
        else
        do:
            message "В настройках не найден БИК банка (" + s-ourbank + ")".
            p-replyText = p-replyText + "<bic></bic>".
        end.

        p-replyText = p-replyText + "<comments>Не задано</comments>".
        p-replyText = p-replyText + "</account>".
end.


p-replyText = p-replyText + "</accounts>".


p-replyText = p-replyText + "<employee>".
p-replyText = p-replyText + "<login>" + txb.cif.cif + "</login>".

v-fname = ''.
v-lname = ''.
v-mname = ''.

find first comm.pcstaff0 where comm.pcstaff0.cif = txb.cif.cif and comm.pcstaff0.pcard = v-maincard no-lock no-error.
if available comm.pcstaff0 then
do:
    v-lname = comm.pcstaff0.sname.
    v-fname = comm.pcstaff0.fname.
    v-mname = comm.pcstaff0.mname.
end.
else
do:
    v-str = trim(txb.cif.name).
    v-lname = entry(1,v-str,' ').
    if num-entries(v-str,' ') > 1 then v-fname = entry(2,v-str,' ').
    if num-entries(v-str,' ') > 2 then v-mname = entry(3,v-str,' ').
end.

p-replyText = p-replyText + "<last_name>" + v-lname + "</last_name>".
p-replyText = p-replyText + "<first_name>" + v-fname + "</first_name>".
p-replyText = p-replyText + "<middle_name>" + v-mname + "</middle_name>".
p-replyText = p-replyText + "<position>" + "</position>".
p-replyText = p-replyText + "<birth_date>" + string(substr(string(txb.cif.expdt),1,2)) + '.' + string(substr(string(txb.cif.expdt),4,2)) + '.' + string(year(txb.cif.expdt)) + "</birth_date>".
p-replyText = p-replyText + "<id_number>" + entry(1,txb.cif.pss,' ') + "</id_number>".
i = 3.
issuer = ''.
repeat:
    if num-entries(txb.cif.pss,' ') > i - 1 then
    do:
        if issuer <> '' then issuer = issuer + ' '.
        issuer = issuer + entry(i,txb.cif.pss,' ').
        i = i + 1.
    end.
    else leave.
end.
p-replyText = p-replyText + "<id_issuer>" + issuer + "</id_issuer>".
issuedt = date(entry(2,txb.cif.pss,' ')) no-error.
if error-status:error then p-replyText = p-replyText + "<id_issue_date>01.01.1900</id_issue_date>".
else p-replyText = p-replyText + "<id_issue_date>" + string(substr(string(issuedt),1,2)) + '.' + string(substr(string(issuedt),4,2)) + '.' + string(year(issuedt)) + "</id_issue_date>".
p-replyText = p-replyText + "<iin>" + txb.cif.bin + "</iin>".

p-replyText = p-replyText + "<phones>" + substring(trim(txb.cif.tel),1,15) + "</phones>". /* не может быть более 15 символов !!! */
p-replyText = p-replyText + "<mobile>" + txb.cif.fax + "</mobile>".
p-replyText = p-replyText + "<emails>" + txb.cif.mail + "</emails>".
p-replyText = p-replyText + "<addresss>" + txb.cif.addr[1] + "</addresss>".

p-replyText = p-replyText + "<authtype>1</authtype>".
p-replyText = p-replyText + "</employee>".


p-replyText = p-replyText + "</organization>".


message "ibfl_init -> OK, charCount=" + string(length(p-replyText)) + "\r\n" + p-replyText.

