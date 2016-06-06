/* vip.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        общая процедура печати выписок и документов по счетам клиентов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        2-4-х
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        .....      sasco   - добавил VIP_DIL (выписка по дилингу)
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        11.09.2003 nadejda - немного оптимизировала циклы для использования индексов
        19.09.2003 nadejda - исключаем печать Storned/Storno, если у клиента есть такая настройка
        05.10.2004 nadejda - убраны условия по jl.gl в поиске проводок, иначе проводки по старому плану счетов не учитываются
        29/10/2008 madiyar - поменял кода символов псевдографики
        20.09.2010 k.gitalov - изменил бик
        21.12.2011 damir - увеличил формат по Дт и Кт...
        18.04.2012 damir - подредактировал по формату вывода на матричный принтер. Формат сумм по полю ДЕБЕТ и КРЕДИТ выставил
        десятки миллиардов, тестировали с филиалами.
        24/04/2012 evseev - rebranding.БИК из sysc cleocod
        25.04.2012 damir  - изменил формат вывода назначения платежа с 20 на 24.
        22.05.2012 evseev - rebranding
        24.05.2012 evseev - rebranding
*/

define input  parameter in_acc       like aaa.aaa.  /* Customer's Account  */
define input  parameter in_date_from as date.       /* Period Begin  */
define input  parameter in_date_to   as date.       /* Period End   */
define input  parameter in_p_vip     as char.       /* put vipiska   */
define input  parameter in_p_mem     as char.       /* Put mem.ord.  */
define input  parameter in_p_memf    as char.       /* Put mem.ord.  */
define input  parameter in_p_pld     as char.       /* Put plat.por. deb.   */
define input  parameter in_p_plc     as char.       /* Put plat.por. kred.  */
define output parameter o_err        as logi.       /* Customer's Account  */

def shared var g-today  as date.
def shared var flg1     as logi initial true.

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

define buffer c-jl for jl.

def var pvid            as char.
def var rec_id          as recid.
def var o_dealtrn       as character.
def var o_custtrn       as character.
def var o_ordinsN       as character.
def var o_ordins        as character.
def var o_ordcustN      as character.
def var o_ordcust       as character.
def var o_ordacc        as character.
def var o_ordacc1       as character.
def var o_benfsrN       as character.
def var o_benfsr        as character.
def var o_benacc        as character.
def var o_benacc1       as character.
def var o_benbankN      as character.
def var o_benbank       as character.
def var o_dealsdet      as character.
def var o_bankinfo      as character.
def var o_vidop         as character.
def var my_jh           like jl.jh.
def var my_ln           like jl.ln.
def var my_acc          like aaa.aaa.
def var in_command      as char init "joe".
def var in_destination  as char init "vip.img".
def var in_destination0 as char init "vipiska.img".
def var partkom         as char.
def var v-sal1          like jl.dam.
def var v-sal2          like jl.dam.
def var v-obd           like jl.dam.
def var v-obc           like jl.dam.
def var v-ndok          as char format "X(9)" .
def var v-voper         as char format "X(7)".
def var v-bank          as char format "X(9)" init "XXX".
def var v-kor           as char format "x(12)".
def var v-ln            as logi init false.
def var v-ok            as logi init false.
def var v-tmp           as char.
def var v-add           as char.
def var v-vp            as char.
def var v-bankcode      as char format "X(9)" init "XXX".
def var v-crccode       like crc.code.
def var v-sln           as char.
def var v-jlln          as inte.
def var v-nostorno      as logi.
def var v-preddat       as date.
def var v-dt            as date.
def var doccount        as inte init 0.

def temp-table temp like jl
index idx is primary jdt cam dam.

find sysc where sysc.sysc eq "CLECOD" no-lock no-error.
if available sysc then v-bankcode = substring(trim(sysc.chval),7,3).

/*if search("mem.img") ne  ? then */
unix silent rm -f value("mem.img").

/*if search("plat.img") ne  ? then */
unix silent rm -f value("plat.img").

