/* pkpros.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Анализ просроченных кредитов для управленческой
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
        29/07/2009 galina
 * BASES
        BANK COMM
 * CHANGES
       02/09/2009 galina - исправила наименование выходного файла
       24/09/2009 galina - исправила наименование выходного файла
*/


{global.i}
def var dat as date no-undo.
def var bdat as date no-undo.
def var i as integer no-undo.

def var v-com as deci no-undo.
def var v-com1 as deci no-undo.
def var v-od as deci no-undo.
def var v-od1 as deci no-undo.
def var v-prc as deci no-undo.
def var v-prc1 as deci no-undo.
def var v-pen as deci no-undo.
def var v-pen1 as deci no-undo.

def var v-sumvyd as deci no-undo.
def var v-amtvyd as deci no-undo. 
def var v-sumport as deci no-undo. 

/*выданные кредиты*/
def new shared temp-table pkvyd
  field sum as decimal
  field amt as integer
  field bank as char.

/*кредитный потфель*/
def new shared temp-table pkport
  field sum as decimal
  field bank as char.    

/*просроченные долг*/
def new shared temp-table pkpros
  field bank as char
  field sum_od as decimal
  field sum_prc as decimal
  field sum_pen as decimal
  field sum_com as decimal
  field sum_od1 as decimal
  field sum_prc1 as decimal
  field sum_pen1 as decimal
  field sum_com1 as decimal.

  
def stream rep.


dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999'
validate (dat <= g-today, " Дата должна быть не позже текущей! ") skip
with side-label row 5 centered frame dat.


def var vdate as integer no-undo.
def var vmont as integer no-undo.
def var vquar as integer no-undo.
def var vyear as integer no-undo.
def var vfname as char no-undo.
def var v-exist as char no-undo.

vdate = DAY (dat).
vmont = MONTH (dat).
vyear = YEAR (dat).
vquar = 0.
case vmont:
   when 1 OR 
   when 2 OR 
   when 3 then vquar = 1.
        
   when 4 OR 
   when 5 OR 
   when 6 then vquar = 2.

   when 7 OR 
   when 8 OR 
   when 9 then vquar = 3.

   when 10 OR 
   when 11 OR 
   when 12 then vquar = 4.
end.

vfname = "/data/reports/push/bmkb/" + "pkpros" + "-" + string(vyear) + "-" + string(vmont) + "-" + string(vquar) + "-" + string(vdate) + ".html".          

input through value( "find " + vfname + ";echo $?").
repeat:
  import unformatted v-exist.
end.

if v-exist = "0" then do:
   unix silent cptwin value(vfname) excel.
   return.
end.    

if dat <> g-today then message 'Комиссионый долг будет выведен на текущую дату'  view-as alert-box title 'ВНИМАНИЕ'.

    
message "Формируется отчет...".
for each comm.txb where comm.txb.consolid no-lock.
 
  if connected ("txb") then disconnect "txb".
  connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
  run pkpros1(txb.bank, dat).
  disconnect "txb".
end.   
output stream rep to value(vfname).
{html-title.i
 &title = "METROCOMBANK" 
 &stream = "stream rep" 
 &size-add = "x-"}
 put stream rep unformatted
 "<center><b>Анализ просроченных потребительских кредитов на " dat format "99/99/9999" "<br>(физические лица)</b></center><BR>" skip
 "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr style=""font:bold"">" skip
 "<td rowspan = ""2"">Просросроченные кредиты</td>" skip
 "<td colspan = ""2"" align=""center"" >"string(dat,'99.99.9999')"</td>" skip.
 put stream rep unformatted
 "<tr>" skip

 "<td align=""center"" >Сумма</td>" skip
 "<td align=""center"" >Количество</td>" skip
 "<td align=""center"" >Удел. вес,%</td>" skip.

v-sumvyd = 0.
v-amtvyd = 0.
v-sumport = 0.

for each pkvyd:
  v-sumvyd = v-sumvyd + pkvyd.sum.
  v-amtvyd = v-amtvyd +  pkvyd.amt.
end.

for each pkport:
 v-sumport = v-sumport + pkport.sum.
end.

