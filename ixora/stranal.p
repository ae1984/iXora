/* stranal.p
 * MODULE
        Анализ проблемных улиц 
 * DESCRIPTION
        Отчет по переоценке внебалансовой валютной позиции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
 * MENU
 * AUTHOR
        24.03.2004 tsoy
 * CHANGES
        18.08.2006 Natalya D. оптимизация: изменила запрос. Необходимо добавить индекс на поля bank & kritcod в таблице pkanketh
 */

{mainhead.i}

def var v-bank    as char.
def var v-str     as char.

def var v-c1 as inte.
def var v-c2 as inte.
def var v-c3 as inte.

def var v-b1 as inte.
def var v-b2 as inte.
def var v-b3 as inte.

def var v-a1 as inte.
def var v-a2 as inte.
def var v-a3 as inte.

def var v-db1 as inte.
def var v-db2 as inte.
def var v-db3 as inte.

define stream m-out.
output stream m-out to str_a.html.

def temp-table str_a
    field str_a_name         as char
    field str_a_value        as char
    field str_a_totcnt1      as inte   
    field str_a_credcnt1     as inte
    field str_a_debcnt1      as inte
    field str_a_totcnt2      as inte   
    field str_a_credcnt2     as inte
    field str_a_debcnt2      as inte
    field str_a_totcnt3      as inte   
    field str_a_credcnt3     as inte
    field str_a_debcnt3      as inte.

def buffer str_a_buf for str_a.

def temp-table t-ank
    field bank as char
    field ln as int
    field kritcod as char
    field value1 as char
    field lon as char
    field debt as deci
    field credtype as char
    index ind1 kritcod
    index ind2 value1.

def var v-lon as char.
def var v-debt as deci.


{comm-txb.i}
v-bank = comm-txb().
 v-c1 = 0.
 v-c2 = 0.
 v-c3 = 0.

 v-b1 = 0.
 v-b2 = 0.
 v-b3 = 0.

 v-a1 = 0.
 v-a2 = 0.
 v-a3 = 0.

 v-db1 = 0.
 v-db2 = 0.
 v-db3 = 0.

for each pkanketh where pkanketh.bank = v-bank and lookup(pkanketh.kritcod,'street1,street2,street3') > 0 no-lock.
  /*if lookup(pkanketh.kritcod,'street1,street2,street3') = 0 then next.*/
  find first pkanketa where pkanketa.bank = pkanketh.bank and pkanketa.ln = pkanketh.ln 
                        and pkanketa.credtype = pkanketh.credtype no-lock no-error.
  if not avail pkanketa then next.
  create t-ank.
  assign t-ank.bank = pkanketh.bank
         t-ank.ln = pkanketh.ln
         t-ank.kritcod = pkanketh.kritcod
         t-ank.value1 = pkanketh.value1
         t-ank.credtype = pkanketh.credtype          
         t-ank.lon = pkanketa.lon.
  for each trxbal where trxbal.subled = 'LON' and trxbal.acc = pkanketa.lon no-lock.
    if lookup(string(trxbal.level),'7,9,16') > 0 and (trxbal.dam - trxbal.cam) > 0 
    then do: t-ank.debt = trxbal.dam - trxbal.cam. leave. end.
  end.
end.

/* Прописка */
   
for each t-ank where t-ank.kritcod = "street1"
                                 break by t-ank.value1 :      
      accumulate t-ank.ln (count by t-ank.value1).
      v-a1 = v-a1 + 1.      
      if t-ank.lon <> "" then do:
              accumulate t-ank.bank (count by t-ank.value1).
              v-b1 = v-b1 + 1.
                  if t-ank.debt > 0 then do:
                     accumulate t-ank.kritcod (count by t-ank.value1).                 
                     v-c1 = v-c1 + 1.
                     v-db1 = v-db1 + 1.                     
                  end.
      end.

      if last-of(t-ank.value1) then do:
               find first codfr where codfr = 'pkstrit0'
                                      and string(code) = trim(t-ank.value1) no-lock no-error.
               if avail codfr then  do:
                   if codfr.name[2]  <> "" then 
                            v-str = codfr.name[1] + " (" + codfr.name[2] + ")". 
                   else     
                            v-str = codfr.name[1]. 
               end.
               else
                       v-str = trim(t-ank.value1).                  

               find first str_a where trim(str_a_name) = trim(v-str) no-lock no-error.
               if avail str_a then do: 
                     str_a.str_a_totcnt1  = str_a.str_a_totcnt1  + accum count by t-ank.value1 t-ank.ln.
                     str_a.str_a_credcnt1 = str_a.str_a_credcnt1 + accum count by t-ank.value1 t-ank.bank.
                     str_a.str_a_debcnt1 = str_a.str_a_debcnt1 + v-db1.
               end.
               else do:
                     create str_a.        
                     str_a.str_a_name     = v-str.
                     str_a.str_a_value    = trim(t-ank.value1).
                     str_a.str_a_totcnt1  = accum count by t-ank.value1 t-ank.ln.
                     str_a.str_a_credcnt1 = accum count by t-ank.value1 t-ank.bank.
                     str_a.str_a_debcnt1 = v-db1.
               end.
               v-db1 = 0.
      end.
