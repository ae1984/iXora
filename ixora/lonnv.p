/* lonnv.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Просмотр выданных кредитов
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
        19.11.2003 marinav
 * CHANGES
        06/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        01/30/2006 Natalya D. - добавлено поле Депозит
        11/12/2008 galina - не передаем параметр &numprg
        15/12/2008 galina - перекомпиляция
        18/12/2008 galina - передаем параметр &numprg (не компилится без передачи этого параметра)
        25/03/2009 galina - перекомпиляция
        23/04/2009 galina - перекомпиляция
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме, перекомпиляция
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        28/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
*/


{mainhead.i LONN}
{lonlev.i}
def new shared var vlcnt like loncon.lcnt.
def var vpy as char format "x(20)" label "DESC".
def new shared var s-longrp like longrp.longrp.
def new shared var xacc like jl.acc.
def new shared var xjh like jh.jh.
define new shared variable v-cif      like cif.cif init "".
define new shared variable v-vards    like cif.name format "x(36)" init "".
define new shared variable v-lcnt     like loncon.lcnt init "".
define new shared variable s-prem     as character.
define new shared variable d-prem     as character.
define new shared variable s-cat      as character.
define new shared variable s-apr      as character.
define new shared variable grp-name   as character init "".
define new shared variable cat-des    as character init "".
define new shared variable crc-code   as character init "".
define new shared variable gs-cif like cif.cif.

def new shared var v-crc like crc.crc.
def new shared var v-rate like crc.rate[1].
def new shared var v-komcl as deci.

/**define variable old-lcnt as character.
define variable viss as decimal.**/
define variable v-uno like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.
define stream s1.
define new shared frame cif.

{mainln.i
 &option    = "LON"
 &head      = "loncon"
 &headkey   = "lon"
 &framename = "lon" /** lon **/
 &formname  = "s-lonrdl"
 &findcon   = "true"
 &addcon    = "false"
 &cond      = "     "
 &start     = "gs-cif = ''. if search('cif.lst') <> ? then do: input stream
  s1   from cif.lst. repeat on endkey undo,leave: import stream s1 gs-cif.
  leave.   end. input stream s1 close. pause 0. end."
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " "
 &postadd = " "
 &prefind    = " run s-lonchs. pause 0. if lastkey = keycode('PF4') then
  undo,retry.
  do transaction:
  find loncon where loncon.lon = s-lon exclusive-lock.
  end.
  display loncon.lon with frame lon. "
 &postfind   = " find lon where lon.lon = s-lon no-lock.
 dam1-cam1 = 0.
 for each trxbal where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
  if lookup(string(trxbal.level),v-lonprnlev,"";"") gt 0
  then dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam).
 end.
 s-longrp = lon.grp. v-uno = lon.prnmos. v-deposit = loncon.deposit. "
 &numprg     = "n-lon"
 &subprg     = "s-lonnv"
 &end        = "output stream s1 to cif.lst. export stream s1 gs-cif. output stream s1 close. pause 0."
}
