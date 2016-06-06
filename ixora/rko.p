/* rko.p
 * MODULE
        Департамент координации СПФ
 * DESCRIPTION
        Отчет по привлеченным клиентам СПФ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.7.14.8
 * AUTHOR
        12/05/2005 dpuchkov
 * CONNECT
        BANK
 * CHANGES
        13.05.2005 dpuchkov оставил только юридических лиц
        16.05.2005 dpuchkov изменил формат отображения данных
        18.05.2005 dpuchkov формирование в excel
        01.07.2005 dpuchkov перекомпиляция.
        11.07.2005 dpuchkov убрал временные таблицы
        08/06/2009 madiyar - отсутствовала в библиотеке, добавил
*/

{global.i}
{crc-crc.i}

def var d_date as date.
def var d_date1 as date.
def var t-ind as date.
def var t-ind1 as date.
def var i_count as integer.
def var i_tmp as integer.
def var v-mon as char init "".
def var d_sum as decimal.
def var d_credit as decimal.
def var d_dtbegin as date.
def var l_acc as logical init false.
def var d_allsum1 as decimal extent 70.
def var d_dohod as decimal decimals 2.
def var r1 as decimal decimals 2.
def var r2 as decimal decimals 2.
def var r3 as decimal decimals 2.
def var r4 as decimal decimals 2.
def var r5 as decimal decimals 2.
def var r6 as decimal decimals 2.
def var r7 as decimal decimals 2.
def var r8 as decimal decimals 2.
def var d_vertsum as decimal decimals 2.
def var v-dep as char format "x(3)".
def var l_cifavail as logical init False.

def temp-table t-cif like cifjl.


    d_date1 = 01.01.08. /* не менять, формирование отчета от данной даты*/

    define frame frame1
    v-dep format "x(3)" label "Код департамента "  validate (v-dep <> "" and can-find (ppoint where ppoint.depart = inte(v-dep) no-lock), " Неверный код департамента") help "F2- Выбор кода департамента." skip

    d_date  label "Отчет на дату    " with side-labels centered row 9.

    d_date = date(month(g-today), 01, year(g-today)).
    displ d_date with frame frame1.
    update v-dep  with frame frame1.
    hide frame frame1.

    display "ЖДИТЕ ИДЕТ ФОРМИРОВАНИЕ ОТЧЕТА..." skip  with row 12 frame ww centered no-box.
    pause 0.


    d_credit = 0.
    d_dohod = 0.
    def buffer b-jl for jl.
