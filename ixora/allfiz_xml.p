/*allfiz_xml.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сведения о размещенных вкладах физ.лиц в формате XML
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
        15/08/2013 galina ТЗ1412
 * BASES
        BANK COMM
 * CHANGES

*/






def var v-dt as date.
def var i as integer.
def var v-summ as deci.

def shared temp-table t-rep
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

/*итоги по банку*/
def var v-bamt_kz as deci.
def var v-bpamt_kz as deci.
def var v-bamt_kz1 as deci.
def var v-bpamt_kz1 as deci.
def var v-bsum as deci no-undo extent 5.
def var n as integer.



{global.i}
 /*form
 v-dt format "99/99/9999" label "Дата отчета" validate(v-dt <= g-today,"Дата должна быть меньше или равна операционной даты!") skip
 with centered side-label row 5 width 30 title "УКАЖИТЕ ДАТУ ОТЧЕТА" frame f-par.


 v-dt = g-today.
 update v-dt with fram f-par.

{r-brfilial.i &proc = "txb_allfiz(v-dt,txb.bank)"}*/
message "XML формируется ...".
def stream rpt2.
/*def var v as char.*/

output stream rpt2 to depfiz.xml.

 put stream rpt2 unformatted
    '<?xml version="1.0" encoding="UTF-8"?>' skip
    '<dataroot xmlns:od="urn:schemas-microsoft-com:officedata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xsi:noNamespaceSchemaLocation="Сведения.xsd" generated="' + string(year(g-today),'9999') + '-' + string(day(g-today),'99') + '-' + string(month(g-today),'99') + 'T' + string(time,'HH:MM:SS') + '">' skip.
 put stream rpt2 unformatted
    '<Сведения>' skip
    '<F3>Док-т, уд-щий личность, N и дата выдачи, кем выдан</F3>'
    '<F4>Док-т, уд-щий личность, N и дата выдачи, кем выдан</F4>' skip
    '<F12>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему вознаграждения</F12>' skip
    '<F13>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему вознаграждения</F13>' skip
    '<F14>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему вознаграждения</F14>' skip
    '<F15>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему вознаграждения</F15>' skip
    '<F16>Сумма внесенного вклада вклада (депозита), а также сумма начисленного по нему вознаграждения</F16>' skip
    '<F17>Сумма встречных требований банка к вкладчику (депозитору)</F17>' skip
    '<F18>Сумма встречных требований банка к вкладчику (депозитору)</F18>' skip
    '<F19>Сумма встречных требований банка к вкладчику (депозитору)</F19>' skip
    '<F20>Сумма встречных требований банка к вкладчику (депозитору)</F20>' skip
    '<F21>Сумма встречных требований банка к вкладчику (депозитору)</F21>' skip
    '<F22>Остаток обязательств/требований банка к вкладчику (депозитору) по результатам взаимозачета</F22>' skip
    '<F23>Остаток обязательств/требований банка к вкладчику (депозитору) по результатам взаимозачета</F23>' skip
    '<F24>Остаток обязательств/требований банка к вкладчику (депозитору) по результатам взаимозачета</F24>' skip
    '<F25>Остаток обязательств банка перед вкладчиком по результатам взаимозачета в тенговом эквиваленте</F25>' skip
    '</Сведения>' skip
    '<Сведения>' skip
    '<F1>N п/п</F1>' skip
    '<F2>Полные Фамилия, Имя и Отчество вкладчика (депозитора)</F2>' skip
    '<F3>N документа удостоверящего личность</F3>' skip
    '<F4>дата выдачи, кем выдан </F4>' skip
    '<F5>РНН</F5>' skip
    '<F6>Адрес местожительства вкладчика (депозитора), номер телефона</F6>' skip
    '<F7>Название и/или N договора банковского обслуживания (банковского вклада, текущего счета, карт-счета и пр.), договор займа/ гарантии, дата заключения договора</F7>' skip
    '<F8>Валюта депозита, встречных требований</F8>' skip
    '<F9>Номер   счета Главной книги</F9>' skip
    '<F10>Номер лицевого счета вклада, текущего счета, карт-счета,  ссудной задолженности, начисленного вознаграждения по вкладу, начисленного вознаграждения ссудной задолженности  </F10>' skip
    '<F11>Референс сделки</F11>' skip
    '<F12>Сумма текущего остатка по вкладу в валюте вклада</F12>' skip
    '<F13>Сумма текущего остатка  вклада в тенговом эквиваленте</F13>' skip
    '<F14>сумма начисленного вознаграждения в валюте вклада</F14>' skip
    '<F15>сумма начисленного вознаграждения в тенговом эквиваленте</F15>' skip
    '<F16>всего в тенговом эквиваленте</F16>' skip
    '<F17>сумма остатка требований по основному долгу в валюте требования</F17>' skip
    '<F18>сумма остатка требований по основному долгу в тенговом эквиваленте</F18>' skip
    '<F19>сумма требований по начисленному вознаграждению банка в валюте требования</F19>' skip
    '<F20>сумма требований по начисленному вознаграждению банка в тенговом эквиваленте</F20>' skip
    '<F21>всего сумма встречных требований банка в тенговом эквиваленте</F21>' skip
    '<F22>сумма остатка по начисленному вознаграждению в тенговом эквиваленте</F22>' skip
    '<F23>сумма остатка по основному долгу в тенговом эквиваленте</F23>' skip
    '<F24>всего по остатку обязательств/ требований в тенговом эквиваленте</F24>' skip
    '<F25>Остаток обязательств банка перед вкладчиком по результатам взаимозачета в тенговом эквиваленте</F25>' skip
    '<F26>Сумма возмещения подлежащая выплате вкладчику (депозитору), но не более эквивалента 5,0 млн. тенге  по итогам взаимозачета встречных требований вкладчика (депозитора) и банка</F26>' skip
    '<F27>Остаток по вкладам (депозитам), с учетом начисленного вознаграждения после выплаты суммы возмещения в тенговом эквиваленте</F27>' skip
    '<F28>БИК</F28>' skip
    '<F29>ИИН</F29>' skip
    '</Сведения>' skip
    '<Сведения>' skip
    '<F1>1</F1>' skip
    '<F2>2</F2>' skip
    '<F3>3</F3>' skip
    '<F4>4</F4>' skip
    '<F5>5</F5>' skip
    '<F6>6</F6>' skip
    '<F7>7</F7>' skip
    '<F8>8</F8>' skip
    '<F9>9</F9>' skip
    '<F10>10</F10>' skip
    '<F11>11</F11>' skip
    '<F12>12</F12>' skip
    '<F13>13</F13>' skip
    '<F14>14</F14>' skip
    '<F15>15</F15>' skip
    '<F16>16=13+15</F16>' skip
    '<F17>17</F17>' skip
    '<F18>18</F18>' skip
    '<F19>19</F19>' skip
    '<F20>20</F20>' skip
    '<F21>21=18+20</F21>' skip
    '<F22>22=15+21</F22>' skip
    '<F23>23</F23>' skip
    '<F24>24</F24>' skip
    '<F25>25</F25>' skip
    '<F26>26</F26>' skip
    '<F27>27=24-26</F27>' skip
    '<F28>28</F28>' skip
    '<F29>29</F29>' skip
    '</Сведения>' skip.


 v-bamt_kz = 0.
 v-bpamt_kz = 0.
 v-bamt_kz1 = 0.
 v-bpamt_kz1 = 0.
 do i = 1 to 5:
 v-bsum[i] = 0.
 end.

