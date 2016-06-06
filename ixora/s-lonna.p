/* s-lonna.p
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
        31/05/2006 madiyar - перекомпиляция в связи с изменениями в lonna.f
        12/12/2008 galina - перекомпиляция
        25/03/2009 galina - добавила поле Поручител
        23.04.2009 galina - убираем поле поручитель
*/

/*---------------------
  #3.KredЁtu apraksts
---------------------*/

{mainhead.i}
def var vpy as char format "x(20)" label "DESC".
define shared variable v-cif   like cif.cif.
define shared variable v-vards like cif.name.
define shared variable v-lcnt  like loncon.lcnt.
def new shared var st as inte.

define shared variable grp-name   as character.
define shared variable cat-des    as character.
define shared variable crc-code   as character.
define shared variable s-stat0 as integer.
define shared variable s-stat1 as integer.
define shared variable s-dts1  as date.
define shared variable s-frez0 as decimal.
define shared variable s-frez1 as decimal.
define shared variable s-dtf1  as date.
define shared variable s-kuzk0 as decimal.
define shared variable s-kuzk1 as decimal.
define shared variable s-dtu1  as date.
define  shared variable s-sk   as decimal.
define  shared variable s-dk   as integer.
define  shared variable s-pk   as integer.
define  shared variable s-dtk  as date.
define  shared variable s-sp   as decimal.
define  shared variable s-dp   as integer.
define  shared variable s-pp   as integer.
define  shared variable s-dtp  as date.
define  shared variable s-sec  as decimal.
define  shared variable s-prc  as decimal.
define  shared variable s-akc  as logical.
define  shared variable s-atll as decimal.
define  shared variable s-atln as decimal.
def shared var s-longrp like longrp.longrp.
def shared var vlcnt like loncon.lcnt.
def shared var xacc like jl.acc.
def shared var xjh like jh.jh.
define shared variable s-dt as date.
define variable v-uno like uno.uno.
define shared frame cif.

{sub.i
&option = "LONSUB2"
&head = "loncon"
&headkey = "lon"
&framename = "lon"
&formname = "lonna"
&where = "loncon.lon = s-lon and "
&updatecon = "false"
&deletecon = "false"
&predelete = " "
&display = " find loncon where loncon.lon = s-lon no-lock.
  find lon where lon.lon = s-lon no-lock.
  find cif where cif.cif = lon.cif no-lock. v-uno = lon.prnmos.
  find last ln%his where ln%his.lon = s-lon and ln%his.stdat < s-dt no-lock
  no-error. if not available ln%his then find first ln%his where ln%his.lon =
  s-lon no-lock. s-longrp = lon.grp. /*v-guarantor = trim(loncon.rez-char[8]).*/ display v-cif v-lcnt loncon.lon
  s-longrp v-uno lon.crc crc-code loncon.objekts ln%his.rdt ln%his.duedt
  ln%his.opnamt ln%his.intrate /*v-guarantor*/ with frame lon. display v-vards with frame cif."
&preupdate = " "
&postupdate = " "
&prerun = "s-lon = loncon.lon."
&postrun = "view frame mainhead."
}
