/* r-opers.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Отчет по нагрузке операционистов за период
        по умолчанию - Профит-центр 103 (операционисты Центрального офиса)
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
        28.11.2002 nadejda
 * CHANGES
        09.04.04 - suchkov - Для филиалов не учитывать профит-центр.
        29/08/06 u00121 заменил nawk на awk
        29.08.08 id00004 заменил ссылку на логотип
        15/03/12 id00810 - добавила v-bankname для печати
        04/05/2012 evseev - наименование банка из banknameDgv
*/

{mainhead.i R-OPERS}
{name2sort.i}
{comm-txb.i}

def var v-profitcn as char init "103".
def var v-pcname as char.
def var v-report as integer init 1.
def var v-god as integer.
def var v-month as integer.
def var v-dtb as date.
def var v-dte as date.
def var v-df as date.
def var v-filename as char init "r-opers.htm".
def var v-filetmp as char init "opers-tmp.txt".
def var v-psjlog as char.
def var v-nofc as integer.
def var v-nval as integer.
def var v-nvald as integer.
def var v-n as integer.
def var v-l as logical.
def var v-s as char.
def var v-glext as integer.
def var v-local as integer.
def var v-hst as char.
def var v-bra as char.
def var v-log as char.
def var v-sum as decimal.
def var v-bankname as char no-undo.

def temp-table t-data
  field ofc like ofc.ofc                /* логин */
  field name like ofc.name
  field sort as char
  field koltrz as integer               /* всего проводок */
  field kolint as integer               /* количество внутрибанковских проводок */
  field kolextlocal as integer          /* количество внешних тенговых */
  field kolextval as integer            /* количество внешних валютных */
  field kolibhyes as integer            /* количество отправленных интернет-платежей */
  field kolibhno as integer             /* количество отвергнутых интернет-платежей */
  field kolpensyes as integer           /* количество пенс.платежей - тест, принятые */
  field kolpensno as integer            /* количество пенс.платежей - тест, ошибочные */
  field sumplatd as decimal extent 20   /* общая сумма дебета проведенных платежей по валютам */
  field sumplatc as decimal extent 20   /* общая сумма кредита проведенных платежей по валютам */
  field sumdohodd as decimal extent 20  /* общая сумма дебета, перечисленная на доходы банка по валютам */
  field sumdohodc as decimal extent 20  /* общая сумма кредита, перечисленная на доходы банка по валютам */
  field sumibh as decimal extent 20     /* сумма инет-платежей по валютам */
  field sumplatkzt as decimal           /* сумма оборотов в тенге */
  field sumdohodkzt as decimal          /* сумма доходов в тенге */
  index main is primary sort ofc.

def temp-table t-ofc
  field ofc like ofc.ofc
  field name like ofc.name
  field sort as char
  index main is primary ofc.

def temp-table t-gldohod
  field gl like gl.gl
  index main is primary gl.

def buffer b-crc for crc.

function sum2str returns char (p-value as decimal).
  def var vp-str as char.
  vp-str = string(p-value, "->>>>>>>>>>>>>>9.99").
  vp-str = entry(1, vp-str, ".") + "," + entry(2, vp-str, ".").
  return vp-str.
end.

form skip(1)
    v-profitcn label "     Департамент" format "xxx"
      validate(can-find(codfr where codfr.codfr = "sproftcn" and codfr.code = v-profitcn and
      codfr.code <> "msc" no-lock), "Неверный департамент!")
    v-pcname no-label format "x(35)" at 25
    skip(1)
    v-dtb format "99/99/9999" label "  Начало периода" skip
    v-dte format "99/99/9999" label "   Конец периода" skip(1)
    v-report format "9"       label "  1) краткий отчет    2) полный отчет"
    skip(1)
with row 6 side-label centered title " ЗАДАЙТЕ ПАРАМЕТРЫ ОТЧЕТА " frame fff.

