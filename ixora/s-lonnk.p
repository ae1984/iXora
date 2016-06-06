/* s-lonnk.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        02/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        25.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        02.11.2004 saltanat - заменила sub.i - sub2.i
        30/01/2006 Natalya D. - добавлено поле Депозит
        04/05/06 marinav Увеличить размерность поля суммы
        12/12/2008 galina - перекомпилЯциЯ
        25/03/2009 galina - добавила поле Џоручител
        23.04.2009 galina - убираем поле поручитель
        09/06/2010 galina- добавила ставку по штрафам до и после 7 дней просрочки
        23/08/2010 madiyar - ставка по комиссии prem_s
        25/08/2010 madiyar - premsdt
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        18/06/2012 kapar - новое поле (Дата прекращения дополнительной % ставки)
        20/06/2012 kapar - новое поле (Дата начала дополнительной % ставки)
        11.01.2013 evseev - ТЗ-1530
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
*/

/**/
{mainhead.i}

{lonlev.i}
def var vpy as char format "x(20)" label "DESC".
define shared variable v-cif   like cif.cif.
define shared variable v-vards like cif.name format "x(36)".
define shared variable v-lcnt  like loncon.lcnt.
def new shared var st as inte.
/**define variable old-lcnt as character.
define variable viss as decimal.**/
define variable v-uno like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.
define shared variable grp-name   as character.
define shared variable cat-des    as character.
define shared variable crc-code   as character.
define shared variable s-cat      as character.
define shared variable s-apr      as character.
define shared variable s-prem     as character.
define shared variable d-prem     as character.
def shared var s-longrp like longrp.longrp.
def shared var vlcnt like loncon.lcnt.
def shared var xacc like jl.acc.
def shared var xjh like jh.jh.
define shared frame cif.

def buffer b-cif for cif.
def buffer b-lon for lon.

def  shared var v-crc like crc.crc.
def  shared var v-rate like crc.rate[1].
def  shared var v-komcl as deci.

{sub2.i
&option = "LONSUB1"
&head = "loncon"
&headkey = "lon"
&framename = "lon"
&formname = "s-lonrdl" /** lonn **/
&where = "loncon.lon = s-lon and "
&updatecon = "false"
&deletecon = "false"
&predelete = " "
&display = " find lon where lon.lon = s-lon.
if index(loncon.rez-char[10],'&') = 0 then paraksts = no.
else if substring(loncon.rez-char[10],index(loncon.rez-char[10],'&') + 1,3) = 'yes' then paraksts = yes. else paraksts = no.
dam1-cam1 = 0. for each trxbal where trxbal.subled = 'LON' and trxbal.acc = lon.lon no-lock:
if lookup(string(trxbal.level),v-lonprnlev,"";"") > 0 then dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam). end. s-longrp = lon.grp.
v-uno = lon.prnmos. s-prem = lon.base + string(lon.prem). d-prem = lon.base + string(lon.dprem). v-deposit = loncon.deposit. /*v-guarantor = trim(loncon.rez-char[8]).*/
find first lons where lons.lon = lon.lon no-lock no-error. if avail lons then assign prem_s = lons.prem premsdt = lons.rdt. else assign prem_s = 0 premsdt = ?.
run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz). cl-voz = - cl-voz. run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz). cl-nevoz = - cl-nevoz.
assign clcif = '' clname = ''.
find first b-lon where b-lon.lon = lon.clmain no-lock no-error.
if avail b-lon then do:
 find first b-cif where b-cif.cif = b-lon.cif no-lock no-error.
 if avail b-cif then assign clcif = b-cif.cif clname = b-cif.name.
end.
display v-cif v-lcnt loncon.lon s-longrp v-uno lon.crc crc-code lon.trtype lon.gua loncon.lcntsub lon.clmain clcif clname loncon.objekts lon.rdt lon.duedt lon.duedt15 lon.duedt35
lon.opnamt dam1-cam1 cl-voz cl-nevoz s-prem d-prem loncon.proc-no lon.rdate lon.ddate lon.ddt[5] lon.cdt[5] loncon.sods1 lon.penprem lon.penprem7 prem_s premsdt
lon.idt15 lon.idt35 paraksts loncon.vad-amats loncon.rez-char[9] loncon.vad-vards loncon.galv-gram
/** loncon.kods loncon.konts loncon.talr **/ lon.aaa lon.aaad v-deposit lon.day lon.plan lon.basedy loncon.who loncon.pase-pier
loncon.lcntdop loncon.dtdop loncon.dtsub loncon.obes-pier
v-crc v-rate v-komcl /*v-guarantor*/ with frame lon. display v-vards with frame cif."
&preupdate = " "
&postupdate = " "
&prerun = "s-lon = loncon.lon."
&postrun = "view frame mainhead."
&end = "for each lonsat where lonsat.lon = s-lon and lonsat.whn = g-today:
 find jl where jl.jh = lonsat.jh and jl.ln = lonsat.ln and jl.gl = lonsat.gl
 no-lock no-error. if not available jl then do: find lonsa where lonsa.lon =
 s-lon. if lonsat.dc = 'D' then lonsa.dam = lonsa.dam - lonsat.amt. else
 lonsa.cam = lonsa.cam - lonsat.amt. delete lonsat. end. end."
}
/*------------------------------------------------------------------------------
   #3.
      1.izmai‡a - jaunin–jums:atlikums tiek r–dЁts uz ekr–na un izdalЁts

-----------------------------------------------------------------------------*/