/*  Заполняем таблицу истории кредитовых оборотов и доходов клиента по месяцам для быстрого поиска */
    for each cif where cif.regdt >= d_date1  no-lock:

   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
   if avail sub-cod and sub-cod.ccode <> '0' then next.



        d_dtbegin = cif.regdt.
        d_vertsum = 0.
        do t-ind = cif.regdt to g-today:
           if day (t-ind + 1) = 1 then do:
              r1 = 0. r2 = 0. r3 = 0. r4 = 0. r5 = 0. r6 = 0. r7 = 0. r8 = 0.
              find last t-cif where t-cif.cif = cif.cif and month(t-cif.dt) = month(t-ind) and year(t-cif.dt) = year(t-ind) no-lock no-error.
              if not avail t-cif then do:
                 for each aaa where aaa.cif = cif.cif no-lock:
                    for each jl where jl.jdt >= d_dtbegin and jl.jdt <= t-ind and jl.acc = aaa.aaa  and jl.dam <> 0 and jl.dc = 'd' and jl.lev = 1 no-lock:
                        find last b-jl where b-jl.ln= jl.ln + 1 and  b-jl.jh = jl.jh and b-jl.dc = "c" and b-jl.cam <> 0 and b-jl.cam = jl.dam and b-jl.jdt = jl.jdt  no-lock no-error.
                        if not avail b-jl then next.
                           d_credit = d_credit + crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind).
                    end.
                 end.

                 for each aaa where aaa.cif = cif.cif no-lock:

                     for each jl where jl.jdt >= d_dtbegin and jl.jdt <= t-ind and jl.acc = aaa.aaa  and jl.dam <> 0 and jl.dc = 'd' and jl.lev = 1 no-lock:
                         find last b-jl where b-jl.ln= jl.ln + 1 and  b-jl.jh = jl.jh and b-jl.dc = "c" and substr(string(b-jl.gl),1,1) = "4" and b-jl.cam <> 0 and b-jl.cam = jl.dam and b-jl.jdt = jl.jdt  no-lock no-error.
                         if not avail b-jl then next.
                         d_dohod = d_dohod + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2).

                         /* номера счетов не менять */
                         if b-jl.gl = 440100 then r1 = r1 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                         if b-jl.gl = 453010 then r2 = r2 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                         if b-jl.gl = 461110 then r3 = r3 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                         if b-jl.gl = 460111 then r4 = r4 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                         if b-jl.gl = 460410 then r5 = r5 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                         if b-jl.gl = 460712 then r6 = r6 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2). else
                            r7 = r7 + round(crc-crc-date(b-jl.cam, aaa.crc, 2, t-ind), 2).
                      end.
                 end.


                  create t-cif.
                         t-cif.cif    = cif.cif  .
                         t-cif.dt     = t-ind    .
                         t-cif.sum    = d_credit .
                         t-cif.doh    = d_dohod  .
                         t-cif.ovr    = r1.
                         t-cif.kupl   = r2.
                         t-cif.kass   = r3.
                         t-cif.perev  = r4.
                         t-cif.sroch  = r5.
                         t-cif.accur  = r6.
                         t-cif.other  = r7.
                         t-cif.alldoh = r1 + r2 + r3 + r4 + r5 + r6 + r7.
                         d_vertsum = d_vertsum + d_dohod.
                         t-cif.period = d_vertsum.
                  d_credit = 0.
               end.
               d_credit = 0.
               d_dohod = 0.
               d_dtbegin = t-ind + 1.
           end.
        end.
    end.

    output to value("drr.htm").
    {html-title.i}

    find last ppoint where ppoint.depart = inte(v-dep) no-lock no-error.
    if not avail ppoint then do:
       message "Не найден код департамента".
       return.
    end.

 /* Формирование шапки отчета */
    put unformatted
        "<P align=""center"" style=""font:bold;font-size:small""> ОТЧЕТ ПО ПРИВЛЕЧЕННЫМ КЛИЕНТАМ " ppoint.name " на " d_date " </P>" skip.
    put unformatted
        "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.
    put unformatted
        "<TR align=""center"" style=""font:bold;background:white "">" skip
        " <tr align=""center"">" skip
        " <td rowspan=3 bgcolor=""#95B2D1""><p align=""center""><FONT size=""2""><b>Месяц год когда клиент был привлечен</b></p></td>" skip
        " <td rowspan=3 bgcolor=""#95B2D1""><p align=""center""><FONT size=""2""><b>Наименование клиента                          </b></p></td>" skip
        " <td rowspan=3 bgcolor=""#95B2D1""><p align=""center""><FONT size=""2""><b>CIF код</b></p></td>" skip.
    put unformatted
        " <td rowspan=3 bgcolor=""#95B2D1""><p><FONT size=""2""><b>Дата открытия первого счета</b></p></td>" skip .

    do t-ind = d_date1 to date(month(g-today) - 1, day(g-today), year(g-today)) :
       if day (t-ind) = 1  then do:

          if month(t-ind) <> month(g-today) - 1 or (month(t-ind) = month(g-today) - 1 and year(t-ind) <> year(g-today) ) then
             put unformatted  " <td colspan=2 bgcolor=""#95B2D1""><p><FONT size=""2""><b>" t-ind "</b></p></td>" skip.
          else
             put unformatted  " <td colspan=8 bgcolor=""#95B2D1""><p><FONT size=""2""><b>" t-ind "</b></p></td>" skip.
       end.
    end.
    put unformatted
        " <td rowspan=3 bgcolor=""#95B2D1""><p><FONT size=""2""><b>Итого общий доход за весь период</b></p></td> " skip
        " </tr>" skip.

    do t-ind = d_date1 to date(month(g-today) - 2, day(g-today), year(g-today)) :
       if day (t-ind) = 1 then
          put unformatted
              " <td rowspan=2 bgcolor=""#95B2D1""><p><FONT size=""2""><b>Среднемесячный оборот в долларах США </b></p></td>"            skip
              " <td rowspan=2 bgcolor=""#95B2D1""><p><FONT size=""2""><b>Доходы за месяц от всех операций в долларах США </b></p></td>" skip.
    end.
    put unformatted
        " <td colspan=8 bgcolor=""#95B2D1""><p><FONT size=""2""><b>Доходность в долларах США </b></p></td>"        skip
        " </tr>"                                                        skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>Доходы от овердрафта м 440100 </b></p></td>"              skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>По купле продаже б\н инвал без ндс 453010 </b></p></td>"  skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>За кассовые операции ю/л 461110 </b></p></td>"            skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>За перевод операцию без НДС 460111 </b></p></td>"         skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>Комиссия за сроч/ конвертацию 460410 </b></p></td>"       skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>За вед сч ЮЛ без НДС  с обор 460712 </b></p></td>"        skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>и т.п </b></p></td>"                                      skip
        " <td bgcolor=""#95B2D1""><p><FONT size=""2""><b>Всего </b></p></td>"                                      skip .
        put unformatted " <tr>"  skip.
    put unformatted " <tr>"  skip.