flg1 = true.
v-sal1=0.
v-sal2=0.
v-obd =0.
v-obc =0.

function GetAcc returns char ( input njh as int):
    def buffer bb-jl for jl.
    find first bb-jl where bb-jl.jh = njh and bb-jl.sub = "cif" and bb-jl.acc <> in_acc no-lock no-error.
    if avail bb-jl then return bb-jl.acc.
    else return "N/A".
end function.

find aaa where aaa.aaa eq in_acc no-lock no-error.
if not avail aaa then return /* err */.

find crc where crc.crc = aaa.crc no-lock no-error.
if avail crc then v-crccode = crc.code.

find lgr where lgr.lgr = aaa.lgr no-lock no-error.
if avail lgr and lgr.led eq "ODA" then return. /* err*/ /*( CDA "DDA" SAV)*/

find cif where cif.cif = aaa.cif no-lock no-error .   /*err */

/* 19.09.2003 nadejda - найти установку у клиента - сторно печатать/нет */
find first sub-cod where sub-cod.sub = "vip" and sub-cod.d-cod = "clnprn" and sub-cod.acc = aaa.cif no-lock no-error.
v-nostorno = (avail sub-cod and sub-cod.ccode = "10").

find last aab where aab.aaa = in_acc and aab.fdt lt in_date_from no-lock no-error.
if avail aab then v-sal1 = aab.bal.
if aaa.craccnt ne "" then do:
    find last aab where aab.aaa = aaa.craccnt and aab.fdt lt in_date_from no-lock no-error.
    if avail aab then v-sal1 = v-sal1 + aab.bal.
end.

output to value(in_destination).

find first cmp no-lock.

put skip fill("-",80) format "X(80)". /*115*/
put skip  trim(cmp.name) + '  ' + v-clecod format "X(120)".
put skip(1).
put skip space(15) "ВЫПИСКА ПО СЧЕТУ ЗА ПЕРИОД С " in_date_from format "99/99/9999" " ПО " in_date_to   format "99/99/9999" " .".
put skip space(35) "СЧЕТ : " in_acc " " v-crccode .
/* put skip space(15) "ДАТА ПОСЛЕДНЕЙ РАБОТЫ СЧЕТА ДО НАЧАЛА ПЕРИОДА : ".*/
v-preddat = ?.

for each jl where jl.acc = in_acc no-lock use-index acc:
    if jl.lev <> 1 then next.
    /* 19.09.2003 nadejda */
    find jh where jh.jh = jl.jh no-lock no-error.
    if v-nostorno and jh.party begins "Storn" then next.
    if jl.jdt >= in_date_from and jl.jdt <= in_date_to then do:
        if jl.rem[1] begins "O/D PROTECT" or jl.rem[1] begins "O/D PAYMENT" then next.
        create temp.
        buffer-copy jl to temp.
    end.
    if jl.sub <> "CIF" then next.
    if jl.jdt < in_date_from and ((v-preddat = ?) or (v-preddat < jl.jdt)) then
    v-preddat = jl.jdt.
end.

put skip(1).
put skip "КЛИЕНТ: " cif.cif "  " trim(trim(cif.prefix) + " " + trim(cif.name)) format "x(80)".
put skip fill("-",80) format "X(80)".
put skip(1) space(40) "ВХОДЯЩЕЕ САЛЬДО " v-sal1 format "zzzzzzzzzzzzz9.99-" to 80 .
put skip fill("-",80) format "X(80)".
if aaa.crc = 1 then do:
    put skip " Дата     | N Док. |     Дебет        |    Кредит        |Счет отпр/получателя".
end.
else do:
    put skip " Дата     | N Док. |     Дебет        |    Кредит        |  Назначение платежа".
end.
put skip fill("-",80) format "X(80)" skip.

