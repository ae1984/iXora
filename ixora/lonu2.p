/* lonu2.p
 * MODULE
         Утверждение кредита
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
        19.07.2004 tsoy копия lonu.p сделана для депртамента автроизации
 * CHANGES
        10/02/06 marinav переломпиляция
        11/12/2008 galina - убрала возможность редактированиЯ
        15/12/2008 galina - перекомпилЯциЯ
        25/03/2009 galina - перекомпилЯциЯ
        23/04/2009 galina - перекомпилЯциЯ
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме, перекомпиляция
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        28/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
*/


{mainhead.i CLOM9}
{lonlev.i}
def new shared var vlcnt like loncon.lcnt.
def var vpy as char format "x(20)" label "DESC".
def new shared var s-longrp like longrp.longrp.
def new shared var xacc like jl.acc.
def new shared var xjh like jh.jh.
define new shared variable v-cif      like cif.cif init "".
define new shared variable v-vards    like cif.name format "x(36)" init "".
define new shared variable v-lcnt     like loncon.lcnt init "".

define new shared variable s-prem as character.
define new shared variable d-prem as character.
define new shared variable s-cat as character.
define new shared variable s-apr as character.
define new shared variable grp-name   as character init "".
define new shared variable cat-des    as character init "".
define new shared variable crc-code   as character init "".
define new shared variable gs-cif like cif.cif.

def new shared var v-crc like crc.crc.
def new shared var v-rate like crc.rate[1].
def new shared var v-komcl as deci .
/*
define variable old-lcnt   like loncon.lcnt.
define variable viss as decimal.
*/
define variable v-uno like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.
define variable vad-amats1 as character.
define variable vad-vards1 as character.
define variable galv-gram1 as character.
define variable kods1      as character.
define variable konts1     as character.
define variable talr1      as character.
define variable nr1        as character.
define variable izd1       as character.
define variable pier1      as character.
define variable pers1      as character.
define variable drv1       as character.
define variable galv1      as character.
define variable whoreg     as character.



define stream s1.
define new shared frame cif.
{mainln.i
 &option    = "LON"
 &head      = "loncon"
 &headkey   = "lon"
 &framename = "lon"
 &formname  = "s-lonrdl"
 &findcon   = "true"
 &addcon    = "false"
 &cond      = " "
 &start     = "gs-cif = ''. if search('./cif.lst') <> ? then do: input stream
  s1 from value('./cif.lst'). repeat on endkey undo,leave: import stream s1
  gs-cif. leave. end. input stream s1 close. end."
 &clearframe = " "
 &viewframe  = " "
 &preadd     = " /*v-cif = gs-cif. do on error undo,retry: display v-cif s-longrp
  with frame lon.
  update v-cif s-longrp with frame lon. find cif where cif.cif = v-cif no-lock.
  v-vards = 'ѓ' + trim(trim(cif.prefix) + ' ' + trim(cif.name)). find longrp where longrp.longrp = s-longrp no-lock.
  grp-name = longrp.des. end. v-lcnt = ''. find last loncon use-index lon where
  loncon.cif = v-cif no-lock no-error. if available loncon then do: vad-amats1 =
  loncon.vad-amats. vad-vards1 = loncon.vad-vards. galv-gram1 = loncon.galv-gram
  . kods1 = loncon.kods. konts1 = loncon.konts. talr1 = loncon.talr. nr1 =
  loncon.pase-nr. izd1 = loncon.pase-izd. pier1 = loncon.pase-pier. pers1 =
  loncon.rez-char[1]. drv1 = loncon.rez-char[2]. whoreg  = loncon.who. end. else do: vad-amats1 = ''.
  vad-vards1 = ''. galv-gram1 = ''. kods1 = ''. konts1 = ''. talr1 = ''.
  nr1 = ''. izd1 = ''. pier1 = ''. pers1 = ''. drv1 = ''. whoreg = ''. end. cat-des = ''.*/ "

 &postadd = "/*if s-lon eq '' then do: {msg.i 101}. undo,return. end.
 find lon where lon.lon eq s-lon exclusive-lock. lon.grp = s-longrp.
 lon.cif = v-cif.
 lon.gl = longrp.gl. lon.rdt = g-today. lon.base = 'F'. lon.prnmos = 2. find
 sysc where sysc.sysc = 'basedy' no-lock. lon.basedy = sysc.inval. lon.who =
 userid('bank'). lon.whn = g-today. loncon.cif = v-cif. loncon.vad-amats =
 vad-amats1. loncon.vad-vards = vad-vards1. loncon.galv-gram = galv-gram1.
 loncon.kods = kods1. loncon.konts = konts1. loncon.talr = talr1. loncon.pase-nr
 = nr1. loncon.pase-izd = izd1. loncon.pase-pier = pier1. loncon.rez-char[1] =
 pers1. loncon.rez-char[2] = drv1. loncon.who = userid('bank'). loncon.whn =
 g-today. find first lonstat no-lock. create lonhar. lonhar.lon = s-lon.
 lonhar.ln = 1. lonhar.lonstat = lonstat.lonstat. lonhar.fdt = date(1,1,1901).
 lonhar.cif = v-cif. lonhar.akc = no. lonhar.who = userid('bank'). lonhar.whn =
 g-today. find first lonhar where lonhar.lon = v-cif no-lock no-error. if not
 available lonhar then do: create lonhar. lonhar.lon = v-cif. lonhar.ln = 2.
 lonhar.fdt = date(1,1,1901). lonhar.cif = v-cif. lonhar.akc = no. lonhar.finrez
 = 999999999999.99. lonhar.who = userid('bank'). lonhar.whn = g-today. end.*/ "

 &prefind = " run s-lonchs. pause 0.
 if lastkey = keycode('PF4') then undo,retry.
  do transaction: find loncon where loncon.lon = s-lon  exclusive-lock. end.
  display loncon.lon with frame lon."
 &postfind   = " find lon where lon.lon = s-lon no-lock. s-longrp = lon.grp.
  /* dam1-cam1 = lon.dam[1] - lon.cam[1].*/
dam1-cam1 = 0. for each trxbal
where trxbal.subled eq 'LON' and trxbal.acc eq lon.lon no-lock :
if lookup(string(trxbal.level),v-lonprnlev,"";"") gt 0 then
dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam). end.
 "
 /*&numprg     = "n-lon"*/
 &numprg     = ""
 &subprg     = "s-lonu2"
 &end        = "output stream s1 to cif.lst. export stream s1 gs-cif. output
  stream s1 close."
}

/*------------------------------------------------------------------------------
   #3.
      1.izmai‡a - jaunin–jums:atlikums tiek r–dЁts uz ekr–na un izdalЁts
      2.izmai‡a - autom–tiski formёjas ieraksts fail– lonhar ar finansu rezu-
                  lt–tu
-----------------------------------------------------------------------------*/