end.
/* Проживание */

for each t-ank where t-ank.kritcod = "street2" break by t-ank.value1 :
      
      accumulate t-ank.ln (count by t-ank.value1).
      v-a2 = v-a2 + 1.      
         if t-ank.lon <> "" then do:
              accumulate t-ank.bank (count by t-ank.value1).
              v-b2 = v-b2 + 1.              
                  if t-ank.debt > 0 then do: 
                     accumulate t-ank.kritcod (count by t-ank.value1).                 
                     v-c2 = v-c2 + 1.
                     v-db1 = v-db1 + 1.                    
                  end.              
         end.
      

      if last-of(t-ank.value1) then do:
         find first str_a where trim(str_a_name) = trim(t-ank.value1) no-lock no-error.
         if avail str_a then do: 
               str_a.str_a_totcnt2  = str_a.str_a_totcnt2  +  accum count by t-ank.value1 t-ank.ln.
               str_a.str_a_credcnt2 = str_a.str_a_credcnt2 + accum count by t-ank.value1 t-ank.bank.
               str_a.str_a_debcnt2 = str_a.str_a_debcnt2 + v-db1.
         end.
         else do:
               create str_a.
               str_a.str_a_value    = trim(t-ank.value1).
               str_a.str_a_name     = trim(t-ank.value1).
               str_a.str_a_totcnt2  = accum count by t-ank.value1 t-ank.ln.
               str_a.str_a_credcnt2 = accum count by t-ank.value1 t-ank.bank.
               str_a.str_a_debcnt2 = v-db1.
         end.
         v-db1 = 0.
      end.
end.
/* Недвижимость */

for each t-ank where t-ank.kritcod = "street3" break by t-ank.value1 :
      accumulate t-ank.ln (count by t-ank.value1).
      v-a3 = v-a3 + 1.
         if t-ank.lon <> "" then do:
              accumulate t-ank.bank (count by t-ank.value1).
              v-b3 = v-b3 + 1.              
                  if t-ank.debt > 0 then do:
                     accumulate t-ank.kritcod (count by t-ank.value1).                 
                     v-c3  = v-c3 + 1.
                     v-db1 = v-db1 + 1.          
                  end.                   
         end.

      if last-of(t-ank.value1) then do:
          
          if avail codfr then  do:
              if codfr.name[2]  <> "" then 
                       v-str = codfr.name[1] + " (" + codfr.name[2] + ")". 
              else     
                       v-str = codfr.name[1]. 
          end.
          else
                  v-str = trim(t-ank.value1).                  

         find first str_a where trim(str_a_name) = trim(v-str) no-lock no-error.
        
         if avail str_a then do: 
               str_a.str_a_totcnt3  = str_a.str_a_totcnt3  + accum count by t-ank.value1 t-ank.ln.
               str_a.str_a_credcnt3 = str_a.str_a_credcnt3 + accum count by t-ank.value1 t-ank.bank.

               str_a.str_a_debcnt3 = str_a.str_a_debcnt3 + v-db1.
         end.
         else do:
               create str_a.        
               str_a.str_a_name     = v-str.
               str_a.str_a_value    = trim(t-ank.value1).
               str_a.str_a_totcnt3  = accum count by t-ank.value1 t-ank.ln.
               str_a.str_a_credcnt3 = accum count by t-ank.value1 t-ank.bank.

               str_a.str_a_debcnt3  = v-db1.
         end.
         v-db1 = 0.
      end.
end.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3>Анализ улиц  <br></h3>" skip.

put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                      style=""border-collapse: collapse"">" skip. 

put stream m-out unformatted "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"" rowspan =""2"">Улица</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan =""3"" >Прописка    </td>"                  
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan =""3"" >Проживание  </td>"                  
                  "<td bgcolor=""#C0C0C0"" align=""center"" colspan =""3"" >Недвижимость</td>"                  
                  "</tr><tr>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Анкет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Кредитов</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Задолжников</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Анкет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Кредитов</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Задолжников</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Анкет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Кредитов</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Задолжников</td>"
                  "</tr>" skip.

for each str_a no-lock break by str_a_name:
put stream m-out  unformatted "<tr style=""font:bold"">"
                   "<td>" str_a_name              "</td>"
                   "<td>" string(str_a_totcnt1  )  "</td>"  
                   "<td>" string(str_a_credcnt1 )  "</td>"  
                   "<td>" string(str_a_debcnt1  )  "</td>"  
                   "<td>" string(str_a_totcnt2  )  "</td>"  
                   "<td>" string(str_a_credcnt2 )  "</td>"  
                   "<td>" string(str_a_debcnt2  )  "</td>"  
                   "<td>" string(str_a_totcnt3  )  "</td>"  
                   "<td>" string(str_a_credcnt3 )  "</td>"  
                   "<td>" string(str_a_debcnt3  )  "</td>"                     
                   "</tr>" skip.

end.

put stream m-out unformatted
"</table>". 
output stream m-out close.
unix silent cptwin str_a.html excel.

