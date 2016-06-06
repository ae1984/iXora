/* lnbddptk.p
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Анализ кредитного портфеля БД+ в разрезе РУПС
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
        02/10/2006 madiyar - скопировал из lnbddpt.p с изменениями
 * BASES
        bank, comm
 * CHANGES
*/  

{mainhead.i}
{pk0.i}

function get-dep returns char ( usr as char, vcif as char, vlon as char).
    find first extuser where extuser.login = usr no-lock no-error.
    if not avail extuser then do:
      message " extuser " + usr + " not found: cif=" + vcif + " lon=" vlon view-as alert-box buttons ok.
      return "unknown".
    end.
    else return extuser.id_dept.
end function.

def var s-ourbank as char init "".
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
end.
else s-ourbank = trim(sysc.chval).

def var dat as date no-undo.
def var dates as date no-undo extent 5. /* последняя дата - для периода */
def var bilance as deci no-undo.
def var v-bal as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-dpt as char no-undo.
def var i as integer no-undo.
def buffer b-jl for jl.
def var v-k as integer no-undo.
def var v-s as deci no-undo.
def var mesa as integer no-undo.

def temp-table t-dpt no-undo
    field dpt as char
    field kolk as integer extent 4
    field sumk as deci extent 4
    field kolv as integer extent 4
    field sumv as deci extent 4
    field kolp as integer extent 4
    field sump as deci extent 4
    field kolp5 as integer extent 4
    field sump5 as deci extent 4
    field kolp50 as integer extent 4
    field sump50 as deci extent 4
    field kolp100 as integer extent 4
    field sump100 as deci extent 4
    field kolpother as integer extent 4
    field sumpother as deci extent 4
    field comf as deci extent 4
    field comr as deci extent 4
    field comv as deci extent 4
    field gprc as deci extent 4
    field gpen as deci extent 4
    /* field aux as char */
    index ind is primary dpt.

dat = g-today.
update dat label " Отчет на дату" format "99/99/9999" skip with side-label row 5 centered frame dat.

def var b-dat as date no-undo.
def var vmonth as integer no-undo.
def var vyear as integer no-undo.
b-dat = dat.
dates[1] = dat.
do i = 2 to 5:
  if i = 4 then do:
    if day(b-dat) = 1 and month(b-dat) = 1 then b-dat = date(1,1,year(b-dat) - 1).
    else b-dat = date(1,1,year(b-dat)).
  end.
  else do:
    vmonth = month(b-dat) - 1.
    vyear = year(b-dat).
    if vmonth = 0 then do: vmonth = 12. vyear = vyear - 1. end.
    b-dat = date(vmonth, 1, vyear).
  end.
  dates[i] = b-dat.
end.