on help of v-profitcn in frame fff do: run uni_help1("sproftcn", "..."). end.
/*
v-month = month(g-today).
v-god = year(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.
v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then v-n = 31.
  when 4 or when 6 or when 9 or when 11 then v-n = 30.
  when 2 then do:
    if v-god mod 4 = 0 then v-n = 29.
    else v-n = 28.
  end.
end case.
v-dte = date(v-month, v-n, v-god).
*/
/*
find last cls no-lock no-error.
v-dtb = cls.whn.
v-dte = v-dtb.
*/
v-dtb = g-today.
v-dte = v-dtb.

run def-pcname.
displ v-profitcn v-pcname v-dtb v-dte v-report with frame fff.

update v-profitcn with frame fff.

run def-pcname.
displ v-pcname with frame fff.

update v-dtb v-dte v-report with frame fff.

message "Формируется отчет...".

v-bra = comm-txb().

/* выбор офицеров департамента */
find sysc where sysc.sysc = "supusr" no-lock no-error.
for each ofc where lookup(caps(ofc.ofc), caps(sysc.chval)) = 0 no-lock:
  find last ofcprofit where ofcprofit.ofc = ofc.ofc and ofcprofit.regdt <= v-dte no-lock no-error.
  if (avail ofcprofit and (ofcprofit.profitcn = v-profitcn)) or
     (not avail ofcprofit and (ofc.titcd = v-profitcn)) or v-bra <> "TXB00" then do:
    create t-ofc.
    t-ofc.ofc = ofc.ofc.
    t-ofc.name = ofc.name.
    t-ofc.sort = name2sort(ofc.name).
  end.
end.

/* транзитный счет ГК для внешних платежей */
FIND sysc WHERE sysc.sysc = "pspygl" NO-LOCK NO-ERROR .
if avail sysc and sysc.inval <> 0 then v-glext = sysc.inval. else v-glext = 255120.

/* нацвалюта */
find crchs where crchs.Hs = "L" no-lock no-error.
v-local = crchs.crc.

/* список счетов доходов */
for each gl where gl.type = "r" no-lock:
  create t-gldohod.
  t-gldohod.gl = gl.gl.
end.


/* разбор проводок */
for each jh where jh.jdt >= v-dtb and jh.jdt <= v-dte and
     can-find(t-ofc where t-ofc.ofc = jh.who) no-lock use-index jdt
     break by jh.who by jh.jdt by jh.jh:

  if first-of(jh.who) then do:
    create t-data.
    t-data.ofc = jh.who.
    find t-ofc where t-ofc.ofc = jh.who no-lock no-error.
    t-data.name = t-ofc.name.
    t-data.sort = t-ofc.sort.
  end.

  v-l = true.
  for each jl where jl.jh = jh.jh no-lock use-index jhln break by jl.crc:

    accumulate jl.dam (sub-total by jl.crc).
    accumulate jl.cam (sub-total by jl.crc).

    if jl.gl = v-glext then do:
      if jl.crc = v-local then t-data.kolextlocal = t-data.kolextlocal + 1.
      else t-data.kolextval = t-data.kolextval + 1.
      v-l = false.
    end.

    find last crchis where crchis.crc = jl.crc and crchis.rdt <= jl.jdt no-lock no-error.

    if can-find(t-gldohod where jl.gl = t-gldohod.gl) then do:
      t-data.sumdohodd[jl.crc] = t-data.sumdohodd[jl.crc] + jl.dam.
      t-data.sumdohodc[jl.crc] = t-data.sumdohodc[jl.crc] + jl.cam.
      t-data.sumdohodkzt = t-data.sumdohodkzt + (jl.cam - jl.dam) * crchis.rate[1] / crchis.rate[9].
    end.

    if last-of(jl.crc) then do:
      v-sum = (accum sub-total by jl.crc jl.dam).
      t-data.sumplatd[jl.crc] = t-data.sumplatd[jl.crc] + v-sum.
      t-data.sumplatc[jl.crc] = t-data.sumplatc[jl.crc] + (accum sub-total by jl.crc jl.cam).
      t-data.sumplatkzt = t-data.sumplatkzt + v-sum * crchis.rate[1] / crchis.rate[9].
    end.
  end.

  if v-l then t-data.kolint = t-data.kolint + 1.

  accumulate jh.jh (sub-count by jh.who).

  if last-of(jh.who) then do:
    t-data.koltrz = (accum sub-count by jh.who jh.jh).
  end.
