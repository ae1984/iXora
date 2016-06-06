/* tarch2.p
 * MODULE
        Тарификатор
 * DESCRIPTION
        Отчет по общей сумме оборотов
 * RUN
        9-14-10
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        19/01/05 saltanat
 * CHANGES
        01.04.05 saltanat - Включила выборку по клиентам
        21.05.05 saltanat - Переделала выборку по счетам.
        05.09.05 saltanat - Переделала формирование отчета.
        12.09.05 saltanat - Включила обработку комиссий снимаемых при закрытии дня.
        11.09.06 ten      - оптимизировал.
        15.06.2010 id00004 - ТЗ-632

*/  

{global.i}

def var dt1 as date no-undo.
def var dt2 as date no-undo.
def var v-vubor  as char init '' no-undo.
def var v-vubor1  as char init '*' no-undo.
def var v-vubor2  as char init '' no-undo.
def var v-vubor3  as char init '' no-undo.
def var v-gk  as char init '' no-undo.
def var v-kodkom  as char init '' no-undo.

def buffer bjl for jl.
def var v-sum as deci no-undo.
def var v-opis as char no-undo.
def var v-dt as date no-undo.

def temp-table wt no-undo
    field cif like cif.cif
    field name as char
    field depart as int
    field gl like gl.gl
    field oborot_tg as deci 
    field oborot_us as deci
    field doxod_tg as deci
    field doxod_des as char
    field kod like tarif2.str5
    field tarif_st as char
    field tarif_lg as char
    field tarif_dt as date
    field tarif_ch as char
    index idx is primary cif gl kod.
/*
index idc cif
index idg gl
index ick kod. 
*/
def temp-table wtd no-undo
    field cif like cif.cif
    field sum as deci
    field kod like tarif2.str5
index idc cif.

define frame fr
   skip(1)
   dt1      label 'Начало периода' format '99/99/9999' skip
   dt2      label ' Конец периода' format '99/99/9999' skip
   v-gk     label '       Счет ГК' format 'x(6)' skip
   v-kodkom label '  Код комиссии' format 'x(3)' skip

   v-vubor1 label '       Клиенты' format 'x(50)' help 'Введиты коды через запятую. * - по всем клиентам.' 
   v-vubor2 no-label format 'x(70)' help 'Введиты коды через запятую. * - по всем клиентам.'
   v-vubor3 no-label format 'x(70)' help 'Введиты коды через запятую. * - по всем клиентам.' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА". 

dt1 = g-today. dt2 = g-today.

update dt1 dt2 v-gk v-kodkom v-vubor1 v-vubor2 v-vubor3 with frame fr.
hide frame fr.

v-vubor = v-vubor1 + v-vubor2 + v-vubor3.
do v-dt = dt1 to dt2:
   for each jl where jl.jdt = v-dt and jl.dc = 'c' no-lock:
if v-gk <> "" then do:
   if jl.gl <> integer(v-gk) then do:
      next.
   end.
end.


/* if jl.jh <> 124722 then next. */


       find first tarif2 where tarif2.kont = jl.gl and tarif2.stat = 'r' no-lock no-error.      
       if not avail tarif2 then next.

       /* определяем дебетовую часть комиссии */
       find first bjl where bjl.jh = jl.jh 
                     and bjl.dc = 'd'
                     and bjl.dam = jl.cam
                     and bjl.cam = jl.dam
                     and bjl.ln = jl.ln - 1 no-lock no-error.
       if not avail bjl or bjl.acc = '' then next.
       find aaa where aaa.aaa = bjl.acc no-lock no-error.
       if not avail aaa then next.

       find cif where cif.cif = aaa.cif no-lock no-error.
       if not avail cif then next.

       if v-vubor ne '*' and lookup(aaa.cif,v-vubor) = 0 then next.

/*       find first tarifex where tarifex.cif = aaa.cif and tarifex.stat = 'r' no-lock no-error.
         if not avail tarifex then next.  */
    
       v-opis = trim(jl.rem[1]) + trim(jl.rem[2]) + trim(jl.rem[3]) + trim(jl.rem[4]) + trim(jl.rem[5]).    
       find first tarif2 where tarif2.kont = jl.gl and tarif2.stat = 'r' and tarif2.pakalp matches "*" + trim(v-opis) + "*" no-lock no-error.
       if not avail tarif2 then do:

          find first tarif2 where tarif2.kont = jl.gl and tarif2.stat = 'r' and v-opis matches "*" + trim(tarif2.pakalp) + "*" no-lock no-error. 

/* find first tarif2 where tarif2.kont = 461110 and tarif2.stat = 'r' and "409 - За обмен б\н на нал(ЮЛ) б/НДС" matches "*" + tarif2.pakalp + "*" no-lock. */
if v-opis = "409 - За обмен б\н на нал(ЮЛ) б/НДС" then pause 4444.

       end.
       if not avail tarif2 then next.

if v-kodkom <> "" then do:
   if tarif2.str5 <> v-kodkom then do:

      next.
   end.
