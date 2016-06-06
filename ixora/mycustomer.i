/* mycustomer.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Для программ формирования файла сообщения при выгрузке
        Функция подбора строки сведений о получателе/отправителе
 * RUN
        
 * CALLER
        lb100.p, lb100g.p, lb100tax.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-5-10
 * AUTHOR
        20.04.2004 nadejda - вынесено из lb100.p
 * CHANGES
        25.01.2011 marinav - изменения в связи с переходом на БИН/ИИН 
*/



FUNCTION myCustomer RETURNS character (INPUT t-on as character, 
  t-acc as character, t-com as character, t-rmz as char) .
def var t-bn as cha .
def var v-on as cha .
def var v-vks as cha . 

/*****БИН**********/
def var v-bin as logi init no.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.



v-ks = trim(t-acc) .
repeat:
 if substr(v-ks,1,1) = "/" then v-ks = trim(substr(v-ks,2)).
 else leave.
end.

if index(v-ks,"/") ne 0 then do :
 v-ks = trim(v-ks) + "/<stop>/" .
 v-tmp = "" . 
 ii = 2 . 
 v-ks1 = "" . 
 do while entry(ii,v-ks,"/") ne "<stop>" :
  v-ks1 = entry(ii,v-ks,"/").
  ii = ii + 1.
 end.
 v-tmp = "".
 if ii > 2 then 
  do i = 1 to ii - 2 :
   v-tmp  = v-tmp + entry(i,v-ks,"/") . 
  end.  
 else  
  v-tmp = entry(1,v-ks,"/") .
 v-ks = v-tmp . 
end.
else
 v-ks1 = "" . 
v-ks1 = trim(v-ks1).

  i = 1.
  t-bn = "" .
  do while entry(i,regs,"!") <> "" :
   n = index(t-on,entry(i,regs,"!")) .
   if n <> 0 then do :
    t-bn = "/RNN/" + substring(t-on, n + length(entry(i,regs,"!")), 
      index(t-on," ",
      n + length(entry(i,regs,"!"))) - n - length(entry(i,regs,"!"))) .
     substring(t-on, n , index(t-on," ",n + length(entry(i,regs,"!"))) - n)
       = "" .
    leave .
   end .
   i = i + 1 .
  end .
  
  if t-bn = "" and remtrz.sbank = ourbank then do :
   find first aaa where aaa.aaa = t-acc no-lock no-error .
   if avail aaa then do :
      find first cif where cif.cif = aaa.cif no-lock no-error .
      if avail cif then do:
          if v-bin = no then t-bn = "/RNN/" + cif.jss .
                        else t-bn = "/RNN/" + cif.bin .
      end.
   end .
   else do :    /*  our rnn  */
     if v-bin = no then do:
        find first cmp no-lock no-error.
        t-bn = "/RNN/" + cmp.addr[2].
     end.
     else do:
        find first sysc where sysc.sysc = "bnkbin" no-lock no-error.
        t-bn = "/RNN/" + trim(sysc.chval).
     end.
   end.
  end.
  t-bn = replace(t-bn," ","") .
  t-bn = replace(t-bn,".","") .
  if trim(t-bn) = "/RNN/" or length(t-bn) > 19
  then t-bn = "" .

  if trim(v-ks) ne "" then 
   v-on = ":" + t-com + (if t-com = "50" then ":/D/" else ":" )
   + replace(v-ks," ","")  + chr(10) .
  else 
   v-on = ":" + t-com + ":" .
  do while substring(t-on,1,1) = "-" or substring(t-on,1,1) = ":" 
    or substring(t-on,1,1) = " " :
    substring(t-on,1,1) = "" .
   if t-on = "" then leave .
  end.
  v-on = v-on + trim(substring(t-on,1,60)) + chr(10) .
                                                                              
  if trim(t-bn) <> "" and trim(t-bn) ne "/" then
   v-on = v-on + t-bn + chr(10) .                                  

  if t-com = "50" then do:
    find first aaa where aaa.aaa = t-acc no-lock no-error .
    if avail aaa then do :
       find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnchf" no-lock no-error .
       if avail sub-cod and sub-cod.ccode ne "msc" then 
          v-on = v-on + "/CHIEF/" + trim(sub-cod.rcode) + chr(10) .
       else 
          v-on = v-on  +  "/CHIEF/НЕ ПРЕДУСМОТРЕНО"  + chr(10) .
       find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnbk" no-lock no-error .
        if avail sub-cod and sub-cod.ccode ne "msc" then 
           v-on = v-on  +  "/MAINBK/" + trim(sub-cod.rcode) + chr(10) .
        else 
           v-on = v-on  +  "/MAINBK/НЕ ПРЕДУСМОТРЕНО"  + chr(10) .
    end. /*  aaa   */
    else do :   
      find lon where lon.lon = t-acc no-lock no-error .
      if avail lon then do :
        find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = lon.cif and sub-cod.d-cod = "clnchf" no-lock no-error .
        if avail sub-cod and sub-cod.ccode ne "msc" then
           v-on = v-on + "/CHIEF/" + trim(sub-cod.rcode) + chr(10) .
        else
           v-on = v-on  +  "/CHIEF/НЕ ПРЕДУСМОТРЕНО"  + chr(10) .
        find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = lon.cif and sub-cod.d-cod = "clnbk" no-lock no-error .
        if avail sub-cod and sub-cod.ccode ne "msc" then
           v-on = v-on  +  "/MAINBK/" + trim(sub-cod.rcode) + chr(10) .
        else
           v-on = v-on  +  "/MAINBK/НЕ ПРЕДУСМОТРЕНО"  + chr(10) .
      end. /*  lon  */
      else do :   /*  our CHIEF  MAINBK   */
         find first sub-cod where sub = "rmz" and sub-cod.acc = t-rmz and d-cod = "clnchf" no-lock no-error.
         if avail sub-cod then v-on = 
            v-on + "/CHIEF/" + sub-cod.rcode + chr(10).
         else do:
             find first sysc where sysc.sysc = "CHIEF" no-lock no-error.
             if avail sysc then 
                v-on = v-on + "/CHIEF/" + trim(sysc.chval) + chr(10).
         end.
         find first sub-cod where sub = "rmz" and sub-cod.acc = t-rmz and d-cod = "clnbk" no-lock no-error.
         if avail sub-cod then v-on = 
            v-on + "/MAINBK/" + sub-cod.rcode + chr(10).
         else do:
             find first sysc where sysc.sysc = "MAINBK" no-lock no-error.
             if avail sysc then
                 v-on = v-on  +  "/MAINBK/" + trim(sysc.chval) + chr(10) .
         end.        
      end.   
    end.
      
  end.

  RETURN v-on . 
END FUNCTION . /* myCustomer */
