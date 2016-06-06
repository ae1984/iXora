/* vcrep1718msg.p
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
   08.04.2008 galina - добавлено поле cursdoc-usd в таблицу t-docs
*/

/* vcrep1718out.p - Валютный контроль 
   Приложение 17 и 18 - все платежи за месяц по контрактам типа 2
   Вывод временной таблицы в файл

   19.11.2002 nadejda создан
   19.03.2003 nadejda - теперь формируется не текстовый файл, а файл телеграммы с копированием на L:\CAPITAL
*/

{vc.i}
{global.i}

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".

def shared temp-table t-docs 
  field dndate as date
  field sum as decimal
  field payret as logical
  field docs as integer
  field paykind as char
  field cif as char
  field prefix as char
  field name as char
  field okpo as char
  field clnsts as char
  field region as char
  field addr as char
  field ctnum as char
  field ctdate as date
  field cttype as char
  field partnprefix as char
  field partner as char
  field codval as char
  field info as char
  field strsum as char
  field bank as char
  field depart as char
  field cursdoc-usd as decimal
  index main is primary cttype dndate payret sum docs.


def var v-name as char.
def var v-stroka as char.

/* проверка валидности данных */

def var v-errmsg as char extent 6 init 
  ["Найдены клиенты с отсутствующим кодом ОКПО!",
   "Найдены клиенты с отсутствующей ФОРМОЙ СОБСТВЕННОСТИ!",
   "Найдены клиенты с отсутствующим НАИМЕНОВАНИЕМ!",
   "Найдены контракты с отсутствующим НОМЕРОМ КОНТРАКТА!",
   "Найдены контракты с отсутствующим НАИМЕНОВАНИЕМ ИНОПАРТНЕРА!",
   "Найдены клиенты с отсутствующим КОДОМ РЕГИОНА!"].

def temp-table t-errs
  field type as integer
  field bank as char
  field depart as char
  field cif as char
  field prefix as char
  field name as char
  field ctdate as date
  field ctnum as char
  field partner as char
  index main is primary type bank depart cif ctdate ctnum.

def var v-err as integer.

for each t-docs:
  v-err = 0.
  if t-docs.okpo = "" then v-err = 1.
  else if t-docs.prefix = "" then v-err = 2.
  else if t-docs.name = "" then v-err = 3.
  else if t-docs.ctnum = "" then v-err = 4.
  else if t-docs.partner = "" then v-err = 5.
  else if t-docs.region = "" then v-err = 6.

  if v-err > 0 then do:
    create t-errs.
    assign t-errs.type = v-err
           t-errs.bank = t-docs.bank
           t-errs.depart = t-docs.depart
           t-errs.cif = t-docs.cif
           t-errs.prefix = t-docs.prefix
           t-errs.name = t-docs.name
           t-errs.ctdate = t-docs.ctdate
           t-errs.ctnum = t-docs.ctnum
           t-errs.partner = trim(trim(t-docs.partnprefix) + " " + trim(t-docs.partner)).
  end.
end.

def stream err.

