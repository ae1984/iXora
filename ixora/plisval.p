/* plisval.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по исходящим валютным платежам в разрезе ЦО, СПФ и филиалов
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
        15/10/2004 saltanat
 * CHANGES
        22.10.2004 saltanat - 1. Если интернет платеж, то принадлежность определяется по Департаменту Клиента.
                              2. Берем все комиссии.
        05/09/2006 u00600 - оптимизация
        24.02.2011 marinav - добавление тенге
        04.01.2012 lyubov - довила валюты: CHF, SEK, AUD
*/

{mainhead.i}
{rkorepfun.i}
def var v-dt as date.

def var v-glacc as char init '105100,105210,105220'.
def var v-dtb   as date.
def var v-dte   as date.
def var dep     as char.
def var cl-mf   as char.
def var i       as integer.

def temp-table t-docsa
    field id   as inte
    field fil  as char
    field rko  as inte init 0
    field typ  as char
    field val  as inte init 0
    field sum  as deci format 'zzz,zzz,zzz,zzz.99'
    field kol  as inte init 0
    field cval as inte init 0
    field csum as deci init 0.

def var itog  as deci extent 9 init 0.
def var itog1 as deci extent 9 init 0.
def var ikol  as deci extent 9 init 0.

form skip(1)
    v-dtb label 'Начало периода' format '99/99/9999' skip
    v-dte label ' Конец периода' format '99/99/9999' skip(1)
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.
v-dtb = g-today.
v-dte = g-today.
update v-dtb v-dte with frame f-dt.

do v-dt = v-dtb to v-dte.
/*for each remtrz where remtrz.valdt2 >= v-dtb and remtrz.valdt2 <= v-dte no-lock.*/
for each remtrz where remtrz.valdt2 = v-dt no-lock.