mesa = 0.
for each pkanketa where pkanketa.id_org = "kazpost" and pkanketa.bank = s-ourbank and pkanketa.credtype = '6' no-lock:
  
  if pkanketa.lon = '' then next.
  find first lon where lon.lon = pkanketa.lon no-lock no-error.
  if not avail lon then next.
  
  if lon.opnamt <= 0 then next.
  if lon.rdt >= dat then next.
  
  v-dpt = get-dep(pkanketa.rwho,lon.cif,lon.lon).
  find first t-dpt where t-dpt.dpt = v-dpt no-error.
  if not avail t-dpt then do:
    create t-dpt.
    t-dpt.dpt = v-dpt.
  end.
  do i = 1 to 4:
    
    if lon.rdt >= dates[i] then next.
    
    /* портфель */
    run lonbalcrc('lon',lon.lon,dates[i],"1,7",no,lon.crc,output bilance).
    if bilance > 0 then do:
      t-dpt.kolk[i] = t-dpt.kolk[i] + 1.
      t-dpt.sumk[i] = t-dpt.sumk[i] + bilance.
    end.
    
    /* выданные */
    if lon.rdt >= dates[i + 1] then do:
      t-dpt.kolv[i] = t-dpt.kolv[i] + 1.
      t-dpt.sumv[i] = t-dpt.sumv[i] + lon.opnamt.
    end.
    
    /* погашенные */
    run lonbalcrc('lon',lon.lon,dates[i + 1],"1,7",no,lon.crc,output v-bal).
    if bilance <= 0 and (v-bal > 0 or lon.rdt >= dates[i + 1]) then do:
      t-dpt.kolp[i] = t-dpt.kolp[i] + 1.
      if v-bal > 0 then t-dpt.sump[i] = t-dpt.sump[i] + v-bal.
      else t-dpt.sump[i] = t-dpt.sump[i] + lon.opnamt.
    end.
    
    /* провизии */
    run lonbalcrc('lon',lon.lon,dates[i],"3,6",no,1,output v-bal).
    if v-bal < 0 then do:
        find last lonhar where lonhar.lon = lon.lon and lonhar.fdt < dates[i] no-lock no-error.
        if avail lonhar then do:
          find first lonstat where lonstat.lonstat = lonhar.lonstat no-lock no-error.
          if avail lonstat then do:
            if lonstat.lonstat = 2 then do:
              if bilance > 0 then t-dpt.kolp5[i] = t-dpt.kolp5[i] + 1.
              t-dpt.sump5[i] = t-dpt.sump5[i] - v-bal.
            end.
            else if lonstat.lonstat = 6 then do:
              if bilance > 0 then t-dpt.kolp50[i] = t-dpt.kolp50[i] + 1.
              t-dpt.sump50[i] = t-dpt.sump50[i] - v-bal.
            end.
            else if lonstat.lonstat = 7 then do:
              if bilance > 0 then t-dpt.kolp100[i] = t-dpt.kolp100[i] + 1.
              t-dpt.sump100[i] = t-dpt.sump100[i] - v-bal.
            end.
            else do:
              if bilance > 0 then t-dpt.kolpother[i] = t-dpt.kolpother[i] + 1.
              t-dpt.sumpother[i] = t-dpt.sumpother[i] - v-bal.
            end.
            /*
            case lonstat.prc:
              when 5.0 then do: t-dpt.kolp5[i] = t-dpt.kolp5[i] + 1. t-dpt.sump5[i] = t-dpt.sump5[i] - v-bal. end.
              when 50.0 then do: t-dpt.kolp50[i] = t-dpt.kolp50[i] + 1. t-dpt.sump50[i] = t-dpt.sump50[i] - v-bal. end.
              when 100.0 then do: t-dpt.kolp100[i] = t-dpt.kolp100[i] + 1. t-dpt.sump100[i] = t-dpt.sump100[i] - v-bal. end.
              otherwise do: -- message lon.cif + " " + lon.lon + " - классификация " + trim(string(lonhar.lonstat,">>>9")) + ", провизии " + trim(string(lonstat.prc,">>>9.99")) + "%". --
                t-dpt.kolpother[i] = t-dpt.kolpother[i] + 1. t-dpt.sumpother[i] = t-dpt.sumpother[i] - v-bal.
              end.
            end case.
            */
          end. /* if avail lonstat */
          else message lon.cif + " " + lon.lon + " - lonstat не найден".
        end.
        else message lon.cif + " " + lon.lon + " - lonhar не найден".
    end.
    
    /* фонд */
    t-dpt.comf[i] = round(t-dpt.comf[i] + lon.opnamt * 0.025,2).
        
    /* полученные % */
    v-bal = 0.
    find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 12
                                 and histrxbal.dt < dates[i + 1] and histrxbal.crc = 1 no-lock no-error.
    if avail histrxbal then v-bal = histrxbal.cam.
    
    find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 12
                                 and histrxbal.dt < dates[i] and histrxbal.crc = 1 no-lock no-error.
    if avail histrxbal and histrxbal.cam > v-bal then t-dpt.gprc[i] = t-dpt.gprc[i] + histrxbal.cam - v-bal.
    /*
    run lonbalcrc('lon',lon.lon,dates[i],"12",no,1,output v-bal). v-bal = - v-bal.
    run lonbalcrc('lon',lon.lon,dates[i + 1],"12",no,1,output v-bal2). v-bal2 = - v-bal2.
    if v-bal > v-bal2 then t-dpt.gprc[i] = t-dpt.gprc[i] + v-bal - v-bal2.
    */
    /* полученная пеня */
    /*
    v-bal = 0.
    find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 16
                                 and histrxbal.dt < dates[i + 1] and histrxbal.crc = 1 no-lock no-error.
    if avail histrxbal then v-bal = histrxbal.cam.
    
    find last histrxbal where histrxbal.subled = 'lon' and histrxbal.acc = lon.lon and histrxbal.level = 16
                                 and histrxbal.dt < dates[i] and histrxbal.crc = 1 no-lock no-error.
    if avail histrxbal and histrxbal.cam > v-bal then t-dpt.gpen[i] = t-dpt.gpen[i] + histrxbal.cam - v-bal.
    */
    
  end. /* do i = 1 to 4 */
  
  /* ведение текущего счета */
  /*
  for each jl where jl.acc = lon.aaa and jl.dc = 'D' and jl.jdt >= dates[5] and jl.jdt < dates[1] no-lock:
    find first b-jl where b-jl.jh = jl.jh and b-jl.ln = jl.ln + 1 no-lock no-error.
    if not avail b-jl then next.
    if b-jl.gl = 460712 then do:
      if jl.jdt >= dates[2] then t-dpt.comv[1] = t-dpt.comv[1] + jl.dam.
      else if jl.jdt >= dates[3] then t-dpt.comv[2] = t-dpt.comv[2] + jl.dam.
      else if jl.jdt >= dates[4] then t-dpt.comv[3] = t-dpt.comv[3] + jl.dam.
      else t-dpt.comv[4] = t-dpt.comv[4] + jl.dam.
    end.
  end.
  */
  mesa = mesa + 1.
  hide message no-pause.
  message " lon " mesa.
  
end. /* for each pkanketa */


def stream rep.
output stream rep to rpt.htm.

