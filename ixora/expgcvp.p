 /* expgcvp.p
 * MODULE
        экспресс кредиты по ПК
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

 * AUTHOR
        11/11/2013 Luiza ТЗ 1831
 * BASES
 		BANK COMM
 * CHANGES
*/

{global.i}

def  var s-credtype as char init '10' no-undo.

def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-bank     as char no-undo.

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
def var vnold as char init "".

define temp-table t-gcvp
field txt as char format "x(50)".

def stream out1.

{sysc.i}
{pk-sysc.i}
{srvcheck.i}

find first pcstaff0 where pcstaff0.cif = v-bank and pcstaff0.cif = v-cifcod use-index bc no-lock no-error.
find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.

run sel2 ("Выберите :", " 1. Просмотреть ответ ГЦВП | 2. Отправить запрос в ГЦВП | 3. Выход ", output v-select).
case v-select:
    when 1 then do:
        v-codrel = "".
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
        if not avail pkanketh or pkanketh.rescha[3] = "" then message skip
        " Запрос данных в ГЦВП  не был отправлен !" skip(1)
        view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
        else do:
            if num-entries(pkanketh.rescha[3],";") = 1 then do:
            /* файл был, но ответ не импортировался */
                fname = entry(1,pkanketh.rescha[3],";").
                if isProductionServer() then do:
                    v-dira = get-sysc-cha ("pkgcva").
                    v-diri = get-sysc-cha ("pkgcvi").
                end.
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
                        run savelog("gcvpout","Экспресс кредиты Ошибка импорта").
                        return.
                    END.
                END.
                input close.

                run savelog("gcvpout", "Экспресс кредиты Принятие ответа из ГЦВП " + fname).

                find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' exclusive-lock no-error.
                pkanketh.value2 = fname.
                pkanketh.value3 = "1".
                pkanketh.value4 = "1".

                for each t-gcvp.
                    if trim(t-gcvp.txt) <> '' then pkanketh.rescha[3] = pkanketh.rescha[3] + ";" + t-gcvp.txt.
                end.
            end.
            v-gcvptxt = pkanketh.rescha[3].
            run pkgcvprep2(v-gcvptxt, "").
        end.
    end.
    when 2 then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
        if avail pkanketh and lookup(trim(pkanketh.value1),"100,110,120") > 0 then do:
            message "Данные уже сохранены, отправление запроса в ГЦВП невозможно!" view-as alert-box  buttons ok.
            return.
        end.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketa.cif = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
        if available pkanketh then vnold = pkanketh.value1.
        run gcvp_send.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketa.cif = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'gcvpres' no-lock no-error.
        if available pkanketh then if vnold <> pkanketh.value1 then message 'Запрос в ГЦВП отправлен' view-as alert-box.
    end.
    when 3 then return.
end.