/*LCDocs2 .p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Amendment - формирование документов
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        30/11/2010 galina - добавила признак MT707
        09/12/2010 galina - выводим номер аккредитива заглавными буквами
        28/02/2011 id00810 - для всех импортных аккредитивов и гарантии
        12/05/2011 id00810 - вызов lcmtamd
        06.04.2012 Lyubov  - добавила печать ордера для лимитов
*/

{global.i}
def new shared var s-jh      like jh.jh .
def     shared var s-lc      like lc.lc.
def     shared var s-lcamend like lcamend.lcamend.
def     shared var s-lcprod  as char.
def     shared var v-cif     as char.
def            var v-sel     as integer.
def            var i         as integer.
def            var v-logsno  as char init "no,n,нет,н,1".
def            var v-bank    as char no-undo.

find first sysc where sysc.sysc = "OURBNK" no-lock no-error.
if avail sysc and sysc.chval <> '' then v-bank = sysc.chval.
else return.

if s-lcprod <> 'pg' then run sel2('Docs',' MT 707 | Payment Order ', output v-sel).
else run sel2('Docs',' MT 767 | Payment Order ', output v-sel).
case v-sel:
    when 1 then do:
        if s-lcprod <> 'pg' then do:
            find first lcamendh where lcamendh.lc = s-lc and lcamendh.lcamend = s-lcamend and lcamendh.kritcode = 'MT707' no-lock no-error.
            if avail lcamendh and lookup(lcamendh.value1,v-logsno) > 0 then do:
                message 'Your choice had been not to create this type of document!' view-as alert-box.
                return.
            end.
            else run lcmtamd.p ('707',no).
        end.
        else run lcmtamd.p ('767',no).
    end.
    when 2 then do:
        find first lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.jh > 0 no-lock no-error.
        if avail lcamendres then do:
            for each lcamendres where lcamendres.lc = s-lc and lcamendres.lcamend = s-lcamend and lcamendres.jh > 0 no-lock:
                s-jh  = 0.
                find first jh where jh.jh = lcamendres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
        end.
        else message 'No postings avail!' view-as alert-box.

        find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
        if avail lch then do:
            find first lclimitres where lclimitres.bank = v-bank and lclimitres.cif = v-cif and lclimitres.number = int(lch.value1) and lclimitres.jh > 0 and lclimitres.lc = s-lc and lclimitres.info[1] = 'amend' no-lock no-error.
            if avail lclimitres then do:
                s-jh  = 0.
                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                if avail jh then do:
                    s-jh = jh.jh.
                    run vou_bank(1).
                end.
            end.
            else message 'No postings avail!' view-as alert-box.
        end.
    end.
end case.