/*if remtrz.tcrc = 1 then next.*/
if (lookup(string(remtrz.crgl),v-glacc) > 0)  then do:

   dep = ''. cl-mf = 'cl'.
   if remtrz.sbank = 'TXB00' then do:
      if remtrz.rwho = '' then dep = '1001'.
      else if remtrz.rwho = 'SUPERMAN' then do:
              find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
              if avail aaa then do:
                 find first cif where cif.cif = aaa.cif no-lock no-error.
                 if avail cif then dep = user_dep(cif.fname).
                 else dep = '1001'.
              end.
              else dep = '1001'.
           end.
           else dep = user_dep(remtrz.rwho).
      if dep = '1001' then do:
         find first swout where swout.rmz = remtrz.remtrz no-lock no-error.
         if avail swout then do:
            if swout.mt = '202' then cl-mf = 'mf'.
            else if swout.mt = '103' then cl-mf = 'cl'.
            else do:
                 if remtrz.sacc <> '' then do:
                 find first aaa where aaa.aaa = remtrz.sacc no-lock no-error.
                 if avail aaa then cl-mf = 'cl'.
                 else do:
                 find first arp where arp.arp = remtrz.sacc no-lock no-error.
                 if avail arp then cl-mf = 'mf'.
                 end.
                 end.
            end.
         end.
      end.
   end.
   find first t-docsa where t-docsa.fil = remtrz.sbank
                        and t-docsa.rko = integer(dep)
                        and t-docsa.typ = cl-mf
                        and t-docsa.val = remtrz.tcrc no-error.
   if not avail t-docsa then do:
         create t-docsa.
         assign t-docsa.id = t-docsa.id + 1
                t-docsa.fil = remtrz.sbank
                t-docsa.rko = integer(dep)
                t-docsa.typ = cl-mf
                t-docsa.val = remtrz.tcrc.
    end.
                t-docsa.sum = t-docsa.sum + remtrz.amt.
                t-docsa.kol = t-docsa.kol + 1.
   if remtrz.tcrc = 1 then do: itog[1] = itog[1] + remtrz.amt. ikol[1] = ikol[1] + 1. end.
   else if remtrz.tcrc = 2 then do: itog[2] = itog[2] + remtrz.amt. ikol[2] = ikol[2] + 1. end.
   else if remtrz.tcrc = 3 then do: itog[3] = itog[3] + remtrz.amt. ikol[3] = ikol[3] + 1. end.
   else if remtrz.tcrc = 4 then do: itog[4] = itog[4] + remtrz.amt. ikol[4] = ikol[4] + 1. end.
   else if remtrz.tcrc = 6 then do: itog[5] = itog[5] + remtrz.amt. ikol[5] = ikol[5] + 1. end.
   else if remtrz.tcrc = 7 then do: itog[7] = itog[7] + remtrz.amt. ikol[7] = ikol[7] + 1. end.
   else if remtrz.tcrc = 8 then do: itog[8] = itog[8] + remtrz.amt. ikol[8] = ikol[8] + 1. end.
   else if remtrz.tcrc = 9 then do: itog[9] = itog[9] + remtrz.amt. ikol[9] = ikol[9] + 1. end.



   find first t-docsa where t-docsa.fil = remtrz.sbank
                        and t-docsa.rko = integer(dep)
                        and t-docsa.typ = cl-mf
                        and t-docsa.cval = remtrz.svcrc no-error.
   if not avail t-docsa then do:
             find first t-docsa where t-docsa.fil = remtrz.sbank
                                  and t-docsa.rko = integer(dep)
                                  and t-docsa.typ = cl-mf
                                  and t-docsa.cval = 0 no-error.
             if not avail t-docsa then do:
                   create t-docsa.
                   assign t-docsa.id = t-docsa.id + 1
                          t-docsa.fil = remtrz.sbank
                          t-docsa.rko = integer(dep)
                          t-docsa.typ = cl-mf.
             end.
             t-docsa.cval = remtrz.svcrc.
    end.
    t-docsa.csum = t-docsa.csum + remtrz.svca.

    if remtrz.svcrc = 1 then itog1[1] = itog1[1] + remtrz.svca.
    else if remtrz.svcrc = 2 then itog1[2] = itog1[2] + remtrz.svca.
    else if remtrz.svcrc = 3 then itog1[3] = itog1[3] + remtrz.svca.
    else if remtrz.svcrc = 4 then itog1[4] = itog1[4] + remtrz.svca.
    else if remtrz.svcrc = 6 then itog1[5] = itog1[5] + remtrz.svca.
    else if remtrz.svcrc = 7 then itog1[7] = itog1[7] + remtrz.svca.
    else if remtrz.svcrc = 8 then itog1[8] = itog1[8] + remtrz.svca.
    else if remtrz.svcrc = 9 then itog1[9] = itog1[9] + remtrz.svca.
end.
end.
end.
/*
for each t-docsa break by t-docsa.fil by t-docsa.rko by t-docsa.typ by t-docsa.val.
  if first-of (t-docsa.fil) then
 displ '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' skip.
  displ fil_name(t-docsa.fil)
        def_dep(string(t-docsa.rko)) format 'x(15)'
        t-docsa.typ format 'x(3)'
        if t-docsa.val  = 0 then '' else def_valute(t-docsa.val) format 'x(3)'
        if t-docsa.sum  = 0 then '' else string(t-docsa.sum)
        if t-docsa.kol  = 0 then '' else string(t-docsa.kol)
        if t-docsa.cval = 0 then '' else def_valute(t-docsa.cval) format 'x(3)'
        if t-docsa.csum = 0 then '' else string(t-docsa.csum).
end.
*/

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Отчет по исходящим платежам"
 &size-add = "xx-"
}

put stream vcrpt unformatted
   "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по исходящим платежам <BR>в разрезе филиалов за период с " + string(v-dtb, "99/99/9999") +
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD rowspan = ""2"" ><FONT size=""2""><B>п/п</B></FONT></TD>" skip
     "<TD colspan = ""2"" rowspan = ""2"" ><FONT size=""2""><B>Наименование</B></FONT></TD>" skip
     "<TD rowspan = ""2"" ><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
     "<TD rowspan = ""2"" ><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD rowspan = ""2"" ><FONT size=""2""><B>Количество</B></FONT></TD>" skip
     "<TD colspan = ""2""><FONT size=""2""><B>Комиссия</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
   "</TR>" skip.

