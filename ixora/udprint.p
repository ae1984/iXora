/* udprint.p
 * MODULE
        Печать удостоверений клиентов
 * DESCRIPTION
        Печать удостоверений клиентов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        call.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        18/09/06 Ten 
 * CHANGES
*/

{global.i}
{get-dep.i}
def input parameter v-ind as char no-undo.
def var s-date as date label "С " no-undo.
def var e-date as date label "По " no-undo.
def var vdep like ppoint.depart no-undo.
def new shared var vpoint like ppoint.point.
def var v-u as int no-undo.
def var v-f as int  no-undo.
def var v-vip as int no-undo.
def var v-pr as int no-undo.
def var v-fr as char no-undo.
def var i as int no-undo.
def var v-iz as int no-undo.
def var v-izpr as int no-undo.
def var v-izpr1 as int no-undo.
def var v-dt as date no-undo.

def temp-table temp
         field code as char
         field ur as char
         field urkol as int.
def temp-table temp1 
         field rnn1 as char
         field code as char
         field rnn as char
         field acc as char
         field cif as char
         field name as char
         index code as primary code rnn1.

def var v-crc as char.
def button bexit label "exit".
def query q1 for temp scrolling.
def browse br1 query q1 
disp temp.ur label "Категория" format "x(40)" temp.urkol label "Количество" format "zzzzz"  with 4 down  separators.
define frame fr2
   br1  bexit  WITH 1 column at row 5 column 38  centered. 


if v-ind = "1" then do:
form vdep label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов'
  validate(can-find (ppoint where ppoint.depart = vdep no-lock),
  ' Ошибочный код департамента - повторите ! ') skip with frame ofc1 col 1 row 3
  2 col width 66.
  vpoint = 1.

  
update vdep with frame ofc1.  
update s-date e-date with frame ofc1 centered.

if e-date > g-today then do:
   message "Дата окончания не может быть больше текущей!!!".
   pause.
   retry.
end.
if e-date > g-today then do:
   message "Дата окончания не может быть больше текущей!!!".
   pause.
   retry.
end.

do v-dt = s-date to e-date:
for each aaa where aaa.regdt = v-dt no-lock.
    find first udcl of aaa no-lock no-error.
    if avail udcl and udcl.des = Yes then next.
    if (aaa.sta = "C" or aaa.sta = "E") then next.
    find cif of aaa no-lock no-error.
    if avail cif then do:
       if aaa.crc = 1 then v-crc = "(KZT)".
       else
       if aaa.crc = 2 then v-crc = "(USD)".
       else
       if aaa.crc = 11 then v-crc = "(EUR)".
       else
       if aaa.crc = 4 then v-crc = "(RUB)".

       if cif.type = "B" then do:
          if (aaa.lgr = "151" or aaa.lgr = "152" or aaa.lgr = "153" or aaa.lgr = "154" or  aaa.lgr = "157" or aaa.lgr = "158" or aaa.lgr = "171" or aaa.lgr = "172") then do:
              find udcl of aaa no-lock no-error.
              if not avail udcl then do:
                 create udcl.
                        udcl.aaa = aaa.aaa.
              end.
              find first temp1 where temp1.code = "ur" and temp1.rnn1 eq cif.jss exclusive-lock no-error.
              if not avail temp1 then do: 
                 v-u = v-u + 1.
                 create temp1.
                        temp1.code = "ur".
                        temp1.rnn = cif.jss.
                        temp1.acc = aaa.aaa + v-crc.
                        temp1.cif = cif.cif.
                        temp1.name = cif.name.
                        temp1.rnn1 = cif.jss.
             end.
             else do:
                  if int(num-entries(temp1.acc)) < 4 then temp1.acc = temp1.acc + ", " + aaa.aaa + v-crc.
                                                     else temp1.rnn1 = temp1.rnn1 + "f".
             end.
          end.
       end.
       else 
       if cif.type = "P" then do:
          if (aaa.lgr = "202" or aaa.lgr = "204" or aaa.lgr = "222" or aaa.lgr = "208") then do:
             find udcl of aaa no-lock no-error.
             if not avail udcl then do:
                create udcl.
                       udcl.aaa = aaa.aaa.
             end.
             if cif.mname eq "VIP" then do:
                find first temp1 where temp1.code = "vip" and temp1.rnn1 eq cif.jss exclusive-lock no-error.
                if not avail temp1 then do:
                   v-vip = v-vip + 1.
                   create temp1.
                          temp1.code = "vip".
                          temp1.rnn = cif.jss.
                          temp1.acc = aaa.aaa + v-crc.
                          temp1.cif = cif.cif.
                          temp1.name = cif.name.
                          temp1.rnn1 = cif.jss.
                end.
                else do:
                     if int(num-entries(temp1.acc)) < 4 then temp1.acc = temp1.acc + ", " + aaa.aaa + v-crc.
                                                        else temp1.rnn1 = temp1.rnn1 + "f".
                end.
             end.
             else do:
                  find first temp1 where temp1.code = "fiz" and temp1.rnn1 eq cif.jss exclusive-lock no-error.
                  if not avail temp1 then do:
                     v-f = v-f + 1.
                     create temp1.
                            temp1.code = "fiz".
                            temp1.rnn = cif.jss.
                            temp1.acc = aaa.aaa + v-crc.
                            temp1.cif = cif.cif.
                            temp1.name = cif.name.
                            temp1.rnn1 = cif.jss.
                  end.
                  else do:
                       if int(num-entries(temp1.acc)) > 3 then temp1.acc = temp1.acc + ", " + aaa.aaa + v-crc.
                                                          else temp1.rnn1 = temp1.rnn1 + "f".
                  end.
             end.
          end.
          else 
          if aaa.lgr = "415" then do:
             find udcl of aaa no-lock no-error.
             if not avail udcl then do:
                create udcl.
                       udcl.aaa = aaa.aaa.
             end.
             find first temp1 where temp1.code = "pr" and temp1.rnn eq cif.jss exclusive-lock no-error.
             if not avail temp1 then do:
                v-pr = v-pr + 1.
                create temp1.
                       temp1.code = "pr".
                       temp1.name = cif.name.    /* ФИО */
                       temp1.rnn = aaa.aaa.
                       temp1.rnn1 = cif.pss.     /* номер дата выдачи кем выдано */
                       temp1.acc = string(aaa.expdt).     /* дата закрытия счета */
             end.
          end.
       end.
    end.
