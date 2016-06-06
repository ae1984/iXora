/* apgrsvldat.p
 * MODULE
        Финансовая отчетность
 * DESCRIPTION
        отчет по оборотам по ГК с курсовой разницей
 * RUN
        
 * CALLER
        apgrsvl.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-2-7
 * AUTHOR
        23.02.2004 nadejda
 * CHANGES
        01.04.2004 nadejda - алиас "ast" заменен на "txb" для совместимости
*/


def input parameter p-bank as char.

define var vinbal as dec format "->>,>>>,>>>,>>9.99".
define var voutbal as dec format "->>,>>>,>>>,>>9.99".
define var vin1bal as dec format "->>,>>>,>>>,>>9.99".
define var vout1bal as dec format "->>,>>>,>>>,>>9.99".
define var vdkurs as dec format "->>,>>>,>>>,>>9.99".
define var v-rate as decimal extent 30.
define var v-rateb as decimal.
define var v-ratee as decimal.

def shared var v-dtb as date.
def shared var v-dte as date.
def var v-dt as date.

def shared temp-table t-data
  field gl as integer
  field balin as decimal extent 30
  field balout as decimal extent 30
  field balinkzt as decimal extent 30
  field baloutkzt as decimal extent 30
  field dam as decimal extent 30
  field cam as decimal extent 30
  field damkzt as decimal extent 30
  field camkzt as decimal extent 30
  field deltakurs as decimal extent 30
  index gl is primary unique gl.


message p-bank " обработка...".

for each txb.crc no-lock:
  if txb.crc.crc > 1 then do:
    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt < v-dtb no-lock no-error.
    if avail txb.crchis then v-rateb = txb.crchis.rate[1] / txb.crchis.rate[9].
                        else v-rateb = 1.

    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dte no-lock no-error.
    if avail txb.crchis then v-ratee = txb.crchis.rate[1] / txb.crchis.rate[9].
                        else v-ratee = 1.
  end.

  for each txb.gl where txb.gl.totact = false no-lock:
    find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt < v-dtb no-lock no-error.
    if available txb.glday then vinbal = txb.glday.bal.
                           else vinbal = 0.
    find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= v-dte no-lock no-error.
    if available txb.glday then voutbal = txb.glday.bal.
                           else voutbal = 0.
    if vinbal + voutbal <> 0 then do:
      find t-data where t-data.gl = txb.gl.gl no-error.
      if not avail t-data then do:
        create t-data.
        t-data.gl = txb.gl.gl.
      end.
      t-data.balin[txb.crc.crc] = t-data.balin[txb.crc.crc] + vinbal.
      t-data.balout[txb.crc.crc] = t-data.balout[txb.crc.crc] + voutbal.

      if txb.crc.crc > 1 then do:
          t-data.balinkzt[txb.crc.crc] = t-data.balinkzt[txb.crc.crc] + vinbal * v-rateb.
          t-data.baloutkzt[txb.crc.crc] = t-data.baloutkzt[txb.crc.crc] + voutbal * v-ratee.
      end.

    end.
  end.
end.

do v-dt = v-dtb to v-dte:
  hide message no-pause.
  message p-bank v-dt.

  for each txb.crc no-lock:
    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= v-dt no-lock no-error.
    if avail txb.crchis then v-rate[txb.crc.crc] = txb.crchis.rate[1] / txb.crchis.rate[9].
                        else v-rate[txb.crc.crc] = 1.
  end.

  for each txb.jl where txb.jl.jdt = v-dt no-lock break by txb.jl.gl:
    if first-of(txb.jl.gl) then do:
      find t-data where t-data.gl = txb.jl.gl no-error.
      if not avail t-data then do:
        create t-data.
        t-data.gl = txb.jl.gl.
      end.
    end.

    if txb.jl.dc = "d" then t-data.dam[txb.jl.crc] = t-data.dam[txb.jl.crc] + txb.jl.dam.
                       else t-data.cam[txb.jl.crc] = t-data.cam[txb.jl.crc] + txb.jl.cam.

    if txb.jl.crc > 1 then do :
      if txb.jl.dc = "d" then t-data.damkzt[txb.jl.crc] = t-data.damkzt[txb.jl.crc] + txb.jl.dam * v-rate[txb.jl.crc].
                         else t-data.camkzt[txb.jl.crc] = t-data.camkzt[txb.jl.crc] + txb.jl.cam * v-rate[txb.jl.crc].
    end.
    
  end.  
end.

hide message no-pause.
