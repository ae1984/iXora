/* clnclst.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Отчет для карточников - статистика по погашенным кредитам
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
        13/06/2005 madiar
 * CHANGES
        16/06/2005 madiar - убрал отладочное сообщение, добавил поле wrk.cards
        14.07.2005 marinav - добавлено адреса, телефоны, уд личности, Рко
        15/09/2005 madiar - автоматическое формирование списка групп кредитов юр. лиц
        10.11.2005 marinav  - задается период в который кредиты погащены
                              добавлен СИК и признак, если сотрудник банка
                              если есть 2 погашенных кредита, то выводить последний
                              если есть еще и непогашенные кредиты, то не показывать клиента вообще
        05/05/2006 NatalyaD. - добавила поле "Наличие дебетной карточки" и изменяла алгоритм расчета количества просрочек
                               максимального количества днеей просрочки
        06/06/2006 NatalyaD. - добавила поле "Код СПФ"
*/

{global.i}
{is-wrkday.i}

/* группы кредитов юридических лиц */
def var lst_ur as char init ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
end.

def var bilance as deci.
def var v-bal as deci.
def var v-ln as integer.
def var usrnm as char.
def var p-coun as integer.
def var p-days as integer.
def var dayc1 as integer.
def var tempost as deci.
def var tempdt as date.
def var mesa as integer init 0.
def var dat_wrk as date.
def var last_cls as date.
DEF VAR vdep as inte.
DEF VAR vpoint as inte.
def var v-max as int.
def var v-fio as char.
def buffer bjl for jl.
find last cls where cls.del no-lock.
last_cls = cls.whn.

define var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

define temp-table wrk
  field cif like cif.cif
  field lname1 as char
  field fname1 as char
  field mname1 as char
  field lname2 as char
  field fname2 as char  
  field rnn as char
  field lon like lon.lon
  field crc like crc.crc
  field opnamt as deci
  field rdt as date
  field duedt as date
  field dt_cl as date
  field pr_num as integer
  field pr_longest as integer
  field wrk_plc as char
  field position as char
  field experience as char
  field bdt as date
  field income_gcvp as deci
  field card as char
  field dcrd as char
  field addr1 as char
  field addr2 as char
  field tel as char
  field udl as char
  field rko as char
  field rko_cod as int
  field sik as char
  field sotr as char
  index idx is primary cif lon.

def buffer b-lnsch for lnsch.
def buffer b-lon for lon.

define variable datums  as date format '99/99/9999'.
define variable datums1  as date format '99/99/9999'.
define var flag as logi init false.

datums = 11/11/05.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

message " Отчет формируется ".