v-com = 0.
v-com1 = 0.
v-od = 0.
v-od1 = 0.
v-prc = 0.
v-prc1 = 0.
v-pen = 0.
v-pen1 = 0.
for each pkpros:
  v-com = v-com + pkpros.sum_com.
  v-od = v-od + pkpros.sum_od.
  v-prc = v-prc + pkpros.sum_prc.
  v-pen =  v-pen + pkpros.sum_pen.
  v-com1 = v-com1 + pkpros.sum_com1.
  v-od1 = v-od1 + pkpros.sum_od1.
  v-prc1 = v-prc1 + pkpros.sum_prc1.
  v-pen1 =  v-pen1 + pkpros.sum_pen1.
end.

put stream rep unformatted
"<tr style=""font:bold"">" skip
"<td>Консолидированный</td>" skip
"<td>" replace(trim(string(v-sumvyd, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" v-amtvyd "</td>" skip
"<td>" replace(trim(string(round(v-sumvyd * 100 / v-sumport, 2), "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.

for each txb where txb.consolid no-lock break by txb.info: 
  find first pkvyd where pkvyd.bank = txb.bank.
  find first pkport where pkport.bank = txb.bank.
  put stream rep unformatted "<tr>" skip
  "<td>" txb.info "</td>" skip
  "<td>" replace(trim(string(pkvyd.sum, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" pkvyd.amt "</td>" skip
  "<td>" replace(trim(string(round(pkvyd.sum * 100 / pkport.sum, 2), "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
end.
put stream rep unformatted "</table><br><br>" skip.


put stream rep unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip
 "<tr align=""center"" style=""font:bold"">" skip
 "<td rowspan = ""3"">Просроченный долг</td>" skip
 "<td colspan = ""12"">" string(dat,'99.99.9999') "</td></tr>" skip.
 
put stream rep unformatted "<tr style=""font:bold"" align=""center"">" skip
 "<td colspan = ""5""> до 30 дней </td>" skip
 "<td colspan = ""5""> свыше 30 дней </td>" skip
 "<td rowspan = ""2""> Всего </td>" skip
 "<td rowspan = ""2""> Удел.вес к портф.%% </td></tr>" skip.
put stream rep unformatted "<tr align=""center"" style=""font:bold"">" skip.
do i = 1 to 2:
  put stream rep unformatted 
  
  "<td>ОД</td>" skip
  "<td>%%</td>" skip
  "<td>Комиссия</td>" skip
  "<td>Пеня</td>" skip
  "<td>Итого</td>" skip.
end. 
put stream rep unformatted "</tr><tr style=""font:bold"">" skip
"<td>Консолидированный</td>" skip
"<td>" replace(trim(string(v-od, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-prc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-com, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-pen, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-od + v-prc + v-com + v-pen, "->>>>>>>>>>>9.99")),".",",") "</td>" skip

"<td>" replace(trim(string(v-od1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-prc1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-com1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-od1 + v-prc1 + v-com1 + v-pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(v-od + v-prc + v-com + v-pen + v-od1 + v-prc1 + v-com1 + v-pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
"<td>" replace(trim(string(round((v-od + v-prc + v-com + v-pen + v-od1 + v-prc1 + v-com1 + v-pen1) * 100 / v-sumport , 2), "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.

for each txb where txb.consolid no-lock break by txb.info:
  find pkpros where pkpros.bank = txb.bank no-lock no-error.
  find pkport where pkport.bank = txb.bank no-lock no-error.
  if not avail pkpros or not avail pkport then next.
  put stream rep unformatted "<tr>" skip
  "<td>" txb.info "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_od, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_prc, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_com, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_pen, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_od + pkpros.sum_prc + pkpros.sum_com + pkpros.sum_pen, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
    
  "<td>" replace(trim(string(pkpros.sum_od1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_prc1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_com1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_od1 + pkpros.sum_prc1 + pkpros.sum_com1 + pkpros.sum_pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(pkpros.sum_od + pkpros.sum_prc + pkpros.sum_com + pkpros.sum_pen + pkpros.sum_od1 + pkpros.sum_prc1 + pkpros.sum_com1 + pkpros.sum_pen1, "->>>>>>>>>>>9.99")),".",",") "</td>" skip
  "<td>" replace(trim(string(round((pkpros.sum_od + pkpros.sum_prc + pkpros.sum_com + pkpros.sum_pen + pkpros.sum_od1 + pkpros.sum_prc1 + pkpros.sum_com1 + pkpros.sum_pen1) * 100 / v-sumport , 2), "->>>>>>>>>>>9.99")),".",",") "</td></tr>" skip.
end.

put stream rep unformatted "</table><br><br>" skip.
 
{html-end.i "stream rep"}
output stream rep close.
hide message no-pause.
unix silent cptwin value (vfname) excel.