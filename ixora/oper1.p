/* oper1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        operimp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-7-4-15
 * AUTHOR
        04.04.06 Tен
 * CHANGES
        09.06.06 Ten - теперь в письма для НБРК 140 счета (овердрафт) не попадают.
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
*/

def input parameter vex as logical.
def input parameter bank as char.
def input parameter bic as char.
def var v-city as char no-undo.

def shared temp-table temp no-undo
         field code as char
         field acc like bank.aaa.aaa
         field val as char
         field id as int
         field name as char
         field rnn as char
         field name1 as char
         field bank as char
         field bic as char
         field docnum as char
         field val1 as char
         field bal1 as dec
         field bal as dec.
def shared buffer btemp for temp .

def var v-cent as int no-undo.
def var v-cent1 as char no-undo.

find first txb.cmp no-lock no-error.
if avail txb.cmp then v-city = substring(entry(1,cmp.addr[1]),3).
else v-city = bank.

if vex = yes then do:
for each btemp where btemp.code = "rnn":
    for each txb.cif where txb.cif.jss eq trim(btemp.rnn) no-lock.
        for each txb.aaa where txb.aaa.cif eq txb.cif.cif no-lock.
           if substring(txb.aaa.aaa,4,3) = "140" then next.
           if txb.aaa.sta <> "C" then do:
               find first temp where temp.code = "aaa" and temp.acc eq txb.aaa.aaa no-lock no-error.
               if not avail temp then do:
               create temp.
                      temp.code = "aaa".                       	
                      temp.acc = txb.aaa.aaa.
                      temp.bal = txb.aaa.cbal.
               if index(string(temp.bal), ".") > 0 then 
                  temp.bal1 = dec(entry(2,string(temp.bal),".")).
               else
                  temp.bal1 = 0.
                  temp.name = btemp.name.
                  temp.rnn = btemp.rnn.
                  temp.bic = bic.
                  temp.bank = v-city.
               if txb.aaa.crc = 1 then do:
                  temp.val = "тенге". 
                  temp.val1 = "тыин". 
               end. 
               else
               if txb.aaa.crc = 2 then do:
                  if temp.bal = 1 then temp.val = "доллар США". 
                  else
                  if temp.bal >= 2 and temp.bal < 5 then temp.val = "долларa США". 
                  else temp.val = "долларов США". 
                  if temp.bal1 = 1 then temp.val1 = "цент".
                  else
                  if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                  else do:
                       v-cent1 = entry(1, string(temp.bal1)).
                       v-cent = length(v-cent1).
                       if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                          temp.val1 = "цента".
                       else
                       temp.val1 = "центов".
                  end.
               end.
               else
               if txb.aaa.crc = 3 then do:                                            	
                  if temp.bal = 1 then temp.val = "немецкая марка". 
                  else 
                  if temp.bal >= 2 and temp.bal < 5 then temp.val = "немецкие марки". 
                  else temp.val = "немецких марок". 
                  if temp.bal1 = 1 then temp.val1 = "цент".
                  else
                  if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                  else do:
                       v-cent1 = entry(1, string(temp.bal1)).
                       v-cent = length(v-cent1).
                       if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                       temp.val1 = "цента".
                       else
                       temp.val1 = "центов".
                  end.
               end.
               else
               if txb.aaa.crc = 4 then do:
                  if temp.bal = 1 then temp.val = "российский рубль". 
                  else
                  if temp.bal >= 2 and temp.bal < 5 then temp.val = "российских рубля". 
                  else temp.val = "российских рублей". 
                  if temp.bal1 = 1 then temp.val1 = "копейка".
                  else
                  if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "копейки".
                  else do:
                       v-cent1 = entry(1, string(temp.bal1)).
                       v-cent = length(v-cent1).
                       if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                       temp.val1 = "копейки".
                       else
                       temp.val1 = "копеек".
                  end.
               end.
               else
               if txb.aaa.crc = 5 then do:
                  if temp.bal = 1 then temp.val = "украинский гривен". 
                  else
                  if temp.bal >= 2 and temp.bal < 5 then temp.val = "украинских гривня". 
                  else temp.val = "украинских гривен". 
                  if temp.bal1 = 1 then temp.val1 = "копейка".
                  else
                  if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "копейки".
                  else do:
                       v-cent1 = entry(1, string(temp.bal1)).
                       v-cent = length(v-cent1).
                       if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                       temp.val1 = "копейки".
                       else
                       temp.val1 = "копеек".
                  end.
               end.
               else
               if txb.aaa.crc = 11 then do:
                  temp.val = "ЕВРО".
                  if temp.bal1 = 1 then temp.val1 = "цент".
                  else
                  if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                  else do:
                      v-cent1 = entry(1, string(temp.bal1)).
                      v-cent = length(v-cent1).
                      if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                      temp.val1 = "цента".
                      else
                      temp.val1 = "центов".
                  end.
               end.
               else                   
               if txb.aaa.crc = 12 then do:
                  if temp.bal = 1 then temp.val = "швейцарский франк". 
                  else
                  if temp.bal >= 2 and temp.bal < 5 then temp.val = "швейцарских франка". 
                  else temp.val = "швейцарских франков". 
                  temp.val1 = "раппен".
               end.
           end.
       end.
   end.
