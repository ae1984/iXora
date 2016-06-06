/* deplst.p
 * MODULE
        Отчеты по клиентам
 * DESCRIPTION
        Список депозитов с определенными сроками
        с возможностью указания групп депозитов
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-7-7-8
 * BASES
        BANK COMM
 * AUTHOR
        27.04.2004 nadejda
 * CHANGES
        10.05.2004 nadejda - добавлены поля nextdt, class
        02.02.10 marinav - расширение поля счета до 20 знаков
*/

{mainhead.i}


def var v-viewcls as logical format "да/нет" init no.
def var v-srokb as integer init 12.
def var v-sroke as integer init 24.
def var v-lgrs as char.
def var v-leds as char init "CDA,TDA".
def var v-mc as decimal.
def var v-mcexist as decimal.
def var v-god as decimal.
def var v-lgrrate as decimal.
def var v-aabrate as decimal.
def var v-currentbase as decimal.
def var v-procs as char.
def var v-dt as date.

def temp-table t-proc
  field rdt as date
  field rate as decimal
  index main is primary rdt rate.

def temp-table t-accs
  field lgr    as char
  field des    as char
  field aaa    as char
  field cif    as char
  field name   as char
  field code   as char
  field opnamt as char
  field mc     as integer
  field class  as integer
  field mcexist as integer
  field rate   as char
  field lgrrate as char
  field aabrate as char
  field procs  as char
  field regdt  as char
  field expdt  as char
  field feensf as integer
  field pri    as char
  field sta    as char
  field bal    as char
  field bal%   as char
  field renew  as char
  field nextdt as date
  index main is primary lgr name opnamt.

  
def frame f-param
  v-srokb   label " Депозиты сроком не менее " format ">>>>>9" 
    validate (v-srokb > 0, " Неверный срок!") skip
  v-sroke   label "               и не более " format ">>>>>9" 
    validate (v-sroke >= v-srokb, " Неверный срок!") skip
  v-leds     label "            По сабледжерам" format "x(30)" skip
  v-lgrs     label "                По группам" format "x(30)" skip
  v-viewcls label " Показывать закрытые деп.?" skip
  with centered row 4 side-labels title " ПАРАМЕТРЫ ОТЧЕТА ".
  
v-dt = g-today.

displ v-srokb v-sroke v-lgrs v-leds v-viewcls with frame f-param.

update v-srokb with frame f-param.
update v-sroke v-leds v-lgrs v-viewcls with frame f-param.

v-lgrs = trim(v-lgrs).

for each lgr no-lock:
  if v-lgrs <> "" and lookup(lgr.lgr, v-lgrs) = 0 then next.

  if v-leds <> "" and lookup(lgr.led, v-leds) = 0 then next.

  for each aaa where aaa.lgr = lgr.lgr no-lock:
    if not v-viewcls and aaa.sta = "c" then next.
    if aaa.cr[1] - aaa.dr[1] = 0 and aaa.cr[2] - aaa.dr[2] = 0 then next.

    v-mc = (aaa.expdt - aaa.regdt) / 30.

    if v-mc < v-srokb or v-mc > v-sroke then next.

    find cif where cif.cif = aaa.cif no-lock no-error.
    find crc where crc.crc = aaa.crc no-lock no-error.

    /* ставка по группе */
    if lgr.led <> "tda" then v-lgrrate = lgr.rate.
    else do:
      find aas where aas.aaa = aaa.aaa and aas.ln = 7777777 no-lock no-error.
      if available aas then v-currentbase = aas.chkamt.
                       else v-currentbase = 0.


      run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, v-currentbase, output v-lgrrate).
    end.

    for each t-proc. delete t-proc. end.
    for each aab where aab.aaa = aaa.aaa no-lock:
      find t-proc where t-proc.rate = aab.rate no-error.
      if avail t-proc then next.
      create t-proc.
      t-proc.rdt = aab.fdt.
      t-proc.rate = aab.rate.
    end.
    v-procs = "".
    for each t-proc:
      if t-proc.rdt = aaa.regdt then next.
      if v-procs <> "" then v-procs = v-procs + ";".
      v-procs = v-procs + string(t-proc.rdt, "99/99/99") + "-" + trim(string(t-proc.rate, ">>>>>>9.99")).
    end.

    find first aab where aab.aaa = aaa.aaa and aab.bal > 0 no-lock no-error.
    if avail aab then v-aabrate = aab.rate.
                 else v-aabrate = aaa.rate.

    v-mcexist = (v-dt - aaa.regdt) / 30.

    create t-accs.
    assign t-accs.lgr = lgr.lgr
           t-accs.des = lgr.des
           t-accs.aaa = aaa.aaa
           t-accs.cif = aaa.cif
           t-accs.name = trim(trim(cif.name) + " " + trim(cif.prefix))
           t-accs.code = crc.code
           t-accs.opnamt = replace(trim(string(aaa.opnamt, ">>>>>>>>>>>>>>9.99")), ".", ",")
           t-accs.mc = round(v-mc, 0)
           t-accs.class = aaa.cla
           t-accs.mcexist = round(v-mcexist, 0)
           t-accs.rate = replace(trim(string(aaa.rate, ">>>>>>>>>>>>>>9.99")), ".", ",") 
           t-accs.lgrrate = replace(trim(string(v-lgrrate, ">>>>>>>>>>>>>>9.99")), ".", ",")
           t-accs.aabrate = replace(trim(string(v-aabrate, ">>>>>>>>>>>>>>9.99")), ".", ",")
           t-accs.procs = v-procs
           t-accs.regdt = string(aaa.regdt, "99/99/9999")
           t-accs.expdt = string(aaa.expdt, "99/99/9999")
           t-accs.feensf = lgr.feensf
           t-accs.pri = aaa.pri
           t-accs.sta = aaa.sta
           t-accs.bal = replace(trim(string(aaa.cr[1] - aaa.dr[1], ">>>>>>>>>>>>>>9.99")), ".", ",")
           t-accs.bal% = replace(trim(string(aaa.cr[2] - aaa.dr[2], ">>>>>>>>>>>>>>9.99")), ".", ",")
           t-accs.renew = lgr.prefix
           t-accs.nextdt = aaa.nextint.
        
  end.