for each lon /*where lon.lon = "127157403"*/ where lon.grp = 90 or lon.grp = 92 no-lock:
  
  if lon.opnamt <= 0 then next.
  if lookup(string(lon.grp),lst_ur) > 0 then next.  

  run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output bilance).
  if bilance > 0 then next.
  
  /* дата фактического закрытия кредита */
  find last lonres where lonres.lon = lon.lon and (lonres.lev = 1 or lonres.lev = 7) and lonres.dc = "C" no-lock no-error.
  if not avail lonres or lonres.jdt < datums or lonres.jdt > datums1 then next.  

  /*Если есть хоть один непогашенный кредит , то выходим*/
  flag = false.
  for each b-lon where b-lon.cif = lon.cif no-lock.
      run lonbalcrc('lon',b-lon.lon,g-today,"1,7",yes,b-lon.crc,output bilance).
      if bilance > 0 then flag = true.
  end.
  if flag = true then next.

  /*если есть кредит погашенный ранее, то его убираем*/
  find first wrk where wrk.cif = lon.cif no-error.
  if avail wrk then do:
      if wrk.dt_cl < lonres.jdt then delete wrk.
  end.  

  find cif where cif.cif = lon.cif no-lock no-error.
  if (trim(cif.ref[8]) matches '*Texakabank*') or (trim(cif.ref[8]) matches '*Тексакабанк*') then next.

  find pkbadlst where pkbadlst.rnn = cif.jss no-lock no-error.
  if avail pkbadlst then next.

  find last card_status where card_status.rnn = cif.jss and substring(card_status.scheme_name,1,2) = 'Cr' 
                          and card_status.expires > datums1 no-lock no-error.
  if avail card_status then next. 
 
  v-fio = replace(trim(cif.name),' ',',').
  create wrk.
  wrk.cif = lon.cif.
  wrk.lname1 = entry(1,v-fio).
  wrk.fname1 = entry(2,v-fio).
  wrk.mname1 = entry(3,v-fio).
  wrk.rnn = cif.jss.
  wrk.lon = lon.lon.
  wrk.crc = lon.crc.
  wrk.opnamt = lon.opnamt.
  wrk.rdt = lon.rdt.
  wrk.duedt = lon.duedt.
  wrk.addr1 = cif.addr[1].
  wrk.addr2 = cif.addr[2].
  wrk.tel = cif.tel + ';' + cif.tlx + ';' + cif.fax.
  wrk.udl = cif.pss.
  wrk.dt_cl = lonres.jdt. 

  vpoint = integer(cif.jame) / 1000 - 0.5.
  vdep = integer(cif.jame) - vpoint * 1000. 

  find ppoint where ppoint.dep = vdep no-lock no-error.
  if available ppoint then do:
     wrk.rko = ppoint.name .
     wrk.rko_cod = ppoint.depart.
  end.
  if lon.ddt[5] <> ? then wrk.duedt = lon.ddt[5].
  if lon.cdt[5] <> ? then wrk.duedt = lon.cdt[5].
  

  /* просрочки */
  
  p-coun = 0. p-days = 0. v-max = 0.

  /*for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
    
    if lnsch.stdat > last_cls then next.
    /* рабочий ил не рабочий день - сохраняется в cls.del только с мая 2004 */
    if lnsch.stdat > 05/10/2004 then do:
      find first cls where cls.whn >= lnsch.stdat and cls.del no-lock no-error.
      if not avail cls then dat_wrk = lnsch.stdat.
    end.
    else do:
      dat_wrk = lnsch.stdat.
      repeat:
        if is-working-day(dat_wrk) then leave.
        else dat_wrk = dat_wrk + 1.
      end.
    end.
    
    run lonbalcrc('lon',lon.lon,dat_wrk,"7",yes,lon.crc,output v-bal).
    if v-bal > 0 then do:
      
/*message dat_wrk view-as alert-box buttons ok.*/  /***/
      
      if v-bal <= lnsch.stval then do: /* если просрочка v-bal > суммы по графику - значит эту просрочку мы уже посчитали */
        p-coun = p-coun + 1.
        tempost = 0.
        tempdt = dat_wrk + 1.
        dayc1 = 0.
        for each lonres where lonres.lon = lon.lon and lonres.jdt > dat_wrk no-lock:
          if not(lonres.dc = 'c' and lonres.lev = 7) then next.
          tempost = tempost + lonres.amt.
          for each b-lnsch where b-lnsch.lnn = lon.lon and b-lnsch.f0 > 0 and b-lnsch.stdat >= tempdt and b-lnsch.stdat < lonres.jdt no-lock:
            v-bal = v-bal + b-lnsch.stval.
          end.
          if tempost >= v-bal then do:
            dayc1 = lonres.jdt - cls.whn.
            leave.
          end.
          tempdt = lonres.jdt.
        end. /* for each lonres */
        if p-days < dayc1 then p-days = dayc1.
      end. /* if v-bal <= lnsch.stval */
        
    end. /* if v-bal > 0 */
    
  end. /* for each lnsch */
