/* s-lonu.p
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
        26.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        10/02/06 marinav переломпиляция
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        28/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
*/


{mainhead.i}
{lonlev.i}
def var vpy as char format "x(20)" label "DESC".
define shared variable v-cif   like cif.cif.
define shared variable v-vards like cif.name format "x(36)".
define shared variable v-lcnt  like loncon.lcnt.
def new shared var st as inte.

define shared variable s-prem as character.
define shared variable d-prem as character.
define shared variable s-apr as character.
define shared variable s-cat as character.
define shared variable grp-name   as character.
define shared variable cat-des    as character.
define shared variable crc-code   as character.
def shared var s-longrp like longrp.longrp.
def shared var vlcnt like loncon.lcnt.
def shared var xacc like jl.acc.
def shared var xjh like jh.jh.

def   shared var v-crc like crc.crc.
def   shared var v-rate like crc.rate[1].
def   shared var v-komcl as deci .

/*
define variable old-lcnt like loncon.lcnt.
define variable viss as decimal.
*/
define variable v-uno like uno.uno.
define variable clcif  like cif.cif no-undo.
define variable clname like cif.name no-undo.

define shared frame cif.
{sub.i
&option = "LONSUB"
&head = "loncon"
&headkey = "lon"
&framename = "lon"
&formname = "s-lonrdl"
&where = "loncon.lon = s-lon and "
&updatecon = "true"
&deletecon = "true"
&predelete = "if lon.dam[1] > 0 or lon.cam[1] > 0 then undo,retry. run del-lon."
&display = "find lon where lon.lon = s-lon.
 if index(loncon.rez-char[10],'&') = 0 then paraksts = no.
 else if substring(loncon.rez-char[10],index(loncon.rez-char[10],'&') + 1,3) = 'yes' then paraksts = yes. else paraksts = no.
 dam1-cam1 = 0. for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock : if lookup(string(trxbal.level),v-lonprnlev,"";"") gt 0 then
 dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam). end.
 s-longrp = lon.grp. v-uno = lon.prnmos. s-prem = lon.base + string(lon.prem). d-prem = lon.base + string(lon.dprem). v-deposit = loncon.deposit. /*v-guarantor = trim(loncon.rez-char[8]).*/
 find first lons where lons.lon = lon.lon no-lock no-error. if avail lons then assign prem_s = lons.prem premsdt = lons.rdt. else assign prem_s = 0 premsdt = ?.
 run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz). cl-voz = - cl-voz. run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz). cl-nevoz = - cl-nevoz.
 display v-cif v-lcnt loncon.lon s-longrp v-uno
 lon.crc crc-code /*s-cat cat-des*/  lon.gua loncon.objekts lon.rdt lon.duedt lon.duedt15 lon.duedt35
 lon.opnamt dam1-cam1 s-prem  d-prem /*lon.lcr*/ loncon.proc-no loncon.sods1 lon.penprem lon.penprem7 prem_s premsdt
 lon.idt15 lon.idt35 /*loncon.sods2*/ paraksts loncon.vad-amats loncon.rez-char[9] loncon.vad-vards
 loncon.galv-gram lon.aaa lon.aaad lon.day lon.plan
 /**loncon.kods loncon.konts loncon.talr **/ lon.basedy loncon.who with frame lon.
         /*31/01/04 nataly*/
          find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock no-error.
          if avail lonhar then do:
           v-crc = lonhar.rez-int[1].
           v-rate = lonhar.rez-dec[1].
           v-komcl = lonhar.rez-dec[2].
          end .
          display v-crc v-rate v-komcl with frame lon.

 color display input dam1-cam1 with frame lon. display v-vards with frame cif."
&preupdate = " run s-lonrdu.
  /* if st > 0 then undo, retry. */ "
&postupdate = " "
&prerun = "s-lon = loncon.lon."
&postrun = "view frame mainhead."
&end = "run put-shis('lnsch'). run put-shis('lnsci')."
}
/*------------------------------------------------------------------------------
   #3.
      1.izmai‡a - jaunin–jums:atlikums tiek r–dЁts uz ekr–na un izdalЁts
      2.izmai‡a - Ѕeit ieraksta pamatsummas un procentu maks–jumu grafika
        vёsturi
-----------------------------------------------------------------------------*/

