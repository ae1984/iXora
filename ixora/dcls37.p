/* dcls37.p
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
        12/03/04 sasco Добавил temp-table tempjh для обработки jh.party (в конце)
	               обнуляем s-jh перед trxgen чтобы индекс не переполнился
	15.07.2003 nadejda - добавила сохранение старого признака clsa и восстановление его после проводки
*/

{mainhead.i DUALCRC}
def var oldsta as log init false.
define new shared var s-jh like jh.jh.
define new shared var s-aah as int.
define new shared var s-line as int.
define new shared var s-force as log init false.
def new shared var s-consol like jh.consol initial false.
def var vln as int.
def buffer buy  for sysc.
def buffer sell for sysc.
def buffer comm for sysc.
def buffer rem1 for sysc.
def var amt like rem.amt.
def var bmt like rem.amt.
def var cmt like rem.amt.
def var  vlog as log.
def buffer xjl for jl.
def var xgl like gl.gl.

def var v-str as char.
def var v-noconv as char.

def temp-table tempjh 
         field jh like jh.jh
         index idx_tmp is primary jh.

def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var rdes1  as cha .
def var rcode1  as int .
def var vparam as cha .
def var vsum as cha .
def var shcode as cha .
def var v-bal like jl.dam . 
def var oldclsa as char.

/* for trxgen end   */

if g-batch eq false then do:

   message " READY TO PROCESS...? " update vlog.
   if not vlog then undo,retry.
end.
find sysc where sysc.sysc eq "convgl" no-lock no-error.
if available sysc then v-str = sysc.chval. else v-str = "".
find sysc where sysc.sysc eq "noconv" no-lock no-error.
if available sysc then v-noconv = sysc.chval. else v-noconv = "".

vln = 1.

for each xjl where xjl.jdt eq g-today and  xjl.crc gt 1
              use-index jdt
   ,each gl of xjl where gl.type = "R" or gl.type = "E"
   or v-str matches "*" + string(gl.gl,"999999") + "*"
   break by gl.gl by xjl.jh by xjl.ln:
if xjl.rem[1] begins " CONVERSION FOR " then next . 
if v-noconv matches "*" + string(xjl.jh,"99999999") + "*" then next.
find gltab where gltab.crc = xjl.crc and gltab.gl = xjl.gl no-error.
if available gltab then xgl = gltab.gl1. else xgl = xjl.gl.
find crc where crc.crc = xjl.crc.
if false then do:
find jl where recid(jl) eq recid(xjl) no-lock no-error.
{jlupd-f.i}
end.
if xjl.acc = "" then do:
if  xjl.cam gt 0  then  do:
      vparam =  string(xjl.cam) + vdel + string(xjl.crc) + 
       vdel + string(xjl.gl) + vdel + xjl.sub + vdel +  
       string(xjl.lev) + vdel +  xjl.acc + vdel + 
       " CONVERSION FOR " + string(xjl.jh) + " LN# " + string(xjl.ln)
       + vdel +
       " MID-RATE " + string(crc.rate[1] / crc.rate[9] , "z,zz9.9999")
       + vdel +
       string(round(xjl.cam * crc.rate[1] / crc.rate[9] , crc.decpnt))
       + vdel +  string(xjl.lev) . 
       shcode = "dcl0003" .
end.
else 
do:                     
      vparam =  string(xjl.dam) + vdel + string(xjl.crc) +
       vdel + string(xjl.gl) + vdel + xjl.sub + vdel +
       string(xjl.lev) + vdel + xjl.acc + vdel +
       " CONVERSION FOR " + string(xjl.jh) + " LN# " + string(xjl.ln)
       + vdel +
       " MID-RATE " + string(crc.rate[1] / crc.rate[9] , "z,zz9.9999")
       + vdel + 
       string(round(xjl.dam * crc.rate[1] / crc.rate[9] , crc.decpnt))
       + vdel +  string(xjl.lev) .
      shcode = "dcl0002" .
 end.
