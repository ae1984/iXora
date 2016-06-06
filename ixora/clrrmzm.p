/* clrrmzm.p
* MODULE
        Название Программного Модуля
* DESCRIPTION
        Назначение программы, описание процедур и функци
* RUN
        Способ вызова программы, описание параметров, примеры вызов
* CALLER
        Список процедур, вызывающих этот фай
* SCRIPT
        Список скриптов, вызывающих этот фай
* INHERIT
        Список вызываемых процеду
* MENU
        Перечень пунктов Меню Прагмы
* AUTHOR
        31/12/99 pragma
* CHANGES
        15.10.2003 nadejda  - задала использование rmzmont.i вместо двух rmzmont1.i, rmzmont2.i
                 06.06.2007 id00004  - закомментарил отправку e-mail.
        19/8/2013 galina - ТЗ1871 добфвила обработку платежей по СМЭП
*/
                 /* KOVAL Ведомость отправленных платежей по Клирингу ил Гроссу*/


{global.i}
{get-dep.i}

def input parameter ipr as integer.
def input parameter cho as char. /* Че будем делать */
def input parameter sdate as date. /* Че будем делать */

{rmzmont.i}

mesgdt="Отчет отправленных платежей (" + QQ + "), пачка N " + string(ipr) + " на " + string(today, "99/99/99") + " " + string(time,"HH:MM:SS").

case QQ:
 when 'LB' or when 'V21' then do:
  for each clrdoc no-lock where clrdoc.pr = ipr and clrdoc.rdt = sdate :
    s-remtrz = clrdoc.rem.
    {rmzmonc.i
        &lb = " true "
        &lbg = " false "
    }
  end.
 end.

 when 'LBG' or when 'V22' then do:
  for each clrdog no-lock where clrdog.pr = ipr and clrdog.rdt = sdate :
    s-remtrz = clrdog.rem.
    {rmzmonc.i
        &lb = " false "
        &lbg = " true "
    }
  end.
 end.
 when 'SMP'  then do:
  for each clrdos no-lock where clrdos.pr = ipr and clrdos.rdt = sdate :
    s-remtrz = clrdos.rem.
    {rmzmonc.i
        &lb = " false "
        &lbg = " true "
    }
  end.
 end.
end case.

{rmzmonf.i}

run rptfile.
case cho:
  when "mailps" then do:
        unix silent un-win value(v-fname) rpt.html.
        find sysc where sysc.sysc = "lbmail" no-lock no-error.
/*        run mail(trim(sysc.chval), "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", mesgdt, mesgdt , "1", "", "rpt.html"). */
/*        run mail("ikoval@elexnet.kz", "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", mesgdt, mesgdt , "1", "", "rpt.html").*/
  end.
  when "menu-prt" then run menu-prt(v-fname).
end case.
