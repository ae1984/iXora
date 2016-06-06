/* r-lnapg2.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Обороты по счетам за период по группам
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
        03/12/2004 madiar
 * CHANGES
*/

{mainhead.i}

def temp-table wrk
  field cif         like lon.cif
  field klname      as   char
  field lon         like lon.lon
  field crc         like lon.crc
  field dtspis      as   date
  field sum         as   deci extent 3
  field all_kzt     as   deci
  index ind is primary cif.

def stream rep.
def var dat as date.
def var b-dat as date.
def var bb as deci extent 3.
def var i as integer.
def var coun as integer.
def var usrnm as char.

dat = g-today.
update dat label ' Отчет на дату ' format '99/99/9999'
       validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
       with side-label row 5 centered frame dat.

message " Формируется отчет... ".

for each lon no-lock:
  
  if lon.opnamt = 0 then next.
  
  find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "kdlost" no-lock no-error.
  if avail sub-cod then do:
     if sub-cod.ccode = '01' then do:
        
        /*
        run lonbal('lon',lon.lon,dat,"13",no,output bb[1]).
        run lonbal('lon',lon.lon,dat,"14",no,output bb[2]).
        run lonbal('lon',lon.lon,dat,"30",no,output bb[3]).
        */
        
        bb = 0. b-dat = ?.
        for each lonres where lonres.lon = lon.lon no-lock:
          if lonres.dc = "C" and lonres.jdt < dat then do:
            if lonres.lev = 13 then do: bb[1] = bb[1] + lonres.amt. if b-dat = ? then b-dat = lonres.jdt. end.
            if lonres.lev = 14 then do: bb[2] = bb[2] + lonres.amt. if b-dat = ? then b-dat = lonres.jdt. end.
            if lonres.lev = 30 then do: bb[3] = bb[3] + lonres.amt. if b-dat = ? then b-dat = lonres.jdt. end.
          end.
        end.
        
        if bb[1] + bb[2] + bb[3] <> 0 then do:
          create wrk.
          wrk.cif = lon.cif.
          find cif where cif.cif = lon.cif no-lock no-error.
          if avail cif then wrk.klname = trim(cif.prefix) + ' ' + trim(cif.name).
          else wrk.klname = "--не найдено--".
          wrk.lon = lon.lon.
          wrk.crc = lon.crc.
          do i = 1 to 3: wrk.sum[i] = bb[i]. end.
          wrk.dtspis = b-dat.
        end.
        
     end.
   end.
  
end. /* for each lon */

output stream rep to rep.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

put stream rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Потерянные кредиты на " dat format "99/99/9999" "</b></center><BR><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
    "<td><BR>пп</td>" skip
    "<td>Код<BR>заемщика</td>" skip
    "<td><BR>Наименование заемщика</td>" skip
    "<td><BR>Ссудный счет</td>" skip
    "<td>Валюта<BR>займа</td>" skip
    "<td>Дата<BR>списания</td>" skip
    "<td>Сумма<BR>спис ОД</td>" skip
    "<td>Сумма<BR>спис %%</td>" skip
    "<td>Сумма<BR>спис штрафов</td>" skip
    "<td>Итого<BR>экв в KZT</td>" skip
    "</tr>" skip.

coun = 1.

for each wrk no-lock:
  find last crchis where crchis.crc = wrk.crc and crchis.regdt < wrk.dtspis no-lock no-error.
  put stream rep unformatted
    "<tr>" skip
    "<td>" coun "</td>" skip
    "<td>" wrk.cif "</td>" skip
    "<td>" wrk.klname "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" crchis.code "</td>" skip
    "<td>" wrk.dtspis format "99/99/9999" "</td>" skip
    "<td>" replace(string(wrk.sum[1], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sum[2], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sum[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "<td>" replace(string(wrk.sum[1] * crchis.rate[1] + wrk.sum[2] * crchis.rate[1] + wrk.sum[3], ">>>>>>>>>>>>>>9.99"),'.',',') "</td>" skip
    "</tr>" skip.
  coun = coun + 1.
end. /* for each wrk */

put stream rep unformatted "</table></body></html>".
output stream rep close.

hide message no-pause.

unix silent cptwin rep.htm excel.
