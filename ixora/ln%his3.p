/* ln%his3.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        ОТчет по неподписанным выданным кредитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        01.09.2004 tsoy
 * CHANGES
        03.09.2004 tsoy Добавил день погашения и Ответсвенного
        08.09.2004 tsoy Добавил код клиента 
        09.09.2004 tsoy Добавил Остаток
        07/04/2006 NatalyaD. - добавила сортировку по полю f0
        06/08/2009 galina - выводим внебал.ставку по шрафам

*/


{global.i}
{lonlev.i}

define stream m-out.
output stream m-out to ln%his3.html.

def var paraksts as logi.
def var bilance as integer.

def var dam1-cam1 as decimal.

def temp-table t-data
  field cif         like lon.cif
  field cif-name    as char
  field lon         like lon.lon
  field sts         as logi
  field f0          like ln%his.f0  
  field rdt         like ln%his.rdt 
  field duedt       like ln%his.duedt 
  field stdat       like ln%his.stdat 
  field opnamt      like ln%his.opnamt 
  field intrate     like ln%his.intrate 
  field long1       like ln%his.long1
  field long2       like ln%his.long2 
  field lcnt        like ln%his.lcnt 
  field gua         like ln%his.gua 
  field grp         like ln%his.grp 
  field pnlt1       like ln%his.pnlt1 
  field pnlt2       like ln%his.pnlt2 
  field comln       like ln%his.comln 
  field kcrc        like ln%his.kcrc 
  field kcrcname    as char 
  field who         as char 
  field drate       like ln%his.drate
  field plan        like  lon.plan
  field crc         like  lon.crc
  field crcname     as char 
  field object      like  loncon.objekts
  field ldate       as date
  field proc-no     like ln%his.proc-no
  field rem         like ln%his.rem
  field day         like ln%his.day          
  field pase-pier   like ln%his.pase-pier.

def shared var s-lon like lnsch.lnn.


for each lon where lon.lon = s-lon no-lock.
  
               for each ln%his where ln%his.lon = lon.lon and ln%his.cif = lon.cif no-lock by ln%his.f0.
                 create t-data.
                     assign
                     t-data.cif     = lon.cif              
                     t-data.lon     = lon.lon            
                     t-data.sts     = no
                     t-data.who     = ln%his.who
                     t-data.f0      = ln%his.f0          
                     t-data.rdt     = ln%his.rdt         
                     t-data.duedt   = ln%his.duedt       
                     t-data.stdat   = ln%his.stdat       
                     t-data.opnamt  = ln%his.opnamt      
                     t-data.intrate = ln%his.intrate     
                     t-data.long1   = ln%his.long1       
                     t-data.long2   = ln%his.long2       
                     t-data.lcnt    = ln%his.lcnt        
                     t-data.gua     = ln%his.gua         
                     t-data.grp     = ln%his.grp         
                     t-data.pnlt1   = ln%his.pnlt1       
                     t-data.pnlt2   = ln%his.pnlt2       
                     t-data.comln   = ln%his.comln       
                     t-data.drate   = ln%his.drate      
                     t-data.kcrc    = ln%his.kcrc        
                     t-data.plan    = ln%his.plan        
                     t-data.crc     = ln%his.crc         
                     t-data.object  = ln%his.object      
                     t-data.ldate   = ln%his.ldate       
                     t-data.proc-no = ln%his.proc-no
                     t-data.rem     = ln%his.rem
                     t-data.day       =  ln%his.day       
                     t-data.pase-pier = ln%his.pase-pier.



                     find first crc where crc.crc = ln%his.kcrc no-lock no-error.
                     if avail crc then do:
                            t-data.kcrcname  = crc.code.
                     end.

                     find first crc where crc.crc = ln%his.crc no-lock no-error.
                     if avail crc then do:
                            t-data.crcname  = crc.code.
                     end.


                     find first cif where cif.cif  = lon.cif no-lock no-error.
                     if avail cif then  do:
                        cif-name = cif.name. 
                     end.

               end.
end.
 
                 
                 



put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3>История изменения карточки. <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip. 
       put stream m-out unformatted "<tr style=""font:bold"">"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Счет              </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Договор           </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Вид               </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата Редактировния  </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата нач.         </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата кон.         </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Сумма             </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Ставка            </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Пролонг1          </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Пролонг1          </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Штраф%(выб)       </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Штраф%внебал       </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Группа            </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия          </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Валюта индексации </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Курс договора     </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Сотрудник         </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Схема             </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Валюта            </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Объект            </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Выплата с        </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Выбрать до        </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">День расчета    </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Ответственный      </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Причина           </td>"
                         "</tr>" skip.

for each t-data break by t-data.cif by t-data.lon by t-data.f0:

if first-of(t-data.lon) then do:

dam1-cam1 = 0.

for each trxbal where trxbal.subled = "LON" 
                      and trxbal.acc = t-data.lon no-lock :

    if lookup(string(trxbal.level) , v-lonprnlev , ";") > 0 then
       dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam).
end.


put stream m-out  unformatted "<tr>"
                   "<td colspan =""22""><b style=""font:bold;color:red"">" t-data.cif-name " " t-data.cif 
                   
                   " Остаток: " replace(trim(string(dam1-cam1,  "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")
                   "</b></td>"  skip
                   "</tr>" skip.
end.

       put stream m-out unformatted "<tr>"
                         "<td>'" t-data.lon                                                                "</td>"
                         "<td>" t-data.lcnt        "</td>"
                         "<td>" t-data.gua         "</td>"
                         "<td>" string(t-data.stdat, "99.99.9999" )                                        "</td>"
                         "<td>" string(t-data.rdt, "99.99.9999" )                                          "</td>"
                         "<td>" string(t-data.duedt, "99.99.9999" )                                        "</td>"
                         "<td>" replace(trim(string(t-data.opnamt,  "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                         "<td>" replace(trim(string(t-data.intrate, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"
                         "<td>" if t-data.long1 = ? then "" else string(t-data.long1, "99.99.9999" )       "</td>"
                         "<td>" if t-data.long2 = ? then "" else  string(t-data.long2, "99.99.9999" )      "</td>"
                         "<td>" replace(trim(string(t-data.pnlt1, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")   "</td>"
                         "<td>" replace(trim(string(t-data.pnlt2, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")   "</td>"
                         "<td>" string(t-data.grp)   "</td>"
                         "<td>" replace(trim(string(t-data.comln, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")   "</td>"
                         "<td>" t-data.kcrcname                                                            "</td>"
                         "<td>" replace(trim(string(t-data.drate, "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")   "</td>"
                         "<td>" t-data.who           "</td>"
                         "<td>" string(t-data.plan)  "</td>"
                         "<td>" t-data.crcname       "</td>"
                         "<td>" t-data.object        "</td>"
                         "<td>" t-data.proc-no       "</td>"
                         "<td>" if t-data.ldate = ? then "" else  string(t-data.ldate, "99.99.9999" )          "</td>"
                         "<td>"  string(t-data.day)          "</td>" 
                         "<td>"  t-data.pase-pier    "</td>" 
                         "<td>" t-data.rem           "</td>"
                         "</tr>" skip.

end.
put stream m-out unformatted
"</table>". 
output stream m-out close.
unix silent cptwin ln%his3.html excel.
