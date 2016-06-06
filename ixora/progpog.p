/* progpog.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Прогноз погашения по кредитам
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
        20/12/2004 madiyar
 * CHANGES
        28/06/2005 madiyar - возникала ошибка при попытке взять отчет за будущий период (dat1 > g-today), исправил
        25/04/2007 madiyar - кредиты из действующего портфеля
        25/11/2009 madiyar - три отчета (общий, задолжники, без задолженностей)
        15/10/2010 madiyar - ограничил выбор дат; отчет по ЮЛ
*/

{mainhead.i}

def new shared temp-table wrk no-undo
  field ztype as integer
  field bank as char
  field bankn as char
  field segm as char
  field dt as date
  field crc like crc.crc
  field od as deci
  field prc as deci
  field com as deci
  field pen as deci
  field ost as deci
  index idx is primary ztype segm dt bank crc.

def temp-table wrk_it
  field ztype as integer
  field segm as char
  field crc like crc.crc
  field od as deci
  field prc as deci
  field com as deci
  field pen as deci
  field ost as deci
  index idx is primary ztype segm crc.

def var dat1 as date.
def var dat2 as date.
dat1 = g-today.
dat2 = g-today.

def new shared var v-type as integer no-undo.
v-type = 1.

update skip(1)
       dat1 validate(dat1 >= g-today, "Дата должна быть >= текущей!") label " С  " " "
       dat2 validate(dat2 >= dat1, "Дата должна быть >= дате начала периода!") label " По " " " skip
       v-type validate(v-type > 0 and v-type < 3, "Введено некорректное значение!") label " Тип отчета " help "1 - физ.лица, 2 - юр.лица" skip(1)
       with centered side-label row 5 frame fr.

{r-brfilial.i &proc = "progpog2(dat1,dat2)"}

def var usrnm as char no-undo.
def stream rep.

def var i as integer no-undo.
def var rtitle as char no-undo extent 3 init ['Кредиты без задолженности','Задолжники','Все кредиты'].

do i = 1 to 3:

    output stream rep to value("rep" + string(i) + ".htm").

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
        "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
        "<center><b>Прогноз погашения кредитов с " dat1 format "99/99/9999" " по " dat2 format "99/99/9999" "</b><br>" skip
        v-bankname "<BR>" skip
        rtitle[i] "</center><BR><BR>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td>Дата</td>" skip
        "<td>Филиал</td>" skip
        "<td>Валюта</td>" skip
        "<td>Основной долг</td>" skip
        "<td>Вознаграждение</td>" skip
        "<td>Ком. за вед. счета</td>" skip
        "<td>Пеня<br>(на тек. момент)</td>" skip
        "<td>Остаток на счету<br>(на тек. момент)</td>" skip
        "</tr>" skip.

    for each wrk where wrk.ztype = i no-lock break by wrk.segm:

      if first-of(wrk.segm) then do:
        find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
        if avail codfr then put stream rep unformatted "<tr style=""font:bold""><td colspan=4>" codfr.name[1] "</td></tr>" skip.
        else put stream rep unformatted "<tr style=""font:bold""><td colspan=4>" wrk.segm "</td></tr>" skip.
      end.

      find first crc where crc.crc = wrk.crc no-lock no-error.
      put stream rep unformatted
        "<tr>" skip
        "<td>" wrk.dt format "99/99/9999" "</td>" skip
        "<td>" wrk.bankn "</td>" skip
        "<td>" crc.code "</td>" skip
        "<td>" replace(trim(string(wrk.od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.com, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.pen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "<td>" replace(trim(string(wrk.ost, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
        "</tr>" skip.

      find first wrk_it where wrk_it.ztype = wrk.ztype and wrk_it.segm = wrk.segm and wrk_it.crc = wrk.crc no-lock no-error.
      if not avail wrk_it then do:
        create wrk_it.
        wrk_it.ztype = wrk.ztype.
        wrk_it.segm = wrk.segm.
        wrk_it.crc = wrk.crc.
      end.
      wrk_it.od = wrk_it.od + wrk.od.
      wrk_it.prc = wrk_it.prc + wrk.prc.
      wrk_it.com = wrk_it.com + wrk.com.
      wrk_it.pen = wrk_it.pen + wrk.pen.
      wrk_it.ost = wrk_it.ost + wrk.ost.

      find first wrk_it where wrk_it.ztype = wrk.ztype and wrk_it.segm = "Итого за период" and wrk_it.crc = wrk.crc no-lock no-error.
      if not avail wrk_it then do:
        create wrk_it.
        assign wrk_it.ztype = wrk_it.ztype
               wrk_it.segm = "Итого за период"
               wrk_it.crc = wrk.crc.
      end.
      wrk_it.od = wrk_it.od + wrk.od.
      wrk_it.prc = wrk_it.prc + wrk.prc.
      wrk_it.com = wrk_it.com + wrk.com.
      wrk_it.pen = wrk_it.pen + wrk.pen.
      wrk_it.ost = wrk_it.ost + wrk.ost.

      if last-of(wrk.segm) then do:
        find first codfr where codfr.codfr = "lnsegm" and codfr.code = wrk.segm no-lock no-error.
        if avail codfr then put stream rep unformatted "<tr style=""font:bold""><td colspan=4>Итого за период по программе " codfr.name[1] "</td></tr>" skip.
        else put stream rep unformatted "<tr style=""font:bold""><td colspan=4>Итого за период по программе " wrk.segm "</td></tr>" skip.
        for each wrk_it where wrk_it.ztype = wrk.ztype and wrk_it.segm = wrk.segm no-lock:
          find first crc where crc.crc = wrk_it.crc no-lock no-error.
          put stream rep unformatted
              "<tr>" skip
              "<td></td>" skip
              "<td></td>" skip
              "<td>" crc.code "</td>" skip
              "<td>" replace(trim(string(wrk_it.od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
              "<td>" replace(trim(string(wrk_it.prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
              "<td>" replace(trim(string(wrk_it.com, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
              "<td>" replace(trim(string(wrk_it.pen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
              "<td>" replace(trim(string(wrk_it.ost, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
              "</tr>" skip.
        end.
      end. /* if last-of(wrk.segm) */

    end. /* for each wrk */

    put stream rep unformatted "<tr style=""font:bold""><td colspan=4>Итого за период</td></tr>" skip.
    for each wrk_it where wrk_it.ztype = i and wrk_it.segm = "Итого за период" no-lock:
        find first crc where crc.crc = wrk_it.crc no-lock no-error.
        put stream rep unformatted
            "<tr>" skip
            "<td></td>" skip
            "<td>" crc.code "</td>" skip
            "<td>" replace(trim(string(wrk_it.od, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk_it.prc, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk_it.com, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk_it.pen, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "<td>" replace(trim(string(wrk_it.ost, ">>>>>>>>>>>>>>9.99")),'.',',') "</td>" skip
            "</tr>" skip.
    end.

    put stream rep unformatted "</table></body></html>".
    output stream rep close.

    hide message no-pause.

    unix silent value("cptwin rep" + string(i) + ".htm excel").
end.