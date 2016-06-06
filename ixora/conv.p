/* conv.p
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
*/

/* last change: 21/02/2002, by sasco : ®Ў¬Ґ­ Ї® «Лё®Б­®¬Ц ЄЦЮАЦ */
def input parameter crc1 as inte.
def input parameter crc2 as inte.
def input parameter cas1 as logi.
def input parameter cas2 as logi.
def input-output parameter amt1 as deci.
def input-output parameter amt2 as deci.
def output parameter vrat1 as deci decimals 10.
def output parameter vrat2 as deci decimals 10.
def output parameter coef1 as inte.
def output parameter coef2 as inte.
def output parameter vbuy as deci.
def output parameter vsel as deci.

def buffer fcrc for crc.
def buffer tcrc for crc.
def buffer feur for eurocrc.
def buffer teur for eurocrc.

/* sasco - ЇҐЮҐ¬Ґ­­ О ¤«О «Лё®Б­®ё® ЄЦЄЮА  */
def shared var vrat as decimal.

def var estr as char 
initial "DEM,ATS,BEF,EUR,ESP,FIM,FRF,ITL,NLG,IEP".

find sysc where sysc.sysc = "EURO" no-lock no-error.
if available sysc then estr = sysc.chval.

def var e1 as logi.
def var e2 as logi.

find fcrc where fcrc.crc = crc1 no-lock.
find tcrc where tcrc.crc = crc2 no-lock.

if estr matches "*" + fcrc.code + "*" then e1 = true.
if estr matches "*" + tcrc.code + "*" then e2 = true.
  
if amt1 >  0 and amt2 = 0 then do:
 if crc1 = crc2 then do:
    amt2 = amt1.
    vbuy = 0.
    vsel = 0.
 end.
 else do:
   if e1 = true and e2 = true then do:
      find feur where feur.crc = crc1 no-lock.
      find teur where teur.crc = crc2 no-lock.
      amt2 = round(amt1 * feur.rate * tcrc.rate[9] 
                        / teur.rate / fcrc.rate[9],tcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - feur.rate) / fcrc.rate[9], 2).
      vsel = round(amt2 * (teur.rate - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = feur.rate.
      vrat2 = teur.rate.
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
   end.
   else do:
    /* ЋЃЊ…ЌЌЂџ ЋЏ…ђЂ–€џ */
    if cas1 = true and cas2 = true then do:
      if vrat > 0 then
      do:
      /* ¤«О «Лё®Б­®ё® ЄЦЮА  */
      amt2 = round(amt1 * vrat * tcrc.rate[9] 
                        / tcrc.rate[3], tcrc.decpnt).
      vbuy = 0.
      vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = vrat.
      vrat2 = tcrc.rate[3].
      coef1 = 1.
      coef2 = tcrc.rate[9].
      end.
      else
      do:
      /* ¤«О ®ЎКГ­®ё® ЄЦЮА  */
      amt2 = round(amt1 * fcrc.rate[2] * tcrc.rate[9]
                        / tcrc.rate[3] / fcrc.rate[9], tcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[2].
      vrat2 = tcrc.rate[3].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
      end.
    end.
    else if cas1 = true and cas2 = false then do:
      amt2 = round(amt1 * fcrc.rate[2] * tcrc.rate[9] 
                        / tcrc.rate[5] / fcrc.rate[9],tcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[5] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[2].
      vrat2 = tcrc.rate[5].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
    else if cas1 = false and cas2 = true then do:
      amt2 = round(amt1 * fcrc.rate[4] * tcrc.rate[9] 
                        / tcrc.rate[3] / fcrc.rate[9],tcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[4]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[4].
      vrat2 = tcrc.rate[3].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
    else do:
      amt2 = round(amt1 * fcrc.rate[4] * tcrc.rate[9] 
                        / tcrc.rate[5] / fcrc.rate[9],tcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[4]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[5] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[4].
      vrat2 = tcrc.rate[5].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
   end.
 end. /*crc1 = crc2*/
end.
else if amt1 =  0 and amt2 > 0 then do:
 if crc1 = crc2 then do:
    amt1 = amt2.
    vbuy = 0.
    vsel = 0.
 end.
 else do:
   if e1 = true and e2 = true then do:
      find feur where feur.crc = crc1 no-lock.
      find teur where teur.crc = crc2 no-lock.
      amt1 = round(amt2 * teur.rate * fcrc.rate[9] 
                        / feur.rate / tcrc.rate[9],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - feur.rate) / fcrc.rate[9], 2).
      vsel = round(amt2 * (teur.rate - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = feur.rate.
      vrat2 = teur.rate.
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
   end.
   else do:
    if cas1 = true and cas2 = true then do:
      if vrat > 0 then
      do:
      /* ¤«О «Лё®Б­®ё® ЄЦЮА  */
      amt1 = round(amt2 * vrat * fcrc.rate[9]
                        / fcrc.rate[2],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
      vsel = 0.
      vrat1 = fcrc.rate[2].
      vrat2 = vrat.
      coef1 = fcrc.rate[9].
      coef2 = 1.
      end.
      else
      do:
      /* ®ЎКГ­К© ЄЦЮА */
      amt1 = round(amt2 * tcrc.rate[3] * fcrc.rate[9] 
                        / fcrc.rate[2] / tcrc.rate[9],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[2].
      vrat2 = tcrc.rate[3].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
      end.
    end.
    else if cas1 = true and cas2 = false then do:
      amt1 = round(amt2 * tcrc.rate[5] * fcrc.rate[9] 
                        / fcrc.rate[2] / tcrc.rate[9],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[2]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[5] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[2].
      vrat2 = tcrc.rate[5].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
    else if cas1 = false and cas2 = true then do:
      amt1 = round(amt2 * tcrc.rate[3] * fcrc.rate[9] 
                        / fcrc.rate[4] / tcrc.rate[9],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[4]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[3] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[4].
      vrat2 = tcrc.rate[3].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
    else do:
      amt1 = round(amt2 * tcrc.rate[5] * fcrc.rate[9] 
                        / fcrc.rate[4] / tcrc.rate[9],fcrc.decpnt).
      vbuy = round(amt1 * (fcrc.rate[1] - fcrc.rate[4]) / fcrc.rate[9], 2).
      vsel = round(amt2 * (tcrc.rate[5] - tcrc.rate[1]) / tcrc.rate[9], 2).
      vrat1 = fcrc.rate[4].
      vrat2 = tcrc.rate[5].
      coef1 = fcrc.rate[9].
      coef2 = tcrc.rate[9].
    end.
   end.
 end. /*crc1 = crc2*/
end.
 