end.

         
       find first tarifex where tarifex.cif = aaa.cif and tarifex.kont = jl.gl and tarifex.stat = 'r' and tarifex.pakalp matches "*" + v-opis + "*" no-lock no-error.
       if not avail tarifex then 
       find first tarifex where tarifex.cif = aaa.cif and tarifex.kont = jl.gl and tarifex.stat = 'r' and v-opis matches "*" + tarifex.pakalp + "*" no-lock no-error.

       /* определяем другие линии */ 
       
       if v-opis begins 'RMZ' then 
          find first wt where wt.cif = aaa.cif and wt.gl = jl.gl and wt.kod = tarif2.str5 and wt.doxod_des begins 'RMZ' no-lock no-error.
       else
          find first wt where wt.cif = aaa.cif and wt.gl = jl.gl and wt.kod = tarif2.str5 /*and wt.doxod_des = jl.rem[1]*/ no-lock no-error.
       
       if not avail wt then do:  
          create wt.
          assign wt.cif = aaa.cif
    	         wt.name = cif.name
                 wt.gl  = jl.gl 
                 wt.doxod_des = v-opis
                 wt.depart = integer(cif.jame) mod 1000.
	         wt.kod = tarif2.str5.
	         wt.tarif_st = if tarif2.ost ne 0 then string(tarif2.ost) else (string(tarif2.proc,'zz9.99') + '%').
	      if wt.doxod_des = '' then wt.doxod_des = tarif2.pakalp.
              if avail tarifex then do:
	         wt.tarif_lg = if tarifex.ost ne 0 then string(tarifex.ost) else (string(tarifex.proc,'zz9.99') + '%').
	         wt.tarif_dt = tarifex.whn.
	      end.   
	      else wt.tarif_lg = ''.   
       end.      
         
       find last crchis where crchis.crc = jl.crc and crchis.rdt le jl.jdt no-lock no-error.
       if avail crchis then wt.doxod_tg  = wt.doxod_tg + jl.cam * crchis.rate[1]. 

       v-sum = 0.
       /* Определим оборот клиента */
       find first bjl where bjl.jh = jl.jh and bjl.dc = 'c' and ((bjl.gl ne jl.gl) or (bjl.cam ne jl.cam)) no-lock no-error.
       if avail bjl then do: 
          if avail tarifex then do:
             if tarifex.proc ne 0 then wt.oborot_tg = wt.doxod_tg * 100 / tarifex.proc.
             else do:   
                  find last crchis where crchis.crc = bjl.crc and crchis.rdt le bjl.jdt no-lock no-error.
                  if avail crchis then wt.oborot_tg = wt.oborot_tg + bjl.cam * crchis.rate[1]. 
             end.
          end.
          else do:
               if tarif2.proc ne 0 then wt.oborot_tg = wt.doxod_tg * 100 / tarif2.proc. 	        
               else do:   
                    find last crchis where crchis.crc = bjl.crc and crchis.rdt le bjl.jdt no-lock no-error.
		    if avail crchis then wt.oborot_tg = wt.oborot_tg + bjl.cam * crchis.rate[1]. 
               end.	
          end.          
       end. /* for bjl */               
       else wt.oborot_tg = 0.
   end.
end.

{tarch_dcls17.i}

for each wt where wt.oborot_tg = 0:
    find first wt2 where wt2.cif = wt.cif and wt2.kod = wt.kod no-error.
    if avail wt2 then do:
       wt.oborot_tg = wt2.amt.
    end.
end.



output to value("Cl_Turnover" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".csv").

put unformatted
    "ОТЧЕТ ПО ОБЩЕЙ СУММЕ ОБОРОТОВ ПО КЛИЕНТАМ ." skip.
put unformatted "За период с " dt1 " по " dt2 "." skip(1).

put unformatted '---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip.

put unformatted 'Счет ГК ; Наименование ГК ; Оборот в тг. ; Доходность по услуге ; Описание комиссии ; Код комиссии ; Стан.тариф ; Льгот.тариф ; Дата установления льготного тарифа' skip.
put unformatted '---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip.

for each wt break by wt.depart by wt.cif by wt.gl:

if first-of(wt.depart) then do:
	put unformatted 		'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip.
    find first ppoint where ppoint.depart = wt.depart no-lock no-error.
    put unformatted ppoint.name skip.
       /*"<TR align=""center"">" skip
        "<TD colspan=""11""><FONT size=""2""><B>" ppoint.name "</B></FONT></TD>" skip
       "</TR>" skip.*/
	put unformatted 		'---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' skip.
end.

if first-of (wt.cif) then 
   put unformatted "По клиенту " wt.cif " " wt.name skip. 

find first tarif2 where tarif2.str5 = wt.kod no-lock no-error.
find first tarifex where tarifex.str5 = wt.kod and tarifex.cif = wt.cif no-lock no-error.
find first gl where gl.gl = wt.gl no-lock no-error.

put unformatted
        wt.gl " ; " 
        gl.des " ; "
        replace(string(wt.oborot_tg, 'zzzzzzzzzzzzzz9.99'),'.',',') " ; "
        replace(string(wt.doxod_tg, 'zzzzzzzzzzzzzz9.99'),'.',',') " ; " 
        wt.doxod_des " ; " 
        '''' wt.kod " ; " 
        wt.tarif_st " ; " 
        wt.tarif_lg " ; " 
        if wt.tarif_dt = ? then '' else string(wt.tarif_dt,'99/99/9999') skip. 

accumulate wt.oborot_tg (total by wt.cif) wt.oborot_us (total by wt.cif) wt.doxod_tg (total by wt.cif).

if last-of (wt.cif) then
   put unformatted 'Итого ; ; ' replace(string(accum total by wt.cif wt.oborot_tg, 'zzzzzzzzzzzzzz9.99'),'.',',') " ; "
                                replace(string(accum total by wt.cif wt.doxod_tg, 'zzzzzzzzzzzzzz9.99'),'.',',') skip(1).
   
end.

put unformatted "========================================================= FINISH ==============================================================="  skip.
output close.   

unix silent cptwin value("Cl_Turnover" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + ".csv") excel.
