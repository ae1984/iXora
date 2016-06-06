/* alltoG.p
 * MODULE
        Автоматическое списание платежей с SWS на F 
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
        5-3-8
 * AUTHOR
        20.07.2004 tsoy 
 * CHANGES
        20.07.2004 tsoy Первые дни для тестирования выдается просто отчет для тестирования
        21.07.2004 tsoy Добавил контроль на банк и сумму
        02.08.2004 tsoy Расширил диапазон дат для поиска выписок на 3 дня
        08.09.2004 tsoy Убрал exclusive-lock 
*/

{global.i}
{lgps.i }
def temp-table  tmpr
  field tmpr_rdt     as    date 
  field tmpr_remtrz  as    char 
  field tmpr_amt     as    deci
  field tmpr_crc     as    integer
  field tmpr_fname   as    char 
  field tmpr_bname   as    char 
  field tmpr_is_go   as    logical .


def var v-clsday as date.

{ps-prmt.i}

find last cls no-lock.
if avail cls then 
    v-clsday =  cls.whn - 3. 
 else
    v-clsday =  g-today - 3. 


for each que where que.pid = "SWS"  and 
                   que.con <> "F" no-lock.

      find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.

      if not avail remtrz then next.
      create tmpr.
      assign                
          tmpr.tmpr_rdt     = remtrz.rdt
          tmpr.tmpr_remtrz  = remtrz.remtrz
          tmpr.tmpr_amt     = remtrz.amt
          tmpr.tmpr_crc     = remtrz.fcrc
          tmpr.tmpr_is_go        = false.
 
      for each swdt where swdt.rdt >= v-clsday and index (swdt.ref, remtrz.remtrz) > 0 no-lock.
     
           if remtrz.amt <> swdt.amt then next.

           find first swhd where swhd.rdt >= v-clsday and swhd.swid = swdt.swid no-lock no-error.
           
           /* Проверим на сумму */
           if remtrz.amt <> swdt.amt then next.

           /* Проверим на  банк */
           find first dfb where dfb.nostroacc = swhd.acc no-lock no-error.
                if avail dfb then do:
                        find first bankt where bankt.acc = dfb.dfb 
                                               and bankt.aut = true no-lock no-error.

                        if avail bankt then do:
                            if remtrz.rbank <> bankt.cbank then next.
                        end.
                        tmpr_bname   = remtrz.rbank.
                end.

           if trim(swhd.type) = "940" or trim(swhd.type) = "950" then do:                                
                tmpr.tmpr_fname  = swhd.fname.
                tmpr.tmpr_is_go  = true.

           end. 
     end.
end.

for each tmpr where tmpr_is_go = true.
       do transaction:
             find first que where que.remtrz = tmpr.tmpr_remtrz exclusive-lock no-error .
             find  first  remtrz  where remtrz.remtrz = tmpr.tmpr_remtrz exclusive-lock no-error.
            
             if avail que then do :
               que.ptype = remtrz.ptype . 
               que.pid   = m_pid.
               que.rcod  = "0" .
               
               v-text = " Авт. Отсылка  " + remtrz.remtrz + " по маршруту , тип = " 
                          + remtrz.ptype + " код возврата = " + que.rcod  .

               run lgps.
               
               que.con = "F".
               que.dp  = today.
               que.tp  = time.

              release que .
              release remtrz.
             end.
       end.
end.


define stream m-out.
output stream m-out to tmpr.html.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3>Платежи <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip. 
       put stream m-out unformatted "<tr style=""font:bold"">"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Платеж</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Банк</td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Файл</td>"
                         "</tr>" skip.



for each tmpr break by tmpr_is_go.


if first-of(tmpr_is_go) then  do:
    if tmpr_is_go then 
                   put stream m-out  unformatted "<tr>"
                   "<td colspan = ""5"" >Платежи которые были проведены автоматически </td>"  skip
                   "</tr>" skip.
    else
                   put stream m-out  unformatted "<tr>"
                   "<td colspan = ""5"" >Платежи по котрым выписка не найдена  </td>"  skip
                   "</tr>" skip.
end.

put stream m-out  unformatted "<tr>"
                   "<td>" tmpr.tmpr_rdt          "</td>"  skip
                   "<td>" tmpr.tmpr_remtrz       "</td>"  skip
                   "<td>" replace(trim(string(tmpr.tmpr_amt, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")      "</td>"  skip
                   "<td>" tmpr.tmpr_crc          "</td>"  skip
                   "<td>" tmpr.tmpr_bname        "</td>"  skip
                   "<td>" tmpr.tmpr_fname        "</td>"  skip
                   "</tr>" skip.

end.


put stream m-out unformatted
"</table>". 

output stream m-out close.
unix silent cptwin tmpr.html excel.


