/* jl-prcd1.f
 * MODULE
        Формирование ордеров при разгрузки терминалов   
 * DESCRIPTION
        Формирование ордеров при разгрузки терминалов   
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        jl-prcd1.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-1-13
 * AUTHOR
        19/05/06 ten
 * CHANGES
*/

def shared var v-point like point.point.

def var vi as inte.
def var ss as inte.

/*----------------------06.06.01-----------------------------------*/
def var        decAmount like xin.
def var        strAmount as char format "x(80)".
def var        temp as char.
def var        strTemp as char. 
def var        str1 as char format "x(80)".
def var        str2 as char format "x(80)".
/*-------------------------------------------------------------*/


/*----------------------27.08.01-----------------------------------*/
def var        decAmountT like xin.
def buffer drate for crc.
/*-----------------------------------------------------------------*/

define variable obmenGL2 as integer.
define variable v-opkkas as char.
def var v-iscash as logical.

find sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then obmenGL2 = sysc.inval. else obmenGL2 = 100200.

find point where point.point = v-point no-lock no-error.
find sysc where sysc.sysc = "CASHGL" no-lock no-error.
find ofc where ofc.ofc = jh.who no-lock no-error.


sxin = 0.
sxout = 0.

find first ljl of jh where ljl.gl = sysc.inval no-lock no-error.
v-iscash = avail ljl.

for each ljl of jh use-index jhln where (ljl.gl = sysc.inval) 
                                        or (ljl.gl = obmenGL2 and not v-iscash     /* если есть Касса в пути - то печатать по ней ордер, только если нет Кассы */
                                            and ((ljl.trx begins "opk") 
                                              or (substring(ljl.rem[1],1,5) = "Обмен")
                                              or (can-find (sub-cod where sub-cod.sub = "arp" 
                                                                      and sub-cod.acc = ljl.acc 
                                                                      and sub-cod.d-cod = "arptype" 
                                                                      and sub-cod.ccode = "obmen1002" no-lock)))) 
    no-lock
    break by ljl.crc by ljl.dc:

    if first-of(ljl.dc) then do:
       if ljl.dc eq "D" then do:
          put skip(3) space(20) "ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
       end.
       else if ljl.dc eq "C" then do:
          put skip(3) space(20) "РАСХОДНЫЙ КАССОВЫЙ ОРДЕР" skip(2).
       end.
       put unformatted string (jh.jh) + "/" + v_doc + "/" + vv-cif + "/" + 
          "Dok.Nr." + trim(refn) + "   /" + ofc.name + 
          "                " + string(dtreg, "99/99/9999") skip.
 
       put
"============================================================================="
                                                         skip(1).
       put 
    "ВАЛЮТА                                      ПРИХОД                РАСХОД"
                                         skip.
       put unformatted fill ("-", 77) skip.    
    end.
    
    find crc of ljl.
    if ljl.dam gt 0 then do: 
        xin = ljl.dam. 
        xout = 0. 
        intot = intot + xin. 
    end.
    else do:
        xin = 0. 
        xout = ljl.cam.  
        outtot = outtot + xout. 
    end.  
    
    put crc.des xin xout skip.    
         
    sxin = sxin + xin.
    sxout = sxout + xout.     
        
    if last-of(ljl.dc) then do:    
       if ljl.dc eq "D" then put unformatted skip(1)
          space(22) "ИТОГО ПРИХОД" sxin format "z,zzz,zzz,zz9.99" skip(2).
       else if ljl.dc eq "C" then put unformatted skip(1)
          space(43) "ИТОГО РАСХОД" sxout format "z,zzz,zzz,zz9.99" skip(2).

/*-------------------------------06.06.01---------------------------------------*/
 if sxin = 0 then decAmount = sxout. else decAmount = sxin. 
 put 'Сумма прописью: '.  /*skip(2).*/ 
 temp = string (decAmount).
/* temp = substring(temp,1,length(temp),"character"). */
 if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    temp = substring(temp, length(temp) - 1, 2).
    if num-entries(temp,".") = 2 then
    temp = substring(temp,2,1) + "0".
 end.
 else temp = "00".
 
 strTemp = string(truncate(decAmount,0)).

 run Sm-vrd(input decAmount, output strAmount).
 run sm-wrdcrc(input strTemp,input temp,input crc.crc,output str1,output str2).
 strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
 


 if length(strAmount) > 80 
    then do:  
        str1 = substring(strAmount,1,80). 
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put str1 skip str2 skip(0).
    end.
    else  put strAmount skip(0).
  
put
"                                                              " skip
"                                                              " skip
"Менеджер                    Контролер                    Кассир                    " skip(1).

/*------------------------------------------------------------------------------*/

/*----------------------27.08.01------------------------------------------------*/
if crc.crc <> 1 then
 do:

  find first drate where drate.crc = crc.crc no-lock no-error.
  if avail drate then 
     do:
       decAmountT = decAmount * drate.rate[1]. 
     end.                                   

   temp = string (decAmountT).
   if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
      temp = substring(temp, length(temp) - 1, 2).
      if num-entries(temp,".") = 2 then
      temp = substring(temp,2,1) + "0".
   end.
   else temp = "00".
 
   strTemp = string(truncate(decAmountT,0)).

   run Sm-vrd(input decAmountT, output strAmount).
   run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
   strAmount = "(" + strAmount + " " + str1 + " " + temp + " " + str2 + ")".

   if length(strAmount) > 80 
      then do:  
          str1 = substring(strAmount,1,80). 
          str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
          put str1 skip str2 skip(0).
      end.
      else  put strAmount skip(0).
 end.
/*------------------------------------------------------------------------------*/

       put drek[1] format "x(75)" skip(2).
        
       if ljl.dc eq "D" and length (trim (drek[2])) ne 0 then put drek[2] skip.
       if ljl.dc eq "C" and length (trim (drek[3])) ne 0 then put drek[3] skip.
       if length (trim (drek[4])) ne 0 then put drek[4] skip.
       if length (trim (drek[5])) ne 0 then put drek[5] skip.
       /* ------ 05/06/2002 ------ */
       /* if ljl.dc eq "C" then put drek[6] skip. - надо печатать и на приходном, и на расходном ордерах */ 
/*
  if ljl.dc eq "D" then do: /*Приходный кассоввый ордер*/
       if length (trim (drek[6]))  ne 0 then put drek[6]  skip.
       if length (trim (drek1[1])) ne 0 then put drek1[1] skip.
       if length (trim (drek1[2])) ne 0 then put drek1[2] skip.
       if length (trim (drek1[3])) ne 0 then put drek1[3] skip.
       if length (trim (drek1[4])) ne 0 then put drek1[4] skip.
       if length (trim (drek1[5])) ne 0 then put drek1[5] skip.
  end.
*/
       /* ------ 05/06/2002 ------ */
       if length (trim (drek[7])) ne 0 then put drek[7] .
       put skip(1).
put
"============================================================================="
skip(1).

       for each remfile:
          put unformatted remfile.rem skip.
       end.
    end.

    if last-of (ljl.crc) then do:
       sxin = 0.   sxout = 0.
    end.
end.

/* by sasco */
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if ofc.mday[2] = 1 then put skip(14).
else put skip(1).


