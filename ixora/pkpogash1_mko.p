/* pkpogash1_mko.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Погашения по кредитам средствами заемщиков для МКО
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        24/11/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        11/02/2010 galina - перекомпиляция
        12/02/2010 galina - добавила остаток ОД
        
*/
{global.i}
def var v-dt1 as date.
def var v-dt2 as date.
def var v-sumplat1 as deci no-undo.
def var v-sumplat2 as deci no-undo.
def var v-sumplat9 as deci no-undo.
def var v-sumplat16 as deci no-undo.
def var v-sumplat7 as deci no-undo.
def var v-sumplatcom as deci no-undo.
def var v-refsum as deci no-undo.
def var v-refcount as integer.
def var v-pogcount as integer.
def stream rep.
def var i as integer.
def var v-select as integer.

def new shared temp-table pk-lnpog
   field bank as char
   field cif like cif.cif
   field name as char
   field crc as integer
   field rdt as date
   field expdt as date
   field daypog as integer
   field opnamt as deci
   field sum1 as deci /*сумма оплаты ОД*/
   field sum2 as deci /*сумма оплаты %% */
   field sum7 as deci /*сумма оплаты просроченного ОД*/
   field sum9 as deci /*сумма оплаты просроченных %% 9 и 4*/
   field sum16 as deci /*сумма оплаты пени 5 и 16*/
   field sumcom as deci /*сумма оплаты комиссии*/
   field sumaaa as deci
   field day_od as integer
   field day_prc as integer   
   field sumod as decimal   
   index ind1 is primary bank crc.

def temp-table pk-lnpogfil
   field bank as char
   field refamt as deci /*сумма рефинанса*/  
   /*field refcount as integer*/ /*количество рефинанса*/
   field pogcount as integer /*количество погашений*/
   field crc as integer
   field sum1 as deci /*сумма оплаты ОД*/
   field sum2 as deci /*сумма оплаты %% */
   field sum7 as deci /*сумма оплаты просроченного ОД*/
   field sum9 as deci /*сумма оплаты просроченных %% 9 и 4*/
   field sum16 as deci /*сумма оплаты пени 5 и 16*/
   field sumcom as deci /*сумма оплаты комиссии*/
   index ind1 is primary bank crc
   index ind2 crc.

def temp-table pk-lnpogfiltot
   field bank as char
   field refamt as deci /*сумма рефинанса*/  
   field refcount as integer /*количество рефинанса*/
   field pogcount as integer /*количество погашений*/
   field crc as integer
   field sum1 as deci /*сумма оплаты ОД*/
   field sum2 as deci /*сумма оплаты %% */
   field sum7 as deci /*сумма оплаты просроченного ОД*/
   field sum9 as deci /*сумма оплаты просроченных %% 9 и 4*/
   field sum16 as deci /*сумма оплаты пени 5 и 16*/
   field sumcom as deci /*сумма оплаты комиссии*/
   index ind1 is primary bank crc
   index ind2 crc.

def temp-table pk-lnpogfilkzt
   field bank as char
   field refamt as deci /*сумма рефинанса*/  
   field refcount as integer /*количество рефинанса*/
   field pogcount as integer /*количество погашений*/
   field sum1 as deci /*сумма оплаты ОД*/
   field sum2 as deci /*сумма оплаты %% */
   field sum7 as deci /*сумма оплаты просроченного ОД*/
   field sum9 as deci /*сумма оплаты просроченных %% 9 и 4*/
   field sum16 as deci /*сумма оплаты пени 5 и 16*/
   field sumcom as deci /*сумма оплаты комиссии*/
   index ind1 is primary bank.


v-dt1 = g-today.
v-dt2 = g-today.
update  v-dt1 label ' с ' format '99/99/9999' validate (v-dt1 <= g-today, " Дата должна быть не позже текущей! ")
        v-dt2 label ' по ' format '99/99/9999' validate (v-dt2 <= g-today, " Дата должна быть не позже текущей! ") 
with side-label row 5 centered frame dat.
message "Формируется отчет..." .

{r-branch.i &proc = "pkpogash_mko(v-dt1,v-dt2)"}

