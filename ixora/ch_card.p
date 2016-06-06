/* ch_card.p
 * MODULE
        Гарантии
 * DESCRIPTION
        История изменения карточки
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
        30.09.2011 lyubov
 * CHANGES


*/


{global.i}
{lonlev.i}

define stream m-out.
output stream m-out to ch_card.html.

def var paraksts as logi.
def var bilance as integer.

def var dam1-cam1 as decimal.

def temp-table t-data no-undo
  field cif         like gar%his.cif
  field cif-name    as char
  field garan       like gar%his.garan
  field dtfrom      like gar%his.dtfrom
  field dtto        like gar%his.dtto
  field whn         like gar%his.whn
  field sum         like gar%his.sum
  field garnum      like gar%his.garnum
  field who         as char
  field crc         like gar%his.crc
  field crcname     as char
  field rem         like ln%his.rem.

def shared var s-lon like gar%his.garan.


for each gar%his where gar%his.garan = s-lon no-lock.

                 create t-data.
                     assign
                     t-data.cif     = gar%his.cif
                     t-data.garan   = gar%his.garan
                     t-data.who     = gar%his.who
                     t-data.dtfrom  = gar%his.dtfrom
                     t-data.dtto    = gar%his.dtto
                     t-data.whn     = gar%his.whn
                     t-data.sum     = gar%his.sum
                     t-data.garnum  = gar%his.garnum
                     t-data.crc     = gar%his.crc
                     t-data.rem     = gar%his.rem .



                     find first crc where crc.crc = gar%his.crc no-lock no-error.
                     if avail crc then do:
                            t-data.crcname  = crc.code.
                     end.


                     find first cif where cif.cif  = gar%his.cif no-lock no-error.
                     if avail cif then  do:
                        cif-name = cif.name.
                     end.

end.




put stream m-out unformatted "<html><head><title>METROCOMBANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<h3>История изменения карточки. <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.
       put stream m-out unformatted "<tr style=""font:bold"">"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Счет              </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Договор           </td>"

                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата изм.  </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата нач.         </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Дата кон.         </td>"
                         "<td bgcolor=""#C0C0C0"" align=""center"">Сумма             </td>"

                         "<td bgcolor=""#C0C0C0"" align=""center"">Сотрудник         </td>"

                         "<td bgcolor=""#C0C0C0"" align=""center"">Валюта            </td>"

                         "<td bgcolor=""#C0C0C0"" align=""center"">Примечание        </td>"
                         "</tr>" skip.




put stream m-out  unformatted "<tr>"
                   "<td colspan =""9""><b style=""font:bold;color:red"">" t-data.cif-name " " t-data.cif

                   /*" Остаток: " replace(trim(string(dam1-cam1,  "->>>>>>>>>>>>>>>>>>>>9.99")),".",",")*/
                   "</b></td>"  skip
                   "</tr>" skip.


for each t-data no-lock break by t-data.whn:

       put stream m-out unformatted "<tr>"
                         "<td>'" t-data.garan                                                              "</td>"
                         "<td>'" t-data.garnum                                                             "</td>"

                         "<td>" string(t-data.whn, "99.99.9999" )                                          "</td>"
                         "<td>" string(t-data.dtfrom, "99.99.9999" )                                       "</td>"
                         "<td>" string(t-data.dtto, "99.99.9999" )                                         "</td>"
                         "<td>" replace(trim(string(t-data.sum,  "->>>>>>>>>>>>>>>>>>>>9.99")),".",",") "</td>"

                         "<td>" t-data.who           "</td>"

                         "<td>" t-data.crcname       "</td>"

                         "<td>" t-data.rem           "</td>"
                         "</tr>" skip.

end.

put stream m-out unformatted
"</table>".
output stream m-out close.
unix silent cptwin ch_card.html excel.
