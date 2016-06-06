/* vcrepthirddat.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок для конракта типа 9
        Сборка данных во временную таблицу по всем филиалам
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM TXB
 * AUTHOR
        28.05.2008 galina
 * CHANGES
        14.12.2010 aigul - убрала проверку для поля ВОЗВРАТ
                           если экспорт и 02 - извещ, то Отправитель бенефициар
                           если импорт и 03 - поруч, то Отправитель наш клиент
        16.07.2012 damir - добавил v-bin,v-iin,v-binben,v-iinben.


*/


{vc.i}

{vcmtform_txb.i}

def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.

def var v-name          as char no-undo.
def var v-rnn           as char no-undo.
def var v-okpo          as char no-undo.
def var v-country       as char no-undo.
def var v-rnnben        as char no-undo.
def var v-okpoben       as char no-undo.
def var v-partner       as char no-undo.
def var v-partnername   as char no-undo.
def var v-countryben    as char no-undo.
def var v-locat         as char no-undo.
def var v-locatben      as char no-undo.
def var v-opertype      as char no-undo.
def var v-clntype       as integer no-undo.
def var v-clntyperep    as char no-undo.
def var v-typeben       as char no-undo.
def var v-note          as char no-undo.
def var v-region        as char no-undo.
def var v-regionben     as char no-undo.
def var v-inout         as char no-undo.
def var v-binsen        as char.
def var v-iinsen        as char.
def var v-binben        as char.
def var v-iinben        as char.

def shared temp-table t-docs
  field psdate      as date
  field psnum       as char
  field name        like txb.cif.name
  field okpo        as char format "999999999999"
  field rnn         as char format "999999999999"
  field clntype     as char
  field country     as char
  field region      as char
  field locat       as char
  field partner     like vcpartners.name
  field rnnben      as char format "999999999999"
  field okpoben     as char format "999999999999"
  field typeben     as char
  field countryben  as char
  field regionben   as char
  field locatben    as char
  field dnnum       as char
  field dndate      like vcdocs.dndate
  field docs        like vcdocs.docs
  field sum         like vcdocs.sum
  field strsum      as char
  field codval      as char
  field ctformrs    as char
  field inout       as char
  field note        as char
  field bin         as char
  field iin         as char
  field binben      as char
  field iinben      as char
  index main is primary dndate sum docs.


