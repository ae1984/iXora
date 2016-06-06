/*allfiz.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сведения о размещенных вкладах физ.лиц
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
        03/02/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        04.02.2009 galina - перекомпиляция
        06/05/2010 galina - исправила согласно замечаниям НБ РК
        13/08/2013 galina - ТЗ1938 добавила выбор группировки по филиалу
        15/08/2013 galina - ТЗ1412 добавила вывод в формате XML
*/





def stream rpt.
def var v-dt as date.
def var i as integer.
def var v-summ as deci.

def new shared temp-table t-rep
  field bank as char
  field cif as char
  field cifname as char
  field cifps1 as char
  field cifps2 as char
  field cifrnn as char
  field cifadr as char
  field docnum as char
  field docdt as date
  field crc as char
  field gl as char /*ГК для ОД/Суммы депозита на 1 уровне*/
  field gl2 as char /*ГК для просроченного ОД*/
  field glprc as char /*ГК для процентов*/
  field glprc2 as char  /*ГК для просроч. процентов*/
  field acc as char
  field amt as deci
  field amt2 as deci /*Сумма просроч. ОД*/
  field amt_kz as deci
  field amt_kz2 as deci  /*Сумма просроч. ОД в тенге*/
  field pamt as deci
  field pamt_kz as deci
  field pamt2 as deci /*Сумма просроч %%*/
  field pamt_kz2 as deci /*Сумма просроч %% в тенге*/
  field sub as char
  field bnkbic as char
  field iin as char
  index main is primary bank cif sub
  index iin iin sub
  index cif cif.

/*итоги по клиентам для текущих счетов и депозитов*/
def var  v-amt_kz as deci.
def var  v-pamt_kz as deci.

/*итоги по клиентам для кредитов*/
def var v-amt_kz1 as deci.
def var v-pamt_kz1 as deci.

/*итоги по филиалам*/
def var v-famt_kz as deci.
def var v-fpamt_kz as deci.
def var v-famt_kz1 as deci.
def var v-fpamt_kz1 as deci.
def var v-fsum as deci no-undo extent 5.
/*def var v-fcomamt_kz as deci.*/

/*итоги по банку*/
def var v-bamt_kz as deci.
def var v-bpamt_kz as deci.
def var v-bamt_kz1 as deci.
def var v-bpamt_kz1 as deci.
def var v-bsum as deci no-undo extent 5.
def var n as integer.
def var v-fillgr as logi init yes.
def var v-sel as char.


{global.i}
 form
 v-dt format "99/99/9999" label "Дата отчета" validate(v-dt <= g-today,"Дата должна быть меньше или равна операционной даты!") skip
 with centered side-label row 5 width 30 title "УКАЖИТЕ ДАТУ ОТЧЕТА" frame f-par.


 v-dt = g-today.
 update v-dt with fram f-par.

{r-brfilial.i &proc = "txb_allfiz(v-dt,txb.bank)"}

def buffer btemp for t-rep.
for each btemp where btemp.sub = "lon" .
   find first  t-rep where t-rep.iin = btemp.iin and t-rep.sub = "aaa" no-lock no-error.
   if not available t-rep  then delete btemp.
end.

