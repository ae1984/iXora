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
        14/06/2013 galina - ТЗ1552
        14/06/2013 yerganat - tz1804, добавил заметки с типом remarkdmo
        28/06/2013 yerganat - tz1930, g-ofc заменил на v-ofc
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def input parameter mcode as char no-undo.
def input parameter v-title as char no-undo.

def frame frdes
    lnmoncln.res-ch[1] label "Описание" format "x(1000)" view-as editor size 90 by 30
    with width 102 side-labels row 5 centered overlay.

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
   &formname  = "chk-clnd"
   &framename = "longr"
   &where     = " lnmoncln.lon = s-lon and lnmoncln.code = mcode "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = " lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc.
                update lnmoncln.pdt with frame longr. if  mcode = 'remarkdmo' or v-ofc = '' then update lnmoncln.pwho with frame longr.
                update lnmoncln.edt lnmoncln.ewho with frame longr.
                if mcode = 'kkres' or mcode = 'remarkdmo'  then do: update lnmoncln.res-ch[1] with frame frdes. end.
                update lnmoncln.otsr with frame longr."
   &prechoose = " message ' F4 - Выход '. "
   &postdisplay = " "
   &display   = "lnmoncln.pdt lnmoncln.pwho lnmoncln.edt lnmoncln.ewho lnmoncln.otsr "
   &highlight = " lnmoncln.pdt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmoncln.pdt  with frame longr.
                   if mcode = 'remarkdmo' or  v-ofc = '' then update lnmoncln.pwho with frame longr.
                   update lnmoncln.edt lnmoncln.ewho with frame longr.
                   if mcode = 'kkres' or mcode = 'remarkdmo'  then do: update lnmoncln.res-ch[1] with frame frdes. hide frame frdes. end.
                   update lnmoncln.otsr with frame longr.
                end."
   &end = "hide frame longr."
}

