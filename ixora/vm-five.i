def temp-table tmp-main
     field crc      like crc.crc
     field ccrc     like crc.code
     field insumm   as deci
     field inovnt   as deci
     field allin    as deci
     field allout   as deci
     field allout2  as deci
     field summfact as deci
     field summprog as deci.

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Свод по валютам".
run lgps .

for each tmp-bal no-lock break by tmp-bal.crc.

     accumulate tmp-bal.inbal    (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.inovnt   (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.dam-amt  (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.cam-amt  (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.lev-amt  (TOTAL by tmp-bal.crc).

     if last-of (tmp-bal.crc) then do:
          create tmp-main.
          tmp-main.crc       = tmp-bal.crc.
          tmp-main.ccrc      = tmp-bal.ccrc.
          tmp-main.insumm    = accum total by (tmp-bal.crc) tmp-bal.inbal.
          tmp-main.inovnt    = accum total by (tmp-bal.crc) tmp-bal.inovnt. 
          tmp-main.allin     = accum total by (tmp-bal.crc) tmp-bal.cam-amt.
          tmp-main.allout    = accum total by (tmp-bal.crc) tmp-bal.dam-amt.
          tmp-main.summfact  = tmp-main.insumm + tmp-main.inovnt + tmp-main.allin - tmp-main.allout - (accum total by (tmp-bal.crc) tmp-bal.lev-amt).
          tmp-main.summprog  = tmp-main.summfact.  
     end.

     for each tmp-out2 break by tmp-out2.crc. 
           accumulate tmp-out2.amt  (TOTAL by tmp-out2.crc).

           if last-of(tmp-out2.crc) then do:
              find first tmp-main where tmp-main.crc = tmp-out2.crc no-lock no-error.
              if avail tmp-main then do:  
                 tmp-main.allout2   = accum total by (tmp-out2.crc) tmp-out2.amt.
                 tmp-main.summprog  = tmp-main.summfact - tmp-main.allout2.
              end.    
           end.
    end.
end.

put stream m-outdt unformatted      
  "<TABLE bgColor=#ffffff border=0 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""100%"">"                                  skip 
       "<TBODY><TR><TD vAlign=top>"                                    skip.

put stream m-outdt unformatted
     "    <FORM name=""BT"">                                                                                        " skip
     "    <input type=""button"" name =""gotop"" value=""TOP""   onclick=""GoToVM(1)""  style=""width: 46px""><br>  " skip
     "    <input type=""button"" name =""gotop"" value=""IN""    onclick=""GoToVM(2)"" style=""width:  46px""><br>  " skip
     "    <input type=""button"" name =""gotop"" value=""OUT""   onclick=""GoToVM(3)""  style=""width: 46px""><br>  " skip
     "    <input type=""button"" name =""gotop"" value=""OUT2""  onclick=""GoToVM(4)""  style=""width: 46px""><br>  " skip
/*     "    <input type=""button"" name =""gotop"" value=""SWIFT"" onclick=""GoToVM(5)""  style=""width: 46px""><br>  " skip
     "    <input type=""button"" name =""gotop"" value=""TRF""   onclick=""GoToVM(6)""  style=""width: 46px""><br>  " skip
*/
     "    </FORM></TD><TD>                                                                                                   ". 
     
                  put stream m-outdt unformatted      
                     "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
                        "cellSpacing=0 width=""100%"">"                                   skip 
                         " <TBODY>"                                                       skip.
                  put stream m-outdt unformatted      
                     "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B> "  skip
                     "          <TD>Валюта</TD>                                                                "  skip
                     "          <TD>Входящий <br>суммарный<br>остаток<br>(в том числе овернайт)</TD>                                     "  skip
/*                     "          <TD>Сумма <br>Овернайта</TD>                                                   "  skip*/
                     "          <TD>Сумма <br>входящих <br>платежей</TD>                                       "  skip
                     "          <TD>Сумма <br>исходящих<br>платежей</TD>                                       "  skip
                     "          <TD>Сумма <br>исходящих<br>платежей <br>(первичный ввод)</TD>                  "  skip
                     "          <TD>Суммарный <br>фактический <br>остаток                        </TD>         "  skip
                     "          <TD>Суммарный <br>прогнозный  <br>остаток                        </TD>         "  skip
                     "        </TR>                                                                            "  skip.

                  for each tmp-main break by tmp-main.crc.
                  put stream m-outdt unformatted      
                     "        <TR>                                                                           "  skip 
                     "          <TD vAlign=top title=""Валюта""><b><font size=1><a href=#crc" tmp-main.crc " onClick=""GoToCRC(" tmp-main.crc ")"">" tmp-main.ccrc "</font></a></b></TD>" skip
                     "          <TD vAlign=top Align=right title=""Входящий суммарный остаток""><b><font size=1>" string(tmp-main.insumm  + tmp-main.inovnt  , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
/*                     "          <TD vAlign=top Align=right title=""Сумма Овернайта""><b><font size=1>" string(tmp-main.inovnt   , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip*/
                     "          <TD vAlign=top Align=right title=""Сумма входящих платежей""><b><font size=1>" string(tmp-main.allin    , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
                     "          <TD vAlign=top Align=right title=""Сумма исходящих платежей""><b><font size=1>" string(tmp-main.allout   , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
                     "          <TD vAlign=top Align=right title=""Сумма исходящих платежей (первичный ввод)""><b><font size=1>" string(tmp-main.allout2  , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
                     "          <TD vAlign=top Align=right title=""Суммарный фактический остаток""><b><font size=1>" string(tmp-main.summfact , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
                     "          <TD vAlign=top Align=right title=""Суммарный прогнозный  остаток""><b><font size=1>" string(tmp-main.summprog , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
                     "        </TR>                                                                                             "  skip.
                  end.

                  put stream m-outdt unformatted      
                     "</TBODY></TABLE>".
put stream m-outdt unformatted      
   "</TD><TR></TBODY></TABLE>".

put stream m-out unformatted      
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""100%"">"                                   skip 
       " <TBODY>"                                                       skip.

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Свод по корр.счетам".
run lgps .

put stream m-out unformatted      
   "<H2><a name=""1"">Остатки</H2>".

put stream m-out unformatted      
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""65%"">"                                   skip 
       " <TBODY>"                                                       skip.

put stream m-out unformatted      
   "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B> "  skip
/*   "          <TD>Счет</TD>                                                                  "  skip */
   "          <TD>БАНК</TD>                                                                  "  skip 
/*   "          <TD>Код</TD>                                                                   "  skip */
/*   "          <TD>Валюта</TD>                                                                "  skip*/
/*   "          <TD>Входящий<br>Остаток<br>Прагма</TD>                                         "  skip*/
   "          <TD>Входящий<br>Остаток<br>Выписка</TD>                                        "  skip
/*   "          <TD>Овернайт</TD>                                                              "  skip*/
   "          <TD>Сумма <br> Входящих   <br> платежей    </TD>                               "  skip
   "          <TD>Сумма <br> Исходящих  <br> платежей    </TD>                               "  skip
   "          <TD>Сумма <br> Неснижаемого <br> отстатка  </TD>                               "  skip
   "          <TD>Прогнозная <br>сумма к <br> пользованию</TD>                               "  skip
   "          </TR>" .
for each tmp-bal no-lock break by tmp-bal.crc.
     tmp-bal.prog-amt = tmp-bal.inbal + tmp-bal.inovnt + tmp-bal.cam-amt - tmp-bal.dam-amt - tmp-bal.lev-amt.
     accumulate tmp-bal.prog-amt (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.inbal    (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.dam-amt  (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.cam-amt  (TOTAL by tmp-bal.crc).
     accumulate tmp-bal.inovnt   (TOTAL by tmp-bal.crc).

     if first-of (tmp-bal.crc) then do:
                 put stream m-out unformatted                     
                    "        <TR>                                                      "  skip 
                    "          <TD colspan=""6"" align=center><font size=2><a name=crc" tmp-bal.crc ">" tmp-bal.ccrc  "</a></font></TD> "  skip 
                    "        </TR>                                                      "  skip.
    end.

     put stream m-out unformatted                                           
        "        <TR>                                                      "  skip 
/*        "          <TD bgcolor=""#ECF1F7"" vAlign=top title=""Счет"">" tmp-bal.acc "</TD> "  skip */
        "          <TD vAlign=top title=""БАНК"">" tmp-bal.name /* " (" tmp-bal.nostro  ") */"</TD>                  "  skip 
/*        "          <TD vAlign=top title=""Код"">" tmp-bal.bank   "</TD>                  "  skip */
/*        "          <TD vAlign=top title=""Валюта"">" tmp-bal.ccrc   "</TD>                  "  skip*/
/*        "          <TD vAlign=top title=""Входящий Остаток Прагма""><b>" string(tmp-bal.inprg   , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip */
        "          <TD vAlign=top Align=right title=""Входящий Остаток Выписка""><b><a href=#swid" tmp-bal.swid ">" string((tmp-bal.inbal  + tmp-bal.inovnt)  , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
/*        "          <TD vAlign=top Align=right title=""Овернайт ""><b>" string(tmp-bal.inovnt  , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip*/
        "          <TD vAlign=top Align=right title=""Сумма Входящих платежей""><b><a href=#in"  tmp-bal.bank ">" string(tmp-bal.cam-amt , "->>>,>>>,>>>,>>9.99")    "</b></TD>"      skip
        "          <TD vAlign=top Align=right title=""Сумма Исходящих платежей""><b><a href=#out" tmp-bal.bank ">" string(tmp-bal.dam-amt , "->>>,>>>,>>>,>>9.99")    "</a></b></TD>"  skip
        "          <TD vAlign=top Align=right title=""Сумма Неснижаемого отстатка""><b>" string(tmp-bal.lev-amt , "->>>,>>>,>>>,>>9.99")    "</b></TD>"  skip
        "          <TD vAlign=top Align=right title=""Прогнозная сумма к пользованию""><b>" if tmp-bal.prog-amt < 0 then "<font color=""red"">" else "" string(tmp-bal.prog-amt, "->>>,>>>,>>>,>>9.99")    
                                       if tmp-bal.prog-amt < 0 then "</font>" else "" "</b></TD>"  skip
        "        </TR>                                                                           "  skip.

        if last-of (tmp-bal.crc) then do:
                    put stream m-out unformatted                     
                       "        <TR>                         "  skip 
                       "          <TD><b>Всего по</b></TD>   "  skip 

/*                     "          <TD></TD>                  "  skip 
                       "          <TD></TD>                  "  skip 
*/
/*                       "          <TD title=""Валюта""><b>" tmp-bal.ccrc         "</b></TD>" skip
                       "          <TD></TD>"  skip                                                 */
                       "          <TD vAlign=top Align=right title=""Входящий Остаток Выписка""><b>" string ( (accum total by (tmp-bal.crc) tmp-bal.inbal) + (accum total by (tmp-bal.crc) tmp-bal.inovnt),   "->>>,>>>,>>>,>>9.99")  "</b></TD>" skip
/*                       "          <TD vAlign=top Align=right title=""Овернайт""><b>" string(accum total by (tmp-bal.crc) tmp-bal.inovnt,  "->>>,>>>,>>>,>>9.99")  "</b></TD>" skip*/
                       "          <TD vAlign=top Align=right title=""Сумма Исходящих платежей""><b>" string(accum total by (tmp-bal.crc) tmp-bal.dam-amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>" skip
                       "          <TD vAlign=top Align=right title=""Сумма Входящих платежей""><b>" string(accum total by (tmp-bal.crc) tmp-bal.cam-amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>" skip
                       "          <TD></TD>"  skip
                       "          <TD vAlign=top title=""Прогнозная сумма к пользованию""><b>" string(accum total by (tmp-bal.crc) tmp-bal.prog-amt,"->>>,>>>,>>>,>>9.99")  "</b></TD>" skip
                       "        </TR>                                                     "  skip.
        end.
end.
put stream m-out unformatted      
   "</TBODY></TABLE>".

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Входящие".
run lgps .

put stream m-out unformatted      
   "<H2><a name=""2"">Входящие платежи </a> </H2>"   
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""65%"">"                                    skip 
       " <TBODY>"                                                       skip.

put stream m-out unformatted                                                                  
   "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B>  "  skip
   "          <TD></TD>                                                                       "  skip
   "          <TD>Референс</TD>                                                               "  skip
   "          <TD>Валюта</TD>                                                                 "  skip
   "          <TD>Банк Отправитель</TD>                                                       "  skip
   "          <TD>Отправитель</TD>                                                            "  skip
   "          <TD>Банк корреспондент</TD>                                                     "  skip
   "          <TD>Бенефициар</TD>                                                             "  skip
   "          <TD>Дата Вал.</TD>                                                              "  skip
   "          <TD>Сумма</TD>                                                                  "  skip
   "          <TD>Время</TD>                                                                  "  skip
   "          <TD>Статус</TD>                                                                 "  skip.

for each tmp-in break by tmp-in.crc by tmp-in.sbank by tmp-in.stsl by tmp-in.amt.
     
         accumulate tmp-in.amt  (TOTAL by tmp-in.crc by tmp-in.sbank by tmp-in.stsl).
         if first-of (tmp-in.sbank) then do:
                 put stream m-out unformatted                     
                    "        <TR>                                                      "  skip 
                    "          <TD colspan=""10"" align=center><font size=2><a name=in" tmp-in.sbank ">" tmp-in.sbank  "</a></font></TD> "  skip 
                    "        <TR>                                                      "  skip.
         end.


              put stream m-out unformatted                                           
                 "        <TR " if tmp-in.stsl then "bgcolor=""#ECF1F7""" else " " ">"  skip 
                 "          <TD><img src=images/down.gif>"  "</TD> "  skip 
                 "          <TD vAlign=top title=""Референс"">" tmp-in.remtrz    "</TD>         "  skip 
                 "          <TD vAlign=top title=""Валюта"">" tmp-in.ccrc       "</TD>         "  skip 
                 "          <TD vAlign=top title=""Банк Отправитель"">" tmp-in.sbank     "</TD>         "  skip 
                 "          <TD vAlign=top title=""Отправитель"">" tmp-in.ord       "</TD>         "  skip
                 "          <TD vAlign=top title=""Банк корреспондент"">" tmp-in.rcbank    "</TD>         "  skip
                 "          <TD vAlign=top title=""Бенефициар"">" tmp-in.rbank     "</TD>         "  skip
                 "          <TD vAlign=top title=""Дата Вал. "">" tmp-in.valdt1     "</TD>         "  skip
                 "          <TD vAlign=top Align=right  title=""Сумма""><b>" string(tmp-in.amt, "->>>,>>>,>>>,>>9.99") "</b></TD>     "  skip
                 "          <TD vAlign=top title=""Время"">" string( tmp-in.rtim ,"HH:MM:SS")"</TD>"skip
                 "          <TD vAlign=top title=""Статус"">" tmp-in.sts   "</TD>             "  skip
                 "        <TR>                                               "  skip.
         if last-of (tmp-in.sbank) then do:
                     put stream m-out unformatted                                           
                        "        <TR>                                  "  skip 
                        "          <TD></TD>  "  skip
                        "          <TD vAlign=top><b>Всего по </b></TD>  "  skip 
                        "          <TD></TD>                           "  skip
                        "          <TD vAlign=top title=""Банк Отправитель""><b>" tmp-in.sbank "</b></TD>         "  skip 
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top Align=right  title=""Сумма""><b>" string(accum total by (tmp-in.sbank) tmp-in.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                        "          <TD vAlign=top>"  "</TD>          "  skip
                        "          <TD vAlign=top>"     "</TD>       "  skip
                        "        <TR>                                "  skip.
        end.

         if last-of (tmp-in.stsl) and tmp-in.stsl then do:
                     put stream m-out unformatted                                           
                        "        <TR>                                  "  skip 
                        "          <TD></TD>  "  skip
                        "          <TD vAlign=top><b>Из них к пользованию </b></TD>  "  skip 
                        "          <TD></TD>                           "  skip
                        "          <TD vAlign=top><b>"  "</b></TD>         "  skip 
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top Align=right  title=""Сумма""><b>" string(accum total by (tmp-in.stsl) tmp-in.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                        "          <TD vAlign=top>"  "</TD>          "  skip
                        "          <TD vAlign=top>"     "</TD>       "  skip
                        "        <TR>                                "  skip.
        end.


         if last-of (tmp-in.crc) then do:
                     put stream m-out unformatted                                           
                        "        <TR>                                  "  skip 
                        "          <TD></TD>  "  skip
                        "          <TD vAlign=top><b>Всего по</b></TD> "  skip 
                        "          <TD title=""Валюта"">" tmp-in.ccrc "</TD>            "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip 
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top>"     "</TD>         "  skip
                        "          <TD vAlign=top Align=right  title=""Сумма""><b>" string(accum total by (tmp-in.crc) tmp-in.amt, "->>>,>>>,>>>,>>9.99") "</b></TD>"  skip
                        "          <TD vAlign=top>"  "</TD>          "  skip
                        "          <TD vAlign=top>"     "</TD>       "  skip
                        "        <TR>                                "  skip.
        end.
end.
put stream m-out unformatted      
   "</TBODY></TABLE>".

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Исходящие".
run lgps .

put stream m-out unformatted      
   "<H2><a name=""3"">Исходящие платежи </a> </H2>"   
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""65%"">"                                    skip 
       " <TBODY>"                                                       skip.

put stream m-out unformatted                                                                  
   "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B>  "  skip
   "          <TD></TD> "  skip 
   "          <TD>Референс</TD>                                                               "  skip
   "          <TD>Валюта</TD>                                                                 "  skip
   "          <TD>Банк Отправитель</TD>                                                       "  skip
   "          <TD>Отправитель</TD>                                                            "  skip
   "          <TD>Банк корреспондент</TD>                                                     "  skip
   "          <TD>Бенефициар</TD>                                                             "  skip
   "          <TD>Дата Вал.</TD>                                                             "  skip
   "          <TD>Сумма</TD>                                                                  "  skip
   "          <TD>Время</TD>                                                                  "  skip
   "          <TD>Статус</TD>                                                                 "  skip.

for each tmp-out break by tmp-out.crc by tmp-out.ccrc by tmp-out.rcbank by tmp-out.stsl by tmp-out.amt.
         accumulate tmp-out.amt  (TOTAL by tmp-out.crc by tmp-out.rcbank by tmp-out.stsl ).
   
         if tmp-out.stsl then 
            accumulate tmp-out.amt (TOTAL by tmp-out.ccrc).

         if first-of (tmp-out.rcbank) then do:
                 put stream m-out unformatted                     
                    "        <TR>                                                      "  skip 
                    "          <TD colspan=""10"" align=center><font size=2><a name=out" tmp-out.rcbank ">" tmp-out.rcbank  "</a></font></TD> "  skip 
                    "        <TR>                                                      "  skip.
         end.


              put stream m-out unformatted                                           
                 "        <TR " if tmp-out.stsl then "bgcolor=""#ECF1F7""" else " " ">    "  skip 
                 "          <TD><img src=images/up.gif>"  "</TD> "  skip 
                 "          <TD vAlign=top title=""Референс"">" tmp-out.remtrz    "</TD>         "  skip 
                 "          <TD vAlign=top title=""Валюта"">" tmp-out.ccrc      "</TD>         "  skip 
                 "          <TD vAlign=top title=""Банк Отправитель"">" tmp-out.sbank     "</TD>         "  skip 
                 "          <TD vAlign=top title=""Отправитель"">" tmp-out.ord       "</TD>         "  skip
                 "          <TD vAlign=top title=""Банк корреспондент"">" tmp-out.rcbank    "</TD>         "  skip
                 "          <TD vAlign=top title=""Бенефициар"">" tmp-out.rbank     "</TD>         "  skip
                 "          <TD vAlign=top title=""Дата Вал."">" tmp-out.valdt1     "</TD>         "  skip
                 "          <TD vAlign=top Align=right  title=""Сумма""><b>"  string (tmp-out.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>      "  skip
                 "          <TD vAlign=top title=""Время"">" string(tmp-out.rtim  ,"HH:MM:SS")"</TD>"skip
                 "          <TD vAlign=top title=""Статус"">"  tmp-out.sts   "</TD>       "  skip
                 "        <TR>                                           "  skip.

         if last-of (tmp-out.rcbank) then do:
               put stream m-out unformatted                             
                       "        <TR>                                  "  skip 
                       "          <TD></TD>  "  skip
                       "          <TD vAlign=top><b>Всего по </b></TD>"  skip 
                       "          <TD><b>"  "</b></TD>                "  skip
                       "          <TD></TD>  "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top title=""Бенефициар""><b>" tmp-out.rcbank  "</b></TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top Align=right  title=""Сумма""><b>" string (accum total by (tmp-out.rcbank) tmp-out.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "        <TR>                                  "  skip.
         end.

         if last-of (tmp-out.stsl) and tmp-out.stsl  then do:
               put stream m-out unformatted                             
                       "        <TR>                                  "  skip 
                       "          <TD></TD>  "  skip
                       "          <TD vAlign=top><b>Из них отправлено </b></TD>"  skip 
                       "          <TD><b>"  "</b></TD>                "  skip
                       "          <TD></TD>                           "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>      </TD>          "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top Align=right  title=""Сумма""><b>" string (accum total by (tmp-out.stsl) tmp-out.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "        <TR>                                  "  skip.
         end.


         if last-of (tmp-out.crc) then do:
               put stream m-out unformatted                             
                       "        <TR>                                  "  skip 
                       "          <TD></TD>  "  skip
                       "          <TD vAlign=top><b>Всего по </b></TD>   "  skip 
                       "          <TD title=""Валюта""><b>" tmp-out.ccrc "</b></TD>                           "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip 
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top Align=right  title=""Сумма""><b>" string (accum total by (tmp-out.crc) tmp-out.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "        <TR>                                  "  skip.
               put stream m-out unformatted                             
                       "        <TR>                                  "  skip 
                       "          <TD></TD>  "  skip
                       "          <TD vAlign=top><b>Из них отправлено </b></TD>   "  skip 
                       "          <TD title=""Валюта""><b>" tmp-out.ccrc "</b></TD>                           "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip 
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top Align=right  title=""Сумма""><b>" string (accum total by (tmp-out.ccrc) tmp-out.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>"  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "          <TD vAlign=top>"     "</TD>         "  skip
                       "        <TR>                                  "  skip.

        end.
end.
put stream m-out unformatted      
   "</TBODY></TABLE>".

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Исходящие прогнозные".
run lgps .

put stream m-out unformatted      
   "<H2><a name=""4"">Исходящие платежи (первичный ввод) </H2>"   
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""65%"">"                                    skip 
       " <TBODY>"                                                       skip.

put stream m-out unformatted      
   "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B> "  skip
   "          <TD></TD>                                                                      "  skip
   "          <TD>Платеж</TD>                                                                "  skip
   "          <TD>Дата Вал.</TD>                                                                "  skip
   "          <TD>Источник</TD>                                                              "  skip
   "          <TD>Валюта</TD>                                                                "  skip
   "          <TD>Отправитель</TD>                                                           "  skip
   "          <TD>Счет отправителя</TD>                                                      "  skip
   "          <TD>Сумма</TD>                                                                 "  skip.

for each tmp-out2 break by tmp-out2.crc by tmp-out2.amt by tmp-out2.valdt.

           if tmp-out2.valdt = g-today then accumulate tmp-out2.amt  (TOTAL by tmp-out2.crc).

           put stream m-out unformatted                                           
              "        <TR"  if tmp-out2.valdt <> g-today then "bgcolor=""#ECF1F7""" else " " ">"  skip 
              "          <TD><img src=images/up.gif>"  "</TD>                   "  skip 
              "          <TD vAlign=top title=""Платеж"">"             tmp-out2.remtrz     "</TD>                "  skip 
              "          <TD vAlign=top title=""Дата валютирования"">" tmp-out2.valdt     "</TD>                "  skip 
              "          <TD vAlign=top title=""Источник"">"         tmp-out2.pid        "</TD>                "  skip 
              "          <TD vAlign=top title=""Валюта"">"           tmp-out2.ccrc        "</TD>                "  skip 
              "          <TD vAlign=top title=""Отправитель"">"      tmp-out2.ord        "</TD>                "  skip 
              "          <TD vAlign=top title=""Счет отправителя"">" tmp-out2.dracc      "</TD>                "  skip
              "          <TD vAlign=top Align=right  title=""Сумма""><b>"         string(tmp-out2.amt, "->>>,>>>,>>>,>>9.99") "</b></TD>           "  skip
              "        <TR>                                                   "  skip.

           if last-of(tmp-out2.crc) then do:
              put stream m-out unformatted                                       
                 "        <TR>                                              "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip 
                 "          <TD vAlign=top> Итого      </TD>                "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip 
                 "          <TD vAlign=top>"          "</TD>                "  skip
                 "          <TD vAlign=top Align=right  title=""Сумма""><b>" string ( accum total by (tmp-out2.crc) tmp-out2.amt, "->>>,>>>,>>>,>>9.99")  "</b></TD>    "  skip
                 "        <TR>                                              "  skip.
           end.
end.
put stream m-out unformatted      
   "</TBODY></TABLE>".

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i СВИФТ".
run lgps .
/*
put stream m-out unformatted      
   "<H2><a name=""5"">SWIFT </a> </H2><br>"                              skip 
   "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
      "cellSpacing=0 width=""70%"">"                                    skip 
       " <TBODY>"                                                       skip.

put stream m-out unformatted      
   "        <TR bgColor=#afcbfd borderColor=#d8e4f8 cellPadding=""1""  cellSpacing=""0""><B> "  skip
   "          <TD>Тип</TD>                                                                   "  skip
   "          <TD>Файл</TD>                                                                  "  skip
   "          <TD>Дата</TD>                                                                  "  skip
   "          <TD>Время</TD>                                                                 "  skip
   "          <TD>Счет</TD>                                                                  "  skip
   "          <TD>Имя</TD>                                                                   "  skip
   "          <TD>Валюта</TD>                                                                "  skip
   "          <TD>Входящий<br>Остаток(60)</TD>                                               "  skip
   "          <TD>Промежуточный<br>Остаток(62)</TD>                                          "  skip
   "          <TD>Исходящий<br>Остаток(64)</TD>                                              "  skip.

for each swhd where swhd.rdt >= v-clsday and lookup(swhd.type,"950,940") > 0 no-lock break by swhd.rdt by swhd.rtime by swhd.snd.

find crc where crc.crc = swhd.f60crc no-lock no-error.
if avail crc then 
    v-crc = crc.code.
else 
    v-crc = "".

     put stream m-out unformatted                                           
        "        <TR bgcolor=""#ECF1F7"">                                                        "  skip 
        "          <TD vAlign=top title=""Тип"">"   swhd.type  "</TD>                            "  skip 
        "          <TD vAlign=top title=""Файл""><a name=swid" swhd.swid ">" swhd.fname "</TD>                            "  skip 
        "          <TD vAlign=top title=""Дата"">"  string(swhd.rdt, "99.99.99")    "</TD>       "  skip 
        "          <TD vAlign=top title=""Время"">" string(swhd.rtime, "HH:MM:SS")  "</TD>       "  skip 
        "          <TD vAlign=top title=""Счет"">"  swhd.acc   "</TD>       "  skip 
        "          <TD vAlign=top title=""Имя"">" swhd.snd "</a></TD>                            "  skip 
        "          <TD vAlign=top title=""Валюта"">" v-crc    "</TD>                             "  skip 
        "          <TD vAlign=top title=""Входящий Остаток(60)""><b>" string (swhd.f60amt) "</b></TD>            "  skip
        "          <TD vAlign=top title=""Промежуточный Остаток(62)""><b>" string (swhd.f62amt) "</b></TD>       "  skip
        "          <TD vAlign=top title=""Исходящий Остаток(64)""><b>" string (swhd.f64amt) "</b></TD>           "  skip
        "        <TR>                                                             "  skip.

end.
put stream m-out unformatted      
   "</TBODY></TABLE>".
*/

def var v-refseq as char.
def var v-snd as char.
def var v-inbalvip  as deci.
def buffer b-swhd for swhd.

v-text =  string(time, "HH:MM:SS") + " -- vm-five.i Платежи".
run lgps .

/*
put stream m-out unformatted      
   "<H2><a name=""6"">Платежи</H2>".

for each tmp-bal no-lock break by tmp-bal.crc.
      if tmp-bal.swid = 0 then next.

         v-refseq = "".
         v-snd    = "".
         v-inbalvip = 0.

         find first swhd where swhd.swid = tmp-bal.swid no-lock no-error.
         if avail swhd then do:
            v-refseq = substring (swhd.f28,1, index(swhd.f28,"/" ) - 1 ).
            v-snd = swhd.snd.

            find last b-swhd where b-swhd.rdt >= v-clsday 
                    and b-swhd.snd = v-snd  
                    and b-swhd.type <> "942" 
                    and b-swhd.info[1] =  "F"
                    no-lock no-error. 
            if avail b-swhd then do:
                       v-inbalvip = b-swhd.f60amt.
                       release b-swhd.
            end.


               put stream m-out unformatted                     
                    "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
                    "cellSpacing=0 width=""65%"" marginwidth=""0"" marginheight=""0"" leftmargin=""0"" topmargin=""0"" >" skip 
                    " <TBODY>"                                                           skip.

               put stream m-out unformatted                     
                    "        <TR>                                                      "  skip 
                    "          <TD colspan=""4"" align=center><font size=2><a name=swid" tmp-bal.swid ">" tmp-bal.name  "</a>" 
                    "                   Входящий  " string(v-inbalvip) 
                    "                   Исходящий " if  swhd.f64amt > 0 then string (swhd.f64amt) else string (swhd.f62amt)       
                    "          </font></TD> "                                                                                          skip 
                    "        </TR>                                                     "  skip.
                    
               put stream m-out unformatted                     
                    "        <TR><TD vAlign=""top"">                                                      "  skip. 

                    put stream m-out unformatted                     
                    "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
                    "cellSpacing=0 marginwidth=""0"" marginheight=""0"" leftmargin=""0"" topmargin=""0"">"                                                     skip 
                    " <TBODY>"                                                           skip
                    " <TR><TD colspan = ""2"">Входящие</TD><TR>"                         skip
                    "      <TR><TD>Получатель                                       </TD>"      skip
                    "          <TD>Сумма                                            </TD></TR>" skip.
                                        
                    for each swhd where swhd.rdt >= v-clsday 
                                        and substring (swhd.f28,1, index(swhd.f28,"/" ) - 1 ) = v-refseq 
                                        and swhd.snd = v-snd  
                                        and swhd.type <> "942" no-lock. 

                          for each swdt where swdt.swid = swhd.swid and swdt.oper = "C" no-lock.
                                  find first remtrz where  remtrz.remtrz = swdt.info[1] no-lock no-error.
                                  put stream m-out unformatted                     
                                          "<TR>"                                        skip
                                          "<TD>" if avail remtrz then remtrz.bn[1] + "(" + (remtrz.remtrz) + ")"  else "" "</TD>" skip
                                          "<TD>" string(swdt.amt) "</TD>"                       skip
                                          "</TR>"                                       skip.
                          end. 
                    end.
                    put stream m-out unformatted
                    "</TBODY></TABLE></TD><TD vAlign=""top"">"                                                   skip
                    "<TABLE bgColor=#ffffff border=1 borderColor=#d8e4f8 cellPadding=1 " skip
                    "cellSpacing=""0"" marginwidth=""0"" marginheight=""0"" leftmargin=""0"" topmargin=""0"">" skip 
                    " <TBODY>"                                                           skip
                    " <TR><TD colspan = ""2"">Исходящие</TD><TR>"                        skip
                    "          <TD>Отправитель                                      </TD>" skip
                    "          <TD>Сумма                                            </TD>" skip.
                    for each swhd where swhd.rdt >= v-clsday 
                                        and substring (swhd.f28,1, index(swhd.f28,"/" ) - 1 ) = v-refseq 
                                        and swhd.snd = v-snd  
                                        and swhd.type <> "942" no-lock. 

                         for each swdt where swdt.swid = swhd.swid and swdt.oper = "D" no-lock.
                                 
                                 find first remtrz where remtrz.valdt1 >= v-clsday - 1 and index (swdt.ref, remtrz.remtrz) > 0 no-lock no-error.
                                 put stream m-out unformatted                     
                                         "<TR>" skip
                                         "<TD>" if avail remtrz then remtrz.ord + "(" + (remtrz.remtrz) + ")" else "" "</TD>" skip
                                         "<TD>" string(swdt.amt) "</TD>" skip
                                         "</TR>" skip.
                         end. 
                    end.
                    put stream m-out unformatted                     
                        "</TBODY></TABLE>"                                                   skip
                        "</TD></TR>                                                          " skip.

               put stream m-out unformatted      
               "</TBODY></TABLE><BR>".
          end.
end.

*/
