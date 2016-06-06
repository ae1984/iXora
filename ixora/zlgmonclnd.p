/* zlgmonclnd.p
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
        18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониториг залогов - переоценка"
 * BASES
        BANK
 * CHANGES
        17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr
*/

def shared var g-ofc as char.
def shared var g-lang as char.
def shared var s-lon like lon.lon.
def shared var m-ln as int.

def input parameter mcode as char no-undo.
def input parameter v-title as char no-undo.

define shared variable g-today  as date.

def frame frdes
    lnmoncln.res-ch[1] label "Описание" format "x(1000)" view-as editor size 90 by 30
    with width 102 side-labels row 5 centered overlay.

def var v-ofc as char no-undo.

find first loncon where loncon.lon = s-lon no-lock no-error.
if avail loncon then v-ofc = loncon.pase-pier.
else v-ofc = g-ofc.

{jabrw.i
   &start      = "  define var v-zalname as char.
                    define buffer b-lonsec1 for lonsec1.
                    find first b-lonsec1 where b-lonsec1.lon = s-lon and b-lonsec1.ln = m-ln no-lock no-error.
                    if avail b-lonsec1 then do: v-zalcrc = b-lonsec1.crc. v-zalname = b-lonsec1.prm + ',' + b-lonsec1.vieta. end.
                    else do: v-zalcrc = 0. v-zalname = ''. end.
                "
   &head       = "lnmoncln"
   &headkey    = "pdt"
   &index      = "lncodepdt"
   &formname   = "chk-clnd_zlg"
   &framename  = "longr2"
   &where      = " lnmoncln.lon = s-lon and lnmoncln.code = mcode and lnmoncln.zalnum = m-ln "
   &addcon     = "true"
   &deletecon  = "true"
   &precreate  = "  v-zalsum = 0. "
   &postcreate  = " lnmoncln.lon = s-lon. lnmoncln.code = mcode. lnmoncln.pwho = v-ofc. lnmoncln.zalnum = m-ln. "
   &postadd    = "  update lnmoncln.pdt with frame longr2. if v-ofc = '' then update lnmoncln.pwho with frame longr2.
                    update lnmoncln.edt lnmoncln.ewho with frame longr2.
                    find first lnmonsrp where lnmonsrp.lon = lnmoncln.lon and lnmonsrp.pdt = lnmoncln.pdt and lnmonsrp.num = integer(lnmoncln.zalnum) exclusive-lock no-error.
                    if lnmoncln.edt <> ? then do:
                        update v-zalsum with frame longr2.
                        if not avail lnmonsrp then do:
                            create lnmonsrp.
                            assign lnmonsrp.lon = lnmoncln.lon lnmonsrp.pdt = lnmoncln.pdt lnmonsrp.num = integer(lnmoncln.zalnum) lnmonsrp.zname = v-zalname lnmonsrp.crc = v-zalcrc.
                        end.
                        lnmonsrp.nsum = v-zalsum.
                    end.
                    else do:
                        if avail lnmonsrp then delete lnmonsrp.
                        v-zalsum = 0.
                        displ v-zalsum with frame longr2.
                    end.
                    update lnmoncln.otsr with frame longr2.
                "
   &prechoose  = " message ' F4 - Выход '. "
   &predisplay = " find first lnmonsrp where lnmonsrp.lon = lnmoncln.lon and lnmonsrp.pdt = lnmoncln.pdt and lnmonsrp.num = integer(lnmoncln.zalnum) no-lock no-error.
                   if avail lnmonsrp then v-zalsum = lnmonsrp.nsum.
                   else v-zalsum = 0.
                   displ v-zalsum with frame longr2.
                 "
   &prevdelete = " find first lnmonsrp where lnmonsrp.lon = lnmoncln.lon and lnmonsrp.pdt = lnmoncln.pdt and lnmonsrp.num = integer(lnmoncln.zalnum) exclusive-lock no-error.
                   if avail lnmonsrp then delete lnmonsrp.
                 "
   &display   = " lnmoncln.pdt lnmoncln.pwho lnmoncln.edt lnmoncln.ewho v-zalcrc v-zalsum lnmoncln.otsr "
   &highlight = " lnmoncln.pdt "
   &postkey   = " else if keyfunction(lastkey) = 'RETURN' then do transaction on endkey undo, leave:
                    find first lnmonsrp where lnmonsrp.lon = lnmoncln.lon and lnmonsrp.pdt = lnmoncln.pdt and lnmonsrp.num = integer(lnmoncln.zalnum) no-lock no-error.
                    if avail lnmonsrp then v-zalsum = lnmonsrp.nsum.
                    else v-zalsum = 0.
                    update lnmoncln.pdt with frame longr2. if v-ofc = '' then update lnmoncln.pwho with frame longr2.
                    update lnmoncln.edt lnmoncln.ewho with frame longr2.
                    if lnmoncln.edt <> ? then update v-zalsum with frame longr2.
                    else v-zalsum = 0.
                    displ v-zalsum with frame longr2.
                    update lnmoncln.otsr with frame longr2.
                    find first lnmonsrp where lnmonsrp.lon = lnmoncln.lon and lnmonsrp.pdt = lnmoncln.pdt and lnmonsrp.num = integer(lnmoncln.zalnum) exclusive-lock no-error.
                    if lnmoncln.edt <> ? then do:
                        if not avail lnmonsrp then do:
                            create lnmonsrp.
                            assign lnmonsrp.lon = lnmoncln.lon lnmonsrp.pdt = lnmoncln.pdt lnmonsrp.num = integer(lnmoncln.zalnum) lnmonsrp.zname = v-zalname lnmonsrp.crc = v-zalcrc.
                        end.
                        lnmonsrp.nsum = v-zalsum.
                     end.
                     else if avail lnmonsrp then delete lnmonsrp.
                 end.
                "
   &end = "hide frame longr2."
}
 find last lnmonsrp where lnmonsrp.lon = s-lon and lnmonsrp.num = m-ln use-index lnpdtspr no-lock no-error.
 find first b-lonsec1 where b-lonsec1.lon = s-lon and b-lonsec1.ln = m-ln exclusive-lock no-error.
 if avail b-lonsec1 and avail lnmonsrp then b-lonsec1.secamt = lnmonsrp.nsum.