end.

/* выдача отчета */
def stream m-out.
output stream m-out to deplst.html.
{html-title.i &stream = "stream m-out" &size-add = "xx-"}

put stream m-out unformatted 
  "<P><b>Список депозитов по срокам<br>на " string(v-dt, "99/99/9999") 
  "<br><br>сроки с " v-srokb " по " v-sroke " месяцев"
  "<br>сабледжеры : " if v-leds = "" then "все" else v-leds
  "<br>группы : " if v-lgrs = "" then "все" else v-lgrs
  "</b></P>" skip
  "<TABLE border=1>" skip
  "<tr align=center style=""font:bold;font-size:xx-small"">"
    "<td>Группа</td>" skip
    "<td>Название</td>" skip
    "<td>Счет</td>" skip
    "<td>Код<br>клиента</td>" skip
    "<td>Клиент</td>" skip
    "<td>Вал</td>" skip
    "<td>Сумма<br>при откр</td>" skip
    "<td>Класс<br>(мес)</td>" skip
    "<td>Срок акт.<br>(мес)</td>" skip
    "<td>Прошло<br>месяцев</td>" skip
    "<td>Ставка<br>счета</td>" skip
    "<td>Ставка<br>группы в<br>наст время</td>" skip
    "<td>Ставка<br>счета<br>при открытии</td>" skip
    "<td>Дата пересмотра<br>% ставки</td>" skip
    "<td>Изменение ставок</td>" skip
    "<td>Дата рег</td>" skip
    "<td>Дата оконч</td>" skip
    "<td>Проц.<br>схема</td>" skip
    "<td>Код<br>табл.%</td>" skip
    "<td>Период<br>обновл %</td>" skip
    "<td>Статус</td>" skip
    "<td>Осн.сумма</td>" skip
    "<td>Проценты</td>" skip
    "<td>Дата<br>допвзноса</td>" skip
    "<td>Ставка<br>допвзноса</td>" skip
    "<td>Дебет<br>допвзноса</td>" skip
    "<td>Кредит<br>допвзноса</td></tr>" skip.

for each t-accs no-lock:
  put stream m-out unformatted 
      "<TR>"  skip
      "<TD>" t-accs.lgr     "</TD>" skip
      "<TD>" t-accs.des     "</TD>" skip
      "<TD>" t-accs.aaa format "x(20)"    "</TD>" skip
      "<TD>" t-accs.cif     "</TD>" skip
      "<TD>" t-accs.name    "</TD>" skip
      "<TD>" t-accs.code    "</TD>" skip
      "<TD>" t-accs.opnamt  "</TD>" skip
      "<TD>" t-accs.class      "</TD>" skip
      "<TD>" t-accs.mc      "</TD>" skip
      "<TD>" t-accs.mcexist "</TD>" skip
      "<TD" if t-accs.rate = t-accs.aabrate then "" else " bgcolor=yellow" ">" t-accs.rate    "</TD>" skip
      "<TD>" t-accs.lgrrate "</TD>" skip
      "<TD" if t-accs.rate = t-accs.aabrate then "" else " bgcolor=yellow" ">" t-accs.aabrate "</TD>" skip
      "<TD>" t-accs.nextdt      "</TD>" skip
      "<TD>" t-accs.procs   "</TD>" skip
      "<TD>" t-accs.regdt   "</TD>" skip
      "<TD>" t-accs.expdt   "</TD>" skip
      "<TD>" t-accs.feensf  "</TD>" skip
      "<TD>" t-accs.pri     "</TD>" skip
      "<TD>" t-accs.renew     "</TD>" skip
      "<TD>" t-accs.sta     "</TD>" skip
      "<TD>" t-accs.bal     "</TD>" skip
      "<TD>" t-accs.bal%    "</TD>" skip.
      
  for each aad where aad.aaa = t-accs.aaa no-lock:
    put stream m-out unformatted 
      "<TD>" aad.regdt "</TD>"
      "<TD>" replace(trim(string(aad.rate, ">>>>>>>>>>>>>>9.99")), ".", ",") "</TD>"
      "<TD>" replace(trim(string(aad.dam, ">>>>>>>>>>>>>>9.99")), ".", ",") "</TD>"
      "<TD>" replace(trim(string(aad.cam, ">>>>>>>>>>>>>>9.99")), ".", ",") "</TD>" skip.
  end. 

  put stream m-out unformatted 
      "</TR>" skip.
end.

put stream m-out unformatted "</TABLE>" skip.

{html-end.i "stream m-out"}
output stream m-out close.

unix silent cptwin deplst.html excel.

unix silent rm -f deplst.html.
pause 0.