end. 
else 
do:
 find first trxbal where trxbal.sub = xjl.sub and trxbal.acc = 
  xjl.acc and trxbal.lev = xjl.lev and trxbal.crc = xjl.crc no-error . 
   if avail trxbal and trxbal.dam ne trxbal.cam then do:
     if trxbal.cam > trxbal.dam then 
     do: 
      vparam =  string(trxbal.cam - trxbal.dam) + vdel + string(xjl.crc) +
       vdel + string(xjl.gl) + vdel + xjl.sub + vdel +
       string(xjl.lev) + vdel +  xjl.acc + vdel +
       " CONVERSION FOR " + string(xjl.jh) + " LN# " + string(xjl.ln)
       + vdel +
       " MID-RATE " + string(crc.rate[1] / crc.rate[9] , "z,zz9.9999")
       + vdel +
       string(round((trxbal.cam - trxbal.dam) * crc.rate[1] / crc.rate[9] ,
             crc.decpnt))
       + vdel +  string(xjl.lev) .
       shcode = "dcl0003" .
     end.
     else 
     do:
      vparam =  string(trxbal.dam - trxbal.cam) + vdel + string(xjl.crc) +
         vdel + string(xjl.gl) + vdel + xjl.sub + vdel +
       string(xjl.lev) + vdel +  xjl.acc + vdel +
       " CONVERSION FOR " + string(xjl.jh) + " LN# " + string(xjl.ln)
       + vdel +
       " MID-RATE " + string(crc.rate[1] / crc.rate[9] , "z,zz9.9999")
       + vdel +
       string(round((trxbal.dam - trxbal.cam ) * crc.rate[1] / crc.rate[9] , 
        crc.decpnt))
       + vdel +  string(xjl.lev) .
       shcode = "dcl0002" .
     end.
 end.
   else next . 
end.

 oldsta = no . 
 find first aaa where aaa.aaa =  xjl.acc no-error . 
 if avail aaa and aaa.sta = "C" then do:
   aaa.sta = "A" . 
   oldsta = yes . 
 end.

 /* 15.07.2003 nadejda */
 oldclsa = "".
 find sub-cod where sub-cod.sub = xjl.sub and sub-cod.acc = xjl.acc and sub-cod.d-cod = "clsa" no-error.
 if avail sub-cod and sub-cod.ccode <> "msc" then do:
   oldclsa = sub-cod.ccode.
   sub-cod.ccode = "msc".
 end.
 /* --- */

 s-jh = 0. /* чтобы не переполнились индексы когда много линий */

 run trxgen(shcode,vdel,vparam,"dcl","CONVERSION",output rcode,
                  output rdes,input-output s-jh).

 /* сохраним jh во временной таблице */
 if s-jh <> 0 and s-jh <> ? then do:
    find tempjh where tempjh.jh = s-jh no-error.
    if not avail tempjh then do:
       create tempjh.
       tempjh.jh = s-jh.
    end.
 end.

 if oldsta then aaa.sta = "C" .

 /* 15.07.2003 nadejda */
 if oldclsa <> "" then do:
   find sub-cod where sub-cod.sub = xjl.sub and sub-cod.acc = xjl.acc and sub-cod.d-cod = "clsa" no-error.
   sub-cod.ccode = oldclsa.
 end.
 /* --- */
                  
  if rcode ne 0 then
   do:
   message rdes + " " + string(xjl.jh) + " line= " + string(xjl.ln) 
    shcode . pause .
    quit .   
  end.
vln = vln + 1.
end.


for each tempjh:
   find jh where jh.jh = tempjh.jh no-error.
   if avail jh then do:
    jh.party = "CONVERT TO LOCAL CURRENCY".
    jh.crc = 0.
   end.
end.

/* message " PROCESSING WITH JH#.. " s-jh.  */
