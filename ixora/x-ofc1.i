/* x-ofc1.i
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

  update
       vpoint validate(can-find (point where point.point = vpoint),
       ' Ошибочный код пункта - повторите ! ') with frame ofc. 
  update
       vdep validate(can-find (ppoint where ppoint.point = vpoint and
       ppoint.depart = vdep),
       ' Ошибочный код департамента - повторите !') with frame ofc.

  /* 16/07/02 - nadejda - код Профит-центра (для Центрального Офиса - отдел, для РКО - префикс как суффикс RMZ + номер РКО) */
       on help of vprofit in frame ofc do:
          run uni_help1('sproftcn', '...').
       end.

       if vdep <> ofc.dpt then do:
         if vdep > 1 then do:
           /* коды РКО в зависимости от филиала - Алматы A, Астана B, Уральск C */
           find sysc where sysc.sysc = "PCRKO" no-lock no-error.
           vprofit = trim(sysc.chval) + string(vdep, '99').
           displ vprofit with frame ofc.
         end.
         else
           update vprofit validate((can-find(codfr where codfr.codfr = 'sproftcn' and 
                         code = vprofit) and vprofit matches '...'),
                        'Неверный Профит-центр - повторите!') with frame ofc. 
       end.
  /* --- end Profit-center --- */

       update ofc.name with frame ofc. 
       update
         ofc.addr ofc.tel ofc.regdt ofc.tit ofc.expr[5] ofc.lang
         ofc.indt ofc.edu ofc.bdt with frame ofc.

       if vpoint <> epoint or vdep <> edep then do :
         find ofchis where ofchis.ofc = ofc.ofc and ofchis.regdt = g-today
              no-error.
         if available ofchis then do :
           ofchis.point = vpoint.
           ofchis.dep = vdep.
         end.
         else do :
           create ofchis.
           ofchis.ofc = ofc.ofc.
           ofchis.point = vpoint.
           ofchis.dep = vdep.
           ofchis.regdt = g-today.
         end.
       end.
       ofc.regno = vpoint * 1000 + vdep.
       if expr[3] eq '' then expr[3] = 'prit'.

  /* 16/07/02 - nadejda - история смены Профит-центров */
       if vprofit <> eprofit then do:
         create ofcprofit.
         ofcprofit.ofc = ofc.ofc.
         ofcprofit.profit = vprofit.
         ofcprofit.regdt = g-today.
         ofcprofit.tim = time.
         ofcprofit.who = g-ofc.
         eprofit = vprofit.
       end.
       ofc.titcd = vprofit.
       find ofc-tn where ofc-tn.ofc = ofc.ofc no-error.
       if avail ofc-tn then ofc-tn.profitcn = vprofit.
  /* --- end history Profit-center --- */


