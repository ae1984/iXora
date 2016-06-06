/* r-depogar1.p
 * MODULE
        Отчет по фонду гарантирования вкладов
 * DESCRIPTION
        Отчет по фонду гарантирования вкладов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        освное меню Список скриптов, вызывающих этот файл
 * INHERIT
        r-depogar2.p
        r-depogar3.p
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        07/10/03 nataly отчет доработан в связи с изменениями, высланными НБ РК от 04.07.04
        14/01/04 nataly был доработан отчет по %% ставкам по депозитам
        29/03/08 marinav - изменения отчетности
        27/04/09 marinav - изменения суммы до 5 млн
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
        05.07.2013 dmitriy - ТЗ 1424. Включение количества счетов и сумм руководящих работников и акционеров
*/

{global.i}
def new shared temp-table vdepo
    field nm as char
    field name as char form "x(132)"
    field kol as int
    field summ as decimal format 'zzz,zzz,zzz,zz9.99'
    field summ_p as decimal format 'zzz,zzz,zzz,zz9.99'
    field summ_g as decimal format 'zzz,zzz,zzz,zz9.99'.

def new shared temp-table vdepo2
    field nm as char
    field srok as int
    field crc as integer
    field rate as decimal
    field garant as logical
    field sum1 as decimal format 'zz9.99'
    field sum2 as decimal format 'zz9.99'.

def new shared temp-table t-rep
  field bank as char
  field cif as char
  field cifname as char
  field cifpss as char
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
  index main is primary bank cif sub
  index cif cif.

/*Временные таблицы*********************************************/
def new shared temp-table t-gl /*временная таблица для сбора данных по счетам ГК*/
    field gl like gl.gl /*счет ГК*/
    field des like gl.des /*Название ГК*/
    index gl is primary unique gl.

def new shared temp-table t-glcrc
    field gl like gl.gl /*счет ГК*/
    field crc like crc.crc /*Валюта*/
    field amt as dec format "zzz,zzz,zzz,zzz.99-" /*сумма в валюте счета, зависит от валюты*/
    field amtkzt as dec format "zzz,zzz,zzz,zzz.99-" /*Сумма в валюте счета конвертированная в тенге*/
    index gl is primary gl.

def new shared temp-table t-acc /*временная таблица для сбора данных по субсчетам счетов ГК*/
    field fil as char format "x(30)"   /*филиал*/
    field gl  like t-gl.gl  /*счет ГК*/
    field gl4  as char   /*счет ГК4*/
    field acc like aaa.aaa  /*субсчет ГК*/
    field cif as char format "x(20)"  /*Название клиента*/
    field rnn as char format "x(12)"  /*Название клиента*/
    field geo as char format "x(3)"  /*ГЕО код*/
    field crc like t-glcrc.crc  /*валюта субсчета*/
    field ecdivis like sub-cod.ccode /*сектор отраслей экономики клиента*/
    field secek like sub-cod.ccode /*сектор экономики клиента*/
    field rdt like aaa.regdt /*дата открытия счета*/
    field duedt like arp.duedt /*дата закрытия счета*/

    field rdt1 as char /*пролонгация счета*/
    field duedt1 as char /*окончание действия счета*/

    field rate like aaa.rate /*процентная ставка по счету, если есть*/

    field opnamt like t-glcrc.amt /*сумма по договору*/

    field amt like t-glcrc.amt /*сумма в валюте субсчета, зависит от валюты*/
    field amtkzt like t-glcrc.amtkzt /*сумма в валюте субсчета конвертированная в тенге*/
    field kurs like crchis.rate[1] /*курс конвертации*/
    field lev2 as deci /*остаток на 2-ом уровне*/
    field lev2kzt as deci /*остаток на 2-ом уровне в kzt*/
    field lev11 as deci /*остаток на 11-ом уровне*/
    field des as char /*остаток на 11-ом уровне*/
    field attrib as char /*признак bnkrel*/
    field attrib_code as char /*код признака bnkrel*/
    field uslov as char /*услоние обслуживания*/
    field osnov as char /*основание*/
    field clnsegm as char /* код сегментации */
    /*field krate like txb.accr.rate ставка по счету на день загрузки отчета*/
    index gl is primary gl.

