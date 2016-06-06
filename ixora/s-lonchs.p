/* s-lonchs.p
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
        17/10/02 Пролонгация
        30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
        02/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        25.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        14/04/2004 madiar  - исправил: программа не показывала активные кредиты, если долг был на других уровнях кроме первого.
        26/10/2004 madiar  - при неправильном вводе кода клиента F4 не работало, исправил
        30/05/2005 madiar  - убрал лишние exclusive-lock'и на loncon
        30/01/2006 Natalya D. - добавлено поле Депозит
        04/05/06 marinav Увеличить размерность поля суммы
        12/12/2008 galina - перекомпиляция
                            убрала краказябрину перед наименованием клиента
        25/03/2009 galina - добавила поле Поручител
        23.04.2009 galina - убираем поле поручитель
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме, перекомпиляция
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        08/11/2011 madiyar - доп. поля в списке кредитов, оптимизировал выборку
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        11.01.2013 evseev - ТЗ-1530
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
*/

{lonlev.i}
define shared variable g-today as date.
define variable visi as logical.
define variable v-uno  like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.
define variable ok as logical.
define shared variable s-prem as character.
define shared variable d-prem as character.
define  shared variable s-lon    like lon.lon.
define  shared variable s-cat as character.
define  shared variable s-apr as character.
define  shared variable s-longrp like longrp.longrp.
define  shared variable grp-name as character.
define  shared variable crc-code as character.
define  shared variable cat-des  as character.
define  shared variable v-cif    like cif.cif.
define  shared variable v-lcnt   like loncon.lcnt.
define  shared variable v-vards  like cif.name format "x(36)".

def   shared var v-crc like crc.crc.
def   shared var v-rate like crc.rate[1].
def   shared var v-komcl as deci .

def buffer b-cif for cif.
def buffer b-lon for lon.

def var ost_act as deci init 0.
def var actcr as logical.

{s-lonrdl.f}.
define shared variable gs-cif like cif.cif.

if s-lon = "1" then visi = no.
               else visi = yes.

v-cif = gs-cif.
repeat on error undo,retry:
   if keyfunction(lastkey) = "END-ERROR" then leave.
   display v-cif with frame lon.
   update v-cif go-on("PF3" /*"PF4"*/) with frame lon.
   if lastkey = keycode("PF4") then leave.
   if lastkey = keycode("PF3") then do:
        visi = not visi.
        next.
   end.
   if length(trim(v-cif)) = 0 then repeat:
        /*display v-lcnt v-guarantor with frame lon.*/
        update v-lcnt go-on("PF3" "PF4") with frame lon.
        if lastkey = keycode("PF4") then leave.
        if lastkey = keycode("PF3") then do:
             visi = not visi.
             next.
        end.
        if length(trim(v-lcnt)) > 0
        then find first loncon where loncon.lcnt = v-lcnt /**exclusive**/ no-lock.
        else repeat:
             prompt loncon.lon go-on("PF3" "PF4") with frame lon.
             if lastkey = keycode("PF4") then leave.
             if lastkey = keycode("PF3") then do:
                  visi = not visi.
                  next.
             end.
             find loncon where loncon.lon = input frame lon loncon.lon no-lock /**exclusive-lock**/ no-error.
             if not available loncon then do:
                  bell.
                  undo,retry.
             end.
             leave.
        end.
        if lastkey = keycode("PF4") then leave.
        v-cif = loncon.cif.
        leave.
   end.
   if lastkey = keycode("PF4") then leave.
   find cif where cif.cif = v-cif no-lock.
   gs-cif = cif.cif.
   v-vards = trim(trim(cif.prefix) + " " + trim(cif.name)).
   display v-cif /* v-vards */ with frame lon.
   display v-vards with frame cif.
   leave.
end.
if lastkey = keycode("PF4")
then return.
if visi
then find first lon where lon.cif = v-cif no-lock no-error.
else do:
     /* find first lon where lon.cif = v-cif and
          (lon.dam[1] > lon.cam[1]) no-lock no-error. */ /* --- madiar: пропускает кредиты с долгами на уровнях кроме 1-го */

     find first lon where lon.cif = v-cif no-lock no-error.

     if not available lon
     then do:
       bell.
       undo,retry.
     end.
     else do:
       if not (lon.dam[1] > lon.cam[1]) then do:
         run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
         if ost_act = 0 then do:
            actcr = yes.
            repeat while ost_act = 0 and actcr:
              find next lon where lon.cif = v-cif no-lock no-error.
              if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
              else actcr = no.
            end. /* repeat */
         end. /* if ost_act = 0 */
       end.  /* if not (lon.dam[1] > lon.cam[1]) */
     end.

     if not(actcr) then do:
          visi = yes.
          find first lon where lon.cif = v-cif no-lock no-error.
     end.
