/* chkdolg.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Проверяет сумму просрочки на кредите, связанном с указанным текущим счетом
 * RUN
        
 * CALLER
        jou_main.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        2-1
 * AUTHOR
        22.12.2003 nadejda
 * CHANGES

*/

{global.i}
{pk0.i}
{comm-txb.i}

def input parameter p-aaa as char.
def output parameter p-sum as decimal.

p-sum = 0.
      
find aaa where aaa.aaa = p-aaa no-lock no-error.
if not avail aaa then return.

def var v-lon as char.
def var v-ourbank as char.

v-ourbank = comm-txb().

v-lon = "".
for each pkanketa where pkanketa.bank = v-ourbank and pkanketa.cif = aaa.cif no-lock:
  if (pkanketa.crc = 1 and pkanketa.aaa = p-aaa) or (pkanketa.crc <> 1 and pkanketa.aaaval = p-aaa) then do:
    v-lon = pkanketa.lon.
    leave.
  end.
end.

/* если нашли счет по анкете - проверить просрочку */
if v-lon <> "" then do:
  for each trxbal where trxbal.subled = "LON" and trxbal.acc = v-lon
                     and trxbal.level = 9 no-lock:
     p-sum = p-sum + trxbal.dam - trxbal.cam.
  end.
  for each trxbal where trxbal.subled = "LON" and trxbal.acc = v-lon
                     and trxbal.level = 7 no-lock:
    p-sum = p-sum + trxbal.dam - trxbal.cam.
  end.
end.

