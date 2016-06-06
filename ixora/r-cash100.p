/* r-cash100.p
 * MODULE
         Транзакции по счетам главной книги для Чимкента
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
 * BASES
        BANK
 * AUTHOR
        11/11/10 marinav
 * CHANGES
        12.01.11 marinav - добавлен счет хранилища
        03.11.2011 lyubov - по счету ГК 100100 (касса) отчет формируется программой r-cashsp
*/

{mainhead.i }

define var fdt as date.
define var tdt as date.
define var vgl like gl.gl.
define var vtitle2 as char form "x(132)".
define var vtitle3 as char form "x(132)".
define var v-bal1  like jl.dam.
define var v-bal2  like jl.dam.
define var v-bal3  like jl.dam.
define var v-end1  like jl.dam.
define var v-end2  like jl.dam.
define var v-end3  like jl.dam.
def var v-arp like arp.arp.
def var v-rem as char.
def var v-glacc as int format ">>>>>>".
def var v-depart as inte.
def var v-nom as inte format "zz9".
def buffer b-jl for jl.
def var v-tim as char.

fdt = g-today.
vgl = 100100.


def var v-sel as char init '0'.
run sel2 ("Отчет по кассе :", " 1. ГК 100100 наличность в кассе  | 2. ГК 100110 наличность в хранилище ", output v-sel).
if v-sel = '0' then return.
if v-sel = '1' then run r-cashsp.
if v-sel = '2' then do:

assign vgl = 100110.


{image1.i rpt.img}
     update
              fdt      label " Дата отчета"  help " Задайте дату отчета" skip
              v-depart label " СП         "  help " Выберите СП " skip
              with row 8 centered  side-label frame opt title "Отчет по кассовым оборотам ".
     hide frame  opt.

find first ppoint where ppoin.depart = v-depart no-lock no-error.

find gl where gl.gl eq vgl no-lock no-error.
{image2.i}
{report1.i 63}

vtitle2 = "Операция          Дебет           Кредит                      ПРИМЕЧАНИЕ                     Исполнитель Время    Акцепт".

form jl.jh
     jl.dam  format "zzz,zzz,zz9.99"
     jl.cam  format "zzz,zzz,zz9.99"
     v-rem format "x(53)" jl.who v-tim jl.teller
     with no-label width 132 down frame detail.

for each crc no-lock where crc.sts ne 9 break by crc.crc:

  v-nom = 0.  v-arp = "".
  v-bal1 = 0.
  v-bal2 = 0.
  if first(crc) eq false then page.
  /*
  find first jl where jl.jdt = fdt and  jl.gl eq vgl and jl.crc = crc.crc no-lock no-error.
  if not available jl then  next.
   */
        for each arp where arp.gl = 100200 and arp.crc = crc.crc  no-lock:
              find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp no-lock no-error.
              if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.
              find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp no-lock no-error.
              if avail sub-cod and (inte(substr(sub-cod.ccode, 2, 2)) = v-depart or (v-depart = 1 and sub-cod.ccode = "514")) then do:
                  find last histrxbal where histrxbal.sub = 'arp' and histrxbal.acc = arp.arp and histrxbal.dt < fdt no-lock no-error.
                  v-bal2 = histrxbal.dam - histrxbal.cam.
                  v-arp = arp.arp.
              end.
        end.
        /*if v-arp = "" then message "Не найден счет кассы в пути для валюты " crc.code " !" view-as alert-box.  */
        /*посчитаем кассу в пути на конец периода*/
         v-end2 = v-bal2.

         find last caspoint where  caspoint.depart = v-depart and caspoint.rdt < fdt and caspoint.crc = crc.crc and caspoint.info[1] = string(vgl) no-lock no-error.
         if avail caspoint then do:
            v-bal1 = caspoint.amount.
         end.

         if v-arp = "" and v-bal1 = 0 then next.
         for each b-jl where b-jl.jdt = fdt and b-jl.acc = v-arp and v-arp ne "" no-lock.
              v-end2 = v-end2 + b-jl.dam - b-jl.cam.
         end.


   vtitle = ppoint.name + ".   Обороты по кассе за :" + string(fdt) .
   vtitle3 = " ВАЛЮТА   - " + caps(crc.des).

   {rep.i 132 "vtitle2 fill(""="",132) format ""x(132)"" "}

   if v-sel = '1' then do:
         display   v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100100 "  skip
                   v-bal2 label "БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200 " with width 122 side-label frame gl.
   end.
   else do:
         display   v-bal1 label "НАЛИЧНОСТЬ В ХРАНИЛИЩЕ   - 100110 "  with width 122 side-label frame gl1.
   end.

  for each jl no-lock where jl.jdt = fdt  and  jl.gl eq vgl and  jl.crc eq crc.crc  use-index jdt
          ,each gl no-lock where gl.gl eq jl.gl
          ,jh no-lock where jh.jh eq jl.jh  break by gl.gl by jl.jdt by jl.cam by jl.dam by jl.jh :

      find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.
      if ofchis.depart = v-depart then do:

             v-rem = trim(jl.rem[1] + jl.rem[2]).
             v-nom = v-nom + 1.
             v-tim = string(jh.tim,"HH:MM") .
             display jl.jh jl.dam jl.cam v-rem jl.who v-tim jl.teller  with frame detail.
             down 1 with frame detail.

             v-bal1 = v-bal1 + jl.dam - jl.cam.
             accumulate jl.dam (total by jl.jdt)  jl.cam (total by jl.jdt).
      end. /* ofchis */

      if last-of (jl.jdt) then do:
          underline jl.dam jl.cam with frame detail.
          down 1 with frame detail.
          display accum sub-total by jl.jdt jl.dam @ jl.dam  format "z,zzz,zzz,zz9.99"  accum sub-total by jl.jdt jl.cam @ jl.cam  format "z,zzz,zzz,zz9.99" with frame detail.
          down 2 with frame detail.
      end.

  end. /* for each jl */



   if v-sel = '1' then do:
          display v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100100 "  at 40  skip
                  v-end2 label "БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200 "  at 40  skip with side-label frame bal.
   end.
   else do:
          display v-bal1 label "НАЛИЧНОСТЬ В ХРАНИЛИЩЕ   - 100110 "  at 40  skip with side-label frame bal1.
   end.

end.  /*for each crc */

{report3.i}
{image3.i}

end.