end.

find loncon  where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
if not available loncon
then do:
     bell.
     undo,retry.
end.
s-lon = loncon.lon.
v-lcnt = loncon.lcnt.
/*galina 25/03/2009*/
/*v-guarantor = trim(loncon.rez-char[8]).
display v-guarantor with frame lon.*/
ok = yes.
readkey pause 0.
repeat:
    if ok
    then display loncon.lon lon.gua lon.rdt with frame ln.
    else ok = yes.
    pause 0.
    if lastkey <> keycode("CURSOR-UP") and lastkey <> keycode("CURSOR-DOWN")
    then do:
         if visi
         then find next lon where lon.cif = v-cif no-lock no-error.
         else do:
            ost_act = 0.
            actcr = yes.
            repeat while ost_act = 0 and actcr:
              find next lon where lon.cif = v-cif no-lock no-error.
              if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
              else actcr = no.
            end. /* repeat */

         end.
         if not available lon then do:
              if visi then find last lon where lon.cif = v-cif no-lock.
              else do:
                find last lon where lon.cif = v-cif no-lock.

                if not (lon.dam[1] > lon.cam[1]) then do:
                   run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).

                   if ost_act = 0 then do:
                     actcr = yes.
                     repeat while ost_act = 0 and actcr:
                       find prev lon where lon.cif = v-cif no-lock no-error.
                       if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
                       else actcr = no.
                     end.  /* repeat */
                   end.  /* if ost_act = 0 */
                end.  /* if not (lon.dam[1] > lon.cam[1]) */

              end.

              find loncon where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
              if not available loncon
              then do:
                   ok = no.
                   next.
              end.
              display loncon.lon lon.gua lon.rdt with frame ln.
              pause 0.

              {s-lonchs.i}.

              choose row loncon.lon go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3") with frame ln.
              pause 0.
              if lastkey <> keycode("RETURN")
              then color display normal loncon.lon lon.gua lon.rdt with frame ln.
         end.
         else do:
              find loncon where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
              if not available loncon
              then do:
                   ok = no.
                   next.
              end.
              down with frame ln.
         end.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
    end.
    if lastkey = keycode("CURSOR-UP") then do:
         if visi then find prev lon where lon.cif = v-cif no-lock no-error.
         else do:
           ost_act = 0.
            actcr = yes.
            repeat while ost_act = 0 and actcr:
              find prev lon where lon.cif = v-cif no-lock no-error.
              if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
              else actcr = no.
            end. /* repeat */
         end.

         if not available lon then do:
              if visi then find first lon where lon.cif = v-cif no-lock.
              else do:
                find first lon where lon.cif = v-cif no-lock.

                if not (lon.dam[1] > lon.cam[1]) then do:
                   ost_act = 0.

                   run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).

                   if ost_act = 0 then do:
                     actcr = yes.
                     repeat while ost_act = 0 and actcr:
                       find next lon where lon.cif = v-cif no-lock no-error.
                       if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
                       else actcr = no.
                     end.  /* repeat */
                   end.  /* if ost_act = 0 */
                end.  /* if not (lon.dam[1] > lon.cam[1]) */
              end.

              find loncon where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
              if not available loncon then do:
                   ok = no.
                   next.
              end.
         end.
         else do:
              find loncon where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
              if not available loncon
              then do:
                   ok = no.
                   next.
              end.
              up with frame ln.
         end.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/

         {s-lonchs.i}.

         display loncon.lon lon.gua lon.rdt with frame ln.
         choose row loncon.lon go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3")  with frame ln.
         pause 0.
         if lastkey <> keycode("RETURN") then color display normal loncon.lon lon.gua lon.rdt with frame ln.
    end.
    if lastkey = keycode("CURSOR-DOWN") then do:
         if visi then find next lon where lon.cif = v-cif no-lock no-error.
         else do:
            ost_act = 0.
            actcr = yes.
            repeat while ost_act = 0 and actcr:
              find next lon where lon.cif = v-cif no-lock no-error.
              if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
              else actcr = no.
            end. /* repeat */
         end.

         if not available lon then do:
              if visi then find last lon where lon.cif = v-cif no-lock.
              else do:
                find last lon where lon.cif = v-cif no-lock.

                if not (lon.dam[1] > lon.cam[1]) then do:
                   run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
                   if ost_act = 0 then do:
                     actcr = yes.
                     repeat while ost_act = 0 and actcr:
                       find prev lon where lon.cif = v-cif no-lock no-error.
                       if avail lon then run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output ost_act).
                       else actcr = no.
                     end.  /* repeat */
                   end.  /* if ost_act = 0 */
                end.  /* if not (lon.dam[1] > lon.cam[1]) */
              end.
         end.
         else down with frame ln.
         find loncon where loncon.lon  = lon.lon /*exclusive*/ no-lock no-error.
         if not available loncon then do:
              ok = no.
              next.
         end.
         s-lon = loncon.lon.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
         {s-lonchs.i}.

         display loncon.lon lon.gua lon.rdt with frame ln.
         choose row loncon.lon go-on("CURSOR-UP" "CURSOR-DOWN" "RETURN" "PF3") with frame ln.
         if lastkey <> keycode("RETURN") then color display normal loncon.lon lon.gua lon.rdt with frame ln.
         pause 0.
    end.
    if lastkey = keycode("PF3") then do:
         pause 0.
         clear frame ln all.
         visi = not visi.
         if visi then find first lon where lon.cif = v-cif no-lock no-error.
         else find first lon where lon.cif = v-cif and (lon.dam[1] > lon.cam[1]) no-lock no-error.
         find loncon where loncon.lon = lon.lon /*exclusive*/ no-lock no-error.
         if not available loncon then do:
              ok = no.
              next.
         end.
         v-lcnt = loncon.lcnt.
         /*v-guarantor = trim(loncon.rez-char[8]).*/
         s-lon = lon.lon.
         readkey pause 0.
    end.
    if lastkey = keycode("RETURN") or lastkey = keycode("PF1") then do:
          hide frame ln.
          run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output dam1-cam1).
          if index(loncon.rez-char[10],"&") > 0 or lon.opnamt > 0 and lon.opnamt - lon.dam[1] <= 0
          then do:
               if index(loncon.rez-char[10],"&") > 0 then do:
                    if substring(loncon.rez-char[10], index(loncon.rez-char[10],"&") + 1,3) = "yes"
                    then paraksts = yes.
                    else paraksts = no.
               end.
               else do:
                    paraksts = yes.
                    find current loncon exclusive-lock.
                    loncon.rez-char[10] = "&yes&".
                    find current loncon no-lock.
               end.
          end.
          else paraksts = no.

          display v-vards with frame cif.
          v-uno = lon.prnmos.
          v-deposit = loncon.deposit.
          display /* v-vards */
                  v-cif v-lcnt loncon.lon s-longrp v-uno lon.crc crc-code lon.gua loncon.lcntsub lon.clmain clcif clname loncon.objekts
                  lon.rdt lon.duedt lon.duedt15 lon.duedt35 lon.opnamt dam1-cam1 s-prem d-prem /** lon.lcr **/ loncon.proc-no loncon.sods1
                  lon.idt15 lon.idt35 paraksts loncon.vad-amats loncon.vad-vards loncon.galv-gram loncon.rez-char[9]
/**                  loncon.kods
                  loncon.konts
                  loncon.talr **/
                  lon.basedy  /*v-crc v-rate*/ lon.plan lon.day lon.aaa lon.aaad v-deposit loncon.who /*v-guarantor*/
                  loncon.lcntdop loncon.dtdop loncon.dtsub loncon.obes-pier
                with frame lon.
         /*31/01/04 nataly*/
          find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 no-lock no-error.
          if avail lonhar then do:
            v-crc = lonhar.rez-int[1].
            v-rate = lonhar.rez-dec[1].
            v-komcl = lonhar.rez-dec[2].
          end.
          display v-crc v-rate v-komcl with frame lon.

          color display input dam1-cam1 with frame lon.
          return.
    end.
end.
/*------------------------------------------------------------------------------
   #3.
      1.izmai‡a - jaunin–jums:atlikums tiek r–dЁts uz ekr–na un izdalЁts

-----------------------------------------------------------------------------*/
