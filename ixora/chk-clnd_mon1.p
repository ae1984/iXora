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
        14/03/2011 madiyar - убрал редактирование поля lnmoncln.pdt
        07.11.2013 dmitriy - ТЗ 1725. Добавил столбцы "Фин.сост" и "Балл"
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def input parameter mcode as char no-undo.
def input parameter v-title as char no-undo.

def var v-codfrname as char init "".

def var v-ofc as char no-undo.
find first loncon where loncon.lon = s-lon no-lock no-error.
if avail loncon then v-ofc = loncon.pase-pier.
else v-ofc = g-ofc.

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
   &formname  = "chk-clnd_mon1"
   &framename = "longr"
   &where     = " lnmoncln.lon = s-lon and lnmoncln.code = mcode "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc.
                update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark with frame longr."
   &prechoose = " message ' F4 - Выход '. "
   &postdisplay = " "
   &display   = "lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark"
   &highlight = " lnmoncln.edt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] v-codfrname lnmoncln.mark with frame longr.
                   lnmoncln.pdt = lnmoncln.edt.
                end."
   &end = "hide frame longr."
}

