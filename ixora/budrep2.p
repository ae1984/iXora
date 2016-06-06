/* budrep2.p
 * MODULE
        Отчет по кодам доходов/расходов операций
 * DESCRIPTION
        Отчет по кодам доходов/расходов операций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER

 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        14/07/2012 Luiza
 * BASES
	BANK TXB
 * CHANGES
*/



def shared var v-date as date.
def shared var v-date2 as date.
def shared var v-gl as char.
def shared var ii   as   int.
ii = ii + 1.

def shared temp-table lnpr no-undo
  field gl       as   int
  field code     as   char
  field s1       as   char
  field nf       as   decimal
  index ind is primary gl code.

def output parameter p-name as char.

def var v-des as char no-undo.
def var v-dxd as decimal no-undo.
def var dt as date  no-undo.

def var v-dep as char no-undo.
def var v-code as char no-undo.
def var v-rate as decimal no-undo.

find first txb.cmp no-lock no-error.
if avail txb.cmp then p-name = txb.cmp.name.


do dt = v-date to v-date2:
for each txb.gl no-lock where txb.gl.gl >= 500000 and txb.gl.gl < 600000.
for each txb.jl  no-lock where txb.jl.jdt = dt and txb.jl.gl = txb.gl.gl use-index jdt.

  if trim(txb.jl.rem[1]) begins 'Свертка '  then next.
  if trim(txb.jl.rem[1]) begins 'CONVERSION ' then next.

  find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.trxln = txb.jl.ln and txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx  no-lock no-error.
  if not avail txb.trxcods then next.
  for each txb.trxcods no-lock where txb.trxcods.trxh = txb.jl.jh  and txb.trxcods.trxln = txb.jl.ln and  txb.trxcods.trxt = 0 and txb.trxcods.codfr = 'cods' use-index trxcd_idx .

   find txb.cods where txb.cods.code = substr(txb.trxcods.code,1,7) no-lock no-error.
   if avail txb.cods  then v-des = txb.cods.des. else next.

   find last txb.crchis where txb.crchis.crc = txb.jl.crc
       and txb.crchis.rdt <= dt   use-index crcrdt no-lock no-error.
   if not available txb.crchis then do:
     v-rate =  1.
   end.
   else do:
     v-rate =  txb.crchis.rate[1].
   end.

   if txb.jl.gl >= 400000 and txb.jl.gl < 500000 Then v-dxd = txb.jl.cam * v-rate - txb.jl.dam * v-rate.
   if txb.jl.gl >= 500000 and txb.jl.gl < 600000 Then v-dxd = txb.jl.dam * v-rate - txb.jl.cam * v-rate.

   find lnpr where lnpr.gl = txb.jl.gl and lnpr.code = substr(txb.trxcods.code,1,7) no-lock no-error.
   if not avail lnpr then do:
     create lnpr.
      assign
       lnpr.gl = txb.jl.gl
       lnpr.code = substr(txb.trxcods.code,1,7)
       lnpr.s1 = v-des.
   end.
   lnpr.nf = lnpr.nf + v-dxd.

  end. /*txb.trxcods*/

end.
end. /*gl*/
end. /*dt*/

