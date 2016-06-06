/* chk_clnd.p
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
       09/07/2004 madiyar
 * BASES
       BANK, COMM
* CHANGES
       08/12/2004 madiyar - исправил ошибку, возникающую при инициализации дат
       05/01/2005 madiyar - добавил отчет по проведенным проверкам
       05/05/2005 madiyar - из отчетов по просроченным и актуальным проверкам исключил погашенные кредиты
       31/05/2005 madiyar - подправил инициализацию дат
       23/12/2005 Natalya D. - добавила столбцы для пунктов: 1,2 - "Дата проверки целевого использования кредита по графику";
                                                                   "Исполнитель"
                                                               3 - "Дата проверки целевого использования кредита по графику";
                                                                   "Дата проведения проверки";
                                                                   "Исполнитель"
       28/12/2005 Natalya D. - добавила столбцы "Дата окончания действия страховки" и "Исполнитель".
                             - реализовала разбивку в отчёте на юр.лиц и физ.лиц.
       16/05/2006 Natalya D. - добавила столбцы "Комиссия за неиспольз. кред.линию", "Комиссия за обсл-е кредита", "Комиссия за предост-е бизнес-кредитов"
       12/09/2006 Natalya D. - добавлены столбцы "Дата окон-ия срока дейст-я депозита", "Исполнитель".
                               добавлена проверка на отсутствие остатков на ур.1,2,4,5,7,9,13,14,16,30.
       09/10/2006 madiyar - списанные кредиты не выводим;
                            в просроченных и актуальных проверках в случае изменения отв.менеджера, меняем логин на актуальный;
                            no-undo
       23/10/2009 madiyar - по всем кредитам, фин-хоз и для физ. лиц тоже
       26/01/2011 madiyar - убрал три проверки, добавил проверку решения КК, расширенный мониторинг
       14/02/2011 madiyar - изменил формат отчета
       09/04/2011 madiyar - фин-хоз -> текущий
       05.11.2012 evseev - ТЗ-1293
       25/02/2013 sayat(id01143) - ТЗ 1696 от 04/02/2013 вывод в отчет отвественного по обеспечению
       15/05/2013 sayat(id01143) - ТЗ 1848 от 15/05/2013 "Отражение просрочки целевого использования кредитных средств"
                                   вывод в отчет данных по мониторингу целевого использования кредитных средств по ФЛ (физ.лицам)
       14/06/2013 galina - ТЗ1552
       14/06/2013 yerganat - tz1804, добавил поля для "Заметки ДМО" в temp таблицу и колонки "Заметки ДМО" для отчета
       18/07/2013 yerganat - tz1965, добавление "Исполнитель" для "Заметки ДМО"
       18/07/2013 Sayat(id01143) - ТЗ 1198 от 04/11/2011 "Мониториг залогов - переоценка"
       17/09/2013 Sayat(id01143) - ТЗ 1586 от 16/11/2012 "Мониторинги - отсрочка" - добавлено поле lnmoncln.otsr и выделение цветом
       04/10/2013 Sayat(id01143) - ТЗ 2127 от 04/10/2013 "Светофор - мониторинги" - добавлено разъяснение цветов заливки
*/

{mainhead.i}