put stream rep "<html><head><title>TEXAKABANK</title>" skip
               "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
               "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<b>Анализ программы БЫСТРЫЕ ДЕНЬГИ ПЛЮС на " dat format "99/99/9999" " в разрезе РУПС<BR><BR>" skip.

for each t-dpt no-lock:
    
    put stream rep unformatted
      "<b>" caps(trim(t-dpt.dpt)) "</b><br><br>".
    
    put stream rep unformatted
      "Динамика роста кредитного портфеля<BR>" skip
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
      "<td colspan=2></td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" dates[i] format "99/99/9999" "</td>" skip. end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted
      "<tr>" skip
      "<td rowspan=2>Кредитный портфель</td>" skip
      "<td>Количество кредитов</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolk[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td>Сумма, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sumk[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "</table><br>" skip.
    
    
    put stream rep unformatted
      "Динамика роста выданных кредитов<BR>" skip
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr>" skip
      "<td colspan=2>Количество выданных кредитов за период</td>" skip.
    
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolv[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td colspan=2>Объем выданных кредитов за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sumv[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "</table><br>" skip.
    
    
    put stream rep unformatted
      "Динамика роста погашенных кредитов<BR>" skip
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr>" skip
      "<td colspan=2>Количество погашенных кредитов за период</td>" skip.
    
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolp[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td colspan=2>Объем погашенного основного долга за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sump[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "</table><br>" skip.
    
    
    put stream rep unformatted
      "Сформированные провизии<BR>" skip
      "<table border=1 cellpadding=0 cellspacing=0>" skip
      "<tr>" skip
      "<td rowspan=2>Сомнительные 1 категории (5%)</td>" skip
      "<td>Количество кредитов</td>" skip.
    
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolp5[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td>Сумма провизий, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sump5[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted
      "<tr>" skip
      "<td rowspan=2>Сомнительные 5 категории (50%)</td>" skip
      "<td>Количество кредитов</td>" skip.
    
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolp50[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td>Сумма провизий, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sump50[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted
      "<tr>" skip
      "<td rowspan=2>Безнадежные (100%)</td>" skip
      "<td>Количество кредитов</td>" skip.
    
    do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolp100[i] "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr><td>Сумма провизий, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sump100[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    /* на всякий пожарный */
    v-k = 0. v-s = 0.
    do i = 1 to 4: v-k = v-k + t-dpt.kolpother[i]. v-s = v-s + t-dpt.sumpother[i]. end.
    if v-k > 0 or v-s > 0 then do:
      put stream rep unformatted
        "<tr>" skip
        "<td rowspan=2>Другие</td>" skip
        "<td>Количество кредитов</td>" skip.
      
      do i = 1 to 4: put stream rep unformatted "<td>" t-dpt.kolpother[i] "</td>". end.
      put stream rep unformatted "</tr>" skip.
      
      put stream rep unformatted "<tr><td>Сумма провизий, KZT</td>" skip.
      do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.sumpother[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
      put stream rep unformatted "</tr>" skip.
    end.
    /* -- */
    
    put stream rep unformatted "<tr style=""font:bold""><td colspan=2>Итого, KZT</td>" skip.
    do i = 1 to 4:
      put stream rep unformatted "<td>" replace(trim(string(t-dpt.sump5[i] + t-dpt.sump50[i] + t-dpt.sump100[i] + t-dpt.sumpother[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>".
    end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "</table><br>" skip.
    
    
    put stream rep unformatted
      "Доходы<BR>" skip
      "<table border=1 cellpadding=0 cellspacing=0>" skip.
    
    put stream rep unformatted  
      "<tr>" skip
      "<td colspan=2>Фонд страхования кредитных рисков за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.comf[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted  
      "<tr>" skip
      "<td colspan=2>Комиссия за рассмотрение заявки за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.comr[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted  
      "<tr>" skip
      "<td colspan=2>Комиссия за ведение текущего счета за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.comv[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted  
      "<tr>" skip
      "<td colspan=2>Полученные %% за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.gprc[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted  
      "<tr>" skip
      "<td colspan=2>Полученная пеня за период, KZT</td>" skip.
    do i = 1 to 4: put stream rep unformatted "<td>" replace(trim(string(t-dpt.gpen[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>". end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "<tr style=""font:bold""><td colspan=2>Итого получено доходов за период, KZT</td>" skip.
    do i = 1 to 4:
      put stream rep unformatted "<td>" replace(trim(string(t-dpt.comf[i] + t-dpt.comr[i] + t-dpt.comv[i] + t-dpt.gprc[i] + t-dpt.gpen[i], ">>>>>>>>>>>>>>9.99")),".",",") "</td>".
    end.
    put stream rep unformatted "</tr>" skip.
    
    put stream rep unformatted "</table><br><br><br>" skip.
    
end. /* for each t-dpt */

    

/*********************************************/

hide message no-pause.
put stream rep unformatted "</body></html>" skip.
output stream rep close.

unix silent cptwin rpt.htm excel.