v-sumplat1 = 0.
v-sumplat2 = 0.
v-sumplat9 = 0.
v-sumplat16 = 0.
v-sumplat7 = 0.
v-sumplatcom = 0.

for each pk-lnpog no-lock break by pk-lnpog.bank by pk-lnpog.crc:
  v-sumplat1 = v-sumplat1 + pk-lnpog.sum1.
  v-sumplat2 = v-sumplat2 + pk-lnpog.sum2.
  v-sumplat9 = v-sumplat9 + pk-lnpog.sum9.
  v-sumplat16 = v-sumplat16 + pk-lnpog.sum16.
  v-sumplat7 = v-sumplat7 + pk-lnpog.sum7.
  v-sumplatcom = v-sumplatcom + pk-lnpog.sumcom.
  if pk-lnpog.sum1 + pk-lnpog.sum2 + pk-lnpog.sum7 + pk-lnpog.sum9 + pk-lnpog.sum16 + pk-lnpog.sumcom > 0 then v-pogcount = v-pogcount + 1.
  if last-of(pk-lnpog.crc) then do:
    find first pk-lnpogfiltot where pk-lnpogfiltot.bank = pk-lnpog.bank and pk-lnpogfiltot.crc = pk-lnpog.crc exclusive-lock no-error.
    if v-sumplat1 + v-sumplat2 + v-sumplat7 + v-sumplat9 + v-sumplat16 + v-sumplatcom > 0 then do:
        if not avail pk-lnpogfiltot then do:    
            create pk-lnpogfiltot.
            assign pk-lnpogfiltot.bank = pk-lnpog.bank
                   pk-lnpogfiltot.crc = pk-lnpog.crc.
        end.   
        
        
        assign pk-lnpogfiltot.sum1 = v-sumplat1
               pk-lnpogfiltot.sum2 = v-sumplat2
               pk-lnpogfiltot.sum9 = v-sumplat9
               pk-lnpogfiltot.sum16 = v-sumplat16
               pk-lnpogfiltot.sum7 = v-sumplat7
               pk-lnpogfiltot.sumcom = v-sumplatcom
               pk-lnpogfiltot.pogcount = v-pogcount.           
    end.       
           
     v-sumplat1 = 0.
     v-sumplat2 = 0.
     v-sumplat9 = 0.
     v-sumplat16 = 0.
     v-sumplat7 = 0.
     v-sumplatcom = 0.
     v-pogcount = 0.
  end.
  
end.
find first crc where crc.crc = 2 no-lock no-error.
     v-sumplat1 = 0.
     v-sumplat2 = 0.
     v-sumplat9 = 0.
     v-sumplat16 = 0.
     v-sumplat7 = 0.
     v-sumplatcom = 0.
     v-pogcount = 0.
     v-refcount = 0.
     v-refsum = 0.    
