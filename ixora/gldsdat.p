/* gldsdat.p.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-cods.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-7-3-14
 * AUTHOR
       01/04/2011 kapar
 * BASES
	TXB
 * CHANGES
*/



def shared var v-date as date.
def shared var v-date2 as date.
def shared var v-gl as char.

def var i as integer no-undo.

def shared temp-table lnpr no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field nf       as   decimal extent 18
  index ind is primary gl code.

def shared temp-table lnprDtl no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field bnk      as   char
  field dam      as   decimal
  field cam      as   decimal.

def input parameter p-bank as char.
def output parameter p-name as char.

def var v-des as char no-undo.
def var v-dxd as decimal no-undo.
def var dt as date  no-undo.

def var v-dep as char no-undo.
def var v-code as char no-undo.
def var v-rate as decimal no-undo.

find first txb.cmp no-lock no-error.
if avail txb.cmp then p-name = txb.cmp.name.

i = integer (substr(p-bank,4,2)) + 1.

do dt = v-date to v-date2:
for each txb.gl no-lock where gl.gl>=500000 and gl.gl<600000.
for each txb.jl  no-lock where jdt = dt and txb.jl.gl = txb.gl.gl use-index jdt.

  if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
  if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

  find first txb.trxcods where txb.trxcods.trxh = jl.jh and txb.trxcods.trxln = jl.ln and trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx  no-lock no-error.
  if not avail txb.trxcods then next.
  for each txb.trxcods no-lock where trxh = jl.jh  and trxcods.trxln = jl.ln and  trxcods.trxt = 0 and codfr = 'cods' use-index trxcd_idx .

   find txb.cods where cods.code = substr(trxcods.code,1,7) no-lock no-error.
   if avail txb.cods  then v-des = cods.des. else next.

   find last txb.crchis where crchis.crc = jl.crc
       and crchis.rdt <= dt   use-index crcrdt no-lock no-error.
   if not available txb.crchis then do:
     v-rate =  1.
   end.
   else do:
     v-rate =  crchis.rate[1].
   end.

   if jl.gl >= 400000 and jl.gl < 500000 Then v-dxd = jl.cam * v-rate - jl.dam * v-rate.
   if jl.gl >= 500000 and jl.gl < 600000 Then v-dxd = jl.dam * v-rate - jl.cam * v-rate.

   find lnpr where lnpr.gl = jl.gl and lnpr.code = substr(trxcods.code,1,7) no-lock no-error.
   if not avail lnpr then do:
     create lnpr.
      assign
       lnpr.gl = jl.gl
       lnpr.code = substr(trxcods.code,1,7)
       lnpr.s1 = v-des.
   end.
   lnpr.nf[i] = lnpr.nf[i] + v-dxd.

   if substr(string(jl.gl),1,4) = v-gl Then do:
     create lnprDtl.
      assign
       lnprDtl.gl = jl.gl
       lnprDtl.code = substr(trxcods.code,1,7)
       lnprDtl.s1 = v-des
       lnprDtl.bnk = p-bank
       lnprDtl.dam = jl.dam * v-rate
       lnprDtl.cam = jl.cam * v-rate.
   end.

  end. /*txb.trxcods*/

end.
end. /*gl*/
end. /*dt*/

