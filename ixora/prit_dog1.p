/* prit_dog1.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Печать данных по депозитам в Word
 * RUN
        prit_dog1.p
 * CALLER
        cif-new2
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        1-1-2
 * AUTHOR
        24.08.2006 - ten 
 * CHANGES
*/

def input parameter vaaa like aaa.aaa.
def input parameter v-int as integer.
def var        decAmount like jl.dam no-undo.
def var        strAmount as char format "x(200)" no-undo.
def var        temp as char no-undo.
def var        vmonth as int no-undo. 
def var        strTemp as char no-undo. 
def var        str1 as char format "x(50)" no-undo.
def var        str2 as char format "x(50)" no-undo.
def var        v-opn as dec no-undo.

output to rpt.img.  
find first aaa where aaa.aaa = vaaa no-lock no-error.
find first cif where cif.cif = aaa.cif no-lock no-error.

decAmount = aaa.opnamt. 

put unformatted ' ' entry(1,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') skip.
put unformatted ' ' entry(2,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') skip.

if num-entries(trim(trim(cif.prefix) + " " + trim(cif.name)),' ') > 2 
   then put unformatted ' ' entry(3,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') format "x(20)" cif.expdt skip.
   else put unformatted ' ' space(20) cif.expdt skip.

put ' ' cif.pss skip.   
put cif.jss  vaaa skip.
put ' ' cif.addr[1] skip.
put ' ' cif.addr[2].


if v-int = 1 then do:
      put skip(2).
      put ' ' cif.tel format 'xxxxxxxxxx' ' ' trim(cif.tlx) ' ' cif.fax.
      put skip.

      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).

      put skip(2).
      put  ' ' day(aaa.regdt) format '99' '   ' month(aaa.regdt) format '99' '   ' year(aaa.regdt) format '9999'  '           ' day(aaa.expdt) format '99' '   ' month(aaa.expdt) format '99' '   '  year(aaa.expdt) format '9999'  skip.
      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
      run Sm-vrd(input vmonth, output strAmount).
      strAmount = trim(strAmount).
      if vmonth = 1 then put unformatted ' ' strAmount '  месяц' skip.
      if vmonth > 1 and vmonth < 5 then put unformatted ' ' strAmount '  месяца' skip.
      if vmonth > 4 then put unformatted ' ' strAmount '  месяцев' skip.
   
      temp = string (decAmount).
      if num-entries(temp,".") = 2 then do:
         temp = substring(temp, length(temp) - 1, 2).
         if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
      end.
      else temp = "00".
      strTemp = string(truncate(decAmount,0)).
                
      run Sm-vrd(input decAmount, output strAmount).
      run sm-wrdcrc(input strTemp,input temp,input aaa.crc,output str1,output str2).
  
      strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

      put skip(1).

      if length(strAmount) > 47 then do:  
         str1 = substring(strAmount,1,47). 
         str2 = substring(strAmount,48,length(strAmount,"CHARACTER") - 47).
         put unformatted ' ' str1 skip str2 skip(1).
      end.
      else  put ' ' strAmount skip(2).
 end.
 else
 if v-int = 2 then do:
      put skip(1).
      put ' ' cif.tel format 'xxxxxxxxxx' ' ' trim(cif.tlx) ' ' cif.fax.
      put skip.

      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).

      put skip(2).
      put  aaa.regdt format '99999999' '      ' aaa.expdt format '99999999'  skip.
      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
      run Sm-vrd(input vmonth, output strAmount).
      strAmount = trim(strAmount).
      if vmonth = 1 then put unformatted ' ' strAmount '  месяц' skip.
      if vmonth > 1 and vmonth < 5 then put unformatted ' ' strAmount '  месяца' skip.
      if vmonth > 4 then put unformatted ' ' strAmount '  месяцев' skip.
 
      temp = string (decAmount).
      if num-entries(temp,".") = 2 then do:
         temp = substring(temp, length(temp) - 1, 2).
         if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
      end.
      else temp = "00".
      strTemp = string(truncate(decAmount,0)).
                
      run Sm-vrd(input decAmount, output strAmount).
      run sm-wrdcrc(input strTemp,input temp,input aaa.crc,output str1,output str2).
  
      strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

      if length(strAmount) > 47 then do:  
         str1 = substring(strAmount,1,47). 
         str2 = substring(strAmount,48,length(strAmount,"CHARACTER") - 47).
         put unformatted ' ' str1 skip str2 skip(1).
      end.
      else  put ' ' strAmount skip(2).
 
      v-opn = round(aaa.opnamt,2).
      put trim(string(v-opn)) format 'x(12)' '      ' round(aaa.rate,2) skip.
 end.
 else 
 if v-int = 4 then do:
    put skip(2).
    put ' ' cif.tel format 'xxxxxxxxxx' ' ' trim(cif.tlx) ' ' cif.fax.
    put skip.
    vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).

    put skip(2).

    put  aaa.regdt format '99999999' '      ' aaa.expdt format '99999999'  skip.
    vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
    run Sm-vrd(input vmonth, output strAmount).
    strAmount = trim(strAmount).
    if vmonth = 1 then put unformatted ' ' strAmount '  месяц' skip.
    if vmonth > 1 and vmonth < 5 then put unformatted ' ' strAmount '  месяца' skip.
    if vmonth > 4 then put unformatted ' ' strAmount '  месяцев' skip.
   
    temp = string (decAmount).
    if num-entries(temp,".") = 2 then do:
       temp = substring(temp, length(temp) - 1, 2).
       if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
    end.
    else temp = "00".
    strTemp = string(truncate(decAmount,0)).
                
    run Sm-vrd(input decAmount, output strAmount).
    run sm-wrdcrc(input strTemp,input temp,input aaa.crc,output str1,output str2).
  
    strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
 
    if length(strAmount) > 47 then do:  
       str1 = substring(strAmount,1,47). 
       str2 = substring(strAmount,48,length(strAmount,"CHARACTER") - 47).
       put unformatted ' ' str1 skip str2 skip(1).
    end.
    else  put ' ' strAmount skip(2).
    v-opn = round(aaa.opnamt,2).
    put trim(string(v-opn)) format 'x(12)' '   ' round(aaa.rate,2) skip.
 end.
 else do:
      put skip(1).
      put ' ' cif.tel format 'xxxxxxxxxx' ' ' trim(cif.tlx) ' ' cif.fax.
      put skip.

      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).

      put skip(2).
      put  aaa.regdt format '99999999' '      ' aaa.expdt format '99999999'  skip.
      vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
      run Sm-vrd(input vmonth, output strAmount).
      strAmount = trim(strAmount).
      if vmonth = 1 then put unformatted ' ' strAmount '  месяц' skip.
      if vmonth > 1 and vmonth < 5 then put unformatted ' ' strAmount '  месяца' skip.
      if vmonth > 4 then put unformatted ' ' strAmount '  месяцев' skip.
 
      temp = string (decAmount).
      if num-entries(temp,".") = 2 then do:
         temp = substring(temp, length(temp) - 1, 2).
         if num-entries(temp,".") = 2 then temp = substring(temp,2,1) + "0".
      end.
      else temp = "00".
      strTemp = string(truncate(decAmount,0)).
                
      run Sm-vrd(input decAmount, output strAmount).
      run sm-wrdcrc(input strTemp,input temp,input aaa.crc,output str1,output str2).
  
      strAmount = strAmount + " " + str1 + " " + temp + " " + str2.

      if length(strAmount) > 47 then do:  
         str1 = substring(strAmount,1,47). 
         str2 = substring(strAmount,48,length(strAmount,"CHARACTER") - 47).
         put unformatted ' ' str1 skip str2 skip(1).
      end.
      else  put ' ' strAmount skip(2).
 
      v-opn = round(aaa.opnamt,2).
      put trim(string(v-opn)) format 'x(12)' ' ' round(aaa.rate,2) skip.
/*
      find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
      if avail acvolt then do:
         put skip(1).

         if acvolt.sts = "1" then do:
            if length(acvolt.accp) = 9 then put '  *' .
                                       else put '      *' .
         end.
         else 
         if acvolt.sts = "2" then           put '          *' .
         else                               put '           ' .

         if acvolt.x3 = "1" then put '          *' .
         else 
         if acvolt.x3 = "2" then put '           *' .
         else                    put '            ' .

         if acvolt.x1 = "1" then put '       *' skip.
         else 
         if acvolt.x1 = "2" then put '        *' skip.
         else                    put skip.

         put '                            ' acvolt.prim1 skip.
         put skip.

         if acvolt.x4 = "2" then put '   *' skip.
         else
         if acvolt.x4 = "1" then put '             *' skip.
      end.
*/
 end.

 put skip(7). 

 output close.   
 unix silent cptwin rpt.img winword.exe.


