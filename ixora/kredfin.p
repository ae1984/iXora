/* kredfin.p
 * MODULE
        Название Программного Модуля
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
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       07.06.2005 marinav отчетность берется из мониторинга
*/

{global.i}
def var crlf as char.
def var coun as int init 1.
def new shared var bilance   as decimal format '->,>>>,>>>,>>9.99'.

crlf = chr(10) + chr(13).

def temp-table wrk
    field cif    like lon.cif
    field adt    like lon.rdt
    field ddt    like lon.rdt.


find first cmp no-lock no-error.
define stream m-out.
output stream m-out to rpt.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" crlf
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" crlf
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 crlf.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 crlf. 


put stream m-out "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)' 
                 "</h3></td></tr><br><br>"
                 crlf crlf.

put stream m-out "<tr align=""center""><td><h3>Наличие отчетности по клиентам "
                 "</h3></td></tr><br><br>"
                 crlf crlf.

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" crlf
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Баланс</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Фин отчетность</td></tr>" crlf.

for each lon.


  run atl-dat (lon.lon,g-today,output bilance). /* остаток  ОД*/                        

  if bilance > 0 then do:
     find first sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = lon.cif and sub-cod.d-cod = 'clnsts' no-lock no-error.
     if sub-cod.ccode = '0'  then do:

      find first wrk where wrk.cif = lon.cif no-error.
      if not avail wrk then do:
         create wrk.
         wrk.cif = lon.cif.
         find last bal_cif where bal_cif.cif = lon.cif and bal_cif.nom begins 'a' use-index cif-rdt no-lock no-error.
         if  avail bal_cif then  wrk.adt = bal_cif.rdt.
                           else  wrk.adt = ?.
         find last bal_cif where bal_cif.cif = lon.cif and bal_cif.nom begins 'z' use-index cif-rdt no-lock no-error.
         if  avail bal_cif then  wrk.ddt = bal_cif.rdt.
                           else  wrk.ddt = ?.
      end.
  end. 
end.
end.

for each wrk break by wrk.adt. 
        
   
   find first cif where cif.cif = wrk.cif no-lock no-error.

    put stream m-out "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.cif "</td>"
               "<td align=""left""> " trim(cif.prefix) + " " + cif.name format "x(60)" "</td>"
               "<td align=""left""> " wrk.adt "</td>"
               "<td align=""left""> " wrk.ddt "</td></tr>" crlf.

    coun = coun + 1.
 
end.                       

put stream m-out "</table>" crlf.
output stream m-out close.

unix silent cptwin rpt.html excel.exe. 

