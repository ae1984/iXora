/* drk_sp.p
 * MODULE
       Кредитный модуль
 * DESCRIPTION
       Отчеты по проверкам фин-хоз деятельности заемщиков и залогового обеспечения
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
       18/06/2013 Luiza ТЗ 986
 * BASES
	BANK COMM
 * CHANGES

*/

{mainhead.i}

def new shared temp-table lnpr
  field pertype   as   int
  field fname     as   char
  field name      as   char
  field lon       as   char
  field cname     as   char
  field dog       as   char
  field crc       as   int
  field intrate   as   decimal
  field eintrate  as   decimal
  field rdt       as   date
  field duedt     as   date
  field klasif    as   char
  field vsum      as   decimal
  field nsum      as   decimal
  field stdat     as   date
  field paid      as   decimal
  field rpaid     as   decimal
  field dtype     as   decimal
  field provod    as   decimal
  field debtod    as   decimal
  field totalp    as   decimal
  field cur       as   decimal
  index ind is primary fname lon pertype stdat .

def new shared var r-dt as date no-undo.
def new shared var b-dt as date no-undo.
def new shared var e-dt as date no-undo.
def new shared var v-today as date no-undo.
def new shared var v-pertype as int no-undo.
def new shared var v-reptype as int no-undo.
def new shared var v-hol as date no-undo.

def var usrnm as char no-undo.
def var v-bank as char no-undo.

v-today = g-today.
update b-dt label ' На дату' format '99/99/9999' validate (b-dt <= g-today, " Дата должна быть не позже текущей!") skip
       v-reptype label ' Вид отчета' format "9" validate ( v-reptype > 0 and v-reptype < 8, " Тип отчета - 1, 2, 3, 4, 5, 6, 7") help "1-Юр, 2-Физ, 3-БД, 4-MCБ, 5-все, 6-физ+БД, 7-МСБ+юр"
       skip with side-label row 5 centered frame dat.
