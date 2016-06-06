/* getstatforinsin1.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        16/05/2011 evseev - возврат статуса для РПРО
 * BASES
        COMM TXB
 * CHANGES
        19.05.2011 evseev - исправил ошибку. txb.cif.jss = insin.clrnn на txb.cif.jss <> insin.clrnn
        08/06/2011 evseev - переход на ИИН/БИН
*/

{chbin_txb.i}
def input parameter i-ref like insin.ref no-undo.
def shared var s-stat  like insin.stat no-undo.

def buffer b-cif for txb.cif.
def var k as integer no-undo.

find first insin where insin.ref = i-ref no-lock no-error.

        s-stat = 12.
        k = 1.
        aa:
        repeat:
          find first txb.aaa where txb.aaa.aaa = entry(k,insin.iik) no-lock no-error.
          if avail txb.aaa then do:
            find first txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
            if not avail txb.cif then do:
              if v-bin then find first b-cif where b-cif.bin = insin.clbin no-lock no-error.
              else find first b-cif where b-cif.jss = insin.clrnn no-lock no-error.
              if avail b-cif then do: s-stat = 16. end.
              else s-stat = 11.
            end.
            else do:
              if v-bin then do:
                  if txb.cif.bin <> insin.clbin then do: s-stat = 16. end.
                  else do:
                    if (txb.aaa.sta ne "C") and (txb.aaa.sta ne "E") then do:
                      s-stat = 1.
                      leave.
                    end.
                    else s-stat = 13.
                  end.
              end. else do:
                  if txb.cif.jss <> insin.clrnn then do: s-stat = 16. end.
                  else do:
                    if (txb.aaa.sta ne "C") and (txb.aaa.sta ne "E") then do:
                      s-stat = 1.
                      leave.
                    end.
                    else s-stat = 13.
                  end.
              end.
            end.
          end. /*avail aaa*/
          if k = num-entries(insin.iik) then leave.
          else do:
            k = k + 1.
            next aa.
          end.

        end. /*repeat*/