i = 0.

for each t-docsa break by t-docsa.fil by t-docsa.typ by t-docsa.val.

put stream vcrpt unformatted
   "<TR align=""center"">" skip.
 if t-docsa.fil = 'TXB00' then do:

     if first-of(t-docsa.fil) then do:
          i = i + 1.
          put stream vcrpt unformatted
         "<TD><FONT size=""2""><B>" i "</B></FONT></TD>" skip
          "<TD><FONT size=""2""><B>" fil_name(t-docsa.fil) "</B></FONT></TD>" skip.
     end.
     else do:
          put stream vcrpt unformatted
         "<TD><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip "<TD><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip.
     end.

       if first-of(t-docsa.typ) then
          put stream vcrpt unformatted
          "<TD><FONT size=""2""><B>" if t-docsa.typ = 'mf' then 'Межбанковские переводы' else 'Клиентские переводы' "</B></FONT></TD>" skip.
       else
          put stream vcrpt unformatted "<TD><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip.
  /*
    else do:
       if first-of(t-docsa.rko) then do:
       i = i + 1.
       put stream vcrpt unformatted
       "<TD><FONT size=""2""><B>" i "</B></FONT></TD>" skip
       "<TD colspan = ""2"" ><FONT size=""2""><B>" def_dep(string(t-docsa.rko)) "</B></FONT></TD>" skip.
       end.
       else
       put stream vcrpt unformatted
       "<TD><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip
       "<TD colspan = ""2"" ><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip.
    end.
  */
 end.
 else do:
     if first-of(t-docsa.fil) then do:
       i = i + 1.
       put stream vcrpt unformatted
       "<TD><FONT size=""2""><B>" i "</B></FONT></TD>" skip
       "<TD colspan = ""2"" ><FONT size=""2""><B>"  fil_name(t-docsa.fil) "</B></FONT></TD>" skip.
     end.
     else
       put stream vcrpt unformatted
       "<TD><FONT size=""2""><B>" ' ' "</B></FONT></TD>" skip
       "<TD colspan = ""2"" ><FONT size=""2"">" ' ' "</FONT></TD>" skip.
 end.

find first crc where crc.crc = t-docsa.val no-lock no-error.

put stream vcrpt unformatted
     "<TD><FONT size=""2"">" if t-docsa.val  = 0 then '' else crc.code "</FONT></TD>" skip
     "<TD><FONT size=""2"">" if t-docsa.sum  = 0 then '' else string(t-docsa.sum) "</FONT></TD>" skip
     "<TD><FONT size=""2"">" if t-docsa.kol  = 0 then '' else string(t-docsa.kol) "</FONT></TD>" skip
     "<TD><FONT size=""2"">" if t-docsa.cval = 0 then '' else def_valute(t-docsa.cval) format 'x(3)' "</FONT></TD>" skip
     "<TD><FONT size=""2"">" if t-docsa.csum = 0 then '' else string(t-docsa.csum) "</FONT></TD>" skip
   "</TR>" skip.

end.

put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD colspan = ""3"" rowspan = ""8""><FONT size=""2""><B>ИТОГО</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>KZT</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[1] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[1] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>KZT</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[1] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>USD</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[2] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[2] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>USD</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[2] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>EUR</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[3] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[3] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>EUR</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[3] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>RUB</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[4] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[4] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>RUB</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[4] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>GPB</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[5] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[5] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>GPB</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[5] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>SEK</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[7] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[7] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>SEK</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[7] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>AUD</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[8] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[8] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>AUD</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[8] "</FONT></TD>" skip
   "</TR>" skip.
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""2""><B>CHF</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog[9] "</FONT></TD>" skip
     "<TD><FONT size=""2"">" ikol[9] "</FONT></TD>" skip
     "<TD><FONT size=""2""><B>CHF</B></FONT></TD>" skip
     "<TD><FONT size=""2"">" itog1[9] "</FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.htm iexplore").

pause 0.
