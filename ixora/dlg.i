/* dlg.i
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Списание доходов с 13 уровня
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
        27.02.2006 dpuchkov
 * CONNECT
        BANK
 * CHANGES

*/



    find last depo where depo.aaa = aaa.aaa and depo.prim2 <> "del" and
             ((depo.lstdt < g-today and depo.prlngdate > g-today) or
              (depo.dt1 < g-today and depo.dt2 > g-today)) and substr(depo.prlngperiod,1,8) = string(g-today) exclusive-lock no-error.
    if avail depo then do:
       if (depo.lstdt < g-today and depo.prlngdate > g-today) then do:
          if (month(depo.lstdt) <> month(g-today) and g-today > depo.lstdt) then do:

              iamt = (GetLastNum(date("05." + string(gtmonmin(month(g-today))) + "." + string(year(g-today)))) - depo.lstdt) + 1.
              s-amt1 = round((depo.sum / (depo.prlngdate - depo.lstdt)) *  iamt, 2).

              if s-amt1 > 0 then do:
                 v-jh = 0.
                 vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.lstdt) + " по " + string(GetLastNum(date("05." + string(gtmonmin(month(g-today))) + "." + string(year(g-today))))) + vdel + "".
                 run trxgen ("uni0188", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                 if rcode ne 0 then 
                    put stream m-out unformatted "-Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                 else do:
                    depo.lev = string(decimal(depo.lev) + s-amt1).
                    put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                    run trxsts(v-jh, 6, output rcode, output rdes).
                 end.
              end.
          end.
          if (depo.dt1 < g-today and depo.dt2 > g-today) then do:
              iamt = (GetLastNum(date("05." + string(gtmonmin(month(g-today))) + "." + string(year(g-today)))) - depo.dt1  ) + 1.
              s-amt1 = round(( decimal(depo.prim1) / (depo.dt2 - depo.dt1)) *  iamt, 2).
              if s-amt1 > 0 then do:
                 v-jh = 0.
                 vparam = string(s-amt1) + vdel + aaa.aaa + vdel + "аренда сейфовой ячейки с " + string(depo.dt1) + " по " + string(GetLastNum(date("05." + string(gtmonmin(month(g-today))) + "." + string(year(g-today))))) + vdel + "".
                 run trxgen ("uni0188", vdel, vparam, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jh).
                 if rcode ne 0 then
                    put stream m-out unformatted "-Ошибка списания " aaa.aaa ", " string(s-amt1) " -> " rdes skip.
                 else do:
                    depo.pr = string(decimal(depo.pr) + s-amt1).
                    put stream m-out unformatted "+Успешно списано " aaa.aaa ", " string(s-amt1) " c " string(depo.lstdt) " по " string(depo.prlngdate) skip.
                    run trxsts(v-jh, 6, output rcode, output rdes).
                 end.
              end.
          end.
       end.
    end.