end.

/* Интернет-платежи за период - просмотр логов для поиска истории платежа */

/* для поиска в логах */
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBNK в таблице SYSC!". pause. return .
end.
v-hst = trim(sysc.chval).

find sysc where sysc.sysc = "ps_log" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись PS_LOG в таблице SYSC!". pause. return.
end.
v-log = trim(sysc.chval).

output to value(v-filetmp).
output close.

do v-df = v-dtb to v-dte:
  if search(v-log + trim(v-hst) + "_logfile.lg." + string(v-df,"99.99.9999")) =
       v-log + trim(v-hst) + "_logfile.lg." + string(v-df,"99.99.9999") then
    unix silent value("awk 'index($0, ""3A XX err_3A_ps"") != 0 \{print $0\}' "
       + v-log + trim(v-hst) + "_logfile.lg." + string(v-df,"99.99.9999") + " >> " + v-filetmp). /*29/08/06 u00121 заменил nawk на awk*/
end.

input from value(v-filetmp).
repeat:
  import unformatted v-s.
  v-n = index(caps(v-s), "ОТПРАВЛЕН RMZ").
  if v-n > 0 then do:
    for each t-ofc :
      if index(caps(v-s), caps(t-ofc.ofc)) > 0 then do:
        find t-data where t-data.ofc = t-ofc.ofc no-error.
        if not avail t-data then do:
          create t-data.
          t-data.ofc = t-ofc.ofc.
          t-data.name = t-ofc.name.
          t-data.sort = t-ofc.sort.
        end.
        v-s = substring(v-s, index(v-s, "RMZ"), 10).
        find remtrz where remtrz.remtrz = v-s no-lock no-error.
        if avail remtrz and remtrz.jh1 <> ? then do:
          find jh where jh.jh = remtrz.jh1 no-lock no-error.
          if avail jh then do:
            if jh.who <> t-ofc.ofc then do:
              t-data.kolibhyes = t-data.kolibhyes + 1.
              t-data.koltrz = t-data.koltrz + 1.
              t-data.sumplatd[remtrz.fcrc] = t-data.sumplatd[remtrz.fcrc] + remtrz.amt.
            end.
            t-data.sumibh[remtrz.fcrc] = t-data.sumibh[remtrz.fcrc] + remtrz.amt.
          end.
        end.
      end.
    end.
  end.
  else do:
    v-n = index(caps(v-s), "ОТВЕРЖЕНИЕ ОТПРАВЛЕНО УСПЕШНО").
    if v-n > 0 then do:
      for each t-ofc :
        if index(caps(v-s), caps(t-ofc.ofc)) > 0 then do:
          find t-data where t-data.ofc = t-ofc.ofc no-error.
          if not avail t-data then do:
            create t-data.
            t-data.ofc = t-ofc.ofc.
            t-data.name = t-ofc.name.
            t-data.sort = t-ofc.sort.
          end.
          t-data.kolibhno = t-data.kolibhno + 1.
          t-data.koltrz = t-data.koltrz + 1.
        end.
      end.
    end.
  end.
end.
input close.
unix silent value("rm -f " + v-filetmp).

/* message "Пенсионные платежи офицеров за период". pause. */
/* просмотр лога пенсионного платежа psj.log на предмет тестирования swift.txt */

define temp-table t-pens
  field dt as date
  field tm as char
  field ofc like ofc.ofc
  field info as char.

/* путь к логу */
find sysc where sysc.sysc = "psjdir" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись PSJDIR в таблице SYSC!". pause. return .
end.
v-psjlog = trim(sysc.chval) + "psj.log".

if not search(v-psjlog) = v-psjlog then
  message "Протокол загрузки пенсионных платежей " + v-psjlog + " не найден !"
      view-as alert-box title " ВНИМАНИЕ ! ".
