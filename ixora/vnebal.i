/* vnebal.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Снятие сумм со счетов внебаланса
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
        28/10/2010 madiyar - 780300 -> 830300
*/


          s-vcourbank = comm-txb().
          if s-vcourbank = "txb00" then do:
             find last vnebal where vnebal.usr = substr(cif.fname,1,8) no-lock no-error.
             if avail vnebal then do:
                v-usrglacc = vnebal.gl.
             end.
             else do:
               v-ofc1 =  string(get-dep(trim(substr(cif.fname,1,8)), g-today)).
               find last vnebal where vnebal.usr = v-ofc1  no-lock no-error.
               if avail vnebal then do:
                  v-usrglacc = vnebal.gl.                        
               end.
             end.
           end. else do:
             find last vnebal where vnebal.usr = s-vcourbank no-lock no-error.
             if avail vnebal then do:
                v-usrglacc = vnebal.gl.
             end.
           end.
           if v-usrglacc <> "" then do:
              v-jhink = 0.
              vparam2 = string(d-SumOfPlat) + vdel + string(1) + vdel + "830300" + vdel + v-usrglacc + vdel + aaa.aaa + vdel + aaa.aaa + vdel.
              run trxgen("vnb0005", vdel, vparam2, "CIF", aaa.aaa, output rcode, output rdes, input-output v-jhink).
              if rcode ne 0 then do:
        run savelog ("k2ink", aaa.aaa + "VNEBALNO" + string(d-SumOfPlat)) .
/*                put stream m-out unformatted aaa.aaa + "Ошибка снятия суммы с внебаланса: " + rdes  skip. */
/*                 undo. */
              end.
              else do:
        run savelog ("k2ink", aaa.aaa + "VNEBALYES" + string(d-SumOfPlat)) .
              end.
           end.
           else do:
/*              put stream m-out unformatted aaa.aaa + "Не найден счет Г/К для снятия с внебаланса "   skip. */
/*                undo. */
           end.






