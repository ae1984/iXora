 def input parameter decAmount as decimal. 
 def input parameter v-crc  like crc.crc. 
 def output parameter strAmount as char format "x(80)".
 
/* def var        strAmount as char format "x(80)".*/
 def var        temp as char.
 def var        strTemp as char. 
 def var        str1 as char format "x(80)".
 def var        str2 as char format "x(80)".
def var        decAmountT as decimal .

  temp = string (decAmount).
   if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
       temp = substring(temp, length(temp) - 1, 2).
           if num-entries(temp,".") = 2 then
               temp = substring(temp,2,1) + "0".
                end.
           else temp = "00".
                  
         strTemp = string(truncate(decAmount,0)).
         find crc where crc.crc  = v-crc.
       run Sm-vrd(input decAmount, output strAmount).
    run sm-wrdcrc(input strTemp,input temp,input crc.crc,output str1,output str2).
 strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
  

/*   if length(strAmount) > 80 
       then do:  
               str1 = substring(strAmount,1,80). 
                       str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put str1 skip str2 skip(0).
            end.
                else  put strAmount skip(0).*/