end.
end.
create temp.
       temp.code = "ur".
       temp.ur = "Юридические лица ".
       temp.urkol = v-u.           
create temp.
       temp.code = "fiz".
       temp.ur = "Физические лица ".
       temp.urkol = v-f.
create temp.
       temp.code = "vip".
       temp.ur = "Физические лица (VIP)".
       temp.urkol = v-vip.
create temp.
       temp.code = "pr".
       temp.ur = "Клиенты депозитария(гр. 415)".
       temp.urkol = v-pr.
end.
else do:
     v-iz = 0.
     update v-fr label "Введите номер счета" format "x(9)" with frame fr centered.
     find aaa where aaa.aaa eq v-fr no-lock no-error.
     if avail aaa then do:
        find first udcl of aaa no-lock no-error.
        if avail udcl and udcl.des = Yes then do:
           message "По данному счету уже было выдано удостоверение". pause.
           undo,retry.
        end.
        find cif of aaa no-lock no-error.
        if avail cif then do:
           if aaa.crc = 1 then v-crc = "(KZT)".
           else
           if aaa.crc = 2 then v-crc = "(USD)".
           else
           if aaa.crc = 11 then v-crc = "(EUR)".
           else
           if aaa.crc = 4 then v-crc = "(RUB)".

           if aaa.lgr = "415" then do:
              find udcl of aaa no-lock no-error.
              if not avail udcl then do:
                 create udcl.
                        udcl.aaa = aaa.aaa.
              end.
              v-izpr = 1.
              create temp1.
                     temp1.code = "izpr".
                     temp1.name = cif.name.    /* ФИО */
                     temp1.rnn = aaa.aaa.
                     temp1.rnn1 = cif.pss.     /* номер дата выдачи кем выдано */
                     temp1.acc = string(aaa.expdt).     /* дата закрытия счета */
              for each uplcif where uplcif.cif = cif.cif and uplcif.coregdt <= g-today and uplcif.finday >= g-today no-lock.
                  v-izpr1 = v-izpr1 + 1.
                  create temp1.
                         temp1.code = "izpr1".
                         temp1.name = uplcif.badd[1].                      /* ФИО */
                         temp1.rnn1 = uplcif.badd[2] + uplcif.badd[3].     /* номер дата выдачи кем выдано */
                         temp1.acc = string(aaa.expdt).                    /* дата закрытия счета */

              end.
           end.
           else do:
                find udcl of aaa no-lock no-error.
                if not avail udcl then do:
                   create udcl.
                          udcl.aaa = aaa.aaa.
                end.
                v-iz = 1.
                create temp1.
                       temp1.code = "iz".
                       temp1.rnn = cif.jss.
                       temp1.acc = aaa.aaa + v-crc.
                       temp1.cif = cif.cif.
                       temp1.name = cif.name.
           end.
        end.
     end.
     else do:
          message "Счет не найден!".
          pause.
          undo,retry.
     end.
     create temp.
            temp.code = "iz".
            temp.ur = "Индивидуальный заказ".
            temp.urkol = v-iz.           
     create temp.
            temp.code = "izpr".
            temp.ur = "Индивидуальный заказ (клиент депозитария)".
            temp.urkol = v-izpr.           
     create temp.
            temp.code = "izpr1".
            temp.ur = "Довереные лица".
            temp.urkol = v-izpr1.           

end.

for each temp where temp.urkol > 0 no-lock.
    i = i + 1.
end.
if i = 0 then do:
   message "Нет информации!".
   pause.
   undo,return.