def new shared temp-table lnpr no-undo
  field cif         like lon.cif
  field name        as   char
  field sts         like cif.type  /*P - физ.лица, B - юр.лица*/
  field lon         like lon.lon
  field pdt_finhoz  as   date init ?
  field pwho_finhoz as   char
  field pdt_zalog   as   date init ?
  field pwho_zalog  as   char
  field edt_finhoz  as   date init ?
  field ewho_finhoz as   char
  field edt_zalog   as   date init ?
  field ewho_zalog  as   char
  field pdt_purp    as   date init ?
  field pwho_purp   as   char
  field edt_purp    as   date init ?
  field ewho_purp   as   char
  field pdt_insu    as   date init ?
  field pwho_insu   as   char
  field edt_insu    as   date init ?
  field ewho_insu   as   char
  field pb_name     as   char
  /*
  field pdt_crln    as   date init ?
  field pwho_crln   as   char
  field edt_crln    as   date init ?
  field ewho_crln   as   char
  field pdt_crsr    as   date init ?
  field pwho_crsr   as   char
  field edt_crsr    as   date init ?
  field ewho_crsr   as   char
  field pdt_crbs    as   date init ?
  field pwho_crbs   as   char
  field edt_crbs    as   date init ?
  field ewho_crbs   as   char
  */
  field pdt_dep     as   date init ?
  field pwho_dep    as   char
  field edt_dep     as   date init ?
  field ewho_dep    as   char
  field pdt_kk      as   date init ?
  field pwho_kk     as   char
  field edt_kk      as   date init ?
  field ewho_kk     as   char
  field kk_rem      as   char
  field pdt_dmo     as   date init ?
  field pwho_dmo    as   char
  field edt_dmo     as   date init ?
  field ewho_dmo    as   char
  field dmo_rem     as   char
  field pdt_extmon      as   date init ?
  field pwho_extmon     as   char
  field edt_extmon      as   date init ?
  field ewho_extmon     as   char
  field sum as decimal
  field sumlimkz as decimal
  field crc as char
  field mng_zalog   as   char
  field des_zalog   as   char
  field otsr_finhoz as   int
  field otsr_zalog  as   int
  field otsr_purp   as   int
  field otsr_insu   as   int
  field otsr_dep    as   int
  field otsr_kk     as   int
  field otsr_dmo    as   int
  field otsr_extmon as   int
  index ind is primary cif lon pdt_finhoz pdt_zalog edt_finhoz edt_zalog pdt_purp edt_purp pdt_insu edt_insu sts.

def new shared temp-table tgaran no-undo
  field cif         like garan.cif
  field name        as   char
  field sts         like cif.type  /*P - физ.лица, B - юр.лица*/
  field lon         like garan.garan
  field pdt_finhoz  as   date init ?
  field pwho_finhoz as   char
  field pdt_zalog   as   date init ?
  field pwho_zalog  as   char
  field edt_finhoz  as   date init ?
  field ewho_finhoz as   char
  field edt_zalog   as   date init ?
  field ewho_zalog  as   char
  field pdt_purp    as   date init ?
  field pwho_purp   as   char
  field edt_purp    as   date init ?
  field ewho_purp   as   char
  field pdt_insu    as   date init ?
  field pwho_insu   as   char
  field edt_insu    as   date init ?
  field ewho_insu   as   char
  field pb_name     as   char
  field pdt_dep     as   date init ?
  field pwho_dep    as   char
  field edt_dep     as   date init ?
  field ewho_dep    as   char
  field pdt_kk      as   date init ?
  field pwho_kk     as   char
  field edt_kk      as   date init ?
  field ewho_kk     as   char
  field kk_rem      as   char
  field pdt_extmon      as   date init ?
  field pwho_extmon     as   char
  field edt_extmon      as   date init ?
  field ewho_extmon     as   char
  field sumlimkz as decimal
  field crc as char
  field mng_zalog   as   char
  field des_zalog   as   char
  field otsr_finhoz as   int
  field otsr_zalog  as   int
  field otsr_purp   as   int
  field otsr_insu   as   int
  field otsr_dep    as   int
  field otsr_kk     as   int
  field otsr_dmo    as   int
  field otsr_extmon as   int
  index ind is primary cif lon pdt_finhoz pdt_zalog edt_finhoz edt_zalog pdt_purp edt_purp pdt_insu edt_insu sts.


def var v-sel as char no-undo.
def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var b-dt as date no-undo.
def var usrnm as char no-undo.
def var bilance as deci no-undo.
def var bilance1 as deci no-undo.
def var bilance2 as deci no-undo.
def var scolor as char no-undo.
def stream rep.
def stream rep2.

def var num_days as integer.

def buffer b-lnmoncln for lnmoncln.
def var crowid as rowid.

