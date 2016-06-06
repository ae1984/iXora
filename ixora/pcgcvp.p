 /* pcgcvp.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Отправка запроса и получение ответа от ГЦВП
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        08.02.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        24.06.2013 evseev - tz-1810
        10.09.2013 Lyubov - ТЗ 2080, убрала вывод номера запроса из сообщения
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF
*/

{global.i}

def shared var v-aaa as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-cifcod   as char no-undo.

run savelog("pcgcvp", "29. " + v-aaa  + " | " + s-credtype ).

def var p-sik as char.
def var p-lastname as char.
def var p-firstname as char.
def var p-midname as char.
def var p-plastname as char.
def var p-birthdt as char.
def var p-numpas as char.
def var p-dtpas as char.
def var v-file as char.
def var v-date as char.
def var v-sr as char.
def var v-dirq as char.
def var num as inte.
def var v-codrel as char.
def var v-qtype as inte.

def var fname as char.
def var v-dira as char.
def var v-diri as char.
def var i as inte.
def var v-suma as deci.
def var v-gcvptxt as char.
def var v-select  as inte.

define temp-table t-gcvp
field txt as char format "x(50)".

def stream out1.

{sysc.i}
{pk-sysc.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
 display " There is no record OURBNK in bank.sysc file !!".
 pause.
 return.
end.
s-ourbank = trim(sysc.chval).

find first pcstaff0 where pcstaff0.aaa = v-aaa and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = s-credtype no-lock no-error.

/*run sel2 ("Выберите :", " 1. Отправить запрос в ГЦВП | 2. Получить ответ из ГЦВП | 3. Выход ", output v-select).*/
run sel2 ("Выберите :", " 1. Просмотреть ответ ГЦВП | 2. Выход ", output v-select).
case v-select:
    /*when 1 then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
        if avail pkanketh then do:
            message 'Запрос в ГЦВП уже был отправлен' pkanketh.rdt '. Отправить еще раз?' view-as alert-box buttons yes-no title '' update v-ans as logical.
        end.
        if not avail pkanketh or v-ans then do:
            num = next-value(pk-gcvp).
            v-sr = string(get-pksysc-int("gcvpsr")).
            v-date = substr(string(g-today), 1, 6) + string(year(g-today)).
            v-dirq = get-sysc-cha ("pkgcvq").
            v-file = fill("0", 8 - length(trim(string(num)))) + trim(string(num)).
            v-codrel = "".
            v-qtype = 2.

            output stream out1 to rpt.txt.
            put stream out1 unformatted  v-file + "|" + string(g-today,'99.99.9999') +  "|" + pcstaff0.iin + "|" + pcstaff0.sname + "|" + pcstaff0.fname + "|" +
            pcstaff0.mname + "|" + string(pcstaff0.birth,'99.99.9999') +  "|" + pcstaff0.nomdoc +  "|" + string(pcstaff0.issdt,'99.99.9999') +  "|" + v-file + "|" +
            v-date + "|" + string(v-qtype) + "|" skip.

            output stream out1 close.

            unix silent un-win rpt.txt value(v-file).
            unix silent cp value(v-file) value(v-dirq + v-file).

            find sysc where sysc.sysc = "pkgcvm" no-lock no-error.

            run mail(trim(sysc.chval), "MKO NK <abpk@fortebank.kz>", "Fdjkl358Jd", "" , "1", "", v-file).
            run savelog( "gcvpout", "Отправка файла в ГЦВП : " + v-file).

            unix silent cp value(v-file) value(v-dirq + v-file).
            unix silent rm -f value(v-file).

            find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
            if not avail pkanketh then do:
                create pkanketh.
                assign pkanketh.bank     = pcstaff0.bank
                       pkanketh.cif      = pcstaff0.cif
                       pkanketh.credtype = '4'
                       pkanketh.ln       = pkanketa.ln
                       pkanketh.kritcod  = 'gcvpres'
                       pkanketh.value1   = "metrocombank" + v-file
                       pkanketh.rescha[3] = "metrocombank" + v-file
                       pkanketh.rdt      = g-today
                       pkanketh.rwho     = g-ofc.
            end.
            else do:
                find current pkanketh exclusive-lock no-error.
                pkanketh.value1    = "metrocombank" + v-file.
                pkanketh.rescha[3] = "metrocombank" + v-file.
                pkanketh.rdt       = g-today.
                pkanketh.rwho      = g-ofc.
                find current pkanketh no-lock no-error.
            end.
            create gcvp.
            assign gcvp.bank = s-ourbank
                   gcvp.lname = pcstaff0.sname
                   gcvp.fname = pcstaff0.fname
                   gcvp.mname = pcstaff0.mname
                   gcvp.dtb = date(pcstaff0.birth)
                   gcvp.iin = pcstaff0.iin
                   gcvp.ofc = g-ofc
                   gcvp.rdt = g-today
                   gcvp.nfile = v-file.
        end.
        else return.
    end.*/
    when 1 then do:
        run savelog("pcgcvp", "145. " + v-aaa  + " | " + s-credtype ).
        v-codrel = "".
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
        if not avail pkanketh or pkanketh.rescha[3] = "" then message skip
        "Запрос данных в ГЦВП не был отправлен !" skip(1)
        view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
        else do:
            if num-entries(pkanketh.rescha[3],";") = 1 then do:
            /* файл был, но ответ не импортировался */
                fname = entry(1,pkanketh.rescha[3],";").
                v-dira = get-sysc-cha ("pkgcva").
                v-diri = get-sysc-cha ("pkgcvi").
                FILE-INFO:FILE-NAME = v-diri + fname.
                IF FILE-INFO:FILE-TYPE = ? THEN do:
                    message skip "Файл ответа " + fname + " из ГЦВП не пришел" skip(1)
                    view-as alert-box button Ok title "Внимание!".
                    return.
                end.

                IF FILE-INFO:FILE-SIZE = 0 THEN do:
                    message skip "При приеме ответа " + fname + " из ГЦВП произошел сбой!" skip
                    "Повторите запрос в ГЦВП !" skip(1)
                    view-as alert-box button Ok title "Внимание!".
                    pkanketh.rescha[3] = "".
                    return.
                end.

                input from value(v-diri + fname).
                REPEAT on error undo, leave:
                    create t-gcvp.
                    import unformatted t-gcvp no-error.
                    IF ERROR-STATUS:ERROR then do:
                        run savelog("gcvpout","Ошибка импорта").
                        return.
                    END.
                END.
                input close.

                run savelog("gcvpout", "Принятие ответа из ГЦВП " + fname).
                run savelog("pcgcvp", "184 . " + v-aaa  + " | " + s-credtype  + " | " +  fname).
                find first pkanketh where pkanketh.kritcod = 'gcvpres' no-error.
                pkanketh.value2 = fname.
                pkanketh.value3 = "1".
                pkanketh.value4 = "1".

                find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '4' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' exclusive-lock no-error.
                for each t-gcvp.
                    if trim(t-gcvp.txt) <> '' then pkanketh.rescha[3] = pkanketh.rescha[3] + ";" + t-gcvp.txt.
                end.
            end.
            v-gcvptxt = pkanketh.rescha[3].
            run savelog("pcgcvp", "196. " + v-aaa  + " | " + s-credtype ).
            run pkgcvprep2(v-gcvptxt, "").
            run savelog("pcgcvp", "198. " + v-aaa  + " | " + s-credtype ).
        end.
    end.
    when 2 then return.
end.