*/
  for each jl where jl.jdt < g-today and jl.lev = 7 and jl.subled = 'LON' and jl.acc = lon.lon and jl.dc = 'd' no-lock.
 find first bjl where bjl.jdt > jl.jdt and bjl.lev = 7 and bjl.subled = 'LON' and bjl.acc = jl.acc and bjl.dc = 'c' no-lock
no-error.
 p-coun = p-coun + 1.
 p-days = bjl.jdt - jl.jdt.
 v-max = max(v-max,p-days).
end.

  
  wrk.pr_num = p-coun.
  wrk.pr_longest = v-max.
  /*if wrk.dt_cl - wrk.duedt > p-days then wrk.pr_longest = wrk.dt_cl - wrk.duedt.
                                    else wrk.pr_longest = p-days.*/
/*displ p-days wrk.dt_cl wrk.duedt.*/
  if p-coun > 1 or p-days > 30 then do:
     delete wrk.
     next.
  end.
  
  if lon.grp = 90 or lon.grp = 92 then do:
    v-ln = -1.
    for each pkanketa where pkanketa.lon = lon.lon no-lock:
         if pkanketa.bank = s-ourbank then do:
           v-ln = pkanketa.ln.
           leave.
         end.
    end. /* for each pkanketa */
    if v-ln > -1 then do:
      find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.ln = v-ln no-lock no-error.
      
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "bdt" no-lock no-error. 
      if avail pkanketh then wrk.bdt = date(trim(pkanketh.value1)).
      
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "joborg" no-lock no-error. 
      if avail pkanketh then wrk.wrk_plc = trim(pkanketh.value1).
      
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobsn" no-lock no-error. 
      if avail pkanketh then wrk.position = trim(pkanketh.value1).
      
      /* стаж */
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobty" no-lock no-error. 
      if avail pkanketh and pkanketh.value1 <> ? and trim(pkanketh.value1) <> "" then wrk.experience = trim(pkanketh.value1) + " г".
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "jobtm" no-lock no-error. 
      if avail pkanketh and pkanketh.value1 <> ? and trim(pkanketh.value1) <> "" then wrk.experience = wrk.experience + " " + trim(pkanketh.value1) + " мес".
      
      /* gcvp */
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "gcvpsum" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.income_gcvp = round(decimal(trim(pkanketh.value1)),2).
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "sik" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.sik = trim(pkanketh.value1).
      
      /* card */
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "ak34" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.card = "yes".  

      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "city2" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.addr1 = trim(pkanketh.value1).
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "street2" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.addr1 = wrk.addr1 + ' ' + trim(pkanketh.value1).
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "house2" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.addr1 = wrk.addr1 + ' д.' + trim(pkanketh.value1).
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "apart2" no-lock no-error. 
      if avail pkanketh and trim(pkanketh.value1) <> '' then wrk.addr1 = wrk.addr1 + ' кв.' + trim(pkanketh.value1).
      
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lnamel" no-lock no-error. 
      if avail pkanketh then wrk.lname2 = trim(pkanketh.value1).
      /*else wrk.lname2 = '-'.*/
      find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fnamel" no-lock no-error. 
      if avail pkanketh then wrk.fname2 = trim(pkanketh.value1).
      /*else wrk.fname2 = '-'.*/      
    end.
  end.
  find last card_status where card_status.rnn = cif.jss and substring(card_status.scheme_name,1,2) = 'Db'
                     and card_status.expires > datums1 no-lock no-error.
  if avail card_status then wrk.dcrd = 'Дб'.
 
  if trim(wrk.wrk_plc) = '' then wrk.wrk_plc = trim(cif.ref[8]).
  if trim(wrk.position) = '' then wrk.position = trim(cif.sufix).
  if wrk.wrk_plc matches '*Texakabank*' then wrk.sotr = 'сотрудник'.

  mesa = mesa + 1.
  hide message no-pause.
  message " " + string(mesa) + " кредитов ". 
  
end. /* for each lon */

