/* dohrep.p
 * MODULE
        Операционист
 * DESCRIPTION
        Отчет о доходах по коду комиссии
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.14.9
 * AUTHOR
        10.11.04 dpuchkov
 * CHANGES
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        10.12.2004 sasco - исправил поиск платежей
        20.12.2004 dpuchkov - исправил поиск комиссии по коду 433(сделал по главной книге)
        25.08.2006 dpuchkov - оптимизация
*/

{global.i}
{crc-crc.i}
{msg-box.i}

  def var d_date as date                   no-undo.
  def var d_date_fin as date               no-undo.
  def var v_date as date                   no-undo.
  def var file1 as char format "x(20)"     no-undo.
  def var v-tarif as char format "x(3)"    no-undo.
  def var d_sum as decimal                 no-undo.


  file1 = "file1.html". 
  d_date = g-today.
  d_date_fin = g-today.

  update v-tarif    label "Код комиссии" with centered side-label row 9.
  update d_date     label "  Дата с"     with centered side-label row 9.
  update d_date_fin label "по"           with centered side-label row 9.

  find last tarif2 where tarif2.str5 = v-tarif and tarif2.stat = 'r' no-lock no-error.
  if not avail tarif2 then
  do:
     message "Не удалось найти данный код комиссии." .
     return.
  end.

  display "......Ж Д И Т Е ......."  with row 12 frame ww centered. pause 0.

  def var zx as decimal init 0                 no-undo.
  define temp-table tmp field des as char .
  define variable vtar as character initial "" no-undo.

  d_sum = 0.

if tarif2.str5 <> "433" then do:
     for each jl where jl.jdt >= d_date and jl.jdt <= d_date_fin and jl.lev = 1 and not jl.rem[1] begins 'rmz' no-lock:
         if jl.crc <> 1 then next.
         if (not jl.rem[1] matches "*" + tarif2.pakalp + "*") and 
            (not jl.rem[2] matches "*" + tarif2.pakalp + "*") and    
            (not jl.rem[3] matches "*" + tarif2.pakalp + "*") and 
            (not jl.rem[4] matches "*" + tarif2.pakalp + "*") and 
            (not jl.rem[5] matches "*" + tarif2.pakalp + "*") and 
            (not jl.rem[1] begins v-tarif + " -") then next.
            if jl.dc = "d" then do:
               d_sum = d_sum + jl.dam.
            end.
     end.
end.

                                
if tarif2.str5 = "433" then do: /*по сейфовым услугам*/
     for each jl where jl.gl = 460815 and jl.jdt >= d_date and jl.jdt <= d_date_fin and  
        jl.lev = 1  no-lock:
        if jl.crc <> 1 then next.
        if jl.dc = "d" then do:
            d_sum = d_sum + jl.dam.
        end.
        if jl.dc = "c" then do:
            d_sum = d_sum + jl.cam.
        end.
     end.
end.

  hide frame ww.
  hide all.
  pause 0.	

  display "ОБЩАЯ СУММА ДОХОДОВ БАНКА ПО УСЛУГЕ:" tarif2.pakalp skip "СОСТАВЛЯЕТ: " d_sum format '>>>,>>>,>>>,>>9.99-' " тенге" with row 10 centered no-label frame chck title " " overlay top-only.
  pause 1000.
