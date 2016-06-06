/* drrmzm.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Вспомогательная процедура по формированию ведомостей по отправленныи платежам по почте
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
        16/06/05 kanat
 * CHANGES
*/

{global.i}
{get-dep.i} 

def input parameter ipr as integer.
def input parameter cho as char. /* Че будем делать */
def input parameter sdate as date. /* Че будем делать */

{rmzmx1.i}

mesgdt="Отчет отправленных платежей ПКО (" + QQ + "), " + string(today, "99/99/99") + " " + string(time,"HH:MM:SS").

case QQ:

 when 'DRLB' then do:
  for each que no-lock where que.pid = "DRLB":
  find remtrz where remtrz.remtrz = que.rem and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
  if avail remtrz then do:
    s-remtrz = remtrz.remtrz.
    {rmzmoncx.i 
        &drlb = " true "
        &drpr = " false "
        &drlbg = " false "
    }
  end.
  end.
 end.

 when 'DRPR' then do:
  for each que no-lock where que.pid = "DRPR":
  find remtrz where remtrz.remtrz = que.rem and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
  if avail remtrz then do:
    s-remtrz = remtrz.remtrz.
    {rmzmoncx.i 
        &drlb = "  false "
        &drpr = "  true "
        &drlbg = " false "
    }
  end.
  end.
 end.

 when 'DRLBG' then do:
  for each que no-lock where que.pid = "DRLBG":
  find remtrz where remtrz.remtrz = que.rem and lookup(remtrz.ptype,  "2,6") > 0 no-lock no-error.
  if avail remtrz then do:
    s-remtrz = remtrz.remtrz.
    {rmzmoncx.i 
        &drlb = " false "
        &drpr = " false "
        &drlbg = " true "
    }
  end.
  end.
 end.

end case.

{rmzmx2.i}

run rptfilex.
case cho:
  when "mailps" then do:
        unix silent un-win value(v-fname) rpt.html.
        find sysc where sysc.sysc = "lbmail" no-lock no-error.
        run mail(trim(sysc.chval), "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", mesgdt, mesgdt , "1", "", "rpt.html").
/*        run mail("ikoval@elexnet.kz", "TEXAKABANK <" + userid("bank") + "@elexnet.kz>", mesgdt, mesgdt , "1", "", "rpt.html").*/
  end.
  when "menu-prt" then run menu-prt(v-fname).
end case.