output stream rep to rep.htm.
output stream rep2 to rep2.htm.

dt1 = g-today.
if month(g-today) = 12 then dt2 = date(1, day(g-today), year(g-today) + 1).
else do:
  run mondays(month(g-today) + 1, year(g-today), output num_days).
  if num_days < day(g-today) then dt2 = date(month(g-today) + 1, num_days, year(g-today)).
  else dt2 = date(month(g-today) + 1, day(g-today), year(g-today)).
end.

  run sel2 ("Выбор :", " 1. Просроченные проверки | 2. Актуальные проверки | 3. Проведенные проверки | 4. Выход ", output v-sel).
  case v-sel:
    when '2' then
      update dt1 label " С " dt2 label " По " with frame fr row 5 centered side-labels.
    when '4' then
      return.
  end.

/*displ dt1 dt2. pause.*/
  /*{r-brfilial.i &proc = "lnchkrepf (v-sel, dt1, dt2)"}*/
  {r-brfilial.i &proc = "lnchkrepf (comm.txb.name, v-sel, dt1, dt2)"}

display '   Ждите...   '  with row 5 frame ww centered .

  put stream rep unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

  put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#3CA105""></td>" skip "<td>Предоставлена 1-я отсрочка</td></tr>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#FFF500""></td>" skip "<td>Предоставлена 2-я отсрочка</td></tr>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#F92205""></td>" skip "<td>Предоставлена 3-я отсрочка</td></tr>" skip
     "</table><BR>" skip.

  case v-sel:
    when '1' then put stream rep unformatted "<center><b>Просроченные проверки</b></center><BR><BR>" skip.
    when '2' then put stream rep unformatted "<center><b>Актуальные проверки с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR><BR>" skip.
    when '3' then put stream rep unformatted "<center><b>Проведенные проверки</b></center><BR><BR>" skip.
  end case.


