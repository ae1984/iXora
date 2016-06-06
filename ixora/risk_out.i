/* risk_out.i
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
*/


/*Заголовок*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b><span style=""background-color: #FFFF00"">" cif.name + lon.lon "</span></b></TD>" skip
     "<TD><FONT ><B>Отрасль</B></FONT></TD>" skip
     "<TD><FONT ><B>Фин устойчивость</B></FONT></TD>" skip
     "<TD><FONT ><B>Вид обеспечения</B></FONT></TD>" skip
     "<TD><FONT ><B>Обеспечение/Сумма займа</B></FONT></TD>" skip
     "<TD><FONT ><B>Оценка проекта</B></FONT></TD>" skip
     "<TD><FONT ><B>Срок кредита</B></FONT></TD>" skip
     "<TD><FONT ><B>Кредитная история</B></FONT></TD>" skip
     "<TD><FONT ><B>Среднемес обороты/Сумма займа</B></FONT></TD>" skip.
/*Весы*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b>Весы</b></TD>" skip
     "<TD><FONT >5%</FONT></TD>" skip
     "<TD><FONT >25%</FONT></TD>" skip
     "<TD><FONT >15%</FONT></TD>" skip
     "<TD><FONT >25%</FONT></TD>" skip
     "<TD><FONT >5%</FONT></TD>" skip
     "<TD><FONT >5%</FONT></TD>" skip
     "<TD><FONT >10%</FONT></TD>" skip
     "<TD><FONT >10%</FONT></TD>" skip.

/*Клиент*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b>Клиент</b></TD>" skip
     "<TD><b>" v-otrasl2 format 'zz9%' "</b></TD>" skip
     "<TD><b>" koef_ust format 'zz9%' "</b></TD>" skip
     "<TD><b>" v-obes format 'zz9%' "</b></TD>" skip
     "<TD><b>" v-zalog2 format 'zz9%'"</b></TD>" skip
     "<TD><b>" v-osenka format 'zz9%'"</b></TD>" skip
     "<TD><b>" v-srok format 'zz9%' "</b></TD>" skip
     "<TD><b>" v-history format 'zz9%' "</b></TD>" skip
     "<TD><b> 0%</b></TD>" skip.

/*Оптимальное значение*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b>Оптимальное значение</b></TD>" skip
     "<TD><FONT >" optimal[1] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[2] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[3] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[4] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[5] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[6] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[7] format 'zz9%' "</FONT></TD>" skip
     "<TD><FONT >" optimal[8] format 'zz9%' "</FONT></TD>" skip.

/*Риски*/
/*risk[1] = replace(string(v-otrasl2 / optimal[1],'zzzz9.99'),".",",").*/
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b>Риски</b></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-otrasl2 / optimal[1],'zzzz9.99'),".",",")";0,5;0,15;1) * "weight[1]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string( koef_ust / optimal[2],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[2]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-obes / optimal[3],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[3]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-zalog2 / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-osenka / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-srok / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-history / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-obor2 / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"</FONT></TD>" skip
     "<TD><FONT > =НОРМРАСП("replace(string(v-otrasl2 / optimal[1],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[1]"+НОРМРАСП("replace(string( koef_ust / optimal[2],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[2]"+НОРМРАСП("replace(string(v-obes / optimal[3],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[3]"+НОРМРАСП("replace(string(v-zalog2 / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"+НОРМРАСП("replace(string(v-osenka / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"+НОРМРАСП("replace(string(v-srok / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"+НОРМРАСП("replace(string(v-history / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"+НОРМРАСП("replace(string(v-obor2 / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"</FONT></TD>" skip.
 

put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><b>&nbsp;</b></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip
     "<TD><FONT >&nbsp;</FONT></TD>" skip.