for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = '9' no-lock:
    if vccontrs.sts = 'C' then next.

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.

    if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then v-clntype = 1.
    if (txb.cif.type = 'B' and txb.cif.cgr = 403) then v-clntype = 2.

    assign v-binsen = "" v-iinsen = "" v-binben = "" v-iinben = "".

    if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.

    for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and
    vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock:
        if vcdocs.info[4] = "" then v-partner = vccontrs.partner.
        else v-partner = vcdocs.info[4].

        find vcpartner where vcpartner.partner = v-partner no-lock no-error.
        if avail vcpartner then do:
            find txb.sub-cod where txb.sub-cod.sub = 'cln' and  txb.sub-cod.acc = vccontrs.cif and txb.sub-cod.d-cod = 'regionkz' no-lock no-error.
            find vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error.

            if vccontrs.expimp = "i" then do:
                /*если импорт и yes, то отправитель - бенефициар, получатель - наш*/
                /*if vcdocs.payret then do:
                v-inout = "2".
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-country = vcpartner.country.
                v-rnn = "".
                v-okpo = "".
                v-region = "".
                if vcpartner.country = "KZ" then v-locat = "1".
                else v-locat = "2".
                if trim(vcpartner.formasob) = 'ИП' then v-clntyperep = "2".
                else v-clntyperep = "1".

                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
                v-countryben = "KZ".
                if v-clntype = 1 then do: v-rnnben = "". v-okpoben = txb.cif.ssn. end.
                if v-clntype = 2 then do: v-rnnben = txb.cif.jss. v-okpoben = "". end.
                v-typeben = string(v-clntype).
                v-regionben = txb.sub-cod.ccode.
                end.*/
                /*если импорт и no, то отправитель - наш, получатель - бенефициар*/
                /*if vcdocs.payret = no then do:*/
                v-inout = "1".
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-region = txb.sub-cod.ccode.
                v-country = "KZ" .

                if v-clntype = 1 then do:
                    v-rnn = "".
                    v-okpo = txb.cif.ssn.
                    if v-bin = yes then v-binsen = txb.cif.bin.
                end.
                if v-clntype = 2 then do:
                    v-rnn = txb.cif.jss.
                    v-okpo = "".
                    if v-bin = yes then v-iinsen = txb.cif.bin.
                end.

                v-clntyperep = string(v-clntype).
                v-locat = substr (txb.cif.geo, 3, 1).

                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-countryben = vcpartner.country.
                v-rnnben = "".
                v-okpoben = "".
                if vcpartner.country = "KZ" then v-locatben = "1".
                else v-locatben = "2".
                if trim(vcpartner.formasob) = 'ИП' then v-typeben = "2".
                else v-typeben = "1".
                /*end.*/
            end.

            if vccontrs.expimp = "e" then do:
                /*если экспорт и yes, то отправитель - наш, получатель - бенефициар*/
                /*if vcdocs.payret then do:
                v-inout = "1".
                v-name = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-region = txb.sub-cod.ccode.
                v-country = "KZ" .

                if v-clntype = 1 then do: v-rnn = "". v-okpo = txb.cif.ssn. end.
                if v-clntype = 2 then do: v-rnn = txb.cif.jss. v-okpo = "". end.
                v-clntyperep = string(v-clntype).
                v-locat = substr (txb.cif.geo, 3, 1).

                v-partnername = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-countryben = vcpartner.country.
                v-rnnben = "".
                v-okpoben = "".
                if vcpartner.country = "KZ" then v-locatben = "1".
                else v-locatben = "2".
                if trim(vcpartner.formasob) = 'ИП' then v-typeben = "2".
                else v-typeben = "1".
                end.*/
                /*если экспорт и no, то отправитель - бенефициар, получатель - наш*/
                /*if vcdocs.payret = no then do:*/
                v-inout = "2".
                v-name = trim(trim(vcpartner.name) + " " + trim(vcpartner.formasob)).
                v-country = vcpartner.country.
                v-rnn = "".
                v-okpo = "".
                v-region = "".
                if vcpartner.country = "KZ" then v-locat = "1".
                else v-locat = "2".
                if trim(vcpartner.formasob) = 'ИП' then v-clntyperep = "2".
                else v-clntyperep = "1".

                v-partnername = trim(trim(txb.cif.name) + " " + trim(txb.cif.prefix)).
                v-locatben = substr (txb.cif.geo, 3, 1).
                v-countryben = "KZ".
                if v-clntype = 1 then do:
                    v-rnnben = "".
                    v-okpoben = txb.cif.ssn.
                    if v-bin = yes then v-binben = txb.cif.bin.
                end.
                if v-clntype = 2 then do:
                    v-rnnben = txb.cif.jss.
                    v-okpoben = "".
                    if v-bin = yes then v-iinben = txb.cif.bin.
                end.
                v-typeben = string(v-clntype).
                v-regionben = txb.sub-cod.ccode.
            end.
        end.
        else do:
            v-partnername = "".
            v-rnnben = "".
            v-locatben = "".
            v-countryben = "".
            v-typeben = "".
            v-regionben = "".
        end.

        find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.
        create t-docs.
        assign t-docs.psdate = vcps.dndate
        t-docs.psnum = vcps.dnnum /*+ string(vcps.num)*/
        t-docs.name = v-name
        t-docs.rnn = v-rnn
        t-docs.okpo = v-okpo
        t-docs.clntype = v-clntyperep
        t-docs.country = v-country
        t-docs.region = v-region
        t-docs.locat = v-locat
        t-docs.partner = v-partnername
        t-docs.rnnben  = v-rnnben
        t-docs.okpoben = v-okpoben
        t-docs.typeben = v-typeben
        t-docs.countryben = v-countryben
        t-docs.regionben = v-regionben
        t-docs.locatben = v-locatben
        t-docs.dnnum = vcdocs.dnnum
        t-docs.dndate = vcdocs.dndate
        t-docs.docs = vcdocs.docs
        t-docs.sum = vcdocs.sum / 1000
        t-docs.strsum = trim(string(t-docs.sum, ">>>>>>>>>>>>>>9.99"))
        t-docs.codval = txb.ncrc.code
        t-docs.ctformrs = vccontrs.ctformrs
        t-docs.inout = v-inout
        t-docs.note = vcdocs.info[1].
        if v-bin = yes then do:
            t-docs.bin = v-binsen.
            t-docs.iin = v-iinsen.
            t-docs.binben = v-binben.
            t-docs.iinben = v-iinben.
        end.
    end.
end.