/* Заполнение отчета */

  do t-ind = d_date1 to g-today:
       if day (t-ind) = 1 then do:
          i_count = 0.

          if month(t-ind) <> month(g-today) or (month(t-ind) = month(g-today) and year(t-ind) <> year(g-today) ) then do:

                 for each cif where int(v-dep) = (int(cif.jame) mod 1000) and month(cif.regdt) = month(t-ind) and year(cif.regdt) = year(t-ind)  no-lock:
   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
   if avail sub-cod and sub-cod.ccode <> '0' then next.

                     i_count = i_count + 1.
                 end.

                 if month(t-ind) = 1  then v-mon = "январь "   + string(year(t-ind)).
                 if month(t-ind) = 2  then v-mon = "февраль "  + string(year(t-ind)).
                 if month(t-ind) = 3  then v-mon = "март "     + string(year(t-ind)).
                 if month(t-ind) = 4  then v-mon = "апрель "   + string(year(t-ind)).
                 if month(t-ind) = 5  then v-mon = "май "      + string(year(t-ind)).
                 if month(t-ind) = 6  then v-mon = "июнь "     + string(year(t-ind)).
                 if month(t-ind) = 7  then v-mon = "июль "     + string(year(t-ind)).
                 if month(t-ind) = 8  then v-mon = "август "   + string(year(t-ind)).
                 if month(t-ind) = 9  then v-mon = "сентябрь " + string(year(t-ind)).
                 if month(t-ind) = 10 then v-mon = "октябрь "  + string(year(t-ind)).
                 if month(t-ind) = 11 then v-mon = "ноябрь "   + string(year(t-ind)).
                 if month(t-ind) = 12 then v-mon = "декабрь "  + string(year(t-ind)).

                 put unformatted "<td rowspan=" i_count  "  width=140><p align=""top""><b> "  v-mon "</b> </p></td>"  skip.
                 l_cifavail  = False.

                 for each cif where int(v-dep) = (int(cif.jame) mod 1000) and month(cif.regdt) = month(t-ind) and year(cif.regdt) = year(t-ind)  no-lock:
   find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and sub-cod.d-cod = "clnsts" no-lock no-error.
   if avail sub-cod and sub-cod.ccode <> '0' then next.

                    l_acc = False. l_cifavail = True.
