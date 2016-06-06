/* r-deprat.p
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

/* r-deprat.p 
   Сводный отчет о депозитах - остатки и средневзвеш.ставки вознаграждения по валютам

   Создан : 27.05.2003 Надежда Лысковская

*/


{mainhead.i}

def var v-bnk as char.

find sysc where sysc = "ourbnk" no-lock no-error.
v-bnk = sysc.chval.

def var v-deps as char init "2215,2217,2219,2223".
def var v-vostr as char init "2203,2211,2221".

def var v-srok as integer.
def var i as integer.
def var v-bal as deci.
def var v-rate as deci.
def var v-kurs as deci.
def var v-name as char.
def new shared var v-dt as date.


def new shared temp-table t-gl 
  field gl as integer
  field vostr as logical
  field sum as deci format "zzz,zzz,zzz,zzz,zz9.99"
  field sumval as deci format "zzz,zzz,zzz,zzz,zz9.99"
  index gl is primary unique gl.

def new shared temp-table t-sums 
  field clnsts as char
  field crc as integer
  field crccode as char
  field srok as integer
  field sum as decimal format "zzz,zzz,zzz,zzz,zz9.99"
  field rate as decimal format "zz9.999999"
  index main is primary clnsts srok crc.


do i = 1 to num-entries(v-deps):
  for each gl where gl.totlev = 1 and string(gl.gl) begins entry(i, v-deps) no-lock:
    create t-gl.
    t-gl.gl = gl.gl.
    t-gl.vostr = no.
  end.
end.

do i = 1 to num-entries(v-vostr):
  for each gl where gl.totlev = 1 and string(gl.gl) begins entry(i, v-vostr) no-lock:
    create t-gl.
    t-gl.gl = gl.gl.
    t-gl.vostr = yes.
  end.
end.

find last cls where cls.whn < g-today no-lock no-error.
if avail cls then v-dt = cls.whn.

update v-dt label  " Конечная дата периода " validate (v-dt < g-today, " Нужно указать дату меньше сегодняшней!")
  with side-label centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".


{r-branch.i &proc = " r-depratfil (txb.bank) "}


for each t-sums break by t-sums.crc:
  if first-of(t-sums.crc) then do:
    find crc where crc.crc = t-sums.crc no-lock no-error.
    v-name = crc.code.
  end.

  t-sums.crccode = v-name.
  if t-sums.sum = 0 then t-sums.rate = 0.
                    else t-sums.rate = t-sums.rate / t-sums.sum.

  /*  выдаем в тысячах тенге */
  t-sums.sum = t-sums.sum / 1000.
end.


def var v-file as char init "deps.htm".
output to value(v-file).

{html-title.i &stream = " " &title = " " &size-add = " "}

put unformatted 
  "<P align=""center""><B>Отчет о депозитах и ставках вознаграждения по ним (сводный)<BR>" skip
  "на " string(v-dt + 1, "99/99/9999") "<BR>" skip
  "в тыс.тенге</B></P>" skip
  "<TABLE width=""60%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
  "<TR align=""center""><TD>Валюта</TD><TD>Остаток</TD><TD>Ставки средневзв.</TD></TR>" skip.


for each t-sums where t-sums.sum >= 0.005 break by t-sums.clnsts by t-sums.srok by t-sums.crc:
  if first-of(t-sums.clnsts) then do:
    put unformatted "<TR><TD colspan=""3""><B>Депозиты ".
    case t-sums.clnsts :
      when "0" then put unformatted "юридических" skip.
      when "1" then put unformatted "физических" skip.
    end case.
    put unformatted " лиц</B></TD></TR>" skip.
  end.
  
  if first-of(t-sums.srok) then do:
    put unformatted "<TR><TD colspan=""3"">".
    case t-sums.srok :
      when 0 then put unformatted " До востреб. (вкл. специальные)" skip.
      when 1 then put unformatted " Краткосрочные" skip.
      when 2 then put unformatted " Долгосрочные" skip.
    end case.
    put unformatted 
      "</TD></TR>" skip.
  end.

  put unformatted 
    "<TR>" skip
    "<TD>" t-sums.crccode "</TD>" skip
    "<TD>" trim(replace(string(t-sums.sum, ">>>>>>>>>>>>>>9.99"), ".", ",")) "</TD>" skip
    "<TD>" trim(replace(string(t-sums.rate, ">>>9.999999"), ".", ",")) "</TD></TR>" skip.

  if last-of(t-sums.clnsts) then put unformatted "<TR><TD>&nbsp;</TD></TR>" skip.
end.

put unformatted "</TABLE>" skip.

{html-end.i " "}

output close.

unix silent cptwin value(v-file) excel.



