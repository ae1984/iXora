/* lnchkgl.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Сверочный отчет по кредитным счетам ГК
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
        03/02/2005 madiar
 * CHANGES
*/

def temp-table wrk
  field gl like gl.gl
  field crc like crc.crc
  field sum_gl as deci
  field dam as deci
  field cam as deci
  field sum_lon as deci
  index gl_idx is primary gl
  index glcrc_idx is unique gl crc.

def var v-bal as deci.
def shared var g-today as date.
def stream rep.
def var mesa as integer.

for each gl where gl.subled = 'lon' no-lock:
  for each crc no-lock:
    create wrk.
    wrk.gl = gl.gl.
    wrk.crc = crc.crc.
    find first glbal where glbal.gl = gl.gl and glbal.crc = crc.crc no-lock no-error.
    if avail glbal then do:
      wrk.sum_gl = glbal.dam - glbal.cam.
      for each jl where jl.jdt = g-today and jl.crc = crc.crc and jl.gl = gl.gl no-lock:
        wrk.dam = wrk.dam + jl.dam.
        wrk.cam = wrk.cam + jl.cam.
      end.
    end.
  end.
end.

mesa = 0.


for each lon no-lock:
  
  for each trxbal where trxbal.subled = "lon" and trxbal.acc = lon.lon no-lock:
    
    if trxbal.dam - trxbal.cam = 0 then next.
    find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = trxbal.level no-lock no-error.
    find first wrk where wrk.gl = trxlevgl.glr and wrk.crc = trxbal.crc no-error.
    wrk.sum_lon = wrk.sum_lon + trxbal.dam - trxbal.cam.
    
  end.
  
  mesa = mesa + 1.
  hide message no-pause.
  message " " mesa " ".
  
end. /* for each lon */


for each wrk:
  if wrk.sum_gl = 0 and wrk.sum_lon = 0 then delete wrk.
/*  else do:
    wrk.sum_gl = absolute(wrk.sum_gl).
    wrk.sum_lon = absolute(wrk.sum_lon).
  end.*/
end.

output stream rep to rep.htm.
put stream rep unformatted
     "<html><head><title>TEXAKABANK</title>" skip
     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip
     "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
     "<tr bgcolor=""#C0C0C0"" style=""font:bold"" align=""center"">" skip
     "<td>Счет ГК</td>" skip
     "<td>Валюта</td>" skip
     "<td>Баланс (утро)</td>" skip
     "<td>Дебет</td>" skip
     "<td>Кредит</td>" skip
     "<td>Баланс (тек)</td>" skip
     "<td>Кредитный модуль</td>" skip
     "<td>Расхождение</td>" skip
     "</tr>" skip.

for each wrk no-lock:
  
  find crc where crc.crc = wrk.crc no-lock no-error.
  put stream rep unformatted
           "<tr>" skip
           "<td>" wrk.gl "</td>" skip
           "<td>" crc.code "</td>" skip
           "<td>" replace(trim(string(wrk.sum_gl)),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk.dam)),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk.cam)),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk.sum_gl + wrk.dam - wrk.cam)),'.',',') "</td>" skip
           "<td>" replace(trim(string(wrk.sum_lon)),'.',',') "</td>" skip
           "<td>" if wrk.sum_gl + wrk.dam - wrk.cam <> wrk.sum_lon then replace(trim(string(wrk.sum_gl + wrk.dam - wrk.cam - wrk.sum_lon)),'.',',') else "" "</td>" skip
           "</tr>" skip.
  
end. /* for each wrk */

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm excel.