end.
end.
end.
else do:
for each btemp where btemp.code = "name":
    for each txb.cif where txb.cif.name matches "*" + trim(btemp.name) + "*" no-lock.
        for each txb.aaa where txb.aaa.cif eq txb.cif.cif no-lock.
        if substring(txb.aaa.aaa,4,3) = "140" then next.
        if txb.aaa.sta <> "C" then do:
           find first temp where temp.code = "aaa" and temp.acc eq txb.aaa.aaa no-lock no-error.
           if not avail temp then do:
                        btemp.rnn = cif.jss.
              create temp.
                     temp.code = "aaa".
                     temp.acc = txb.aaa.aaa.
                     temp.name = btemp.name.
                     temp.bal = txb.aaa.cbal.
                     temp.rnn = btemp.rnn.
              if index(string(temp.bal), ".") > 0 then
                 temp.bal1 = dec(entry(2,string(temp.bal),".")).
              else
                 temp.bal1 = 0.
                 
                 temp.bank = v-city.
                 temp.bic = bic.
              if txb.aaa.crc = 1 then do:
                 temp.val = "тенге". 
                 temp.val1 = "тыин". 
              end. 
              else
              if txb.aaa.crc = 2 then do:
                 if temp.bal = 1 then temp.val = "доллар США". 
                 else
                 if temp.bal >= 2 and temp.bal < 5 then temp.val = "долларa США". 
                 else temp.val = "долларов США". 
                 if temp.bal1 = 1 then temp.val1 = "цент".
                 else
                 if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                 else do:
                    v-cent1 = entry(1, string(temp.bal1)).
                    v-cent = length(v-cent1).
                    if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                    temp.val1 = "цента".
                    else
                    temp.val1 = "центов".
                 end.
              end.
              else
              if txb.aaa.crc = 3 then do:                                            	
                 if temp.bal = 1 then temp.val = "немецкая марка". 
                 else 
                 if temp.bal >= 2 and temp.bal < 5 then temp.val = "немецкие марки". 
                 else temp.val = "немецких марок". 
                 if temp.bal1 = 1 then temp.val1 = "цент".
                 else
                 if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                 else do:
                    v-cent1 = entry(1, string(temp.bal1)).
                    v-cent = length(v-cent1).
                    if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                    temp.val1 = "цента".
                    else
                    temp.val1 = "центов".
                 end.
              end.
              else
              if txb.aaa.crc = 4 then do:
                 if temp.bal = 1 then temp.val = "российский рубль". 
                 else
                 if temp.bal >= 2 and temp.bal < 5 then temp.val = "российских рубля". 
                 else temp.val = "российских рублей". 
                 if temp.bal1 = 1 then temp.val1 = "копейка".
                 else
                 if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "копейки".
                 else do:
                      v-cent1 = entry(1, string(temp.bal1)).
                      v-cent = length(v-cent1).
                      if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                      temp.val1 = "копейки".
                      else
                      temp.val1 = "копеек".
                 end.
              end.
              else
              if txb.aaa.crc = 5 then do:
                 if temp.bal = 1 then temp.val = "украинский гривен". 
                 else
                 if temp.bal >= 2 and temp.bal < 5 then temp.val = "украинских гривня". 
                 else temp.val = "украинских гривен". 
                 if temp.bal1 = 1 then temp.val1 = "копейка".
                 else
                 if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "копейки".
                 else do:
                    v-cent1 = entry(1, string(temp.bal1)).
                    v-cent = length(v-cent1).
                    if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                    temp.val1 = "копейки".
                    else
                    temp.val1 = "копеек".
                 end.
              end.
              else
              if txb.aaa.crc = 11 then do:
                 temp.val = "ЕВРО".
                 if temp.bal1 = 1 then temp.val1 = "цент".
                 else
                 if temp.bal1 > 1 and temp.bal1 < 5 then temp.val1 = "центa".
                 else do:
                    v-cent1 = entry(1, string(temp.bal1)).
                    v-cent = length(v-cent1).
                    if (substring(v-cent1,v-cent) = "2" or substring(v-cent1,v-cent) = "3" or substring(v-cent1,v-cent) = "4") then
                    temp.val1 = "цента".
                    else
                    temp.val1 = "центов".
                 end.
              end.
              else                   
              if txb.aaa.crc = 12 then do:
                 if temp.bal = 1 then temp.val = "швейцарский франк". 
                 else
                 if temp.bal >= 2 and temp.bal < 5 then temp.val = "швейцарских франка". 
                 else temp.val = "швейцарских франков". 
                 temp.val1 = "раппен".
              end.
          end.
      end.
  end.
end.
end.
end.