/*ЮРИДИЧЕСКИЕ ЛИЦА*/

  put stream rep unformatted
      "<BR><b>Юридические лица</b><BR>" skip.
  put stream rep unformatted "<table><tr>" skip.
  put stream rep unformatted
         "<table border=1 cellpadding=0 cellspacing=0>" skip
         "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
         "<td>Филиал</td>" skip
         "<td>Код заемщика</td>" skip
         "<td>Наименование заемщика</td>" skip
         "<td>Ссудный счет</td>" skip
         "<td>Сумма<BR>лимита в KZT</td>" skip
         "<td>Дата текущего<BR>мониторинга<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep unformatted
         "<td>Исполнитель по оценке залогов</td>" skip.
  put stream rep unformatted
         "<td>Дата проверки<BR>залогового обеспечения<BR>по графику</td>" skip
         "<td>Залог</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '1' or v-sel = '2' then
  put stream rep unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

    put stream rep unformatted
         "<td>Дата окончания<BR>действия страховки</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '1' or v-sel = '2' then do:
    put stream rep unformatted
         "<td>Дата окончания<BR>срока действия<BR>депозита<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.
    put stream rep unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  end.

  if v-sel = '3' then do:
    put stream rep unformatted
         "<td>Дата окончания<BR>срока действия<BR>депозита<BR>по графику</td>" skip
         "<td>Дата переоформления<BR>депозита</td>" skip
         "<td>Исполнитель</td>" skip.
    put stream rep unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  end.

  put stream rep unformatted
         "<td>Дата <BR> Заметки ДМО</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Заметки ДМО</td>" skip.

  if v-sel = '1' or v-sel = '2' then
  put stream rep unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Дата проведения<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  /*put stream rep unformatted
         "<td>Сумма<BR>лимита</td>" skip
         "<td>Валюта</td>" skip.*/

  put stream rep unformatted "</tr>" skip.

  for each lnpr where lnpr.sts = 'B' no-lock break by lnpr.cif by lnpr.lon:

    put stream rep unformatted "<tr>" skip.
    put stream rep unformatted
    "<td>" lnpr.pb_name "</td>" skip.
    if first-of(lnpr.cif) then put stream rep unformatted
                                      "<td>" lnpr.cif "</td>" skip
                                      "<td>" lnpr.name "</td>" skip.
    else put stream rep unformatted "<td></td><td></td>" skip.
    if first-of(lnpr.lon) then put stream rep unformatted "<td>&nbsp;" lnpr.lon "</td>" skip.
    else put stream rep unformatted "<td></td>" skip.

    put stream rep unformatted "<td align=""right"">" replace(replace(string(lnpr.sumlimkz, ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>" skip.
    case lnpr.otsr_finhoz:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.

    put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_finhoz <> ? then string(lnpr.pdt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_finhoz "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_finhoz <> ? then string(lnpr.edt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_finhoz "</td>" skip.

    case lnpr.otsr_zalog:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " >" lnpr.mng_zalog "</td>" skip.
    put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_zalog <> ? then string(lnpr.pdt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.des_zalog "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_zalog "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_zalog <> ? then string(lnpr.edt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_zalog "</td>" skip.

    case lnpr.otsr_purp:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
    put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_purp <> ? then string(lnpr.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_purp "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_purp <> ? then string(lnpr.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_purp <> ? then string(lnpr.edt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_purp "</td>" skip.

    case lnpr.otsr_insu:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_insu <> ? then string(lnpr.pdt_insu) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_insu "</td>" skip.

    case lnpr.otsr_dep:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then do:
     put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_dep <> ? then string(lnpr.pdt_dep) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_dep "</td>" skip.

     case lnpr.otsr_kk:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
     end case.
     put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_kk <> ? then string(lnpr.pdt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_kk "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.kk_rem "</td>" skip.
    end.
    if v-sel = '3' then do:
        case lnpr.otsr_dep:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_dep <> ? then string(lnpr.pdt_dep) else '-' "</td>" skip
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_dep <> ? then string(lnpr.edt_dep) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_dep "</td>" skip.
        case lnpr.otsr_kk:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_kk <> ? then string(lnpr.pdt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_kk <> ? then string(lnpr.edt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_kk "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.kk_rem "</td>" skip.
    end.

    case lnpr.otsr_dmo:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_dmo <> ? then string(lnpr.pdt_dmo) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_dmo "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_dmo <> ? then string(lnpr.edt_dmo) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_dmo "</td>" skip.

    put stream rep unformatted
         "<td bgcolor = " scolor " >" lnpr.dmo_rem "</td>" skip.

    case lnpr.otsr_extmon:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
    put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_extmon <> ? then string(lnpr.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.pwho_extmon "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.pdt_extmon <> ? then string(lnpr.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor "  align=""right"">" if lnpr.edt_extmon <> ? then string(lnpr.edt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor " >" lnpr.ewho_extmon "</td>" skip.

    /*put stream rep unformatted
         "<td align=""right"">" replace(string(lnpr.sum),'.',',') "</td>" skip
         "<td>" lnpr.crc "</td>" skip.*/

    put stream rep unformatted "</tr>" skip.

  end.
  put stream rep unformatted "</tr></table>" skip.
/*ФИЗИЧЕСКИЕ ЛИЦА*/

  put stream rep unformatted
      "<BR><b>Физические лица</b><BR><br>" skip.

  put stream rep unformatted
         "<table border=1 cellpadding=0 cellspacing=0>" skip
         "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
         "<td>Филиал</td>" skip
         "<td>Код заемщика</td>" skip
         "<td>Наименование заемщика</td>" skip
         "<td>Ссудный счет</td>" skip
         "<td>Сумма<BR>лимита в KZT</td>" skip
         "<td>Дата проверки<BR>фин-хоз деят-сти<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep unformatted
         "<td>Исполнитель по оценке залогов</td>" skip.
  put stream rep unformatted
         "<td>Дата проверки<BR>залогового обеспечения<BR>по графику</td>" skip
         "<td>Залог</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.


  if v-sel = '1' or v-sel = '2' then
  put stream rep unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.


  put stream rep unformatted
         "<td>Дата окончания<BR>действия страховки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep unformatted
         "<td>Дата окончания<BR>сроков действия<BR>депозита по графику</td>" skip.
  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>переоформления<BR>депозита</td>" skip.
  put stream rep unformatted
         "<td>Исполнитель</td>" skip.

  put stream rep unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата<BR>проведения<BR>проверки решения КК</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep unformatted
         "<td>Дата <BR> Заметки ДМО</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Заметки ДМО</td>" skip.

  put stream rep unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep unformatted
         "<td>Дата проведения<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  /*put stream rep unformatted
         "<td>Сумма<BR>лимита</td>" skip
         "<td>Валюта</td>" skip.*/

  put stream rep unformatted "</tr>" skip.

  for each lnpr where lnpr.sts = 'P' no-lock break by lnpr.cif by lnpr.lon:

    put stream rep unformatted "<tr>" skip.
    put stream rep unformatted
    "<td>" lnpr.pb_name "</td>" skip.
    if first-of(lnpr.cif) then put stream rep unformatted
                                      "<td>" lnpr.cif "</td>" skip
                                      "<td>" lnpr.name "</td>" skip.
    else put stream rep unformatted "<td></td><td></td>" skip.
    if first-of(lnpr.lon) then put stream rep unformatted "<td>&nbsp;" lnpr.lon "</td>" skip.
    else put stream rep unformatted "<td></td>" skip.

    put stream rep unformatted "<td align=""right"">" replace(replace(string(lnpr.sumlimkz, ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>" skip.

    case lnpr.otsr_finhoz:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_finhoz <> ? then string(lnpr.pdt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_finhoz "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_finhoz <> ? then string(lnpr.edt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_finhoz "</td>" skip.

    case lnpr.otsr_zalog:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor ">" lnpr.mng_zalog "</td>" skip.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_zalog <> ? then string(lnpr.pdt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.des_zalog "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_zalog "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_zalog <> ? then string(lnpr.edt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_zalog "</td>" skip.

    case lnpr.otsr_purp:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_purp <> ? then string(lnpr.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_purp "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_purp <> ? then string(lnpr.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_purp <> ? then string(lnpr.edt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_purp "</td>" skip.

    case lnpr.otsr_insu:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_insu <> ? then string(lnpr.pdt_insu) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_insu "</td>" skip.

    case lnpr.otsr_dep:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_dep <> ? then string(lnpr.pdt_dep) else '-' "</td>" skip.
    if v-sel = '3' then do:
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_dep <> ? then string(lnpr.edt_dep) else '-' "</td>" skip.
    put stream rep unformatted
         "<td bgcolor = " scolor ">"lnpr.ewho_dep "</td>" skip.
    end.
    else
    put stream rep unformatted
         "<td bgcolor = " scolor ">"lnpr.pwho_dep "</td>" skip.

    case lnpr.otsr_kk:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_kk <> ? then string(lnpr.pdt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_kk "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.kk_rem "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_kk <> ? then string(lnpr.edt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_kk "</td>" skip.

    case lnpr.otsr_dmo:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_dmo <> ? then string(lnpr.pdt_dmo) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_dmo "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_dmo <> ? then string(lnpr.edt_dmo) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_dmo "</td>" skip.

    put stream rep unformatted
         "<td bgcolor = " scolor ">" lnpr.dmo_rem "</td>" skip.

    case lnpr.otsr_extmon:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.pdt_extmon <> ? then string(lnpr.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.pwho_extmon "</td>" skip.
    if v-sel = '3' then
       put stream rep unformatted
         "<td bgcolor = " scolor " align=""right"">" if lnpr.edt_extmon <> ? then string(lnpr.edt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" lnpr.ewho_extmon "</td>" skip.

    /*put stream rep unformatted
         "<td align=""right"">" replace(string(lnpr.sum),'.',',') "</td>" skip
         "<td>" lnpr.crc "</td>" skip.*/

  end.

  put stream rep unformatted "</table></body></html>".
  output stream rep close.

  /*hide message no-pause.*/


  /*****galina гарантии и лимиты**********/
    put stream rep2 unformatted
      "<html><head>" skip
      "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
      "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
      "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
      "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
      "</head><body>" skip.

  find first ofc where ofc.ofc = g-ofc no-lock no-error.
  if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

  put stream rep2 unformatted
      "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
      "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip.

  put stream rep2 unformatted
    "<table border=0 cellpadding=0 cellspacing=0>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#3CA105""></td>" skip "<td>Предоставлена 1-я отсрочка</td></tr>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#FFF500""></td>" skip "<td>Предоставлена 2-я отсрочка</td></tr>" skip
     "<tr style=""font:bold;font-size: 12"" align=""left"">" skip "<td bgcolor=""#F92205""></td>" skip "<td>Предоставлена 3-я отсрочка</td></tr>" skip
     "</table><BR>" skip.

  case v-sel:
    when '1' then put stream rep2 unformatted "<center><b>Просроченные проверки</b></center><BR><BR>" skip.
    when '2' then put stream rep2 unformatted "<center><b>Актуальные проверки с " dt1 format "99/99/9999" " по " dt2 format "99/99/9999" "</b></center><BR><BR>" skip.
    when '3' then put stream rep2 unformatted "<center><b>Проведенные проверки</b></center><BR><BR>" skip.
  end case.


/*ЮРИДИЧЕСКИЕ ЛИЦА*/

  put stream rep2 unformatted
      "<BR><b>Юридические лица</b><BR>" skip.
  put stream rep2 unformatted "<table><tr>" skip.
  put stream rep2 unformatted
         "<table border=1 cellpadding=0 cellspacing=0>" skip
         "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
         "<td>Филиал</td>" skip
         "<td>Код заемщика</td>" skip
         "<td>Наименование заемщика</td>" skip
         "<td>Номер договора гарантии</td>" skip
         "<td>Сумма<BR>лимита в KZT</td>" skip
         "<td>Дата текущего<BR>мониторинга<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted
         "<td>Исполнитель по оценке залогов</td>" skip.
  put stream rep2 unformatted
         "<td>Дата проверки<BR>залогового обеспечения<BR>по графику</td>" skip
         "<td>Залог</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '1' or v-sel = '2' then
  put stream rep2 unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

    put stream rep2 unformatted
         "<td>Дата окончания<BR>действия страховки</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '1' or v-sel = '2' then do:
    put stream rep2 unformatted
         "<td>Дата окончания<BR>срока действия<BR>депозита<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.
    put stream rep2 unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  end.

  if v-sel = '3' then do:
    put stream rep2 unformatted
         "<td>Дата окончания<BR>срока действия<BR>депозита<BR>по графику</td>" skip
         "<td>Дата переоформления<BR>депозита</td>" skip
         "<td>Исполнитель</td>" skip.
    put stream rep2 unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  end.

  if v-sel = '1' or v-sel = '2' then
  put stream rep2 unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Дата проведения<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.


  put stream rep2 unformatted "</tr>" skip.

  for each tgaran where tgaran.sts = 'B' no-lock break by tgaran.cif by tgaran.lon:

    put stream rep2 unformatted "<tr>" skip.
    put stream rep2 unformatted
    "<td>" tgaran.pb_name "</td>" skip.
    if first-of(tgaran.cif) then put stream rep2 unformatted
                                      "<td>" tgaran.cif "</td>" skip
                                      "<td>" tgaran.name "</td>" skip.
    else put stream rep2 unformatted "<td></td><td></td>" skip.
    if first-of(tgaran.lon) then put stream rep2 unformatted "<td>&nbsp;" tgaran.lon "</td>" skip.
    else put stream rep2 unformatted "<td></td>" skip.

    put stream rep2 unformatted "<td align=""right"">" replace(replace(string(tgaran.sumlimkz, ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>" skip.

    case tgaran.otsr_finhoz:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_finhoz <> ? then string(tgaran.pdt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_finhoz "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_finhoz <> ? then string(tgaran.edt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_finhoz "</td>" skip.

    case tgaran.otsr_zalog:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor ">" tgaran.mng_zalog "</td>" skip.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_zalog <> ? then string(tgaran.pdt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.des_zalog "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_zalog "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_zalog <> ? then string(tgaran.edt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_zalog "</td>" skip.

    case tgaran.otsr_purp:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
        put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_purp <> ? then string(tgaran.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_purp "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_purp <> ? then string(tgaran.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_purp <> ? then string(tgaran.edt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_purp "</td>" skip.

    case tgaran.otsr_insu:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_insu <> ? then string(tgaran.pdt_insu) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_insu "</td>" skip.

    if v-sel = '1' or v-sel = '2' then do:
        case tgaran.otsr_dep:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
        put stream rep2 unformatted
            "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_dep <> ? then string(tgaran.pdt_dep) else '-' "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.pwho_dep "</td>" skip.
        case tgaran.otsr_kk:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
        put stream rep2 unformatted
            "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_kk <> ? then string(tgaran.pdt_kk) else '-' "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.pwho_kk "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.kk_rem "</td>" skip.
    end.
    if v-sel = '3' then do:
        case tgaran.otsr_dep:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
        put stream rep2 unformatted
            "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_dep <> ? then string(tgaran.pdt_dep) else '-' "</td>" skip
            "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_dep <> ? then string(tgaran.edt_dep) else '-' "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.ewho_dep "</td>" skip.
        case tgaran.otsr_kk:
            when 0 then scolor = "#FBFCFA".
            when 1 then scolor = "#3CA105".
            when 2 then scolor = "#FFF500".
            when 3 then scolor = "#F92205".
        end case.
        put stream rep2 unformatted
            "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_kk <> ? then string(tgaran.pdt_kk) else '-' "</td>" skip
            "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_kk <> ? then string(tgaran.edt_kk) else '-' "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.ewho_kk "</td>" skip
            "<td bgcolor = " scolor ">" tgaran.kk_rem "</td>" skip.
    end.

    case tgaran.otsr_extmon:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_extmon <> ? then string(tgaran.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_extmon "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_extmon <> ? then string(tgaran.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_extmon <> ? then string(tgaran.edt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_extmon "</td>" skip.


    put stream rep2 unformatted "</tr>" skip.

  end.
  put stream rep2 unformatted "</tr></table>" skip.
/*ФИЗИЧЕСКИЕ ЛИЦА*/

  put stream rep2 unformatted
      "<BR><b>Физические лица</b><BR><br>" skip.

  put stream rep2 unformatted
         "<table border=1 cellpadding=0 cellspacing=0>" skip
         "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
         "<td>Филиал</td>" skip
         "<td>Код заемщика</td>" skip
         "<td>Наименование заемщика</td>" skip
         "<td>Ссудный счет</td>" skip
         "<td>Сумма<BR>лимита в KZT</td>" skip
         "<td>Дата проверки<BR>фин-хоз деят-сти<BR>по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted
         "<td>Исполнитель по оценке залогов</td>" skip.
  put stream rep2 unformatted
         "<td>Дата проверки<BR>залогового обеспечения<BR>по графику</td>" skip
         "<td>Залог</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.


  if v-sel = '1' or v-sel = '2' then
  put stream rep2 unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата проверки<BR>целевого использования<BR>кредита по графику</td>" skip
         "<td>Дата<BR>проведения<BR>проверки</td>" skip
         "<td>Исполнитель</td>" skip.


  put stream rep2 unformatted
         "<td>Дата окончания<BR>действия страховки</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted
         "<td>Дата окончания<BR>сроков действия<BR>депозита по графику</td>" skip.
  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>переоформления<BR>депозита</td>" skip.
  put stream rep2 unformatted
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted
         "<td>Дата проверки<BR>решения КК</td>" skip
         "<td>Исполнитель</td>" skip
         "<td>Содержание решения КК</td>" skip.
  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата<BR>проведения<BR>проверки решения КК</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted
         "<td>Дата<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  if v-sel = '3' then
  put stream rep2 unformatted
         "<td>Дата проведения<BR>расширенного<BR>мониторинга</td>" skip
         "<td>Исполнитель</td>" skip.

  put stream rep2 unformatted "</tr>" skip.

  for each lnpr where tgaran.sts = 'P' no-lock break by tgaran.cif by tgaran.lon:

    put stream rep2 unformatted "<tr>" skip.
    put stream rep2 unformatted
    "<td>" tgaran.pb_name "</td>" skip.
    if first-of(tgaran.cif) then put stream rep2 unformatted
                                      "<td>" tgaran.cif "</td>" skip
                                      "<td>" tgaran.name "</td>" skip.
    else put stream rep2 unformatted "<td></td><td></td>" skip.
    if first-of(tgaran.lon) then put stream rep2 unformatted "<td>&nbsp;" tgaran.lon "</td>" skip.
    else put stream rep2 unformatted "<td></td>" skip.

    put stream rep2 unformatted "<td align=""right"">" replace(replace(string(tgaran.sumlimkz, ">>>,>>>,>>>,>>>,>>9"),","," "),".",",") "</td>" skip.

    case tgaran.otsr_finhoz:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_finhoz <> ? then string(tgaran.pdt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_finhoz "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_finhoz <> ? then string(tgaran.edt_finhoz) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_finhoz "</td>" skip.

    case tgaran.otsr_zalog:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor ">" tgaran.mng_zalog "</td>" skip.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_zalog <> ? then string(tgaran.pdt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.des_zalog "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_zalog "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_zalog <> ? then string(tgaran.edt_zalog) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_zalog "</td>" skip.

    case tgaran.otsr_purp:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    if v-sel = '1' or v-sel = '2' then
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_purp <> ? then string(tgaran.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_purp "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_purp <> ? then string(tgaran.pdt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_purp <> ? then string(tgaran.edt_purp) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_purp "</td>" skip.

    case tgaran.otsr_insu:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_insu <> ? then string(tgaran.pdt_insu) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_insu "</td>" skip.

    case tgaran.otsr_dep:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_dep <> ? then string(tgaran.pdt_dep) else '-' "</td>" skip.
    if v-sel = '3' then do:
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_dep <> ? then string(tgaran.edt_dep) else '-' "</td>" skip.
    put stream rep2 unformatted
         "<td bgcolor = " scolor ">"tgaran.ewho_dep "</td>" skip.
    end.
    else
    put stream rep2 unformatted
         "<td bgcolor = " scolor ">"tgaran.pwho_dep "</td>" skip.

    case tgaran.otsr_kk:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_kk <> ? then string(tgaran.pdt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_kk "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.kk_rem "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_kk <> ? then string(tgaran.edt_kk) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_kk "</td>" skip.

    case tgaran.otsr_extmon:
        when 0 then scolor = "#FBFCFA".
        when 1 then scolor = "#3CA105".
        when 2 then scolor = "#FFF500".
        when 3 then scolor = "#F92205".
    end case.
    put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.pdt_extmon <> ? then string(tgaran.pdt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.pwho_extmon "</td>" skip.
    if v-sel = '3' then
       put stream rep2 unformatted
         "<td bgcolor = " scolor " align=""right"">" if tgaran.edt_extmon <> ? then string(tgaran.edt_extmon) else '-' "</td>" skip
         "<td bgcolor = " scolor ">" tgaran.ewho_extmon "</td>" skip.


  end.

  put stream rep2 unformatted "</table></body></html>".
  output stream rep2 close.

  unix silent cptwin rep.htm excel.
  unix silent cptwin rep2.htm excel.

  hide all no-pause.

  /****************/

