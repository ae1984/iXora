/* chk-clnd_mon1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Первичный мониторинг
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
        02/03/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        04/03/2011 madiyar - указал не ту форму
        31/05/2011 madiyar - ухудшение фин. состояния обязательно к проставлению только если проставлена дата проверки
        14/06/2013 galina - ТЗ1552
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
        04/10/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" перекомпиляция в связи с изменением chk-clnd_fhmon.f
        07.11.2013 dmitriy - ТЗ 1725
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def input parameter mcode as char no-undo.
def input parameter v-title as char no-undo.

def var v-codfrname as char init "".

def var v-ofc as char no-undo.
v-ofc = ''.

find first lon where lon.lon = s-lon no-lock no-error.
if avail lon then do:
    find first loncon where loncon.lon = s-lon no-lock no-error.
    if avail loncon then v-ofc = loncon.pase-pier.
    else v-ofc = g-ofc.
end.

find first lnmoncln where lnmoncln.lon = s-lon no-lock no-error.
if avail lnmoncln then do:
    find first codfr where codfr.codfr = "finsost" and codfr.code = lnmoncln.fins no-lock no-error.
    if avail codfr then v-codfrname = codfr.name[1].
end.


{jabrw.i
   &start     = " "
   &head      = "lnmoncln"
   &headkey   = "pdt"
   &index     = "lncodepdt"
   &formname  = "chk-clnd_fhmon"
   &framename = "longr"
   &where     = " lnmoncln.lon = s-lon and lnmoncln.code = mcode "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc.
                update lnmoncln.pdt with frame longr. if v-ofc = '' then update lnmoncln.pwho with frame longr.
                update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark with frame longr.
                update lnmoncln.res-ch[1] with frame longr.
                lnmoncln.res-ch[1] = caps(lnmoncln.res-ch[1]).
                if lnmoncln.res-ch[1] = 'Д' or lnmoncln.res-ch[1] = 'YES' or lnmoncln.res-ch[1] = 'Y' then lnmoncln.res-ch[1] = 'ДА'.
                if lnmoncln.res-ch[1] = 'Н' or lnmoncln.res-ch[1] = 'NO' or lnmoncln.res-ch[1] = 'N' then lnmoncln.res-ch[1] = 'НЕТ'.
                displ lnmoncln.res-ch[1] with frame longr.
                update lnmoncln.otsr with frame longr."
   &prechoose = " message ' F4 - Выход '. "
   &postdisplay = " "
   &display   = "lnmoncln.pdt lnmoncln.pwho lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark lnmoncln.res-ch[1] lnmoncln.otsr"
   &highlight = " lnmoncln.pdt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmoncln.pdt with frame longr.
                   if v-ofc = '' then update lnmoncln.pwho with frame longr.
                   update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark with frame longr.
                   update lnmoncln.res-ch[1] with frame longr.
                   lnmoncln.res-ch[1] = caps(lnmoncln.res-ch[1]).
                   if lnmoncln.res-ch[1] = 'Д' or lnmoncln.res-ch[1] = 'YES' or lnmoncln.res-ch[1] = 'Y' then lnmoncln.res-ch[1] = 'ДА'.
                   if lnmoncln.res-ch[1] = 'Н' or lnmoncln.res-ch[1] = 'NO' or lnmoncln.res-ch[1] = 'N' then lnmoncln.res-ch[1] = 'НЕТ'.
                   displ lnmoncln.res-ch[1] with frame longr.
                   update lnmoncln.otsr with frame longr.
                end."
   &end = "hide frame longr."
}
/*--------------------------------------*/