run sel2 ("Период погашения:", " 1. все периоды  | 2. За 7 дней | 3. от 7 - 30 дней | 4. от 31 - 92 дней | 5. от 92 - 180 дней | 6. от 180 - 365 дней |
 7. от 365 - 1095 дней | 8. свыше 1095 дней ", output v-pertype).
if v-pertype = 1 then v-pertype = 8.
else v-pertype = v-pertype - 1.

r-dt = b-dt.
v-hol = r-dt.
def var vpr as int.
vpr = 0.
repeat:
    find last cls where cls.cls < v-hol no-lock no-error.
    v-hol = cls.cls.
    vpr = vpr + 1.
    find first hol where hol.hol = v-hol no-lock no-error.
    if available hol then v-hol = v-hol - 1.
    else do:
        v-hol = v-hol + vpr.
        leave.
    end.
end.
 /* проверяем не явл-ся ли предыдущие дни субботой или воскрес */
   if weekday(v-hol - 1) = 1 then v-hol = v-hol - 1. /* если 1 значит воскрес по америк формату */
   if weekday(v-hol - 1) = 7 then v-hol = v-hol - 1. /* если 7 значит субб по америк формату */

{r-brfilial.i &proc = "drk_spf" }
def var v-tot as decim.
/* для основного долга пересчитаем сумму провизии */
def buffer b-lnpr for lnpr.
for each lnpr where lnpr.dtype  = 1 and lnpr.paid <> 0 break by lnpr.fname by lnpr.lon  .
    if first-of(lnpr.lon) then v-tot = 0.
    v-tot = v-tot + lnpr.paid.
    if last-of(lnpr.lon) then do:
        for each b-lnpr where b-lnpr.fname = lnpr.fname and b-lnpr.lon = lnpr.lon and b-lnpr.dtype  = 1.
            b-lnpr.vsum = (b-lnpr.paid * b-lnpr.provod) / (v-tot + b-lnpr.debtod). /* провизия в валюте */
            b-lnpr.nsum = ((b-lnpr.paid * b-lnpr.provod) / (v-tot + b-lnpr.debtod)) * b-lnpr.cur. /* провизия в тенге */
        end.
    end.
end.

def var v-rpt as int.
v-rpt = 1.
repeat while v-rpt <= 4:

    def stream repmzo.
    output stream repmzo to repmzo.htm.

      put stream repmzo unformatted
          "<html><head>" skip
          "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
          "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
          "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
          "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
          "</head><body>" skip.

      find first ofc where ofc.ofc = g-ofc no-lock no-error.
      if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

      put stream repmzo unformatted
          "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
          "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.


      case v-rpt:
       when 1 then do:
          put stream repmzo unformatted
              "<BR><b>Приложение 1 - График погашения основного долга</b><BR>" skip
              "<b>Отчет на " string(r-dt) "</b><br>" skip.

          put stream repmzo unformatted
          "<table border=1 cellpadding=0 cellspacing=0>"
          "<tr> </tr>"
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

          "<td>Период </td>"
          "<td>Филиал</td>"
          "<td>Ссудный счет</td>"
          "<td>Наименование заемщика</td>"
          "<td>№ Договора</td>"
          "<td>Валюта займа</td>"
          "<td>% ставка</td>"
          "<td>Эффект. % ставка</td>"
          "<td>Дата выдачи</td>"
          "<td>Срок погашения</td>"

          "<td>Классификационная категория </td>"
          "<td>Сумма провизий в валюте</td>"
          "<td>Сумма провизий в тенге</td>"
          "<td> Дата погашения</td>"
          "<td> Сумма погашения</td>"
          "<td> Эквивалент в тенге</td>" skip.
       end.
       when 2 then do:
          put stream repmzo unformatted
              "<BR><b>Приложение 2 - Начисленное вознаграждение</b><BR>" skip
              "<b>Отчет на " string(r-dt) "</b><br>" skip.

          put stream repmzo unformatted
          "<table border=1 cellpadding=0 cellspacing=0>"
          "<tr> </tr>"
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

          "<td>Период </td>"
          "<td>Филиал</td>"
          "<td>Ссудный счет</td>"
          "<td>Наименование заемщика</td>"
          "<td>№ Договора</td>"
          "<td>Валюта займа</td>"
          "<td>% ставка</td>"
          "<td>Эффект. % ставка</td>"
          "<td>Дата выдачи</td>"
          "<td>Срок погашения</td>"

          "<td>Классификационная категория </td>"
          "<td>Сумма провизий в валюте</td>"
          "<td>Сумма провизий в тенге</td>"
          "<td> Дата погашения</td>"
          "<td> Сумма начисл вознагражд-я</td>"
          "<td> Эквивалент в тенге</td>" skip.

       end.
       when 3 then do:
          put stream repmzo unformatted
              "<BR><b>Приложение 3 - График погашения по просроченной задолженности по основному долгу;</b><BR>" skip
              "<b>Отчет на " string(r-dt) "</b><br>" skip.

          put stream repmzo unformatted
          "<table border=1 cellpadding=0 cellspacing=0>"
          "<tr> </tr>"
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

          "<td>Филиал</td>"
          "<td>Ссудный счет</td>"
          "<td>Наименование заемщика</td>"
          "<td>№ Договора</td>"
          "<td>Валюта займа</td>"
          "<td>% ставка</td>"
          "<td>Эффект. % ставка</td>"
          "<td>Дата выдачи</td>"
          "<td>Срок погашения</td>"

          "<td>Классификационная категория </td>"
          "<td>Сумма провизий в валюте</td>"
          "<td>Сумма провизий в тенге</td>"
          "<td> Дата выноса на просрочку</td>"
          "<td> Сумма просроченного основного долга</td>"
          "<td> Эквивалент в тенге</td>" skip.
       end.
       when 4 then do:
          put stream repmzo unformatted
              "<BR><b>Приложение 4 - График погашения по просроченной задолженности по вознаграждению</b><BR>" skip
              "<b>Отчет на " string(r-dt) "</b><br>" skip.

          put stream repmzo unformatted
          "<table border=1 cellpadding=0 cellspacing=0>"
          "<tr> </tr>"
          "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"

          "<td>Филиал</td>"
          "<td>Ссудный счет</td>"
          "<td>Наименование заемщика</td>"
          "<td>№ Договора</td>"
          "<td>Валюта займа</td>"
          "<td>% ставка</td>"
          "<td>Эффект. % ставка</td>"
          "<td>Дата выдачи</td>"
          "<td>Срок погашения</td>"

          "<td>Классификационная категория </td>"
          "<td>Сумма провизий в валюте</td>"
          "<td>Сумма провизий в тенге</td>"
          "<td> Дата выноса на просрочку</td>"
          "<td> Сумма просроченного вознаграждения</td>"
          "<td> Эквивалент в тенге</td>" skip.

       end.
      end.

      for each lnpr where lnpr.dtype  = v-rpt break by lnpr.fname by lnpr.lon  .
        if first-of(lnpr.lon) and v-rpt = 1 then do:
            put stream repmzo  unformatted "<TR bgcolor=""#e8e9ed"">" skip.
        end.
        else put stream repmzo unformatted "<tr>" skip.

        case v-rpt:
         when 1 then do:
            put stream repmzo unformatted
            "<td>" lnpr.name "</td>" skip.
         end.
         when 2 then do:
            put stream repmzo unformatted
            "<td>" lnpr.name "</td>" skip.
         end.
        end.

        put stream repmzo unformatted
        "<td>'" lnpr.fname "</td>" skip.
        put stream repmzo unformatted
        "<td>'" lnpr.lon "</td>" skip.
        put stream repmzo unformatted
        "<td>" lnpr.cname "</td>" skip.
        put stream repmzo unformatted
        "<td>" lnpr.dog "</td>" skip.
        if lnpr.lon = '' then do:
            put stream repmzo unformatted
            "<td> </td>" skip.
            put stream repmzo unformatted
            "<td> </td>" skip.
            put stream repmzo unformatted
            "<td> </td>" skip.
            put stream repmzo unformatted
            "<td> </td>" skip.
        end.
        else do:
            put stream repmzo unformatted
            "<td>" lnpr.crc "</td>" skip.
            put stream repmzo unformatted
            "<td>" replace(trim(string(lnpr.intrate,'>>>>>>>>>>>9.99')),'.',',') "%</td>" skip.
            put stream repmzo unformatted
            "<td>" lnpr.eintrate "%</td>" skip.
            put stream repmzo unformatted
            "<td>" lnpr.rdt "</td>" skip
            "<td>" lnpr.duedt "</td>" skip.
        end.

        put stream repmzo unformatted
        "<td>" lnpr.klasif "</td>" skip.
        if lnpr.vsum <> ? then put stream repmzo unformatted
        "<td>" replace(trim(string(lnpr.vsum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        else put stream repmzo unformatted "<td>"  "</td>" skip.
        if lnpr.nsum <> ? then put stream repmzo unformatted
        "<td>" replace(trim(string(lnpr.nsum,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        else put stream repmzo unformatted "<td>"  "</td>" skip.

        put stream repmzo unformatted
        "<td>" lnpr.stdat "</td>" skip.
        put stream repmzo unformatted
        "<td>" replace(trim(string(lnpr.paid,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
        put stream repmzo unformatted
        "<td>" replace(trim(string(lnpr.rpaid,'>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
      end.

      put stream repmzo unformatted "</table></body></html>".
      output stream repmzo close.
      unix silent cptwin repmzo.htm excel.

v-rpt = v-rpt + 1.
end.

































































