/* trxstor.p
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Удаление проводок
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
        22.07.2002 sasco - возврат сумм по АРП счетам из arpcon 
        26/09/2002 sasco - удаление проводок по дебиторам 
        21/09/2003 sasco - удаление записей из mobtemp (KCell, KMobile, Пласт. карточки)

       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       22.01.2005 nataly вставила проверку на удаление транзакций Деп-та Пл Карт
       12.04.2010 k.gitalov закоментил проверку на g-today
       29/10/2010 k.gitalov перекомпиляция
*/

def input parameter vjh as inte.
def input parameter vsts as inte.
def output parameter vjhs as inte.
def output parameter rcode as inte.
def output parameter rdes as char.
def new shared temp-table tmpl like trxtmpl.
def new shared temp-table cdf like trxcdf.
def buffer bjh for jh.
def buffer bjl for jl.
def buffer btrxcods for trxcods.

def var errlist as char extent 36.
errlist[23] = "Can't stamp cash transaction.".
errlist[33] = "Current day transaction. No STORNO necessary.".
errlist[34] = "Can't find transaction for STORNO generation.".
errlist[35] = "Transaction STORNED already with Trx.Nr:".
errlist[36] = "Для удаления проводки необходим контроль Деп-та Пл Карт! ".

def var vcrc as inte.
def var vdam as deci.
def var vcam as deci.
def buffer fcrc for crc.
def buffer tcrc for crc.
def new shared var s-jh like jh.jh.
def new shared var s-aaa like aaa.aaa.
def new shared var s-aah as int.
def new shared var s-line as inte.
def new shared var s-force as log.
def new shared var hsts as inte initial 6.
def shared var g-lang as char.
def shared var g-today as date.
def shared var g-ofc as char.
def var vln as inte.

def var v-arp as char. /*nataly 20/01/05 для проверки  счетов Деп-та Пласт Карт*/ 

find sysc where sysc.sysc = "cashgl" no-lock.

find first jl where jl.jh = vjh no-lock no-error.
if not available jl then do:
   rcode = 34.
   rdes = errlist[rcode] + ":Trx.Nr=" + string(vjh) + ".".
   return.
end.
 else if jl.jdt = g-today then do:
   /*
   rcode = 33.
   rdes = errlist[rcode] + ":Trx.Nr=" + string(vjh) + ".".
   return.
   */
end.
find jh where jh.jh = vjh no-lock.
if jh.party begins "Storned(" then do:
   find first jl where jl.jh = integer(entry(1,entry(2,jh.party,"("),")")) 
    no-lock no-error . 
   if avail jl then do: 
    rcode = 35.
    rdes = errlist[rcode] + substring(jh.party,index(jh.party,"Stor") + 8,8).
    return.
   end.
end.
if vsts = 6 then do:
   find first jl where jl.jh = vjh and jl.gl = sysc.inval no-lock no-error.
   if available jl then do:
    rcode = 23.
    rdes = errlist[rcode] + ":Trx.Nr=" + string(vjh) + ".".
    return.
   end.
end.


/*nataly - cards control*/
   /* берем счета из справочника*/
for each jl where jl.jh = vjh no-lock:
   if jl.dc <> 'C' then next. 
   find sysc where sysc.sysc = "cardac" no-lock no-error.
   if avail sysc then v-arp = sysc.chval.

   if lookup(trim(jl.acc), trim(v-arp)) <> 0  then do: /*если проводка идет по счету Деп-та Пласт Карт*/

    find cursts where cursts.sub = 'trx' and cursts.acc = string(jl.jh) no-lock no-error.
    if not  avail cursts  or cursts.sts <> 'con' then do: 
    message 'Для удаления транзакции необходим контроль Деп-та Пл. Карт'  view-as alert-box. 
     rcode = 36.
     rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
    return.
   end.
  end.
end.

       vln = 0.