/* Наименование */  put unformatted "<td><p style=""font-size:8.0pt"">" cif.prefix " " cif.name  "</p></td>" skip.
/* CIF-код      */  put unformatted "<td width=50><p style=""font-size:8.0pt"">" cif.cif   "</p></td>" skip.
                    put unformatted "<td width=60><p align=""center"" style=""font-size:8.0pt"">" cif.regdt format "99/99/9999" "</p></td>" skip.
                    d_sum = 0.
                    l_acc = False.
                    i_tmp = 0.
                    do t-ind1 = d_date1 to date(month(g-today) - 1, day(g-today), year(g-today)):
                       if day (t-ind1) = 1 then do:

                          if month(t-ind1) <> month(g-today) - 1 or (month(t-ind1) = month(g-today) - 1 and year(t-ind1) <> year(g-today) ) then do:
                             find last t-cif where t-cif.cif = cif.cif and month(t-cif.dt) = month(t-ind1) and year(t-cif.dt) = year(t-ind1) no-lock no-error.
                             if avail t-cif then do: /* Среднемесячные обороты */
                                i_tmp = i_tmp + 1.
                                d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.sum.
                                put unformatted "<td width=70 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.sum,'z,zzz,zzz,zzz,zz9.99-') "</p></td>" skip.
                                i_tmp = i_tmp + 1.
                                d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.doh.
                                put unformatted "<td width=70 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.doh,'z,zzz,zzz,zzz,zz9.99-') "</p></td>" skip. /* доходы от всех операций */
                             end.
                             else do: /* доходы от операций */
                                     i_tmp = i_tmp + 1.
                                     d_allsum1[i_tmp] = d_allsum1[i_tmp] + 0.
                                     i_tmp = i_tmp + 1.
                                     d_allsum1[i_tmp] = d_allsum1[i_tmp] + 0.
                                     put unformatted "<td  height=18><p align=""center"" style=""font-size:8.0pt""> - </p></td>" skip.
                                     put unformatted "<td  height=18><p align=""center"" style=""font-size:8.0pt""> - </p></td>" skip.
                             end.
                          end.
                          else do: /* последний месяц */
                               find last t-cif where t-cif.cif = cif.cif and month(t-cif.dt) = month(t-ind1) and year(t-cif.dt) = year(t-ind1) no-lock no-error.
                               if avail t-cif then do: /* Среднемесячные обороты */
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.ovr.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.ovr,'z,zzz,zzz,zzz,zz9.99-')  "</p></td>"        skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.kupl.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.kupl,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"        skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.kass.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.kass,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"        skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.perev.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.perev,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"       skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.sroch.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.sroch,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"       skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.accur.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.accur,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"       skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.other.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.other,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"       skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.alldoh.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.alldoh,'z,zzz,zzz,zzz,zz9.99-') "</p></td>"      skip.
                                  i_tmp = i_tmp + 1. d_allsum1[i_tmp] = d_allsum1[i_tmp] + t-cif.period.
                                  put unformatted "<td width=100 height=18><p align=""center"" style=""font-size:8.0pt"">" string(t-cif.period,'z,zzz,zzz,zzz,zz9.99-') "</p></td></tr>" skip.
                                  i_tmp = 0.
                               end.
                          end.
                       end.
                    end.
                end.
                if not l_cifavail then put unformatted "</tr>" skip.
           end.
       end.
    end.

    put unformatted " <tr><td width=100 height=18><FONT size=""2""><p>ИТОГО </p></td>".
    put unformatted " <td  height=18><FONT size=""2""><p> - </p></td>".
    put unformatted " <td  height=18><FONT size=""2""><p> - </p></td>".
    put unformatted " <td  height=18><FONT size=""2""><p> - </p></td>".

    /*итого*/
    i_tmp = 0.
    do t-ind1 = d_date1 to date(month(g-today) - 1, day(g-today), year(g-today)):
       if day (t-ind1) = 1 then do:
          i_tmp = i_tmp + 1.

          if month(t-ind1) <> month(g-today) - 1 or (month(t-ind1) = month(g-today) - 1 and year(t-ind1) <> year(g-today) ) then do:
             put unformatted " <td width=80 height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-')  "</p></td>".
             i_tmp = i_tmp + 1.
             put unformatted " <td width=80 height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-')  "</p></td>".
          end.
          else do:
             put unformatted " <td  height=18><FONT size=""2""> <p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>". i_tmp = i_tmp + 1.
             put unformatted " <td  height=18><FONT size=""2""><p align=""center"" style=""font-size:8.0pt"">" string(d_allsum1[i_tmp],'z,zzz,zzz,zzz,zz9.99-') "</p></td>".
          end.
       end.
    end.

    put unformatted "</TABLE>" skip.
    {html-end.i " "}
    output close .
    hide frame ww.
    unix silent cptwin value("drr.htm") excel.