for each pk-lnpogfiltot no-lock break by pk-lnpogfiltot.bank:
  if pk-lnpogfiltot.crc = 1 then do:
      v-sumplat1 = v-sumplat1 + pk-lnpogfiltot.sum1.
      v-sumplat2 = v-sumplat2 + pk-lnpogfiltot.sum2.
      v-sumplat9 = v-sumplat9 + pk-lnpogfiltot.sum9.
      v-sumplat7 = v-sumplat7 + pk-lnpogfiltot.sum7.
      v-sumplatcom = v-sumplatcom + pk-lnpogfiltot.sumcom.
      v-refsum = v-refsum + pk-lnpogfiltot.refamt.    
  end.
  
  assign v-refcount = v-refcount + pk-lnpogfiltot.refcount
         v-sumplat16 = v-sumplat16 + pk-lnpogfiltot.sum16
         v-pogcount = v-pogcount + pk-lnpogfiltot.pogcount.
         
  if pk-lnpogfiltot.crc = 2 then do:
      v-sumplat1 = v-sumplat1 + pk-lnpogfiltot.sum1 * crc.rate[1].
      v-sumplat2 = v-sumplat2 + pk-lnpogfiltot.sum2 * crc.rate[1].
      v-sumplat9 = v-sumplat9 + pk-lnpogfiltot.sum9 * crc.rate[1].
      v-sumplat7 = v-sumplat7 + pk-lnpogfiltot.sum7 * crc.rate[1].
      v-sumplatcom = v-sumplatcom + pk-lnpogfiltot.sumcom * crc.rate[1].
      v-refsum = v-refsum + pk-lnpogfiltot.refamt * crc.rate[1].    
  end.
  
  
  if last-of(pk-lnpogfiltot.bank) then do:
     find first pk-lnpogfilkzt where pk-lnpogfilkzt.bank = pk-lnpogfiltot.bank no-lock no-error.
     if not avail pk-lnpogfilkzt then do:    
        create pk-lnpogfilkzt.
        assign pk-lnpogfilkzt.bank = pk-lnpogfiltot.bank.
     end.   
        
        
     assign pk-lnpogfilkzt.sum1 = v-sumplat1
            pk-lnpogfilkzt.sum2 = v-sumplat2
            pk-lnpogfilkzt.sum9 = v-sumplat9
            pk-lnpogfilkzt.sum16 = v-sumplat16
            pk-lnpogfilkzt.sum7 = v-sumplat7
            pk-lnpogfilkzt.sumcom = v-sumplatcom
            pk-lnpogfilkzt.pogcount = v-pogcount 
            pk-lnpogfilkzt.refamt = v-refsum
            pk-lnpogfilkzt.refcount = v-refcount.      

     v-sumplat1 = 0.
     v-sumplat2 = 0.
     v-sumplat9 = 0.
     v-sumplat16 = 0.
     v-sumplat7 = 0.
     v-sumplatcom = 0.
     v-pogcount = 0.
     v-refcount = 0.
     v-refsum = 0.  
  end.
end.

output stream rep to pkpogash.html.
{html-title.i
 &title = "METROCOMBANK" 
 &stream = "stream rep" 
 &size-add = "x-"}
 put stream rep unformatted
 "<center><b>Отчет по погашеной ссудной задолженности средствами заемщиков <br>с " v-dt1 format "99/99/9999" " по " v-dt2 format "99/99/9999" "</b></center><BR>" skip
 "<p>Приложение 1</p>" skip
 "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
 "<td>№</td>" skip
 "<td>Наименование заемщика</td>" skip
 "<td>Код<BR>заемщика</td>" skip
 "<td> Филиал</td>" skip
 "<td>Валюта<BR>кредита</td>" skip
 "<td>Дата<BR>выдачи</td>" skip
 "<td>Срок<BR>погашения</td>" skip
 "<td>День<BR>погашения</td>" skip
 "<td>Поступления<BR>на счет</td>" skip
 "<td>Одобренная сумма<br>(в валюте кредита)</td>" skip  
 "<td>Остаток ОД<br>(в валюте кредита)</td>" skip       
 "<td>Сумма оплаты ОД<br>(в валюте кредита)</td>" skip    
 "<td>Сумма оплаты %%<br>(в валюте кредита)</td>" skip    
 "<td>Сумма оплаты<br>просроченного ОД<br>(в валюте кредита)<br>7 уровень</td>" skip    
 "<td>Кол-во дней просрочки по ОД</td>" skip    
 "<td>Сумма просроченных %%<br>(в валюте кредита)<br>9 и 4 уровень</td>" skip    
 "<td>Кол-во дней просрочки по %%</td>" skip        
 "<td>Сумма оплаты пени<br>(16 и 5 уровень)</td>" skip    
 "<td>Сумма оплаты комиссии<br>за ведение счета</td>" skip
 "<td>Итого сумма оплаты</td></tr>" skip.
 i = 0.