FOR EACH temp NO-LOCK  BREAK BY temp.jdt by temp.dam by temp.cam:
    find jl where jl.jh eq temp.jh and jl.ln eq temp.ln no-lock no-error.
    if not avail jl then next.
    v-obd = v-obd + temp.dam.
    v-obc = v-obc + temp.cam.
    rec_id = recid(jl).
    v-ndok = "".
    v-voper = "01".
    v-bank = v-bankcode.
    v-kor = "X".
    v-ok = false.
    v-vp = "".
    find jh where jh.jh = temp.jh no-lock no-error.
    IF temp.dc = "D" then do:
        v-ln = false.
        find first trxcods where trxcods.trxh = temp.jh and trxcods.trxln = temp.ln and trxcods.codfr = "faktura" no-lock no-error.
        if avail trxcods and trxcods.code begins "chg" then do:
            v-tmp = trxcods.code .
            v-ln = false .
            v-sln = "".
            v-jlln = 0.

            for each trxcods where trxcods.trxh = temp.jh no-lock:
                if trxcods.codfr <> "faktura" then next.
                if trxcods.code <> v-tmp then next.
                v-sln = v-sln + string(trxcods.trxln) + ",".
            end.
            if lookup(string(temp.ln),v-sln) modulo 2 eq 0 then v-jlln = integer(entry(lookup(string(temp.ln),v-sln) - 1, v-sln))
            no-error.
            else v-jlln = integer(entry(lookup(string(temp.ln),v-sln) + 1, v-sln)) no-error.
            if error-status:error then v-jlln = 0.
            find c-jl where c-jl.jh = temp.jh and c-jl.ln = v-jlln  use-index jhln  no-lock no-error.
            if available c-jl then do:
                find first fakturis where fakturis.jh = temp.jh and fakturis.trx = c-jl.trx and fakturis.ln = c-jl.ln
                use-index jhtrxln no-lock no-error.
                if available fakturis then do:
                    v-ndok = trim(string(fakturis.order)).
                    v-voper = "06".
                    v-bank = v-bankcode.
                    v-kor = trim(c-jl.acc).
                    if v-kor = "" then v-kor = trim(string(c-jl.gl)).
                    v-ok = true.
                    v-vp = "f".
                end.
            end.
        end.
    end.
    IF not v-ok then DO:
        If jh.sub = "RMZ"  and not (jh.party begins "Storned") then do:
            v-ndok = jh.ref.
            o_vidop = "".
            run vip_rmze(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
            if return-value = "0" then do:
                v-ndok=o_custtrn.
                if o_vidop eq "" then  v-voper = "01".
                else  v-voper=o_vidop.
                if temp.dam <> 0 then do:           /* dati sanemeja:  */
                    v-bank = o_benbankN.
                    v-kor  = o_benacc.
                end.
                else do:                      /* jl.cam <> 0   dati maksataja  */
                    v-bank = o_ordinsN.
                    v-kor  = o_ordacc.
                end.
                v-ok = true.
                v-vp = "p".
                o_dealsdet = o_dealsdet + o_bankinfo.
            end.
        end.
        /* ----------------------- NOVOE ---->  DEALING ------- */
        else If jh.sub = "DIL" and not (jh.party begins "Storned") then do:
            v-ndok = jh.ref.
            o_vidop = "".
            run vip_dil(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).

            if return-value = "0" then do:
                v-ndok = o_custtrn.
                if o_vidop eq "" then  v-voper = "01".
                else  v-voper = o_vidop.

                if temp.dam <> 0 then do:           /* dati sanemeja:  */
                    v-bank = o_benbankN.
                    v-kor  = o_benacc.
                end.
                else do:                      /* jl.cam <> 0   dati maksataja  */
                    v-bank = o_ordinsN.
                    v-kor  = o_ordacc.
                end.
                if trim(v-kor) = "" then  v-kor = GetAcc( jh.jh ).
                v-ok = true.
                v-vp = "f".
                o_dealsdet=o_dealsdet + o_bankinfo.
                my_jh = temp.jh.
                my_ln = temp.ln.
                my_acc = o_ordacc.
            end.
        end.
        /* ----------------------------------------------------------------- */
        else If jh.sub = "JOU" and not (jh.party begins "Storned" ) then do:
            v-ndok = jh.ref.
            o_vidop = "".
            run vip_joul(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
            if return-value = "0" then do:
                v-ndok = o_custtrn.
                if o_vidop eq "" then  v-voper="01".
                else  v-voper = o_vidop.
                if temp.dam <> 0 then do:   /* dati sanemeja:  */
                    v-bank = v-bankcode.  /* ?? */
                    v-kor  = o_benacc.
                end.
                else do:  /* jl.cam <> 0   dati maksataja  */
                    v-bank = v-bankcode.
                    v-kor  = o_ordacc.
                end.
                v-ok = true.
                v-vp = "p".
                o_dealsdet = o_dealsdet + o_bankinfo.
            end.
        end.

        If not v-ok then do:
            run vip_cit(rec_id, output o_dealtrn,output o_custtrn, output o_ordinsN, output o_ordins, output o_ordcustN, output o_ordcust, output o_ordacc, output o_ordacc1,output o_benfsrN,output o_benfsr, output o_benacc, output o_benacc1, output o_benbankN, output o_benbank, output o_dealsdet,  output o_bankinfo, output o_vidop).
            if return-value = "0" then do:
                v-ndok=o_custtrn.
                if o_vidop eq "" then  v-voper="01".   /*"01-".*/
                else  v-voper = o_vidop.
                if temp.dam <> 0 then do:   /* dati sanemeja:  */
                    v-bank = o_benbankN.
                    v-kor  = o_benacc.
                end.
                else do:  /* jl.cam <> 0   dati maksataja  */
                    v-bank = o_ordinsN.
                    v-kor  = o_ordacc.
                end.
                v-ok = true.
                v-vp = "p".
                /*if in_pvid ne "pl" then v-vp="f". */
                o_dealsdet = o_dealsdet + o_bankinfo.
            end.
        end.
    END.
    /*if temp.dam <> 0  then put temp.dam format "zzzzzzzzzzzzz9.99-" to 36.
    if temp.cam <> 0  then put temp.cam format "zzzzzzzzzzzzz9.99-" to 53.*/

    if aaa.crc <> 1 then do:
        def var v-rem as char.
        def var z as int init 0.
        v-rem = temp.rem[1].
        do z = 1 to 5:
            if trim(temp.rem[z]) <> '' and trim(temp.rem[z]) <> trim(v-rem) then do:
                if v-rem <> '' then v-rem = v-rem + ''.
                v-rem = v-rem + temp.rem[z].
            end.
        end.
        v-kor = v-rem.
    end.
    put unformatted temp.jdt format "99/99/9999" "|" v-ndok format "x(8)" "|" temp.dam format "zz,zzz,zzz,zz9.99-"
    "|" temp.cam format "zz,zzz,zzz,zz9.99-" "|".

    if length( v-kor ) > 24 then do:
        def var Ilen as int.
        def var Ipos as int.
        def var spc as int.
        Ilen = length(v-kor).
        repeat Ipos = 1 to Ilen:
            spc = 24.
            if substring( v-kor,Ipos + 24,1) <> ' '  and  substring( v-kor,Ipos + 25,1) <> ' ' then do:
                repeat:
                    if substring( v-kor,Ipos + spc,1) = ' ' or spc = 1 then leave.
                    else do:
                        spc = spc - 1.
                    end.
                end.
                if spc = 1 then spc = 24.
            end.
            put unformatted trim(substring( v-kor,Ipos,spc)) format "x(24)" skip.
            Ipos = Ipos + ( spc - 1 ).
            if Ipos >= Ilen then Ipos = Ilen.
            else put unformatted "          |        |                  |                  |".
        end.
    end.
    else put unformatted  v-kor format "x(24)"  skip.
    doccount = doccount + 1.
    /*if (in_p_mem = "1" or in_p_memf = "1") and v-vp = "f"  then do:
    pvid = "mem".
    if in_p_memf = "1" then pvid = "memf".
    if avail c-jl then run vipfaktur(pvid,in_acc,c-jl.jh,c-jl.ln,temp.dam).
    else run vipfaktur(pvid, in_acc, temp.jh, temp.ln, temp.dam).
    end.*/

    /*if v-vp="p" and ( (temp.dam > 0 and in_p_pld="1") or (temp.cam > 0 and in_p_plc="1") ) then do:
    pvid="pl".
    run vipplat(pvid,rec_id,o_custtrn,o_ordcustN,o_ordcust,o_ordacc,o_ordacc1,o_ordinsN,o_ordins,o_benfsrN,o_benfsr,o_benacc,o_benacc1,o_benbankN,o_benbank,o_dealsdet).
    end.*/
END.  /* for jl */
v-sal2 = v-sal1 + v-obc - v-obd.
/*Put skip fill(chr(157),80) format "X(80)".*/
put skip fill("-",80) format "X(80)" skip.
put unformatted      "  ИТОГО   |" string(doccount,"zzzzzzz9") "|" v-obd format "zz,zzz,zzz,zz9.99-" "|"
v-obc format "zz,zzz,zzz,zz9.99-" "|".
/* v-obd format "z,zzz,zzz,zz9.99-" to 63
v-obc format "z,zzz,zzz,zz9.99-" to 80.*/
put skip fill("-",80) format "X(80)" skip.
put space(40) "ИСХОДЯЩЕЕ САЛЬДО" v-sal2 format "zzzzzzzzzzzzzzzzzzzzzzzzzzzzz9.99-" to 80 .
/*PUT SKIP space(20)   "ИСХОДЯЩЕЕ САЛЬДО".
if v-sal2 < 0 then
put v-sal2 * (-1) format "zzzzzzzzzzzzz9.99-" to 63.
else
put v-sal2        format "zzzzzzzzzzzzz9.99-" to 80.*/
put skip fill("-",80) format "X(80)".
put skip(5).
/* atlikuma parbaude */

define variable v-a1     like jl.dam init 0.
define variable pbal     like jl.dam.   /*Full balance*/
define variable pavl     like jl.dam.   /*Available balance*/
define variable phbal    like jl.dam.   /*Hold balance*/
define variable pfbal    like jl.dam.   /*Float balance*/
define variable pcrline  like jl.dam.   /*Credit line*/
define variable pcrlused like jl.dam.   /*Used credit line*/
define variable pooo     like aaa.aaa.

if in_date_to >= g-today then do:
    run aaa-bal777 (input in_acc, output pbal, output pavl,
    output phbal, output pfbal, output pcrline, output pcrlused, output pooo).
    v-a1 = pbal - pcrline.
end.
else do:
    find last aab where aab.aaa = in_acc and aab.fdt <= in_date_to no-lock no-error.
    if avail aab then v-a1 = aab.bal.
    if aaa.craccnt <> "" then do:
        find last aab where aab.aaa = aaa.craccnt and aab.fdt <= in_date_to no-lock no-error.
        if avail aab then v-a1 = v-a1 + aab.bal.
    end.
end.
if abs(v-sal2) ne  abs(v-a1) then do:
    run vip_err("VIP","ERR","Error: счет " + string(in_acc) + "  ИСХОДЯЩЕЕ САЛЬДО " + trim(string(v-a1,"zzzzzzzzzzzzzz9.99-")) +
    " " + trim(string(v-sal2,"zzzzzzzzzzzzzz9.99-")) + " " + trim(string(v-sal2 - v-a1 ,"zzzzzzzzzzzzzz9.99-"))) .
    o_err=true.
end.
output close.

v-add = "cat ".
if in_p_vip = "1" then v-add = v-add + " vip.img".
if search("./mem.img")  <>  ? then   v-add = v-add + " mem.img".
if search("./plat.img") <>  ? then   v-add = v-add + " plat.img".
v-add = v-add + " >> vipiska.img".
unix silent value(v-add).
pause 0.

procedure SW:
    def input param dd as char.
    if v-crccode <> "KZT" then message dd view-as alert-box.
end procedure.