v-sel = ''.
run sel2 (" Выбор: ", " 1. Вывод в формате Excell | 2. Вывод в формате XML | 3. Выход ", output v-sel).
if v-sel = '3' then return.
if v-sel = '2' then run allfiz_xml.
if v-sel = '1' then do:


    update v-fillgr  format 'да/нет' label 'Группировать по филиалу'  with frame fillgr centered side-label overlay row 5 width 30 title "ТИП ГРУППИРОВКИ".
    output stream rpt to test.htm.

    {html-title.i
     &stream = " stream rpt "
     &size-add = "xx-"
     &title = " "
    }
     put stream rpt unformatted
     "<p><B>Сведения о размещенных вкладах физических лиц <BR>" skip
     "за " string(v-dt,'99/99/9999') "</B></p><BR><BR>" skip.

     put stream rpt unformatted
     "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
     "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12>" skip
     "<TD rowspan = 2>П/П</TD>" skip
     "<TD rowspan = 2>Полные Фамилия, Имя <BR> и Отчество вкладчика <BR>(депозитора)</TD>" skip
     "<TD colspan = 2> Док-т, уд-щий <BR>личность, № и дата <BR>выдачи, кем выдан</TD>" skip
     "<TD rowspan = 2>РНН</TD>" skip
     "<TD rowspan = 2>Адрес местожительства <BR> вкладчика (депозитора), <BR> номер телефона</TD>" skip
     "<TD rowspan = 2>Название и/или № <BR> договора <BR> банковского <BR> обслуживания <BR> (банковского вклада,<BR>текущего счета,<BR>карт-счета и пр.),<BR>договор займа/ гарантии,<BR>дата заключения<BR>договора</TD>" skip
     "<TD rowspan = 2>Валюта <BR> депозита,<BR> встречных <BR> требований </TD>" skip
     "<TD rowspan = 2>Номер счета <BR> главной книги</TD>" skip
     "<TD rowspan = 2>Номер лицевого счета<BR>вклада, текущего<BR>счета, карт-счета,<BR>ссудной<BR>задолженности,<BR>начисленного<BR>вознаграждения по<BR>вкладу, начисленного<BR>вознаграждения<BR>ссудной<BR>задолженности</TD>" skip
     "<TD rowspan = 2>Референс <BR> сделки </TD>" skip
     "<TD colspan = 5>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему <BR> вознаграждения</TD>" skip
     "<TD colspan = 5>Сумма встречных требований банка к вкладчику (депозитору)</TD>" skip
     "<TD colspan = 3>Остаток обязательств/требований банка к вклачику <BR> (депозитору) по результатам взаимозачета</TD>" skip
     "<TD rowspan = 2>Остаток<BR>обязательств<BR>банка перед<BR>вкладчиком по<BR> результатам<BR>взаимозачета в<BR>тенговом<BR>эквиваленте</TD>" skip
     "<TD rowspan = 2>Сумма возмещения<BR>подлежащая выплате<BR>вкладчику (депозитору),<BR>но не более 5 миллионов<BR>тенге по итогам<BR>взаимозачета встречных<BR>требований вкладчика<BR>(депозитора) и банка</TD>" skip
     "<TD rowspan = 2>Остаток по<BR> вкладам (депозитам),<BR>с учетом<BR>начсиленного<BR>вознаграждения<BR>после выплаты<BR>суммы возмещения<BR>в тенговом<BR>эквиваленте</TD>"
     "<TD rowspan = 2>БИК</TD>" skip
     "<TD rowspan = 2>ИИН</TD>" skip
     "</TR>" skip
     "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
     "<TD>№ документа <BR>удостоверящего личность</TD>" skip
     "<TD>дата выдачи,<BR> кем выдан</TD>" skip
     "<TD>Сумма текущего<BR>остатка по вкладу<BR>в валюте вклада</TD>" skip
     "<TD>Сумма текущего<BR>остатка по вкладу<BR> в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Сумма<BR>начисленного<BR>вознаграждения<BR>в валюте<BR>вклада</TD>" skip
     "<TD>Сумма<BR>начисленного<BR>вознаграждения<BR>в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Всего в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Сумма остатка <BR>требований по<BR>основному<BR>долгу в валюте<BR>требований</TD>" skip
     "<TD>Сумма остатка <BR>требований по<BR>основному долгу<BR>в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Сумма<BR>требований по<BR>начисленному<BR>вознаграждению<BR>банка в валюте<BR>требований</TD>" skip
     "<TD>Сумма<BR>требований по<BR>начисленному<BR>вознаграждению<BR>банка в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Всего сумма<BR>встречных требований<BR> банка в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Сумма остатка по<BR>начисленному<BR>вознаграждению в<BR>тенговом<BR>эквиваленте</TD>" skip
     "<TD>Сумма остатка по<BR>основному долгу<BR>в тенговом<BR>эквиваленте</TD>" skip
     "<TD>Всего по остатку<BR>обязательств/<BR>требований в<BR>тенговом<BR>эквиваленте</TD>" skip
     "</TR>" skip

     "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
     "<TD >1</TD>" skip
     "<TD >2</TD>" skip
     "<TD >3</TD>" skip
     "<TD >4</TD>" skip
     "<TD >5</TD>" skip
     "<TD >6</TD>" skip
     "<TD >7</TD>" skip
     "<TD >8</TD>" skip
     "<TD >9</TD>" skip
     "<TD >10</TD>" skip
     "<TD >11</TD>" skip
     "<TD >12</TD>" skip
     "<TD >13</TD>" skip
     "<TD >14</TD>" skip
     "<TD >15</TD>" skip
     "<TD >16</TD>" skip
     "<TD >17</TD>" skip
     "<TD >18</TD>" skip
     "<TD >19</TD>" skip
     "<TD >20</TD>" skip
     "<TD >21</TD>" skip
     "<TD >22</TD>" skip
     "<TD >23</TD>" skip
     "<TD >24</TD>" skip
     "<TD >25</TD>" skip
     "<TD >26</TD>" skip
     "<TD >27</TD>" skip
     "<TD >28</TD>" skip
     "<TD >29</TD>" skip
     "</TR>" skip.

     v-bamt_kz = 0.
     v-bpamt_kz = 0.
     v-bamt_kz1 = 0.
     v-bpamt_kz1 = 0.
     do i = 1 to 5:
     v-bsum[i] = 0.
     end.
    if v-fillgr then do:
        n = 1.
         for each t-rep no-lock break by t-rep.bank by t-rep.cif by t-rep.sub:

           accumulate (t-rep.amt_kz + t-rep.amt_kz2) (TOTAL by t-rep.sub).
           accumulate (t-rep.pamt_kz + t-rep.pamt_kz2) (TOTAL by t-rep.sub).
           if first-of(t-rep.bank) then do:
           find first txb where txb.bank = t-rep.bank no-lock no-error.
           put stream rpt unformatted
           "<TR align=""left"" valign=""center"" style=""font:bold"">" skip
           "<TD  bgcolor=""#C0C0C0"" colspan = 29>Филиал " txb.name "</TD></TR>" skip.
              v-famt_kz = 0.
              v-fpamt_kz = 0.
              v-famt_kz1 = 0.
              v-fpamt_kz1 = 0.
              do i = 1 to 5:
              v-fsum[i] = 0.
              end.
           end.

           if t-rep.sub = "aaa" then do:
                put stream rpt unformatted
                "<TR align=""center"" valign=""center"">" skip
                "<TD >" string(n) "</TD>" skip
                "<TD >" t-rep.cifname "</TD>" skip
                "<TD >" t-rep.cifps1 "</TD>" skip
                "<TD >" t-rep.cifps1 "</TD>" skip
                "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                "<TD >" t-rep.cifadr "</TD>" skip
                "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                "<TD >" t-rep.crc "</TD>" skip
                "<TD >" t-rep.gl "</TD>" skip
                "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                "<TD></TD>"

                "<TD >" replace(string(t-rep.amt,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                "<TD >" replace(string(t-rep.amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                "<TD ></TD>" skip
                "<TD ></TD>" skip
                "<TD ></TD>" skip.
                do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
                put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                if length(t-rep.iin) = 12 then put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                else put stream rpt unformatted "<TD ></TD ></tr>" skip.


                if t-rep.pamt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>"
                    "<TD></TD>"
                    "<TD></TD>"
                    "<TD >" replace(string(t-rep.pamt,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    if length(t-rep.iin) = 12 then put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                    else put stream rpt unformatted "<TD ></TD ></tr>" skip.
                end.

           end.

           if t-rep.sub = "lon" then do:
                /*ОД*/
                if t-rep.amt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD >" replace(string(t-rep.amt * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.amt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.


                end.

                /*просроч.ОД*/
                if t-rep.amt2 > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD >" replace(string(t-rep.amt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.amt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

                /*проценты*/
                if t-rep.pamt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.glprc "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD >" replace(string(t-rep.pamt * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

                /*просроч проценты*/
                if t-rep.pamt2 > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.glprc2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD >" replace(string(t-rep.pamt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

           end.
           if first-of(t-rep.cif) then do:
               v-amt_kz = 0.
               v-pamt_kz = 0.
               v-amt_kz1 = 0.
               v-pamt_kz1 = 0.
           end.
           /*if t-rep.sub = 'aaa' then do:
                v-amt_kz = v-amt_kz + (t-rep.amt_kz + t-rep.amt_kz2).
                v-pamt_kz = v-pamt_kz + (t-rep.pamt_kz + t-rep.pamt_kz2).
           end.
           else do:
               v-amt_kz1 = -(v-amt_kz1 + (t-rep.amt_kz + t-rep.amt_kz2)).
               v-pamt_kz1 = -(v-pamt_kz1 + (t-rep.pamt_kz + t-rep.pamt_kz2)).
           end.*/

           if last-of(t-rep.sub) then do:
               if t-rep.sub = 'aaa' then do:
                  v-amt_kz = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
                  v-pamt_kz = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).

                   v-famt_kz = v-famt_kz + v-amt_kz.
                   v-fpamt_kz = v-fpamt_kz + v-pamt_kz.
        /*           v-famt_kz1 = v-famt_kz1 + v-amt_kz1.
                   v-fpamt_kz1 = v-fpamt_kz1 + v-pamt_kz1.*/

                   v-bamt_kz = v-bamt_kz + v-amt_kz.
                   v-bpamt_kz = v-bpamt_kz + v-pamt_kz.
                   /*v-bamt_kz1 = v-bamt_kz1 + v-amt_kz1.
                   v-bpamt_kz1 = v-bpamt_kz1 + v-pamt_kz1.*/

               end.
               else do:
                  v-amt_kz1 = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
                  v-pamt_kz1 = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).
                  v-amt_kz1 = v-amt_kz1 * (-1).
                  v-pamt_kz1 = v-pamt_kz1 * (-1).
        /*       v-famt_kz = v-famt_kz + v-amt_kz.
               v-fpamt_kz = v-fpamt_kz + v-pamt_kz.*/
               v-famt_kz1 = v-famt_kz1 + v-amt_kz1.
               v-fpamt_kz1 = v-fpamt_kz1 + v-pamt_kz1.

               /*v-bamt_kz = v-bamt_kz + v-amt_kz.
               v-bpamt_kz = v-bpamt_kz + v-pamt_kz.*/
               v-bamt_kz1 = v-bamt_kz1 + v-amt_kz1.
               v-bpamt_kz1 = v-bpamt_kz1 + v-pamt_kz1.

               end.

        /*       v-famt_kz = v-famt_kz + v-amt_kz.
               v-fpamt_kz = v-fpamt_kz + v-pamt_kz.
               v-famt_kz1 = v-famt_kz1 + v-amt_kz1.
               v-fpamt_kz1 = v-fpamt_kz1 + v-pamt_kz1.

               v-bamt_kz = v-bamt_kz + v-amt_kz.
               v-bpamt_kz = v-bpamt_kz + v-pamt_kz.
               v-bamt_kz1 = v-bamt_kz1 + v-amt_kz1.
               v-bpamt_kz1 = v-bpamt_kz1 + v-pamt_kz1.*/
           end.

           if last-of(t-rep.cif) then do:
              n = n + 1.
               put stream rpt unformatted
               "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
               "<TD >Итого по вкладчику</TD>" skip.
               do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
               put stream rpt unformatted
               "<TD >" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*13*/
               "<TD ></TD >" skip /*14*/
               "<TD >" replace(string(v-pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*15*/
               "<TD >" replace(string((v-pamt_kz + v-amt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*16*/
               "<TD ></TD >" skip /*17*/
               "<TD >" replace(string(v-amt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*18*/
               "<TD ></TD >" skip /*19*/
               "<TD >" replace(string(v-pamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*20*/
               "<TD >" replace(string((v-pamt_kz1 + v-amt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*21*/
               "<TD >" replace(string((v-pamt_kz + v-amt_kz1 + v-pamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*22*/
               if (v-pamt_kz + v-pamt_kz1 + v-amt_kz1) >= 0 then do:
                 v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz1 + v-amt_kz.
                 put stream rpt unformatted
                 "<TD >" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*23*/
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*24*/
                 v-fsum[1] = v-fsum[1] + v-amt_kz.
                 v-bsum[1] = v-bsum[1] + v-amt_kz.
               end.

               else do:
                 /*v-summ = (2 * (v-pamt_kz + v-pamt_kz1)) + v-amt_kz.*/
                 v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz + v-amt_kz1.
                 put stream rpt unformatted
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*23*/
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*24*/
                 v-fsum[1] = v-fsum[1] + v-summ.
                 v-bsum[1] = v-bsum[1] + v-summ.
               end.
                 v-fsum[2] = v-fsum[2] + v-summ.
                 v-bsum[2] = v-bsum[2] + v-summ.
               if v-summ > 0 then do:
                 put stream rpt unformatted
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*25*/
                 v-fsum[3] = v-fsum[3] + v-summ.
                 v-bsum[3] = v-bsum[3] + v-summ.
                 if /*v-amt_kz*/ v-summ > 5000000 then do:
                   v-fsum[4] = v-fsum[4] + 5000000. /*25*/
                   v-fsum[5] = v-fsum[5] + v-summ - 5000000. /*26*/
                   v-bsum[4] = v-bsum[4] + 5000000. /*25*/
                   v-bsum[5] = v-bsum[5] + v-summ - 5000000. /*26*/

                   put stream rpt unformatted
                   "<TD >" replace(string(5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*26*/
                   "<TD >" replace(string(v-summ - 5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></tr>" skip. /*27*/

                 end.
                 else do:
                   v-fsum[4] = v-fsum[4] + /*v-amt_kz*/ v-summ.
                   /*v-fsum[5] = v-fsum[5] + v-summ - v-amt_kz.*/
                   v-bsum[4] = v-bsum[4] + /*v-amt_kz*/ v-summ.
                   /*v-bsum[5] = v-bsum[5] + v-summ - v-amt_kz.*/

                   put stream rpt unformatted
                   "<TD >" replace(string(/*v-amt_kz*/ v-summ,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                   /*"<TD >" replace(string(v-summ - v-amt_kz,'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></TR>" skip.*/
                   "<TD >" replace(string(0,'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></TR>" skip.

                 end.
               end.
               else do:
                 put stream rpt unformatted
                 "<TD >" replace(string(0,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                 "<TD ></TD><TD ></TD><TD ></TD><TD ></TD></tr>" skip.

               end.
           end.

           if last-of(t-rep.bank) then do:
               put stream rpt unformatted
               "<TR align=""center"" valign=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
               "<TD >Итого по филиалу " txb.name "</TD>" skip.
               do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
               put stream rpt unformatted
               "<TD >" replace(string(v-famt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*13*/
               "<TD ></TD >" skip /*14*/
               "<TD >" replace(string(v-fpamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*15*/
               "<TD >" replace(string((v-fpamt_kz + v-famt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*16*/
               "<TD ></TD >" skip /*17*/
               "<TD >" replace(string(v-famt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*18*/
               "<TD ></TD >" skip
               "<TD >" replace(string(v-fpamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
               "<TD >" replace(string((v-fpamt_kz1 + v-famt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*21*/
               "<TD >" replace(string((v-fpamt_kz + v-fpamt_kz1 + v-famt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*22*/
               "<TD >" replace(string(v-fsum[1],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*23*/
               "<TD >" replace(string(v-fsum[2],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*24*/
               "<TD >" replace(string(v-fsum[3],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
               "<TD >" replace(string(v-fsum[4],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
               "<TD >" replace(string(v-fsum[5],'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></tr>" skip.
           end.
         end.
         put stream rpt unformatted
         "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD >Итого по банку</TD>" skip.
         do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
         put stream rpt unformatted
         "<TD >" replace(string(v-bamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bpamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz + v-bamt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bpamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz + v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[1],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[2],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[3],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[4],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[5],'->>>>>>>>>>>>>9.99'),'.',',') "</TD><TD></TD><TD></TD></TR>" skip.

         put stream rpt unformatted
         "</table>" skip.
    end.
    /*без группировки по филиалу*/
    if not v-fillgr then do:
        n = 1.
         for each t-rep no-lock break by t-rep.iin by t-rep.sub:

           accumulate (t-rep.amt_kz + t-rep.amt_kz2) (TOTAL by t-rep.sub).
           accumulate (t-rep.pamt_kz + t-rep.pamt_kz2) (TOTAL by t-rep.sub).
           if t-rep.sub = "aaa" then do:
                put stream rpt unformatted
                "<TR align=""center"" valign=""center"">" skip
                "<TD >" string(n) "</TD>" skip
                "<TD >" t-rep.cifname "</TD>" skip
                "<TD >" t-rep.cifps1 "</TD>" skip
                "<TD >" t-rep.cifps1 "</TD>" skip
                "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                "<TD >" t-rep.cifadr "</TD>" skip
                "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                "<TD >" t-rep.crc "</TD>" skip
                "<TD >" t-rep.gl "</TD>" skip
                "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                "<TD></TD>"

                "<TD >" replace(string(t-rep.amt,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                "<TD >" replace(string(t-rep.amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                "<TD ></TD>" skip
                "<TD ></TD>" skip
                "<TD ></TD>" skip.
                do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
                put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                if length(t-rep.bnkbic) = 12 then put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                else put stream rpt unformatted "<TD ></TD >" skip.


                if t-rep.pamt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>"
                    "<TD></TD>"
                    "<TD></TD>"
                    "<TD >" replace(string(t-rep.pamt,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
                    if length(t-rep.bnkbic) = 12 then put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

           end.

           if t-rep.sub = "lon" then do:
                /*ОД*/
                if t-rep.amt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD >" replace(string(t-rep.amt * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.amt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

                /*просроч.ОД*/
                if t-rep.amt2 > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.gl2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD >" replace(string(t-rep.amt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.amt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

                /*проценты*/
                if t-rep.pamt > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.glprc "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD >" replace(string(t-rep.pamt * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

                /*просроч проценты*/
                if t-rep.pamt2 > 0 then do:
                    put stream rpt unformatted
                    "<TR align=""center"" valign=""center"">" skip
                    "<TD >" string(n) "</TD>" skip
                    "<TD >" t-rep.cifname "</TD>" skip
                    "<TD >" t-rep.cifps1 "</TD>" skip
                    "<TD >" t-rep.cifps2 "</TD>" skip
                    "<TD > &nbsp;" t-rep.cifrnn "</TD>" skip
                    "<TD >" t-rep.cifadr "</TD>" skip
                    "<TD >" t-rep.docnum + "&nbsp;" /* "<BR>"*/ + string(t-rep.docdt,'99/99/9999') "</TD>" skip
                    "<TD >" t-rep.crc "</TD>" skip
                    "<TD >" t-rep.glprc2 "</TD>" skip
                    "<TD >`" string(t-rep.acc,'x(20)') "</TD>" skip
                    "<TD></TD>".
                    do i = 1 to 5: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted
                    "<TD ></TD>" skip
                    "<TD ></TD>" skip
                    "<TD >" replace(string(t-rep.pamt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD >" replace(string(t-rep.pamt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                    "<TD ></TD>" skip.
                    do i = 1 to 6: put stream rpt unformatted "<TD ></TD >" skip. end.
                    put stream rpt unformatted "<TD >" t-rep.bnkbic "</TD >" skip.
                    put stream rpt unformatted "<TD >" "&nbsp;" + t-rep.iin "</TD ></tr>" skip.
                end.

           end.
           if first-of(t-rep.iin) then do:
               v-amt_kz = 0.
               v-pamt_kz = 0.
               v-amt_kz1 = 0.
               v-pamt_kz1 = 0.
           end.


           if last-of(t-rep.sub) then do:
               if t-rep.sub = 'aaa' then do:
                  v-amt_kz = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
                  v-pamt_kz = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).

                   v-bamt_kz = v-bamt_kz + v-amt_kz.
                   v-bpamt_kz = v-bpamt_kz + v-pamt_kz.

               end.
               else do:
                  v-amt_kz1 = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
                  v-pamt_kz1 = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).
                  v-amt_kz1 = v-amt_kz1 * (-1).
                  v-pamt_kz1 = v-pamt_kz1 * (-1).

                  v-bamt_kz1 = v-bamt_kz1 + v-amt_kz1.
                  v-bpamt_kz1 = v-bpamt_kz1 + v-pamt_kz1.

               end.


           end.

           if last-of(t-rep.iin) then do:
              n = n + 1.
               put stream rpt unformatted
               "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
               "<TD >Итого по вкладчику</TD>" skip.
               do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
               put stream rpt unformatted
               "<TD >" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*13*/
               "<TD ></TD >" skip /*14*/
               "<TD >" replace(string(v-pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*15*/
               "<TD >" replace(string((v-pamt_kz + v-amt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*16*/
               "<TD ></TD >" skip /*17*/
               "<TD >" replace(string(v-amt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*18*/
               "<TD ></TD >" skip /*19*/
               "<TD >" replace(string(v-pamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*20*/
               "<TD >" replace(string((v-pamt_kz1 + v-amt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*21*/
               "<TD >" replace(string((v-pamt_kz + v-amt_kz1 + v-pamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*22*/
               if (v-pamt_kz + v-pamt_kz1 + v-amt_kz1) >= 0 then do:
                 v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz1 + v-amt_kz.
                 put stream rpt unformatted
                 "<TD >" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*23*/
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*24*/

                 v-bsum[1] = v-bsum[1] + v-amt_kz.
               end.

               else do:

                 v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz + v-amt_kz1.
                 put stream rpt unformatted
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*23*/
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*24*/

                 v-bsum[1] = v-bsum[1] + v-summ.
               end.

                 v-bsum[2] = v-bsum[2] + v-summ.
               if v-summ > 0 then do:
                 put stream rpt unformatted
                 "<TD >" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip. /*25*/

                 v-bsum[3] = v-bsum[3] + v-summ.
                 if  v-summ > 5000000 then do:
                   v-bsum[4] = v-bsum[4] + 5000000. /*25*/
                   v-bsum[5] = v-bsum[5] + v-summ - 5000000. /*26*/

                   put stream rpt unformatted
                   "<TD >" replace(string(5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip /*26*/
                   "<TD >" replace(string(v-summ - 5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></tr>" skip. /*27*/

                 end.
                 else do:
                   v-bsum[4] = v-bsum[4] + v-summ.

                   put stream rpt unformatted
                   "<TD >" replace(string(v-summ,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                   "<TD >" replace(string(0,'->>>>>>>>>>>>>9.99'),'.',',') "</TD><td></td><td></td></TR>" skip.

                 end.
               end.
               else do:
                 put stream rpt unformatted
                 "<TD >" replace(string(0,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                 "<TD ></TD><TD ></TD><TD ></TD><TD ></TD></tr>" skip.
               end.
           end.


         end.
         put stream rpt unformatted
         "<TR align=""center"" valign=""center"" style=""font:bold"">" skip
         "<TD >Итого по банку</TD>" skip.
         do i = 1 to 11: put stream rpt unformatted "<TD ></TD >" skip. end.
         put stream rpt unformatted
         "<TD >" replace(string(v-bamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bpamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz + v-bamt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD ></TD >" skip
         "<TD >" replace(string(v-bpamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string((v-bpamt_kz + v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[1],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[2],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[3],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[4],'->>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
         "<TD >" replace(string(v-bsum[5],'->>>>>>>>>>>>>9.99'),'.',',') "</TD><TD></TD><TD></TD></TR>" skip.

         put stream rpt unformatted
         "</table>" skip.
    end.




    /*********************/
    {html-end.i}

    output stream rpt close.

    hide all no-pause.

    unix silent value("cptwin test.htm excel").
    unix silent rm -f  test.htm.

end.