for each jl where jl.jh = vjh no-lock:
       create tmpl.
       vln = vln + 1.
       tmpl.ln = vln.
    if jl.dc = "c" then do:
       tmpl.amt = jl.cam.
       tmpl.amt-f = "d".
       tmpl.crc = jl.crc.
       tmpl.crc-f = "d". 
       tmpl.drgl = jl.gl.
       tmpl.drgl-f = "d".
       tmpl.drsub = jl.subled.
       tmpl.drsub-f = "d".
       tmpl.dev = jl.lev.
       tmpl.dev-f = "d".
       tmpl.dracc = jl.acc.
       tmpl.dracc-f = "d".
    end.
    else do: 
       tmpl.amt = jl.dam.
       tmpl.amt-f = "d".
       tmpl.crc = jl.crc.
       tmpl.crc-f = "d". 
       tmpl.crgl = jl.gl.
       tmpl.crgl-f = "d".
       tmpl.crsub = jl.subled.
       tmpl.crsub-f = "d".
       tmpl.cev = jl.lev.
       tmpl.cev-f = "d".
       tmpl.cracc = jl.acc.
       tmpl.cracc-f = "d".
    end.
end.


  run trxchk1(output rcode, output rdes).
  if rcode > 0 then return.

/* sasco - debetors */
{trx-debdel.i}

/* sasco - mobile & pl.cards */
{trx-mobdel.i}

do transaction:
  run trxbal(output rcode, output rdes).
  if rcode > 0 then return.
  find bjh where bjh.jh = vjh exclusive-lock.
   run x-jhnew.
   find jh where jh.jh eq s-jh exclusive-lock.
   jh.crc = bjh.crc.
   jh.party = "Storno(" + string(vjh) + ")/" + bjh.party.
   bjh.party = "Storned(" + string(jh.jh) + ")/" + bjh.party.
  /* jh.point = bjh.point.
   jh.depart = bjh.depart.
 */  jh.sts = vsts.
   vln = 0.

   find sysc where sysc.sysc = "ourbnk" no-lock no-error.

  for each bjl where bjl.jh = vjh no-lock:

       /* by sasco -> change arpcon table record for controlled ARP`s from jl.DRacc */
      if bjl.dc = "D" then
      for each arpcon where arpcon.arp = bjl.acc and
                            arpcon.txb = sysc.chval:
          /* если нет в списке пользователей и надо было контролировать... */
          if LOOKUP (bjl.who, arpcon.uids) = 0 and arpcon.checktrx then
                    arpcon.curr = arpcon.curr - bjl.dam.
      end.

   create jl.
   vln = vln + 1.
    jl.jh = jh.jh. 
    jl.ln = vln.
    jl.crc = bjl.crc.
    jl.cam = bjl.dam.
    jl.dam = bjl.cam.
    jl.gl = bjl.gl.
    jl.acc = bjl.acc.
    if bjl.dc = "D" then jl.dc = "C".
    else jl.dc = "D".
    jl.who = jh.who.
 /*   jl.point = jh.point.
    jl.depart = jh.depart.
 */   jl.subled = bjl.subled.
    jl.lev = bjl.lev.
/*    jl.trx = bjl.trx.*/
    jl.rem[1] = "Storno(" + string(vjh) + ")/"  + bjl.rem[1].
    if bjl.rem[2] <> "" then jl.rem[2] = "Storno(" + string(vjh) + ")/"  + bjl.rem[2].
    if bjl.rem[3] <> "" then jl.rem[3] = "Storno(" + string(vjh) + ")/"  + bjl.rem[3].
    if bjl.rem[4] <> "" then jl.rem[4] = "Storno(" + string(vjh) + ")/"  + bjl.rem[4].
    if bjl.rem[5] <> "" then jl.rem[5] = "Storno(" + string(vjh) + ")/"  + bjl.rem[5].
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.sts = jh.sts.  
  end.  

  for each jl where jl.jh = s-jh and jl.acc <> "" exclusive-lock:
      {trxupd-r.i}
  end. /*for each jl*/

/* added on 15.05.2001 for codificators processing */  
    for each btrxcods where btrxcods.trxh = vjh:
       create trxcods.
              trxcods.trxh = jh.jh.
              trxcods.trxln = btrxcods.trxln.
              trxcods.codfr = btrxcods.codfr.
              trxcods.code = btrxcods.code. 
    end.  
/**/

  release trxcods.
  release jl.
end. /*Transaction*/
vjhs = jh.jh.

{trxupd-i.i}
