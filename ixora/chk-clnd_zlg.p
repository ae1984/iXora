/* chk-clnd_zlg.p
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
        18/07/2011 kapar - ТЗ 948
        14/06/2013 galina - ТЗ1552
        19/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка"
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
        07/10/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониторинг залогов - переоценка" перекомпиляция в связи с изменением chk-clnd_zlg.f
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.

def shared var g-today as date.

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
   &formname  = "chk-clnd_zlg"
   &framename = "longr"
   &where     = " lnmoncln.lon = s-lon and lnmoncln.code = mcode "
   &addcon    = "true"
   &deletecon = "true"
   &precreate = " "
   &postadd   = "lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc.
                update lnmoncln.pdt with frame longr. if v-ofc = '' then update lnmoncln.pwho with frame longr.
                update lnmoncln.edt lnmoncln.ewho with frame longr.
                update lnmoncln.otsr with frame longr.
                "
   &prechoose = " message ' F4 - Выход, F6-Стоимость в результате переоценки '. "
   &postdisplay = " "
   &display   = "lnmoncln.pdt lnmoncln.pwho lnmoncln.edt lnmoncln.ewho lnmoncln.otsr "
   &highlight = " lnmoncln.pdt "
   &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                then do transaction on endkey undo, leave:
                   update lnmoncln.pdt with frame longr.
                   if v-ofc = '' then update lnmoncln.pwho with frame longr.
                   update lnmoncln.edt lnmoncln.ewho with frame longr.
                   update lnmoncln.otsr with frame longr.
                end.
                if lastkey = keycode('F6') then run chk-clnd_zlg1(lnmoncln.pdt).
                "
   &end = "hide frame longr."
}