if can-find(first t-errs) then do:
  output stream err to err.htm.
  {html-title.i &title = " " &stream = "stream err" &size-add = "x-"}
  put stream err unformatted 
    "<TABLE width=""100%"" align=""center"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""center"" style=""font:bold;font-size=xx-small"">" skip
      "<TD>Банк</TD>"
      "<TD>Департамент</TD>"
      "<TD>Код клиента</TD>"
      "<TD>Форма собств. клиента</TD>"
      "<TD>Наименование клиента</TD>"
      "<TD>Дата контракта</TD>"
      "<TD>Номер контракта</TD>"
      "<TD>Инопартнер</TD>"
    "</TR>" skip.
  for each t-errs break by t-errs.type:
    if first-of(t-errs.type) then
      put stream err unformatted 
        "<TR><TD colspan=""8"">&nbsp;</TD></TR>" skip
        "<TR><TD colspan=""8"" style=""font:bold;font-size=small"">" v-errmsg[t-errs.type] "</TD></TR>" skip.

    
    put stream err unformatted 
      "<TR>"
        "<TD>" t-errs.bank "</TD>"
        "<TD>" t-errs.depart "</TD>"
        "<TD>" t-errs.cif "</TD>"
        "<TD>" t-errs.prefix "</TD>"
        "<TD>" t-errs.name "</TD>"
        "<TD>" t-errs.ctdate "</TD>"
        "<TD>" t-errs.ctnum "</TD>"
        "<TD>" t-errs.partner "</TD>"
      "</TR>" skip.

  end.
  put stream err unformatted 
    "</TABLE>" skip.
  {html-end.i &stream = "stream err"}
  output stream err close.

  message skip " Обнаружены критические ошибки в данных !"
          skip " Смотрите протокол ошибок."
          skip(1) " Телеграмма не сформирована !"
          skip(1) view-as alert-box button ok title " ВНИМАНИЕ ! ".
  unix silent cptwin err.htm iexplore.
  return.
end.

/* формирование телеграммы */

{vctstparam.i &msg = "106"}

v-text = "/REPORTDATE/" + string(v-month, "99") + string(v-god, "9999").
put stream rpt unformatted v-text skip.

find first cmp no-lock no-error.
v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
put stream rpt unformatted v-text skip.


for each t-docs no-lock:

  if length(t-docs.okpo) < 12 then t-docs.okpo = t-docs.okpo + fill("0", 12 - length(t-docs.okpo)).
  v-text = "/OKPO/" + t-docs.okpo.
  put stream rpt unformatted v-text skip.

  v-text = "//FORM/" + substr(t-docs.prefix, 1, 10).
  put stream rpt unformatted v-text skip.

  v-text = "//NAME/" + substr(t-docs.name, 1, 100).
  put stream rpt unformatted v-text skip.

  /* NEW */
  v-text = "//REGIONCODE/" + t-docs.region.
  put stream rpt unformatted v-text skip.

  /* NEW */
  v-text = "//ADDRESS/" + t-docs.addr.
  put stream rpt unformatted v-text skip.


  if t-docs.cttype = "e" then v-text = "1".
                         else v-text = "2".
  if t-docs.clnsts = "0" then v-text = v-text + "1".
                         else v-text = v-text + "2".
  v-text = "//SIGN/" + v-text.
  put stream rpt unformatted v-text skip.

  v-text = "//CONTRACT/" + substr(t-docs.ctnum + " от " + string(t-docs.ctdate, "99/99/9999"), 1, 50).
  put stream rpt unformatted v-text skip.

  v-text = "//PAYDATE/" + replace(string(t-docs.dndate, "99/99/9999"), "/", "").
  put stream rpt unformatted v-text skip.

  /* NEW */
  v-text = "//PAYSIGN/" + if t-docs.payret then "2" else "1".
  put stream rpt unformatted v-text skip.

  /* NEW */
  v-text = "//PAYKIND/" + t-docs.paykind.
  put stream rpt unformatted v-text skip.

  /* NEW */
  v-text = "//SUMM/" + caps(t-docs.codval) + replace(t-docs.strsum, ".", ",").
  put stream rpt unformatted v-text skip.


  v-text = "//PARTNER/" + substr(t-docs.partner, 1, 100).
  put stream rpt unformatted v-text skip.

  v-text = "//PFORM/" + substr(t-docs.partnprefix, 1, 10).
  put stream rpt unformatted v-text skip.

  v-text = "//NOTE/" + trim(substr(t-docs.info, 1, 100)).
  put stream rpt unformatted v-text skip.

  if length(t-docs.info) > 100 then do:
    v-text = trim(substr(t-docs.info, 101, 100)).
    put stream rpt unformatted v-text skip.
  end.

  if length(t-docs.info) > 200 then do:
    v-text = trim(substr(t-docs.info, 201, 100)).
    put stream rpt unformatted v-text skip.
  end.
end.

{vctstend.i &msg = "106"}


