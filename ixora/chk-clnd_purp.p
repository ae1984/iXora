/* chk-clnd_purp.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Мониторинг целевого использования кредита
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
        03/03/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        01/07/2011 madiyar - убрал копирование даты из lon.opndt
        14/06/2013 galina - ТЗ1552
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def input parameter mcode as char no-undo.
def input parameter v-title as char no-undo.

/*
def var v-opndt as date.
def var v-grp as char initial '10,15,16,50,55,56'.

find first lon where lon.lon = s-lon no-lock no-error.
if lookup(string(lon.grp),v-grp) > 0 then v-opndt = lon.opndt.
*/

def var v-ofc as char no-undo.

v-ofc = ''.
find first lon where lon.lon = s-lon no-lock no-error.
if avail lon then do:
    find first loncon where loncon.lon = s-lon no-lock no-error.
    if avail loncon then v-ofc = loncon.pase-pier.
    else v-ofc = g-ofc.
end.
{jabrw.i
   &start     = " "
   &head      = "lnmoncln"
   &headkey   = "pdt"
   &index     = "lncodepdt"
   &formname  = "chk-clnd_purp"
   &framename = "longr"
   &where     = " lnmoncln.lon = s-lon and lnmoncln.code = mcode "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc.
                update lnmoncln.pdt with frame longr. if v-ofc = '' then update lnmoncln.pwho with frame longr.
                update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] with frame longr.
                update lnmoncln.otsr with frame longr.
                "
   &prechoose = " message ' F4 - Выход '. "
   &postdisplay = " "
   &display   = "lnmoncln.pdt lnmoncln.pwho lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] lnmoncln.otsr "
   &highlight = " lnmoncln.pdt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmoncln.pdt with frame longr.
                   if v-ofc = '' then update lnmoncln.pwho with frame longr.
                   update lnmoncln.edt lnmoncln.ewho lnmoncln.res-deci[1] with frame longr.
                   update lnmoncln.otsr with frame longr.
                end."
   &end = "hide frame longr."
}