end.
else
open query q1 for each temp.
on  "enter" of browse br1 do:
    if temp.urkol = 0 then do:
       message "Нет информации!".
       pause.
       undo,return.
    end.
    else do:
    output to ttt.htm.
    put unformatted  "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                     "<head><title>TEXAKABANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip
                     "</head><body>" skip.

    if temp.code = "pr" or temp.code = "izpr" or  temp.code = "izpr1" then do:
       put unformatted        	
                       "<TABLE width=""100%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
                       "<tr><TD   bgcolor=""#95B2D1"" valign = ""top""> ФИО  </FONT></TD>" skip
                       "    <TD   bgcolor=""#95B2D1"" valign = ""top""> N документа</FONT></TD>" skip
                       "    <TD   bgcolor=""#95B2D1"" valign = ""top""> Дата  </FONT></TD>" skip
                       "    <TD   bgcolor=""#95B2D1"" valign = ""top""> Кем </FONT></TD>" skip
                       "    <TD   bgcolor=""#95B2D1"" valign = ""top""> Действ.до </FONT></TD>" skip
                       "</tr>" skip.
       for each temp1 where temp1.code eq temp.code no-lock.
           find first udcl where udcl.aaa eq temp1.rnn exclusive-lock no-error.
           if avail udcl then udcl.des = Yes.
           put unformatted  "<tr><td>" temp1.name  "</td>" skip
                            "    <td>" temp1.rnn1  "</td><td></td><td></td>" skip
                            "    <td>" temp1.acc  "</td>" skip
                            "</tr>" skip.

       end.
       put unformatted "</table>" skip.
    end.
    else do:
         put unformatted        	
                          "<TABLE width=""100%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
                          "<tr><TD   bgcolor=""#95B2D1"" valign = ""top"">РНН  </FONT></TD>" skip
                          "    <TD   bgcolor=""#95B2D1"" valign = ""top"">Счета</FONT></TD>" skip
                          "    <TD   bgcolor=""#95B2D1"" valign = ""top"">Код  </FONT></TD>" skip
                          "    <TD   bgcolor=""#95B2D1"" valign = ""top"">ФИО  </FONT></TD>" skip
                          "</tr>" skip.

         for each temp1 where temp1.code eq temp.code no-lock break by temp1.rnn.
             if int(num-entries(temp1.acc,",")) = 1 then do:
                find first udcl where udcl.aaa = substring(temp1.acc,1,9) exclusive-lock no-error.
                if avail udcl then udcl.des = Yes.
             end.
             else do:
                  i = 0.
                do i = 1 to int(num-entries(temp1.acc,",")):
                   find first udcl where udcl.aaa = substring(entry(i,temp1.acc),1,9) exclusive-lock no-error.
                   if avail udcl then udcl.des = Yes.
                end.
             end.
             put unformatted  "<tr><td>" temp1.rnn  "</td>" skip
                              "    <td>" temp1.acc  "</td>" skip
                              "    <td>" temp1.cif  "</td>" skip
                              "    <td>" temp1.name "</td></tr>" skip.
         end.
         put unformatted "</table>" skip.
    end.
    unix silent cptwin ttt.htm excel.
    output to tt1.htm.
    put unformatted  "<html xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"">"   skip
                     "<head><title>TEXAKABANK</title>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru"">"  skip
                     "</head><body>" skip.
    put unformatted  "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                     "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "  today "<br><br><br><br>" skip
                     "<center>&nbsp &nbsp &nbsp &nbsp <b> Акт - приема передачи удостоверений клиентов. <br>" skip
                     "(юридические лица/физические лица/VIP клиенты/пропуски для депозитария)<br><br><br><br></center>" skip
                     "Операционный департамент (СПФ)</b><br>" skip.
    put unformatted  "<table width=""100%"" border=""1"" cellspacing=""1"" cellpadding=""3"">" skip
                     "<tr><TD   bgcolor=""#95B2D1"" valign = ""top"">N  </FONT></TD>" skip
                     "    <TD   bgcolor=""#95B2D1"" valign = ""top"">Наименование/ФИО</FONT></TD>" skip
                     "    <TD   bgcolor=""#95B2D1"" valign = ""top"">Т Код  </FONT></TD>" skip
                     "    <TD   bgcolor=""#95B2D1"" valign = ""top"">РНН клиента  </FONT></TD>" skip
                     "    <TD   bgcolor=""#95B2D1"" valign = ""top"">ИИК клиента  </FONT></TD>" skip
                     "</tr>" skip.
         i = 0.
         for each temp1 where temp1.code eq temp.code no-lock break by temp1.rnn.
             i = i + 1.
                  put unformatted  "<tr><td>" i          "</td>" skip
                                   "    <td>" temp1.name  "</td>" skip
                                   "    <td>" temp1.cif  "</td>" skip
                                   "    <td>" temp1.rnn  "</td>" skip
                                   "    <td>" temp1.acc "</td></tr>" skip.
         end.
         put unformatted "</table>" skip.
         put unformatted "<br><br><br><br><b> Передал: "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp "
                         "&nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp &nbsp Принял: </b>" skip.
         unix silent cptwin tt1.htm winword.
    end.
end.
on choose of bexit do:
   leave.
end.
enable all with frame fr2.
wait-for choose of bexit.