n = 1.
 for each t-rep no-lock break by t-rep.bank by t-rep.cif by t-rep.sub:

   accumulate (t-rep.amt_kz + t-rep.amt_kz2) (TOTAL by t-rep.sub).
   accumulate (t-rep.pamt_kz + t-rep.pamt_kz2) (TOTAL by t-rep.sub).
   if first-of(t-rep.bank) then do:
       find first txb where txb.bank = t-rep.bank no-lock no-error.

       put stream rpt2 unformatted
       '<Сведения>' skip
       '<F2>Филиал ' + txb.info + '</F2>' skip
       '</Сведения>' skip.

       v-famt_kz = 0.
       v-fpamt_kz = 0.
       v-famt_kz1 = 0.
       v-fpamt_kz1 = 0.
       do i = 1 to 5:
         v-fsum[i] = 0.
       end.
   end.

   if t-rep.sub = "aaa" then do:
        put stream rpt2 unformatted
        '<Сведения>' skip
        '<F1>' string(n)  '</F1>' skip
        '<F2>' t-rep.cifname  '</F2>' skip
        '<F3>' t-rep.cifps1  '</F3>' skip
        '<F4>' t-rep.cifps2  '</F4>' skip
        '<F5>' t-rep.cifrnn '</F5>' skip
        '<F6>' t-rep.cifadr '</F6>' skip
        '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
        '<F8>' t-rep.crc '</F8>' skip
        '<F9>' t-rep.gl '</F9>' skip
        '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
        '<F12>' replace(string(t-rep.amt,'>>>>>>>>>>>>>9.99'),'.',',') '</F12>' skip
        '<F13>' replace(string(t-rep.amt_kz,'>>>>>>>>>>>>>9.99'),'.',',')'</F13>' skip
        '<F28>' t-rep.bnkbic '</F28>' skip
        '<F29>' t-rep.iin '</F29>' skip
        '</Сведения>' skip.



        if t-rep.pamt > 0 then do:
            put stream rpt2 unformatted
            '<Сведения>' skip
            '<F1>' string(n)  '</F1>' skip
            '<F2>' t-rep.cifname  '</F2>' skip
            '<F3>' t-rep.cifps1  '</F3>' skip
            '<F4>' t-rep.cifps2  '</F4>' skip
            '<F5>' t-rep.cifrnn '</F5>' skip
            '<F6>' t-rep.cifadr '</F6>' skip
            '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
            '<F8>' t-rep.crc '</F8>' skip
            '<F9>' t-rep.gl '</F9>' skip
            '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
            '<F14>' replace(string(t-rep.pamt,'>>>>>>>>>>>>>9.99'),'.',',') '</F14>' skip
            '<F15>' replace(string(t-rep.pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',')'</F15>' skip
            '<F28>' t-rep.bnkbic '</F28>' skip
            '<F29>' t-rep.iin '</F29>' skip
            '</Сведения>' skip.
        end.
   end.

   if t-rep.sub = "lon" then do:
        /*ОД*/
        if t-rep.amt > 0 then do:
            put stream rpt2 unformatted
            '<Сведения>' skip
            '<F1>' string(n)  '</F1>' skip
            '<F2>' t-rep.cifname  '</F2>' skip
            '<F3>' t-rep.cifps1  '</F3>' skip
            '<F4>' t-rep.cifps2  '</F4>' skip
            '<F5>' t-rep.cifrnn '</F5>' skip
            '<F6>' t-rep.cifadr '</F6>' skip
            '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
            '<F8>' t-rep.crc '</F8>' skip
            '<F9>' t-rep.gl '</F9>' skip
            '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
            '<F17>' replace(string(t-rep.amt * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F17>' skip
            '<F18>' replace(string(t-rep.amt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F18>' skip
            '<F28>' t-rep.bnkbic '</F28>' skip
            '<F29>' t-rep.iin '</F29>' skip
            '</Сведения>' skip.
        end.

        /*просроч.ОД*/
        if t-rep.amt2 > 0 then do:
            put stream rpt2 unformatted
            '<Сведения>' skip
            '<F1>' string(n)  '</F1>' skip
            '<F2>' t-rep.cifname  '</F2>' skip
            '<F3>' t-rep.cifps1  '</F3>' skip
            '<F4>' t-rep.cifps2  '</F4>' skip
            '<F5>' t-rep.cifrnn '</F5>' skip
            '<F6>' t-rep.cifadr '</F6>' skip
            '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
            '<F8>' t-rep.crc '</F8>' skip
            '<F9>' t-rep.gl '</F9>' skip
            '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
            '<F17>' replace(string(t-rep.amt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F17>' skip
            '<F18>' replace(string(t-rep.amt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F18>' skip
            '<F28>' t-rep.bnkbic '</F28>' skip
            '<F29>' t-rep.iin '</F29>' skip
            '</Сведения>' skip.
        end.

        /*проценты*/
        if t-rep.pamt > 0 then do:

            put stream rpt2 unformatted
            '<Сведения>' skip
            '<F1>' string(n)  '</F1>' skip
            '<F2>' t-rep.cifname  '</F2>' skip
            '<F3>' t-rep.cifps1  '</F3>' skip
            '<F4>' t-rep.cifps2  '</F4>' skip
            '<F5>' t-rep.cifrnn '</F5>' skip
            '<F6>' t-rep.cifadr '</F6>' skip
            '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
            '<F8>' t-rep.crc '</F8>' skip
            '<F9>' t-rep.gl '</F9>' skip
            '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
            '<F19>' replace(string(t-rep.pamt * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F19>' skip
            '<F20>' replace(string(t-rep.pamt_kz * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F20>' skip
            '<F28>' t-rep.bnkbic '</F28>' skip
            '<F29>' t-rep.iin '</F29>' skip
            '</Сведения>' skip.

        end.

        /*просроч проценты*/
        if t-rep.pamt2 > 0 then do:
            put stream rpt2 unformatted
            '<Сведения>' skip
            '<F1>' string(n)  '</F1>' skip
            '<F2>' t-rep.cifname  '</F2>' skip
            '<F3>' t-rep.cifps1  '</F3>' skip
            '<F4>' t-rep.cifps2  '</F4>' skip
            '<F5>' t-rep.cifrnn '</F5>' skip
            '<F6>' t-rep.cifadr '</F6>' skip
            '<F7>' t-rep.docnum + ' ' + string(t-rep.docdt,'99/99/9999') '</F7>' skip
            '<F8>' t-rep.crc '</F8>' skip
            '<F9>' t-rep.gl '</F9>' skip
            '<F10>' string(t-rep.acc,'x(20)') '</F10>' skip
            '<F19>' replace(string(t-rep.pamt2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F19>' skip
            '<F20>' replace(string(t-rep.pamt_kz2 * -1,'->>>>>>>>>>>>>9.99'),'.',',') '</F20>' skip
            '<F28>' t-rep.bnkbic '</F28>' skip
            '<F29>' t-rep.iin '</F29>' skip
            '</Сведения>' skip.
        end.

   end.
   if first-of(t-rep.cif) then do:
       v-amt_kz = 0.
       v-pamt_kz = 0.
       v-amt_kz1 = 0.
       v-pamt_kz1 = 0.
   end.


   if last-of(t-rep.sub) then do:
       if t-rep.sub = 'aaa' then do:
          v-amt_kz = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
          v-pamt_kz = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).

           v-famt_kz = v-famt_kz + v-amt_kz.
           v-fpamt_kz = v-fpamt_kz + v-pamt_kz.

           v-bamt_kz = v-bamt_kz + v-amt_kz.
           v-bpamt_kz = v-bpamt_kz + v-pamt_kz.

       end.
       else do:
          v-amt_kz1 = ACCUM total by (t-rep.sub) (t-rep.amt_kz + t-rep.amt_kz2).
          v-pamt_kz1 = ACCUM total by (t-rep.sub)(t-rep.pamt_kz + t-rep.pamt_kz2).
          v-amt_kz1 = v-amt_kz1 * (-1).
          v-pamt_kz1 = v-pamt_kz1 * (-1).
          v-famt_kz1 = v-famt_kz1 + v-amt_kz1.
          v-fpamt_kz1 = v-fpamt_kz1 + v-pamt_kz1.
          v-bamt_kz1 = v-bamt_kz1 + v-amt_kz1.
          v-bpamt_kz1 = v-bpamt_kz1 + v-pamt_kz1.
       end.
   end.

   if last-of(t-rep.cif) then do:
      n = n + 1.
       put stream rpt2 unformatted
       '<Сведения>' skip
       '<F2>Итого по вкладчику</F2>' skip


       "<F13>" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F13>" skip /*13*/

       "<F15>" replace(string(v-pamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F15>" skip /*15*/
       "<F16>" replace(string((v-pamt_kz + v-amt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</F16>" skip /*16*/
       "<F18>" replace(string(v-amt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F18>" skip /*18*/
       "<F20>" replace(string(v-pamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F20>" skip /*20*/
       "<F21>" replace(string((v-pamt_kz1 + v-amt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F21>" skip /*21*/
       "<F22>" replace(string((v-pamt_kz + v-amt_kz1 + v-pamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F22>" skip. /*22*/
       if (v-pamt_kz + v-pamt_kz1 + v-amt_kz1) >= 0 then do:
         v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz1 + v-amt_kz.
         put stream rpt2 unformatted
         "<F23>" replace(string(v-amt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F23>" skip /*23*/
         "<F24>" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</F24>" skip. /*24*/
         v-fsum[1] = v-fsum[1] + v-summ. /*v-amt_kz.*/
         v-bsum[1] = v-bsum[1] + v-summ. /*v-amt_kz.*/
       end.

       else do:

         v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz + v-amt_kz1.
         put stream rpt2 unformatted
         "<F23>" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</F23>" skip /*23*/
         "<F24>" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</F24>" skip. /*24*/
         v-fsum[1] = v-fsum[1] + v-summ.
         v-bsum[1] = v-bsum[1] + v-summ.
       end.
         v-fsum[2] = v-fsum[2] + v-summ.
         v-bsum[2] = v-bsum[2] + v-summ.
       if v-summ > 0 then do:
         put stream rpt2 unformatted
         "<F25>" replace(string(v-summ,'->>>>>>>>>>>>>9.99'),'.',',') "</F25>" skip. /*25*/
         v-fsum[3] = v-fsum[3] + v-summ.
         v-bsum[3] = v-bsum[3] + v-summ.
         if v-amt_kz > 5000000 then do:
           v-fsum[4] = v-fsum[4] + 5000000. /*25*/
           v-fsum[5] = v-fsum[5] + v-summ - 5000000. /*26*/
           v-bsum[4] = v-bsum[4] + 5000000. /*25*/
           v-bsum[5] = v-bsum[5] + v-summ - 5000000. /*26*/

           put stream rpt2 unformatted
           "<F26>" replace(string(5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</F26>" skip /*26*/
           "<F27>" replace(string(v-summ - 5000000,'->>>>>>>>>>>>>9.99'),'.',',') "</F27></Сведения>" skip. /*27*/

         end.
         else do:
           v-fsum[4] = v-fsum[4] + v-summ.

           v-bsum[4] = v-bsum[4] + v-summ.


           put stream rpt2 unformatted
           "<F26>" replace(string( /*v-amt_kz */ v-summ,'>>>>>>>>>>>>>9.99'),'.',',') "</F26>" skip

           "<F27>" replace(string(0,'->>>>>>>>>>>>>9.99'),'.',',') "</F27></Сведения>" skip.

         end.
       end.
       else  put stream rpt2 unformatted "<F26>" replace(string(0,'>>>>>>>>>>>>>9.99'),'.',',') "</F26></Сведения>" skip.
   end.
/***************/
   if last-of(t-rep.bank) then do:
       find first txb where txb.bank = t-rep.bank no-lock no-error.

       put stream rpt2 unformatted
       "<Сведения>" skip
       "<F2>Всего по филиалу " + txb.info + "</F2>" skip
       "<F13>" replace(string(v-famt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F13>" skip /*13*/
       "<F15>" replace(string(v-fpamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F15>" skip /*15*/
       "<F16>" replace(string((v-fpamt_kz + v-famt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</F16>" skip /*16*/
       "<F18>" replace(string(v-famt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F18>" skip /*18*/

       "<F20>" replace(string(v-fpamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F20>" skip
       "<F21>" replace(string((v-fpamt_kz1 + v-famt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F21>" skip /*21*/
       "<F22>" replace(string((v-fpamt_kz + v-fpamt_kz1 + v-famt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F22>" skip /*22*/
       "<F23>" replace(string(v-fsum[1],'->>>>>>>>>>>>>9.99'),'.',',') "</F23>" skip /*23*/
       "<F24>" replace(string(v-fsum[2],'->>>>>>>>>>>>>9.99'),'.',',') "</F24>" skip /*24*/
       "<F25>" replace(string(v-fsum[3],'->>>>>>>>>>>>>9.99'),'.',',') "</F25>" skip
       "<F26>" replace(string(v-fsum[4],'->>>>>>>>>>>>>9.99'),'.',',') "</F26>" skip
       "<F27>" replace(string(v-fsum[5],'->>>>>>>>>>>>>9.99'),'.',',') "</F27></Сведения>" skip.
   end.
 end.
 put stream rpt2 unformatted
 "<Сведения>" skip
 "<F2>Всего по Банку</F2>" skip
 "<F13>" replace(string(v-bamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F13>" skip
 "<F15>" replace(string(v-bpamt_kz,'>>>>>>>>>>>>>9.99'),'.',',') "</F15>" skip
 "<F16>" replace(string((v-bpamt_kz + v-bamt_kz),'>>>>>>>>>>>>>9.99'),'.',',') "</F16>" skip
 "<F18>" replace(string(v-bamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F18>" skip
 "<F20>" replace(string(v-bpamt_kz1,'->>>>>>>>>>>>>9.99'),'.',',') "</F20>" skip
 "<F21>" replace(string((v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F21>" skip
 "<F22>" replace(string((v-bpamt_kz + v-bpamt_kz1 + v-bamt_kz1),'->>>>>>>>>>>>>9.99'),'.',',') "</F22>" skip
 "<F23>" replace(string(v-bsum[1],'->>>>>>>>>>>>>9.99'),'.',',') "</F23>" skip
 "<F24>" replace(string(v-bsum[2],'->>>>>>>>>>>>>9.99'),'.',',') "</F24>" skip
 "<F25>" replace(string(v-bsum[3],'->>>>>>>>>>>>>9.99'),'.',',') "</F25>" skip
 "<F26>" replace(string(v-bsum[4],'->>>>>>>>>>>>>9.99'),'.',',') "</F26>" skip
 "<F27>" replace(string(v-bsum[5],'->>>>>>>>>>>>>9.99'),'.',',') "</F27></Сведения></dataroot>" skip.


output stream rpt2 close.

hide all no-pause.

unix silent koi2utf depfiz.xml depfiz1.xml.
hide message no-pause.
unix silent value("cptwin depfiz1.xml explorer").
unix silent rm -f depfiz.xml.
unix silent rm -f depfiz1.xml.