def new shared var v-gllist  as char.
def new shared var vasof  as date.
def new shared var v-crc  like crc.crc.
def new shared var vglacc as char format "x(6)".
def new shared var v-withprc as logi.
def new shared var v-withzero as logi.
/***************************************************************/


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
def var v-summ as deci.
def var v-shifr as logi.

def var sum_0   as deci.
def var kol_0   as deci.
def var sum_1-3 as deci.
def var kol_1-3 as deci.
def var sum_2-3 as deci.
def var kol_2-3 as deci.
def var sum_3-3 as deci.
def var kol_3-3 as deci.
def var file1 as char.

def new shared var m-dt as date.
def stream vcrpt.
output stream vcrpt to rpt.html.
def var v-bankname as char.
/*find cmp  no-lock.
 */
m-dt = today.

def var prz as integer.
def new shared var m-kvar as integer.
def new shared var m-year as integer.


find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

def frame opt1
    m-dt     format  "99/99/9999" label  "За дату         " skip
    v-shifr  format  "Да/Нет"     label  "Расшифровка     " skip
with side-labels centered row 10.

def var v-path as char no-undo.

if bank.cmp.name matches "*МКО*" then v-path = '/data/'.
else v-path = '/data/b'.

find bank.sysc where bank.sysc.sysc = "ourbnk" no-lock no-error.
find comm.txb where comm.txb.consolid and comm.txb.bank = bank.sysc.chval no-lock no-error.

if not comm.txb.is_branch then do:
  {sel-filial.i}
end.
else do:
  v-select = comm.txb.txb + 2.
end.

def button  btn1  label "Отчет по гаран. вкладов".
   def button  btn2  label "Средневз. ставки вознаграждения".
   def button  btn3  label "Выход".
   def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете отчет:" row 5 .

  on choose of btn1,btn2,btn3 do:
    if self:label = "Отчет по гаран. вкладов" then prz = 1.
    else
    if self:label = "Средневз. ставки вознаграждения" then prz=2.
    else prz = 3.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if prz = 3 then return.
 hide  frame frame1.

def var i as integer.


if prz = 2 then  do:
 update m-kvar  format 'zz' label 'Введите месяц '
        validate (m-kvar >= 1 and m-kvar <= 12,"Неверно задан месяц !")
         help "Задайте месяц."
        m-year format 'zzzz' label 'Введите год '
        validate (m-year >= 2001 and m-year <= year(g-today),"Неверно задан год !")
         help "Задайте год."
         with with row 8 centered  side-labels frame opt.
hide frame opt.
message "  Формируется отчет...".