for each pk-lnpog no-lock break by pk-lnpog.bank by pk-lnpog.cif:
    i = i + 1.
    find first txb where txb.consolid and txb.bank = pk-lnpog.bank no-lock no-error.
    put stream rep unformatted "<tr style=""font-size:xx-small"" align=""left"">" skip
    "<td>" i "</td>" skip
    "<td>" pk-lnpog.name "</td>" skip
    "<td>" pk-lnpog.cif "</td>" skip
    "<td>" txb.info "</td>" skip
    "<td>" pk-lnpog.crc "</td>" skip
    "<td>" string(pk-lnpog.rdt,'99/99/9999') "</td>" skip
    "<td>" string(pk-lnpog.expdt,'99/99/9999') "</td>" skip
    "<td>" pk-lnpog.daypog "</td>" skip
    "<td>" replace(string(pk-lnpog.sumaaa,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
    "<td>" replace(string(pk-lnpog.opnamt,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
    "<td>" replace(string(pk-lnpog.sumod,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip    
    "<td>" replace(string(pk-lnpog.sum1,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
    "<td>" replace(string(pk-lnpog.sum2,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
    "<td>" replace(string(pk-lnpog.sum7,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" string(pk-lnpog.day_od) "</td>" skip
    "<td>" replace(string(pk-lnpog.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" string(pk-lnpog.day_prc) "</td>" skip
    "<td>" replace(string(pk-lnpog.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
    "<td>" replace(string(pk-lnpog.sumcom,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip.
    if pk-lnpog.crc <> 1 then  put stream rep unformatted "<td>" replace(string(pk-lnpog.sumcom + pk-lnpog.sum1 + pk-lnpog.sum2 + pk-lnpog.sum7 + pk-lnpog.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.  
    else  put stream rep unformatted "<td>" replace(string(pk-lnpog.sumcom + pk-lnpog.sum1 + pk-lnpog.sum2 + pk-lnpog.sum7 + pk-lnpog.sum9 + pk-lnpog.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.  
end.
put stream rep unformatted "</table><br><br>" skip.

find first pk-lnpogfiltot where pk-lnpogfiltot.crc = 1 no-lock no-error.
if avail pk-lnpogfiltot then do:
   put stream rep unformatted     
   "<p>Приложение № 2</p>" skip
   "<b>Консолидированный отчет по погашению кредитов, выданных в тенге</b><BR>" skip
   "<table border=1 cellpadding=0 cellspacing=0>" skip
   "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
   "<td> Филиал</td>" skip
   "<td> Кол-во<br> рефинансированных</td>" skip
   "<td> Сумма<br> рефинансирования</td>" skip
   "<td> Кол-во<br> погашенных</td>" skip
   "<td>Сумма оплаты ОД<br>(в тенге)</td>" skip    
   "<td>Сумма оплаты %%<br>(в тенге)</td>" skip    
   "<td>Сумма оплаты<br>просроченного<br>ОД (в тенге)</td>" skip    
   "<td>Сумма просроченных<br>%%(в тенге)</td>" skip    
   "<td>Сумма оплаты пени" skip    
   "<td>Сумма оплаты комиссии<br>за ведение счета</td>" skip
   "<td>ИТОГО СУММА<br>ОПЛАТЫ (В ТЕНГЕ)</td></tr>" skip.
   for each pk-lnpogfiltot where pk-lnpogfiltot.crc = 1 no-lock break by pk-lnpogfiltot.bank:
     find first txb where txb.consolid and txb.bank = pk-lnpogfiltot.bank no-lock no-error.
     put stream rep unformatted "<tr style=""font-size:xx-small"" align=""left"">" skip
     "<td>" txb.info "</td>" skip
     "<td>" pk-lnpogfiltot.refcount "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.refamt,'->>>>>>>>>>>>>>9.99'),'.',',')  "</td>" skip
     "<td>" pk-lnpogfiltot.pogcount "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum1,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum2,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum7,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sumcom,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sumcom + pk-lnpogfiltot.sum1 + pk-lnpogfiltot.sum2 + pk-lnpogfiltot.sum7 + pk-lnpogfiltot.sum9 + pk-lnpogfiltot.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.  
   end.   
   put stream rep unformatted "</table><br><br>" skip.
end.

find first pk-lnpogfiltot where pk-lnpogfiltot.crc = 2 no-lock no-error.
if avail pk-lnpogfiltot then do:
    put stream rep unformatted
     "<p>Приложение № 3</p>" skip
     "<b>Консолидированный отчет по погашению кредитов, выданных в долларах</b><BR>" skip
     "<table border=1 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
     "<td> Филиал</td>" skip
     "<td> Кол-во<br> рефинансированных</td>" skip
     "<td> Сумма<br> рефинансирования</td>" skip
     "<td> Кол-во<br> погашенных</td>" skip
     "<td>Сумма оплаты ОД<br>(в долларах)</td>" skip    
     "<td>Сумма оплаты %%<br>(в долларах)</td>" skip    
     "<td>Сумма оплаты<br>просроченног<br>ОД (в долларах)</td>" skip    
     "<td>Сумма просроченных<br>%% (в долларах)</td>" skip    
     "<td>ИТОГО СУММА ОПЛАТЫ<br>(В ДОЛЛАРАХ)</td>" skip
     "<td>Сумма оплаты комиссии<br>за ведение<br> счета (в долларах)</td>" skip
     "<td>Сумма оплаты пени<br>(в тенге)</td></tr>" skip.
   for each pk-lnpogfiltot where pk-lnpogfiltot.crc = 2 no-lock break by pk-lnpogfiltot.bank:
     find first txb where txb.consolid and txb.bank = pk-lnpogfiltot.bank no-lock no-error.
     put stream rep unformatted "<tr style=""font-size:xx-small"" align=""left"">" skip
     "<td>" txb.info "</td>" skip
     "<td>" pk-lnpogfiltot.refcount "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.refamt,'->>>>>>>>>>>>>>9.99'),'.',',')  "</td>" skip
     "<td>" pk-lnpogfiltot.pogcount "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum1,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum2,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum7,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string( pk-lnpogfiltot.sumcom + pk-lnpogfiltot.sum1 + pk-lnpogfiltot.sum2 + pk-lnpogfiltot.sum7 + pk-lnpogfiltot.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip  
     "<td>" replace(string(pk-lnpogfiltot.sumcom,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfiltot.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.
   end.   
   put stream rep unformatted "</table><br><br>" skip.     
end.     

find first pk-lnpogfilkzt no-lock no-error.
if avail pk-lnpogfilkzt then do:
   put stream rep unformatted     
   "<p>Приложение № 4</p>" skip
   "<b>Консолидированный отчет по погашению кредитов конвертируемый в тенге, курс 1$ = " string(crc.rate[1],'>>9.99') " тенге</b><BR>" skip
   "<table border=1 cellpadding=0 cellspacing=0>" skip
   "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
   "<td> Филиал</td>" skip
   "<td> Кол-во<br> рефинансированных</td>" skip
   "<td> Сумма<br> рефинансирования</td>" skip
   "<td> Кол-во<br> погашенных</td>" skip
   "<td>Сумма оплаты ОД<br>(в тенге)</td>" skip    
   "<td>Сумма оплаты %%<br>(в тенге)</td>" skip    
   "<td>Сумма оплаты<br>просроченного<br>ОД (в тенге)</td>" skip    
   "<td>Сумма просроченных<br>%%(в тенге)</td>" skip    
   "<td>Сумма оплаты пени" skip    
   "<td>Сумма оплаты комиссии<br>за ведение счета</td>" skip
   "<td>ИТОГО СУММА<br>ОПЛАТЫ (В ТЕНГЕ)</td></tr>" skip.
   for each pk-lnpogfilkzt no-lock break by pk-lnpogfilkzt.bank:
     find first txb where txb.consolid and txb.bank = pk-lnpogfilkzt.bank no-lock no-error.
     put stream rep unformatted "<tr style=""font-size:xx-small"" align=""left"">" skip
     "<td>" txb.info "</td>" skip
     "<td>" pk-lnpogfilkzt.refcount "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.refamt,'->>>>>>>>>>>>>>9.99'),'.',',')  "</td>" skip
     "<td>" pk-lnpogfilkzt.pogcount "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sum1,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sum2,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sum7,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sum9,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sumcom,'->>>>>>>>>>>>>>9.99'),'.',',') "</td>" skip
     "<td>" replace(string(pk-lnpogfilkzt.sumcom + pk-lnpogfilkzt.sum1 + pk-lnpogfilkzt.sum2 + pk-lnpogfilkzt.sum7 + pk-lnpogfilkzt.sum9 + pk-lnpogfilkzt.sum16,'->>>>>>>>>>>>>>9.99'),'.',',') "</td></tr>" skip.  
   end.   
   put stream rep unformatted "</table>" skip.
end.    


output stream rep close.
hide message no-pause.
unix silent cptwin pkpogash.html excel.
unix silent rm -f pkpogash.html.