def stream rep.
output stream rep to clnclst.htm.

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
    "<BR><b>Подготовил:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Статистика по погашенным кредитам физ.лиц</b></center><BR>" skip
    "<table border=1 cellpadding=0 cellspacing=0>" skip
    "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"" valign=""top"">" skip
    "<td>Код<BR>клиента</td>" skip
    "<td>Фамилия</td>" skip
    "<td>Имя</td>" skip
    "<td>Отчество</td>" skip
    "<td>Last name</td>"
    "<td>First name</td>"    
    "<td>РНН</td>" skip
    "<td>Сс счет</td>" skip
    "<td>Валюта</td>" skip
    "<td>Размер<BR>кредита</td>" skip
    "<td>Дата открытия<BR>кредита</td>" skip
    "<td>Дата погашения<BR>по договору</td>" skip
    "<td>Дата погашения<BR>по факту</td>" skip
    "<td>Количество<BR>просрочек</td>" skip
    "<td>Срок самой<BR>долгой просрочки</td>" skip
    "<td>Место работы</td>" skip
    "<td>Должность</td>" skip
    "<td>Стаж</td>" skip
    "<td>Дата<BR>рождения</td>" skip
    "<td>Размер дохода<BR>по ГЦВП</td>" skip
    "<td>Платеж.<BR>карта</td>" skip
    "<td>Наличик<BR>дебетной<BR>карта</td>" skip
    "<td>Адрес факт проживания</td>" skip
    "<td>Адрес прописки</td>" skip
    "<td>Телефоны</td>" skip
    "<td>Уд личности</td>" skip
    "<td>СИК</td>" skip
    "<td>СПФ</td>" skip
    "<td>Код СПФ</td>" skip
    "<td>Сотрудник</td>" skip
    "</tr>" skip.

for each wrk no-lock:
  
  find crc where crc.crc = wrk.crc no-lock no-error.
  put stream rep unformatted
    "<tr>" skip
    "<td>" wrk.cif "</td>" skip    
    "<td>" wrk.lname1 "</td>" skip
    "<td>" wrk.fname1 "</td>" skip
    "<td>" wrk.mname1 "</td>" skip
    "<td>" wrk.lname2 "</td>" skip
    "<td>" wrk.fname2 "</td>" skip
    "<td>&nbsp;" wrk.rnn "</td>" skip
    "<td>&nbsp;" wrk.lon "</td>" skip
    "<td>" crc.code "</td>" skip
    "<td>" replace(trim(string(wrk.opnamt)),'.',',') "</td>" skip
    "<td>" wrk.rdt format "99/99/9999" "</td>" skip
    "<td>" wrk.duedt format "99/99/9999" "</td>" skip
    "<td>" wrk.dt_cl format "99/99/9999" "</td>" skip
    "<td>" wrk.pr_num "</td>" skip
    "<td>" wrk.pr_longest "</td>" skip
    "<td>" wrk.wrk_plc "</td>" skip
    "<td>" wrk.position "</td>" skip
    "<td>" wrk.experience "</td>" skip
    "<td>" wrk.bdt  format "99/99/9999" "</td>" skip
    "<td>" replace(trim(string(wrk.income_gcvp)),'.',',') "</td>" skip
    "<td>" wrk.card "</td>" skip
    "<td>" wrk.dcrd "</td>" skip
    "<td>" wrk.addr1 "</td>" skip
    "<td>" wrk.addr2 "</td>" skip
    "<td>" wrk.tel "</td>" skip
    "<td>" wrk.udl "</td>" skip
    "<td>" wrk.sik "</td>" skip
    "<td>" wrk.rko "</td>" skip
    "<td>" wrk.rko_cod "</td>" skip
    "<td>" wrk.sotr "</td>" skip
    "</tr>" skip.
  
end.

put stream rep unformatted "</table></body></html>" skip.

output stream rep close.
hide message no-pause.
unix silent cptwin clnclst.htm excel. 


