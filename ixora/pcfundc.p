/* pcfundc.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Формирование решния о финансировании
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
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF
*/

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.

def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var vnomer  as char no-undo.
def var vdecis  as char no-undo.
def var vmonthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".


v-infile  = "/data/docs/" + "pcfundec.htm".
v-ofile = "FundingDecision.htm".
output stream out to value(v-ofile).

find first pcstaff0 where pcstaff0.aaa = v-aaa and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
find first pkanketa where pkanketa.bank = v-bank and pkanketa.aaa = pcstaff0.aaa and pkanketa.credtype = s-credtype no-lock no-error.

find first pccards where pccards.aaa = pcstaff0.aaa and pccards.pcard = pcstaff0.pcard and pccards.sts <> 'Closed' no-lock no-error.
if not avail pccards then do:
    message ' Не выпущена платежная карта! ' view-as alert-box.
    return.
end.

if pkanketa.sts = '110' then do:
    message 'Просим рассмотреть заявку в Нестандартном процессе!' view-as alert-box.
    return.
end.

else if pkanketa.sts = '60' or pkanketa.rateq > 0 then do:
    input from value(v-infile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*vnomer*" then do:
                if pkanketa.rescha[1]  = '' then
                vnomer = substr(v-bank,4) + 'КЛ-' + string(year(today),'9999') + '-' + string(month(today),'99') + '/' + string(day(today),'99') + '-' + string(pkanketa.ln).
                else vnomer = pkanketa.rescha[1].
                v-str = replace (v-str, "vnomer", vnomer).
                next.
            end.

            if v-str matches "*vregion*" then do:
                find first cmp no-lock no-error.
                v-str = replace (v-str, "vregion", cmp.name).
                next.
            end.

            if v-str matches "*vday*" then do:
                v-str = replace (v-str, "vday", '«' + string(day(today),'99') + '»').
                next.
            end.

            if v-str matches "*vmonth*" then do:
                v-str = replace (v-str, "vmonth", entry(month(today),vmonthname)).
                next.
            end.

            if v-str matches "*vyear*" then do:
                v-str = replace (v-str, "vyear", substr(string(year(today),'9999'),3)).
                next.
            end.

            if v-str matches "*vcity*" then do:
                find first cmp no-lock no-error.
                v-str = replace (v-str, "vcity", trim(substr(cmp.addr[1],index(cmp.addr[1],',') + 2,index(substr(cmp.addr[1],index(cmp.addr[1],',') + 2),",")), ',')).
                next.
            end.

            if v-str matches "*vdecision*" then do:
                if pkanketa.rating = 0 then vdecis = 'Одобрить установление кредитного лимита на платежную карту на следующих условиях:'.
                if pkanketa.rating < 0 then vdecis = 'Отказать в установлении кредитного лимита на платежную карту на следующих условиях:'.
                v-str = replace (v-str, "vdecision", vdecis).
                next.
            end.

            if v-str matches "*vname*" then do:
                v-str = replace (v-str, "vname", pkanketa.name).
                next.
            end.

            if v-str matches "*viin*" then do:
                v-str = replace (v-str, "viin", pcstaff0.iin).
                next.
            end.

            if v-str matches "*vball*" then do:
                v-str = replace (v-str, "vball", '«' + string(pkanketa.rating) + '»').
                next.
            end.

            if v-str matches "*vsumlim*" then do:
                v-str = replace (v-str, "vsumlim", string(pkanketa.summa)).
                next.
            end.

            if v-str matches "*vsrok*" then do:
                find first pccards where pccards.aaa = pcstaff0.aaa and pccards.pcard = pcstaff0.pcard no-lock no-error.
                v-str = replace (v-str, "vsrok", string(pccards.expdt,'99/99/9999')).
                next.
            end.

            if v-str matches "*vgesv*" then do:
                v-str = replace (v-str, "vgesv", string(pkanketa.rateq)).
                next.
            end.
            leave.
        end. /* repeat */

        put stream out unformatted v-str skip.
    end. /* repeat */
    input close.
    /********/


    output stream out close.

    unix silent value("cptwin " + v-ofile + " winword").
    unix silent value("rm -r " + v-ofile).

    if pkanketa.rescha[1] = '' then do:
        find current pkanketa exclusive-lock no-error.
        pkanketa.rescha[1] = vnomer.
        pkanketa.resdat[1] = today.
        pkanketa.sts       = '160'.
        find current pkanketa no-lock no-error.
    end.
end.

else do:
    message 'Не рассчитана ГЭСВ!' view-as alert-box.
    return.
end.