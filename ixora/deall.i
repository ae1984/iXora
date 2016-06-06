/*



 * BASES
        BANK 


*/
    put stream m-out unformatted "<tr align=""right"">"
                "<td align=""center""> " wrk.gl "</td>"
                "<td align=""left""> " wrk.mom "</td>"
                "<td align=""left""> " '`' wrk.fun "</td>"
                "<td > " replace(trim(string(wrk.sum1, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(wrk.sum11, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td > " replace(trim(string(wrk.intrate, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td > " replace(trim(string(wrk.parval, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td > " replace(trim(string(wrk.open_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td > " replace(trim(string(wrk.close_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "</tr>" skip.
    accumulate wrk.sum1 (TOTAL by wrk.gl by wrk.mom).
    accumulate wrk.sum11 (TOTAL by wrk.gl by wrk.mom).
    accumulate wrk.open_price  (TOTAL by wrk.gl by wrk.mom).
    accumulate wrk.close_price (TOTAL by wrk.gl by wrk.mom).
    accumulate wrk.parval  (TOTAL by wrk.gl by wrk.mom).

   if last-of(wrk.mom) then do:  
     summa1 = ACCUMulate total  by (wrk.mom) wrk.sum1.   
     summa11 = ACCUMulate total  by (wrk.mom) wrk.sum11.   
     v-open_price  = ACCUMulate total  by (wrk.mom) wrk.open_price.   
     v-close_price = ACCUMulate total  by (wrk.mom) wrk.close_price.
     v-parval      = ACCUMulate total  by (wrk.mom) wrk.parval.
                                                                                                         
    put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                "<td align=""center""> ИТОГО ПО </td>"
                "<td align=""left""> " wrk.mom "</td>"
                "<td align=""left""> " "</td>"
                "<td > " replace(trim(string(summa1, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(summa11, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td align=""left""> " "</td>"
                "<td > " replace(trim(string(v-parval, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(v-open_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(v-close_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "</tr>" skip.
   end.
   if last-of(wrk.gl) then do:  
     summa1 = ACCUMulate total  by (wrk.gl) wrk.sum1.   
     summa11 = ACCUMulate total  by (wrk.gl) wrk.sum11.   
     v-open_price  = ACCUMulate total  by (wrk.gl) wrk.open_price.   
     v-close_price = ACCUMulate total  by (wrk.gl) wrk.close_price.
     v-parval      = ACCUMulate total  by (wrk.gl) wrk.parval.

    put stream m-out unformatted "<tr align=""right"" style=""font:bold"">"
                "<td align=""center""> ИТОГО ПО </td>"
                "<td align=""left""> " wrk.gl "</td>"
                "<td align=""left""> " "</td>"
                "<td > " replace(trim(string(summa1, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(summa11, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                "<td align=""left""> " "</td>"
                "<td > " replace(trim(string(v-parval, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(v-open_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "<td > " replace(trim(string(v-close_price, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")  "</td>"
                "</tr>" skip.
   end.

