/* spay.p
 * MODULE
         
 * DESCRIPTION
         otchet по простым платежам
 RUN
 * CALLER
          
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        
 * AUTHOR
         17.08.05 ten
 * CHANGES

 */
{global.i}
{get-dep.i}

def temp-table pay-table
field num as integer
field sif like aaa.cif
field name like aaa.name
field ch like remtrz.dracc
field rem like remtrz.source
field sta like aaa.sta
field sum as char
field val like remtrz.tcrc
field cod like sub-cod.ccode
field kol as integer
field summ like remtrz.amt
index iii is primary sif.


def var stime as date label " В период с ".
def var endtime as date label " по ".
def var i as int.
def var v-face as char.

def buffer b-pay-table for pay-table.

def var face like sub-cod.ccode label "Статус".
def var vdep1 as integer.
def var vdep like ppoint.depart.
def new shared var vpoint like ppoint.point.





 
form vdep label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов'
  validate(can-find (ppoint where ppoint.depart = vdep no-lock),
  ' Ошибочный код департамента - повторите ! ') skip with frame ofc1 col 1 row 3
  2 col width 66.
  vpoint = 1.

  
update vdep with frame ofc1.  
form face label 'Статус' skip with frame ofc1.
 message 'В - юр.лица, Р - физ.лица'.

update face with frame ofc1.


if face = "B" then 
              v-face = "0".
              else do:
if face = "P"
              then
              v-face = "1".
              else do: message "Неправильный статус! (P-физ лица, B-юр лица)". return. end.
end.

update stime endtime with frame ofc1.

for each joudoc where joudoc.whn >= stime and joudoc.whn <= endtime no-lock.    
  find aaa where aaa.aaa = joudoc.dracc no-lock no-error.
    if avail aaa then do:  
      find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" and sub-cod.rcode = v-face no-lock no-error.
        if avail sub-cod then do:
          find first cif where cif.cif = aaa.cif no-lock no-error.
            if avail cif then do:    
                   vpoint = integer(cif.jame) / 1000 - 0.5.
                   vdep1 = integer(cif.jame) - vpoint * 1000. 
                               if vdep = vdep1 then do:         
                                  find pay-table where pay-table.ch = joudoc.dracc and  pay-table.val = joudoc.crcur no-lock no-error.
                               if not avail pay-table then do:
                                      
                                     create pay-table.
                                            pay-table.sif = aaa.cif.
                                            pay-table.name = aaa.name.
                                            pay-table.ch = joudoc.dracc.
                                            pay-table.sta = aaa.sta. 
                                            pay-table.val = joudoc.crcur.
                                            pay-table.cod = sub-cod.ccode.
                               end.
                               
                                            pay-table.kol = pay-table.kol + 1. 
                                            pay-table.summ = pay-table.summ  + joudoc.cramt.

                
                               end.           
            end.  
       end. 
    end.
end.
      

for each remtrz where remtrz.rdt >= stime and remtrz.rdt <= endtime no-lock. 
  find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
    if avail aaa then do:
       find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = aaa.cif and sub-cod.d-cod = "clnsts" and sub-cod.ccode = v-face no-lock no-error.
         if avail sub-cod  then do: 
            find cif where cif.cif =  aaa.cif no-lock no-error.
              if avail cif then do: 
                   vpoint = integer(cif.jame) / 1000 - 0.5.
                   vdep1 = integer(cif.jame) - vpoint * 1000. 
                               if vdep = vdep1 then do:    
                                  find pay-table where pay-table.ch = remtrz.dracc and pay-table.rem = remtrz.source and pay-table.val = remtrz.tcrc no-lock no-error.
                               if not avail pay-table then do:  
                                     create pay-table.
                                            pay-table.sif = aaa.cif.
                                            pay-table.name = aaa.name.
                                            pay-table.rem = remtrz.source.
                                            pay-table.ch = remtrz.dracc.
                                            pay-table.sta = aaa.sta. 
                                            pay-table.val = remtrz.tcrc.
                                            pay-table.cod = sub-cod.ccode.
                               end.
                                            pay-table.kol = pay-table.kol + 1. 
                                            pay-table.summ = pay-table.summ  + remtrz.amt.
                               end.
              end.
         end.
    end.
end.
  

for each b-pay-table no-lock.
      find first pay-table where pay-table.sif = b-pay-table.sif and (pay-table.rem = 'IBH' or pay-table.rem = 'scn')  no-lock no-error. 
      if avail pay-table then do:
         for each pay-table where pay-table.sif = b-pay-table.sif.
             delete pay-table.
         end.
      end.
end.
    

output  to txt1.htm.

put unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.

put unformatted 
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr"">" skip
   " Отчет по простым платежам в период  с " string(stime) " по " string(endtime) "</FONT><BR><BR><BR>" skip

      "<TABLE> " skip
   "<TR align=""center"" valign=""top"">" skip
   "<TABLE width=""140%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
   "<TR align=""center"" valign=""top"">" skip.

put unformatted
     "<TD  bgcolor=""#95B2D1""><B>Номер</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Cif-код клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Наименование клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Номер счета клиента</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Код валюты</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Количество платежей</B></FONT></TD>" skip
     "<TD  bgcolor=""#95B2D1""><B>Сумма</B></FONT></TD>" skip
        
   "</TR>" skip.               

i = 0.
 for each pay-table where pay-table.kol >= 1 no-lock.

                 i = i + 1.
                 pay-table.num = i.
         put unformatted "<tr><td>" pay-table.num "</td>" skip
                          "<td><font size=""2""><b>" pay-table.sif "</b></font></td>" skip
                          "<td><b>" pay-table.name "</b></td>" skip
                          "<td>" pay-table.ch "</td>" skip
                          "<td>" pay-table.val "</td>" skip
                          "<td>" pay-table.kol "</td>" skip
                          "<td>" pay-table.summ "</td>"skip.
end. 
put unformatted "</TABLE>" skip.             
unix silent cptwin txt1.htm excel.

   


   
