/* lonna.p
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
        12/12/2008 galina - перекомпеляция
        15/12/2008 galina - перекомпиляция
        25/03/2009 galina - перекомпиляция
        23/04/2009 galina - перекомпиляция
*/

/*----------------------
  #3.KredЁta apraksts
----------------------*/
{mainhead.i LONN}
def new shared var vlcnt like loncon.lcnt.
def var vpy as char format "x(20)" label "DESC".
def new shared var s-longrp like longrp.longrp.
def new shared var xacc like jl.acc.
def new shared var xjh like jh.jh.
define new shared variable v-cif      like cif.cif init "".
define new shared variable v-vards    like cif.name init "".
define new shared variable v-lcnt     like loncon.lcnt init "".

define new shared variable grp-name   as character init "".
define new shared variable cat-des    as character init "".
define new shared variable crc-code   as character init "".
define new shared variable s-stat0    as integer init 0.
define new shared variable s-stat1    as integer init 0.
define new shared variable s-dts1     as date.
define new shared variable s-frez0    as decimal init 0.
define new shared variable s-frez1    as decimal init 0.
define new shared variable s-dtf1     as date init ?.
define new shared variable s-kuzk0    as decimal init 0.
define new shared variable s-kuzk1    as decimal init 0.
define new shared variable s-dtu1     as date init ?.
define new shared variable s-sk       as decimal init 0.
define new shared variable s-dk       as integer init 0.
define new shared variable s-pk       as integer init 0.
define new shared variable s-dtk      as date init ?.
define new shared variable s-sp       as decimal init 0.
define new shared variable s-dp       as integer init 0.
define new shared variable s-pp       as integer init 0.
define new shared variable s-dtp      as date init ?.
define new shared variable s-sec      as decimal init 0.
define new shared variable s-prc      as decimal init 0.
define new shared variable s-akc      as logical init no.
define new shared variable s-dt       as date.
define new shared variable s-atll     as decimal init 0.
define new shared variable s-atln     as decimal init 0.
define new shared variable gs-cif     like cif.cif.
define variable v-uno like uno.uno.
define stream s1.
define new shared frame cif.

s-dts1 = today.
s-dtf1 = today.
s-dt = g-today.

{mainln.i
 &option    = "LON"
 &head      = "loncon"
 &headkey   = "lon"
 &framename = "lon"
 &formname  = "lonna"
 &findcon   = "true"
 &addcon    = "false"
 &cond      = "     "
 &start     = "gs-cif = ''. if search('cif.lst') <> ? then do: input stream
  s1 from cif.lst. do on endkey undo: import stream s1 gs-cif. end. 
  input stream s1 close. end."
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " "
 &postadd = " "
 &prefind    = "view frame cif. run s-harchs. if lastkey = keycode('PF4') 
  then undo,retry.
  find loncon where loncon.lon = s-lon. display loncon.lon with frame lon. "
 &postfind   = " find lon where lon.lon = s-lon no-lock. find last ln%his
  where ln%his.lon = s-lon and ln%his.stdat < s-dt no-lock no-error. if not
  available ln%his then find first ln%his where ln%his.lon = s-lon no-lock.
  s-longrp = lon.grp."
 &numprg     = "n-lon"
 &subprg     = "s-lonna"
 &end        = "output stream s1 to cif.lst. export stream s1 gs-cif. output
  stream s1 close." }