else do:
  /* поиск в нужном лог-файле - выбираем диапазон дат */
  do v-df = v-dtb to v-dte:
    unix silent value("awk 'index($0, """ + string(day(v-df), "99") + "/" +
         string(month(v-df), "99") + "/" + substring(string(year(v-df), "9999"), 3, 2) +
         """) != 0 \{print $0\}' " + v-psjlog + " >> " + v-filetmp). /*29/08/06 u00121 заменил nawk на awk*/
  end.

  input from value(v-filetmp).
  repeat:
    create t-pens.
    import unformatted v-s.
    v-s = trim(v-s).

    t-pens.dt = date(substring(v-s, 1, index(v-s, " ") - 1)).
    v-s = trim(substring(v-s, index(v-s, " ") + 1)).

    t-pens.tm = substring(v-s, 1, index(v-s, " ") - 1).
    v-s = trim(substring(v-s, index(v-s, " ") + 1)).

    t-pens.ofc = substring(v-s, 1, index(v-s, " ") - 1).
    v-s = trim(substring(v-s, index(v-s, " ") + 1)).

    t-pens.info = substring(v-s, 1, index(v-s, " ") - 1).
    v-s = trim(substring(v-s, index(v-s, " ") + 1)).
  end.
  input close.

  /* оаставить только нужных офицеров */
  for each t-pens where t-pens.ofc = "" or
       not can-find(t-ofc where trim(t-ofc.ofc) = trim(t-pens.ofc)).
    delete t-pens.
  end.

  /* раскидать отправленные/отвергнутые  */
  /* посчитать все */
  for each t-pens where t-pens.info matches "*TEST*" no-lock break by t-pens.ofc:
    accumulate t-pens.tm (sub-count by t-pens.ofc).
    if last-of(t-pens.ofc) then do:
      find t-data where t-data.ofc = t-pens.ofc no-error.
      if not avail t-data then do:
        create t-data.
        find t-ofc where t-ofc.ofc = t-pens.ofc no-lock no-error.
        t-data.ofc = t-ofc.ofc.
        t-data.name = t-ofc.name.
        t-data.sort = t-ofc.sort.
      end.
      t-data.kolpensyes = (accum sub-count by t-pens.ofc t-pens.tm).
    end.
  end.

  /* отнять ошибочные */
  for each t-pens where t-pens.info matches "*Delete*" no-lock break by t-pens.ofc:
    accumulate t-pens.tm (sub-count by t-pens.ofc).
    if last-of(t-pens.ofc) then do:
      find t-data where t-data.ofc = t-pens.ofc no-error.
      if not avail t-data then do:
        create t-data.
        find t-ofc where t-ofc.ofc = t-pens.ofc no-lock no-error.
        t-data.ofc = t-ofc.ofc.
        t-data.name = t-ofc.name.
        t-data.sort = t-ofc.sort.
      end.
      t-data.kolpensno = (accum sub-count by t-pens.ofc t-pens.tm).
      t-data.kolpensyes = t-data.kolpensyes - t-data.kolpensno.
    end.
  end.
  unix silent value("rm -f " + v-filetmp).

  for each t-data:
    t-data.koltrz = t-data.koltrz + t-data.kolpensyes + t-data.kolpensno.
  end.
end.

find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
if avail sysc then v-bankname = sysc.chval.

/* печать отчета */
def stream rep.
output stream rep to value(v-filename).

{html-title.i
 &stream = " stream rep "
 &title = " "
 &size-add = "x-"
}

put stream rep unformatted
   "<IMG border=""0"" src=""http://portal/_layouts/images/top_logo_bw.jpg""><BR><BR><BR>" skip
   "<B><P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   "НАГРУЗКА СОТРУДНИКОВ АО " v-bankname "</FONT><BR><BR>" skip
   "<FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">Департамент: (" +
   v-profitcn + ")&nbsp;&nbsp;" + v-pcname + "<BR><BR>" skip
   "за период с " +
   string(v-dtb, "99/99/9999") + " по " + string(v-dte, "99/99/9999") + "</FONT></P></B>" skip
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"" valign=""top"">" skip.

if v-report = 2 then
  put stream rep unformatted
     "<TD rowspan=""2""><FONT size=""1""><B>N</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Логин</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>ФИО менеджера</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Всего<BR>проводок</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Кол.<BR>внутрибанк.<BR>проводок</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Кол.<BR>внешних<BR>проводок:<BR>KZT</B></FONT></TD>" skip
     "<TD rowspan=""2""><FONT size=""1""><B>Кол.<BR>внешних<BR>проводок:<BR>валюта</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>Кол.<BR>Интернет-<BR>платежей</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""1""><B>Кол.<BR>пенсион.<BR>платежей</B></FONT></TD>" skip
     "<TD colspan=""4""><FONT size=""1""><B>Общая сумма<BR>оборотов</B></FONT></TD>" skip
     "<TD colspan=""4""><FONT size=""1""><B>Общая сумма,<BR>перечисленная<BR>на счета доходов</B></FONT></TD>" skip
   "</TR><TR align=""center"">" skip
     "<TD><FONT size=""1""><B>отправл</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>отвергн</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>отправл</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>отвергн</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Обороты</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Интернет-платежи</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Всего</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Валюта</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Дебет</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Кредит</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Сумма</B></FONT></TD>" skip
   "</TR>" skip.
else
  put stream rep unformatted
     "<TD><FONT size=""1""><B>N</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ФИО менеджера</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Всего<BR>проводок</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Общая сумма<BR>оборотов</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>Общая сумма,<BR>перечисленная<BR>на счета доходов</B></FONT></TD>" skip
   "</TR>" skip.

v-nofc = 0.

for each t-data:
  v-nofc = v-nofc + 1.

  if v-report = 2 then do:

    v-nval = 1.
    for each crc no-lock:
      if t-data.sumplatd[crc.crc] <> 0 or t-data.sumibh[crc.crc] <> 0 then do:
        v-nval = crc.crc.
        leave.
      end.
    end.

    find crc where crc.crc = v-nval no-lock no-error.
    put stream rep unformatted
       "<TR valign=""top"">" skip
         "<TD>" + string(v-nofc) + "</TD>" skip
         "<TD>" + t-data.ofc + "</TD>" skip
         "<TD>" + t-data.name + "</TD>" skip
         "<TD align=""right"">" + string(t-data.koltrz) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolint) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolextlocal) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolextval) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolibhyes) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolibhno) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolpensyes) + "</TD>" skip
         "<TD align=""right"">" + string(t-data.kolpensno) + "</TD>" skip
         "<TD>" + crc.code + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumplatd[v-nval]) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumibh[v-nval]) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumplatd[v-nval] +
                t-data.sumibh[v-nval]) + "</TD>" skip
         skip.

    v-nvald = 1.
    for each b-crc no-lock:
      if t-data.sumdohodd[b-crc.crc] <> 0 or t-data.sumdohodc[b-crc.crc] <> 0 then do:
        v-nvald = b-crc.crc.
        leave.
      end.
    end.
    find b-crc where b-crc.crc = v-nvald no-lock no-error.
    put stream rep unformatted
         "<TD>" + b-crc.code + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumdohodd[v-nvald]) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumdohodc[v-nvald]) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumdohodc[v-nvald] - t-data.sumdohodd[v-nvald]) + "</TD>"
       "</TR>" skip.

    for each crc where crc.crc > v-nval no-lock:
      if t-data.sumplatd[crc.crc] <> 0 or t-data.sumibh[crc.crc] <> 0 then do:
        put stream rep unformatted
          "<TR valign=""top"">" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>&nbsp;</TD>" skip
            "<TD>" + crc.code + "</TD>" skip
            "<TD align=""right"">" + sum2str(t-data.sumplatd[crc.crc]) + "</TD>" skip
            "<TD align=""right"">" + sum2str(t-data.sumibh[crc.crc]) + "</TD>" skip
            "<TD align=""right"">" + sum2str(t-data.sumplatd[crc.crc] +
                t-data.sumibh[crc.crc]) + "</TD>" skip.

        find b-crc where b-crc.crc = v-nvald no-lock no-error.
        if avail b-crc then do:
          v-n = v-nvald.
          for each b-crc where b-crc.crc > v-nvald no-lock:
            if t-data.sumdohodd[b-crc.crc] <> 0 or t-data.sumdohodc[b-crc.crc] <> 0 then do:
              v-n = b-crc.crc.
              leave.
            end.
          end.
          if v-n = v-nvald then do:
            find last b-crc no-lock.
            v-nvald = b-crc.crc + 1.
            put stream rep unformatted
                "<TD>&nbsp;</TD>" skip
                "<TD>&nbsp;</TD>" skip
                "<TD>&nbsp;</TD>" skip
                "<TD>&nbsp;</TD>" skip.
          end.
          else do:
            v-nvald = v-n.
            find b-crc where b-crc.crc = v-nvald no-lock no-error.
            put stream rep unformatted
                 "<TD>" + b-crc.code + "</TD>" skip
                 "<TD align=""right"">" + sum2str(t-data.sumdohodd[v-nvald]) + "</TD>" skip
                 "<TD align=""right"">" + sum2str(t-data.sumdohodc[v-nvald]) + "</TD>" skip
                 "<TD align=""right"">" + sum2str(t-data.sumdohodc[v-nvald] -
                    t-data.sumdohodd[v-nvald]) + "</TD>" skip.
          end.
          put stream rep unformatted "</TR>" skip.
        end.
        else
          put stream rep unformatted
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD></TR>" skip.

      end.
    end.

    find b-crc where b-crc.crc = v-nvald no-lock no-error.
    if avail b-crc then do:
      for each b-crc where b-crc.crc > v-nvald no-lock:
        if t-data.sumdohodd[b-crc.crc] <> 0 or t-data.sumdohodc[b-crc.crc] <> 0 then do:
          put stream rep unformatted
            "<TR valign=""top"">" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>&nbsp;</TD>" skip
              "<TD>" + b-crc.code + "</TD>" skip
              "<TD align=""right"">" + sum2str(t-data.sumdohodd[b-crc.crc]) + "</TD>" skip
              "<TD align=""right"">" + sum2str(t-data.sumdohodc[b-crc.crc]) + "</TD>" skip
              "<TD align=""right"">" + sum2str(t-data.sumdohodc[b-crc.crc] -
                 t-data.sumdohodd[b-crc.crc]) + "</TD>" skip
              "</TR>" skip.
        end.
      end.
    end.

    find crc where crc.crc = v-local no-lock no-error.
    put stream rep unformatted
      "<TR valign=""top"">" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD>&nbsp;</TD>" skip
        "<TD colspan=""3"" align=""right"">Итого в " + crc.code + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-data.sumplatkzt) + "</TD>" skip
        "<TD colspan=""3"" align=""right"">Итого в " + crc.code + "</TD>" skip
        "<TD align=""right"">" + sum2str(t-data.sumdohodkzt) + "</TD>" skip
        "</TR>" skip.
  end.
  else do:
    put stream rep unformatted
       "<TR valign=""top"">" skip
         "<TD>" + string(v-nofc) + "</TD>" skip
         "<TD>" + t-data.name + "</TD>" skip
         "<TD align=""right"">" + string(t-data.koltrz) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumplatkzt) + "</TD>" skip
         "<TD align=""right"">" + sum2str(t-data.sumdohodkzt) + "</TD>" skip
        "</TR>" skip.

  end.
end.

put stream rep unformatted
  "</TABLE>"skip.

{html-end.i "stream rep" }

output stream rep close.

hide message no-pause.

unix silent value("cptwin " + v-filename + " excel").

pause 0.

/* ========================================================= */

procedure def-pcname.
  find codfr where codfr.codfr = "sproftcn" and codfr.code = v-profitcn no-lock no-error.
  if avail codfr then v-pcname = codfr.name[1]. else v-pcname = "".
end procedure.