/* {r-branch-arx3.i &proc = "r-depogar3"}*/
for each comm.txb where comm.txb.consolid and
         (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run r-depogar3.
end.

if connected ("txb")  then disconnect "txb".

if v-select = 1 then do:
  find first bank.cmp no-lock no-error.
  v-bankname = bank.cmp.name + "<br>Консолидированный отчет".
end.
else do:
  find comm.txb where comm.txb.consolid and comm.txb.txb = v-select - 2 no-lock no-error.
  v-bankname = comm.txb.name.
end.



{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

  put stream vcrpt unformatted "<b> Средневзвешанные ставки вознаграждения по привлеченным вкладам (депозитам) физических лиц
     за "  + string(m-kvar) +  "."  + string(m-year) + " г.</b>" skip.

put stream vcrpt unformatted
   "<TABLE  border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD ><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip
     "<TD  colspan=""2"" ><FONT size=""1""><B>гарантируемые</B></FONT></TD>" skip
     "</TR>" skip
   "<TR align=""center"">" skip
     "<TD ><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip
     "<TD ><FONT size=""1""><B>в тенге</B></FONT></TD>" skip
     "<TD ><FONT size=""1""><B>в иностранной валюте</B></FONT></TD>" skip
     "</TR>" skip.


def var v-sum1 as decimal.
def var v-sum2 as decimal.
def var v-sum11 as decimal.
def var v-sum22 as decimal.

def var sum1_gar as decimal.
def var sum11_gar as decimal.
def var sum2_gar as decimal.
def var sum22_gar as decimal.

def var sum1_garn as decimal.
def var sum11_garn as decimal.
def var sum2_garn as decimal.
def var sum22_garn as decimal.

def new shared temp-table vdepo3
    field des as char
    field srok as int
    field crc as integer
    field sum1 as decimal format 'zz9.99'
    field sum2 as decimal format 'zz9.99'
    field sum3 as decimal format 'zz9.99'
    field sum4 as decimal format 'zz9.99'.



for each vdepo2 break by vdepo2.garant by vdepo2.srok.
if vdepo2.crc = 1 then do:
      v-sum1 =  v-sum1 + vdepo2.rate * vdepo2.sum1.
      v-sum11 =  v-sum11 +  vdepo2.sum1.
   end.
else  do:
   v-sum2 =  v-sum2 + vdepo2.rate * vdepo2.sum1.
   v-sum22=  v-sum22 + vdepo2.sum1.
 end.
 if last-of(vdepo2.srok) then do:
  find vdepo3 where vdepo3.srok = vdepo2.srok  no-lock no-error.
  if not avail vdepo3 then do:
    create vdepo3.
    vdepo3.crc = vdepo2.crc.
    vdepo3.srok = vdepo2.srok.
  end.
    if vdepo2.garant = true then do:
     if v-sum11 <> 0 then vdepo3.sum1 = v-sum1 / v-sum11. else vdepo3.sum1 = 0. /*tenge*/
     if v-sum22 <> 0 then  vdepo3.sum2 = v-sum2 / v-sum22. else vdepo3.sum2 = 0.
   end.
   if (vdepo2.srok = 1 or  vdepo2.srok = 2 or vdepo2.srok = 3  or vdepo2.srok = 4) and vdepo2.garant = true
    then do:
       sum1_gar =  sum1_gar + v-sum1.   sum11_gar =  sum11_gar + v-sum11.
       sum2_gar =  sum2_gar + v-sum2.   sum22_gar =  sum22_gar + v-sum22.
    end.

   v-sum1 = 0. v-sum2 = 0.  v-sum11 = 0. v-sum22 = 0.
end.
end.

def var v-name as char extent 8 init ['до 6 месяцев вкл', 'до 12 месяцев вкл', 'до 36 месяцев вкл', 'свыше 36 месяцев','2)Условные вклады', '3)Вклады до востребования','4)Текущие счета','5)Карт-счета'].

find first vdepo3 where vdepo3.srok = 4 no-lock no-error.
if not avail vdepo3 then do: create vdepo3. vdepo3.srok = 4. end.
find first vdepo3 where vdepo3.srok = 5 no-lock no-error.
if not avail vdepo3 then do: create vdepo3. vdepo3.srok = 5. end.
find first vdepo3 where vdepo3.srok = 6 no-lock no-error.
if not avail vdepo3 then do: create vdepo3. vdepo3.srok = 6. end.
find first vdepo3 where vdepo3.srok = 7 no-lock no-error.
if not avail vdepo3 then do: create vdepo3. vdepo3.srok = 7. end.
find first vdepo3 where vdepo3.srok = 8 no-lock no-error.
if not avail vdepo3 then do: create vdepo3. vdepo3.srok = 8. end.

find first vdepo3 where vdepo3.srok = 0 no-lock no-error.
if avail vdepo3 then delete vdepo3.

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .
  put stream vcrpt unformatted
     "<TD><FONT size=""1"">1)Срочные вклады: </FONT></TD>" skip
     "<TD><FONT size=""1"">"  + replace(string(sum1_gar / sum11_gar , 'zzzzzzzz9.99'),'.',',') +  "</FONT></TD>" skip
     "<TD><FONT size=""1"">"  + replace(string(sum2_gar / sum22_gar , 'zzzzzzzz9.99'),'.',',') +  "</FONT></TD>" skip.
  put stream vcrpt unformatted
    "</TR>" skip.

for each vdepo3 break by vdepo3.srok .
   if vdepo3.srok = 0 then next.
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .
     put stream vcrpt unformatted
     "<TD><FONT size=""1"">"   +  v-name[srok]   +  "</FONT></TD>" skip
     "<TD><FONT size=""1"">"  + replace(string(vdepo3.sum1 , 'zzzzzzzz9.99'),'.',',') +  "</FONT></TD>" skip
     "<TD><FONT size=""1"">"  + replace(string(vdepo3.sum2 , 'zzzzzzzz9.99'),'.',',') +  "</FONT></TD>" skip.

  put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin rpt.html  excel").

end.
else do:
v-shifr = yes.
display m-dt v-shifr with frame opt1.
update m-dt v-shifr with frame opt1.

hide frame opt1.

/*-----------------------------*/
for each comm.txb where comm.txb.consolid and  (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run txb_allfiz(m-dt,txb.bank).
end.
if connected ("txb")  then disconnect "txb".

run calc_sum.

v-gllist = "".
vasof = m-dt.
v-crc = 1.
vglacc = "".
v-withprc = yes.
v-withzero = no.

for each comm.txb where comm.txb.consolid and  (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run depogar_dop (comm.txb.bank).
end.
if connected ("txb")  then disconnect "txb".

kol_1-3 = 0.
for each t-rep where lookup(t-rep.gl, "2205191,2205291,2205192,2205193,2205292,2205293,2224191,2224291,2224192,2224193,2224292,2224293") > 0 no-lock:
    find first t-acc where t-acc.acc = t-rep.acc no-lock no-error.
    if avail t-acc and lookup(t-acc.attrib_code, "01,04,07,11") > 0 then do:
        sum_1-3 = sum_1-3 + (t-rep.amt_kz + t-rep.amt_kz2).
        kol_1-3 = kol_1-3 + 1.
    end.
end.

kol_2-3 = 0.
for each t-rep where lookup(t-rep.gl, "2206191,2206291,2206192,2206193,2206292,2206293,2207191,2207291,2207192,2207193,2207292,2207293,2208191,2208291,2208192,
2208193,2208292,2208293,2213191,2213291,2213192,2213193,2213292,2213293,2226191,2226291,2232191,2232291,2226192,2226193,2226292,2226293,2232192,2232193,22322292,2232293") > 0 no-lock:
    find first t-acc where t-acc.acc = t-rep.acc no-lock no-error.
    if avail t-acc and lookup(t-acc.attrib_code, "01,04,07,11") > 0 then do:
        sum_2-3 = sum_2-3 + (t-rep.amt_kz + t-rep.amt_kz2).
        kol_2-3 = kol_2-3 + 1.
    end.
end.

kol_3-3 = 0.
for each t-rep where lookup(t-rep.gl, "2204191,2204291,2209191,2209291,2204192,2204193,2204292,2204293,2209193,2209292,2209293") > 0 no-lock:
    find first t-acc where t-acc.acc = t-rep.acc no-lock no-error.
    if avail t-acc and lookup(t-acc.attrib_code, "01,04,07,11") > 0 then do:
        sum_3-3 = sum_3-3 + (t-rep.amt_kz + t-rep.amt_kz2).
        kol_3-3 = kol_3-3 + 1.
    end.
end.

/*-----------------------------*/

create vdepo. nm = '0'. vdepo.name = 'Всего депозитов физ. лиц в тенге и иностранной валюте, в т.ч.'.
create vdepo. nm = '1'. vdepo.name = 'Вкдады до востребования, в т.ч.'.
create vdepo. nm = '1.1'. vdepo.name = 'в тенге'.
create vdepo. nm = '1.2'. vdepo.name = 'в иностранной валюте'.
create vdepo. nm = '1.3'. vdepo.name = 'Вклады до востребования руководящих работников и акционеров, владеющих более 5% акций банка с правом голоса, их близких родтсвенников'.
create vdepo. nm = '2'. vdepo.name = 'Срочные и условные вклады, в т.ч.:'.
create vdepo. nm = '2.1'. vdepo.name = 'в тенге, в т.ч.:'.
create vdepo. nm = '2.1.a'. vdepo.name ='  до 1 000 тыс. тенге включительно, в т.ч.'.
create vdepo. nm = '2.1.b'. vdepo.name = '  от 1 000 тыс.    до 3 000 тыс. тенге включительно'.
create vdepo. nm = '2.1.c'. vdepo.name = '  от 3 000 тыс.  до 5 000 тыс. тенге включительно'.
create vdepo. nm = '2.1.d'. vdepo.name = '  от 5 000 тыс.  до 10 000 тыс. тенге включительно'.
create vdepo. nm = '2.1.e'. vdepo.name = '  от 10 000 тыс. до 15 000 тыс. тенге включительно'.
create vdepo. nm = '2.1.f'. vdepo.name = '  свыше 15 000 тыс. '.
create vdepo. nm = '2.2'. vdepo.name = 'в иностранной валюте, в т.ч.:'.
create vdepo. nm = '2.2.a'. vdepo.name ='  до 1 000 тыс. тенге в эквиваленте включительно, в т.ч.'.
create vdepo. nm = '2.2.b'. vdepo.name = '  от 1 000 тыс. до 3 000 тыс. тенге в эквиваленте включительно'.
create vdepo. nm = '2.2.c'. vdepo.name = '  от 3 000 тыс. до 5 000 тыс. тенге включительно'.
create vdepo. nm = '2.2.d'. vdepo.name = '  от 5 000 тыс. до 10 000 тыс. тенге включительно'.
create vdepo. nm = '2.2.e'. vdepo.name = '  от 10 000 тыс. до 15 000 тыс. тенге в эквиваленте включительно'.
create vdepo. nm = '2.2.f'. vdepo.name = '  свыше 15 000 тыс. '.
create vdepo. nm = '2.3'. vdepo.name = 'Срочные вклады  руководящих работников и акционеров, владеющих более 5% акций банка с правом голоса, их близких родтсвенников'.

create vdepo. nm = '3'. vdepo.name = 'Остатки денег на тек. счетах (с учетом остатков денег на карт-счетах) в т.ч.'.
create vdepo. nm = '3.1'. vdepo.name = 'в тенге'.
create vdepo. nm = '3.2'. vdepo.name = 'в иностранонй валюте'.
create vdepo. nm = '3.3'. vdepo.name = 'Остатки денег на тек счетах руководящих работников и акционеров, владеющих более 5% акций банка с правом голоса, их близких родтсвенников'.

def new shared stream m-out.
output stream m-out to m-out.txt.


message "  Формируется отчет...".
/* {r-branch-arx3.i &proc = "r-depogar2"}*/

for each comm.txb where comm.txb.consolid and  (if v-select = 1 then true else comm.txb.txb = v-select - 2) no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run r-depogar2.
end.
if connected ("txb")  then disconnect "txb".


if v-select = 1 then do:
  find first bank.cmp no-lock no-error.
  v-bankname = bank.cmp.name + "<br>Консолидированный отчет".
end.
else do:
  find comm.txb where comm.txb.consolid and comm.txb.txb = v-select - 2 no-lock no-error.
  v-bankname = comm.txb.name.
end.

output stream m-out close.


find first vdepo where vdepo.nm = '1.3' exclusive-lock no-error.
if avail vdepo then do transaction:
    vdepo.summ = sum_1-3.
    vdepo.kol = kol_1-3.
end.

find first vdepo where vdepo.nm = '2.3' exclusive-lock no-error.
if avail vdepo then do transaction:
    vdepo.summ = sum_2-3.
    vdepo.kol = kol_2-3.
end.

find first vdepo where vdepo.nm = '3.3' exclusive-lock no-error.
if avail vdepo then do transaction:
    vdepo.summ = sum_3-3.
    vdepo.kol = kol_3-3.
end.

/* добавление arp к карточным счетам */
for each t-acc where t-acc.gl = 220431 no-lock:
    if t-acc.crc = 1 then do:
         find first vdepo where vdepo.nm = '3.1' no-lock no-error.
         vdepo.kol = vdepo.kol + 1.
         vdepo.summ = vdepo.summ + t-acc.amtkzt.
    end.
    else do:
         find first vdepo where vdepo.nm = '3.2' no-lock no-error.
         vdepo.kol = vdepo.kol + 1.
         vdepo.summ = vdepo.summ + t-acc.amtkzt.
    end.

    find first vdepo where vdepo.nm = '3' no-lock no-error.
         vdepo.kol = vdepo.kol + 1.
         vdepo.summ = vdepo.summ + t-acc.amtkzt.
end.

find first vdepo where vdepo.nm = '1' no-lock no-error.
sum_0 = sum_0 + vdepo.summ. kol_0 = kol_0 + vdepo.kol.
find first vdepo where vdepo.nm = '2' no-lock no-error.
sum_0 = sum_0 + vdepo.summ. kol_0 = kol_0 + vdepo.kol.
find first vdepo where vdepo.nm = '3' no-lock no-error.
sum_0 = sum_0 + vdepo.summ. kol_0 = kol_0 + vdepo.kol.

find first vdepo where vdepo.nm = '0' no-lock no-error.
vdepo.summ = sum_0.
vdepo.kol  = kol_0.

/* --------------------------------- */

{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}

  put stream vcrpt unformatted "<b>" v-bankname "</b><br>" skip.
  put stream vcrpt unformatted "<b> Отчет о вкладах (депозитах) физических лиц, являющихся объектом
    обязательного коллективного гарантирования (страхования) вкладов (депозитов) ФЛ  на "  + string(m-dt) + "</b>" skip.

put stream vcrpt unformatted
   "<TABLE border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B> п/п</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Наименование</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кол-во счетов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Всего депозитов</B></FONT></TD>" skip
     /*"<TD><FONT size=""1""><B>Сумма возмещения <br>Фонда по депозитам</B></FONT></TD>" skip*/
     "</TR>" skip.

for each vdepo break by vdepo.nm .

  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .
  put stream vcrpt unformatted
     "<TD><FONT size=""1"">"   + if vdepo.nm matches '*a*' or vdepo.nm matches '*b*' or vdepo.nm matches '*c*'
        or vdepo.nm matches '*d*' or vdepo.nm matches '*e*' or vdepo.nm matches '*f*' then " " else  '`' + vdepo.nm +  "</FONT></TD>" skip
     "<TD><FONT size=""1"">"  + vdepo.name +  "</FONT></TD>" skip
     "<TD><FONT size=""1"">"  + string(vdepo.kol) +  "</FONT></TD>" skip
     "<TD>"   int(round(vdepo.summ / 1000, 0))    "</TD>" skip
     /*"<TD><FONT size=""1"">"  + replace(string(vdepo.summ_g / 1000,'zzzzzzzzz9.99'),'.',',') +  "</FONT></TD>" skip.*/
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

put stream vcrpt unformatted "<TABLE><TR></TR></TABLE>".


put stream vcrpt unformatted
    "<TABLE border=""1"" cellspacing=""0"" cellpadding=""5""><TR>"
    "<TD>" "</TD>"
    "<TD>Сумма возмещения Фонда по депозитам</TD>"
    "<TD>" int(round(v-bsum[4] / 1000, 0)) "</TD>"
    "</TR>"
    "<TR>"
    "<TD>" "</TD>"
    "<TD>Количество клиентов</TD>"
    "<TD>" string(n - 1) "</TD>"
    "</TR></TABLE>".



{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin rpt.html  excel").
end. /*prz = 1*/

pause 0.

if v-shifr then run PrintShifr.

procedure calc_sum:
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
            v-famt_kz = 0.
            v-fpamt_kz = 0.
            v-famt_kz1 = 0.
            v-fpamt_kz1 = 0.
            do i = 1 to 5:
                v-fsum[i] = 0.
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

            if (v-pamt_kz + v-pamt_kz1 + v-amt_kz1) >= 0 then do:
                v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz1 + v-amt_kz.

                v-fsum[1] = v-fsum[1] + v-summ. /*v-amt_kz.*/
                v-bsum[1] = v-bsum[1] + v-summ. /*v-amt_kz.*/
            end.
            else do:
                v-summ = v-pamt_kz + v-pamt_kz1 + v-amt_kz + v-amt_kz1.

                v-fsum[1] = v-fsum[1] + v-summ.
                v-bsum[1] = v-bsum[1] + v-summ.
            end.

            v-fsum[2] = v-fsum[2] + v-summ.
            v-bsum[2] = v-bsum[2] + v-summ.

            if v-summ > 0 then do:
                v-fsum[3] = v-fsum[3] + v-summ.
                v-bsum[3] = v-bsum[3] + v-summ.

                if v-amt_kz > 5000000 then do:
                    v-fsum[4] = v-fsum[4] + 5000000. /*25*/
                    v-fsum[5] = v-fsum[5] + v-summ - 5000000. /*26*/
                    v-bsum[4] = v-bsum[4] + 5000000. /*25*/
                    v-bsum[5] = v-bsum[5] + v-summ - 5000000. /*26*/
                end.
                else do:
                    v-fsum[4] = v-fsum[4] + v-amt_kz.
                    v-fsum[5] = v-fsum[5] + v-summ - v-amt_kz.
                    v-bsum[4] = v-bsum[4] + v-amt_kz.
                    v-bsum[5] = v-bsum[5] + v-summ - v-amt_kz.
                end.
            end.
        end.
    end.
end procedure.

procedure PrintShifr:
    file1 = "depo_ost.html".
    output to value(file1).
    {html-title.i}

    put unformatted
    "<HTML xmlns:o=""urn:schemas-microsoft-com:office:office"" xmlns:x=""urn:schemas-microsoft-com:office:excel"" xmlns="""">" skip
    "<HEAD>"                                          skip
    " <!--[if gte mso 9]><xml>"                       skip
    " <x:ExcelWorkbook>"                              skip
    " <x:ExcelWorksheets>"                            skip
    " <x:ExcelWorksheet>"                             skip
    " <x:Name>17161</x:Name>"                         skip
    " <x:WorksheetOptions>"                           skip
    " <x:Selected/>"                                  skip
    " <x:DoNotDisplayGridlines/>"                     skip
    " <x:TopRowVisible>52</x:TopRowVisible>"          skip
    " <x:Panes>"                                      skip
    " <x:Pane>"                                       skip
    " <x:Number>3</x:Number>"                         skip
    " <x:ActiveRow>12</x:ActiveRow>"                  skip
    " <x:ActiveCol>24</x:ActiveCol>"                  skip
    " </x:Pane>"                                      skip
    " </x:Panes>"                                     skip
    " <x:ProtectContents>False</x:ProtectContents>"   skip
    " <x:ProtectObjects>False</x:ProtectObjects>"     skip
    " <x:ProtectScenarios>False</x:ProtectScenarios>" skip
    " </x:WorksheetOptions>"                          skip
    " </x:ExcelWorksheet>"                            skip
    " </x:ExcelWorksheets>"                           skip
    " <x:WindowHeight>7305</x:WindowHeight>"          skip
    " <x:WindowWidth>14220</x:WindowWidth>"           skip
    " <x:WindowTopX>120</x:WindowTopX>"               skip
    " <x:WindowTopY>30</x:WindowTopY>"                skip
    " <x:ProtectStructure>False</x:ProtectStructure>" skip
    " <x:ProtectWindows>False</x:ProtectWindows>"     skip
    " </x:ExcelWorkbook>"                             skip
    "</xml><![endif]-->"                              skip
    "<meta http-equiv=Content-Language content=ru>"   skip.

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""0"" width=""100%"">"
    "<TR align=""left""><td colspan=""26"">АО ""ForteBank""</td></tr>"
    "<TR align=""center""><td colspan=""26"">ОСТАТКИ ПО СЧЕТАМ Г/К (2204,2205,2206,2207,2208,2209,2213,2221,2226,2232) ЗА " m-dt format "99.99.9999" "</td></tr>"
    "<TR align=""center""><td colspan=""26"">Время создания: " today " , " STRING(TIME,"HH:MM:SS")"</td></tr>"
    "<tr></tr>"
    "</TABLE>".

    put unformatted
    "<TABLE cellspacing=""0"" cellpadding=""5"" align=""center"" border=""1"" width=""100%"">" skip.

    put unformatted
    "<TR align=""center"" valign=""top"">"
            "<TD>Филиал</TD>"
            "<TD>Счет</TD>"
            "<TD>Счет ГК</TD>"
            "<TD>Клиент</TD>"
            "<TD>Валюта</TD>"
            "<TD>Сектор отраслей <br> экономики</TD>"
            "<TD>Сектор <br> экономики</TD>"
            "<TD>Дата открытия</TD>"
            "<TD>Дата закрытия</TD>"
            "<TD>Код сегментации</TD>"
            "<TD>Ставка <br> (%)</TD>"
            "<TD>Сумма по <br> договору</TD>"
            "<TD>Сумма в валюте <br> счета</TD>"
            "<TD>Сумма конверт. <br> в тенге</TD>"
            "<TD>Курс конверт. <br> в тенге</TD>"
            "<TD>Гео код</TD>"
            "<TD>Нач. %%</TD>"
            "<TD>Нач. %% (KZT)</TD>"
            "<TD>Расходы (11 ур.)</TD>"
            "<TD>Группа депозита</TD>"
            "<TD>Признак ""Лица связанные с банком особыми отношениями""</TD>"
            "<TD>код признака <br>""Лица связанные с банком особыми отношениями""</TD>"
            "<TD>Условие обслуживания</TD>"
            "<TD>Основание</TD>"
            "<TD>Дата открытия после пролонгации</TD>"
            "<TD>Дата закрытия после пролонгации</TD>"
            "<TD>ИИН/БИН</TD>"
    "</TR>".

    for each t-acc where lookup(t-acc.gl4, "2204,2205,2206,2207,2208,2209,2213,2224,2226,2232") > 0 no-lock:
            put unformatted
            "<TR align=""center"">"
            "<TD>" t-acc.fil "</TD>"
            "<TD>" t-acc.acc "</TD>"
            "<TD>" t-acc.gl "</TD>"
            "<TD>" t-acc.cif "</TD>"
            "<TD>" t-acc.crc "</TD>"
            "<TD>" t-acc.ecdivis "</TD>"
            "<TD>" t-acc.secek "</TD>"
            "<TD>" t-acc.rdt "</TD>"
            "<TD>" t-acc.duedt "</TD>"
            "<TD>" t-acc.clnsegm "</TD>"
            "<TD>" replace(string(t-acc.rate),".",",") "</TD>"
            "<TD>" replace(string(t-acc.opnamt),".",",") "</TD>"
            "<TD>" replace(string(t-acc.amt),".",",") "</TD>"
            "<TD>" replace(string(t-acc.amtkzt),".",",") "</TD>"
            "<TD>" replace(string(t-acc.kurs),".",",") "</TD>"
            "<TD>" t-acc.geo "</TD>"
            "<TD>" replace(string(t-acc.lev2),".",",") "</TD>"
            "<TD>" replace(string(t-acc.lev2kzt),".",",") "</TD>"
            "<TD>" replace(string(t-acc.lev11),".",",") "</TD>"
            "<TD>" t-acc.des "</TD>"
            "<TD>" t-acc.attrib "</TD>"
            "<TD>" t-acc.attrib_code "</TD>"
            "<TD>" t-acc.uslov "</TD>"
            "<TD>" t-acc.osnov "</TD>"
            "<TD>" t-acc.rdt1 "</TD>"
            "<TD>" t-acc.duedt1 "</TD>"
            "<TD>'" t-acc.rnn "</TD>"
            "</TR>".
    end.

    put unformatted
    "</TABLE>".

    {html-end.i " "}
    output close.
    unix silent cptwin value(file1) excel.
    unix silent rm value(file1).
end procedure.

