/* plateg.p * MODULE
        Платежная система
 * DESCRIPTION
        Отчет по подразделениям  
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
          5-11-16
 * AUTHOR
        29.07.2003 tsoy
 * CHANGES
        09.08.2004 tsoy Пенсионные платежи без открытия счета беру из таблицы p_f_payment
        11.08.2004 tsoy Отделил пенсионные по Гроссу, теперь итого Гросс = Гросс + пенсионные
        11.08.2004 tsoy Изменил расчет чистого клиринга 
        05.01.2005 saltanat Дополнила отчет по требованиям Т/З ї1287.
        13.12.2005 saltanat - доработка по требованиям Т/З ї1287.
        02.03.2005 saltanat - Расчет интернет платежей на филиалах расчитывается через plateg_txb.p
        10.11.2005 saltanat - Добавлено в расчет платежи по корр.отношениям
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/


{global.i}
{get-dep.i}
{deparp_pmp.i}
{comm-txb.i}

def stream v-out.
output stream v-out to plateg.html.
def var v-dtb as date.
def var v-dte as date.
def var v-076 as char init "". /*"000076449,004076704,008076108,006076906,005076305,020076720,007076701,009076709,016076116,014076914,011076111,013076313,022076922,024076124,000076452,023076523,021076523,021076321,015076515,000076148,000076850,000076177,015076515,018076318,017076717,026076326".*/
def var v-com-arp as char init "". /*"000904883,000904786,000076960,000076449,025076725,026076326,027076927,028076528,000076151,020076720,024076124,016076116,017076717,018076318,019076919,021076321,022076922,023076523,000076148,000076850,004076704,005076305,009076709,007076701,008076108,006076906,011076111,013076313,014076914,015076515,000076261,001076668,010904006,010904705,010904514,010904815,010904417,010904608,010904307,010904213,010904404,010904103,010904116,010904802,000076672,000076575,000076562,010904718,0000904184,0000904074,498904301".*/

def var v_to_pens_s  as deci.
def var v_to_pens_n  as deci.

def var v_to_sos_s  as deci.
def var v_to_sos_n  as deci.

def var v_to_cl_s    as deci.
def var v_to_cl_n   as deci.

def var v_to_gr_s    as deci.
def var v_to_gr_n    as deci.

def var v_to_076_s    as deci.
def var v_to_076_n    as deci.

def var v_to_076s_s    as deci.
def var v_to_076s_n    as deci.

define temp-table tcommonpl like commonpl
       field dep as integer
       field account as char.

def var v-knp as char init '012,017'.
def var v-ibhkol_cl as inte.
def var v-ibhsum_cl as deci.
def var v-ibhkol_gr as inte.
def var v-ibhsum_gr as deci.

update 
  v-dtb label " Начальная дата" skip
  v-dte label " Конечная дата "
  with centered side-label row 5 frame f-dt.

def temp-table t-data
  field dep        as integer
  field clr-n      as inte /* Клиринг */
  field clr-s      as deci
  field gro-n      as inte /* Гросс */
  field gro-s      as deci
  field pens-n     as inte /* пенсионные платежи */
  field pens-s     as deci
  field pens-fiz-n as inte 
  field pens-fiz-s as deci
  field pens-ur-n  as inte
  field pens-ur-s  as deci
  field sos-n     as inte /* социальные платежи */
  field sos-s     as deci
  field sos-fiz-n as inte 
  field sos-fiz-s as deci
  field sos-ur-n  as inte
  field sos-ur-s  as deci
  field tax-gr-n   as inte /* налоговые платежи */
  field tax-gr-s   as deci
  field tax-cl-n   as inte
  field tax-cl-s   as deci
  field ibh-gr-n   as inte /* интернет платежи */
  field ibh-gr-s   as deci
  field ibh-cl-n   as inte
  field ibh-cl-s   as deci
  field scn-gr-n   as inte /* платежи со штрих-кодами */
  field scn-gr-s   as deci
  field scn-cl-n   as inte
  field scn-cl-s   as deci
  field tam-gr-n   as inte /* платежи Таможенные */
  field tam-gr-s   as deci
  field tam-cl-n   as inte
  field tam-cl-s   as deci
  field als-gr-n   as inte /* платежи Алсеко */
  field als-gr-s   as deci
  field als-cl-n   as inte
  field als-cl-s   as deci
  field ivs-gr-n   as inte /* платежи ИВЦ */
  field ivs-gr-s   as deci
  field ivs-cl-n   as inte
  field ivs-cl-s   as deci
  field pro-gr-n   as inte /* прочие платежи */
  field pro-gr-s   as deci
  field pro-cl-n   as inte
  field pro-cl-s   as deci
index main is primary dep.

def buffer b-t-data for t-data.

def var i     as integer.
def var v-dep as integer.


def var seltxb as int.
seltxb = comm-cod().

for each commonls no-lock where commonls.txb = seltxb break by commonls.arp:
if first-of(commonls.arp) and commonls.arp <> ""
then do: 
   if v-com-arp = '' then v-com-arp = commonls.arp.
   else v-com-arp = v-com-arp + ',' + commonls.arp.
end. 
end.

for each clrdog where clrdog.rdt >= v-dtb and clrdog.rdt <= v-dte no-lock:
  find remtrz where remtrz.remtrz = clrdog.rem no-lock no-error.

  if not avail remtrz then do: 
    /*displ clrdog.rem clrdog.amt.*/
    next.
  end.

  case remtrz.source :
    when "IBH" then do:
      find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
      find cif where cif.cif = aaa.cif no-lock no-error.
      v-dep = integer(cif.jame) mod 1000.
      find t-data where t-data.dep = v-dep no-error.
      if not avail t-data then do:
         create t-data.
         t-data.dep = v-dep.
      end.
      t-data.ibh-gr-n = t-data.ibh-gr-n + 1.
      t-data.ibh-gr-s = t-data.ibh-gr-s + clrdog.amt.
    end.
    when "SCN" then do:
       /* Платежи со штрих-кодами */
      find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
      if not avail ofchis then do:
         displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
      end.
      else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
      find t-data where t-data.dep = v-dep no-error.
      if not avail t-data then do:
         create t-data.
         t-data.dep = v-dep.
      end.
      t-data.scn-gr-n = t-data.scn-gr-n + 1.
      t-data.scn-gr-s = t-data.scn-gr-s + clrdog.amt.
    end.
    otherwise do:
      if remtrz.source = "A" then v-dep = 1000 + integer(substr(remtrz.sbank, 4, 2)).
      else do:
           if remtrz.source = "PRR" then do:
		  if lookup(remtrz.dracc,v-com-arp) > 0 then do:
		        v-dep = 1.
		        case remtrz.dracc :
		             when "000076261" then do:
				      find t-data where t-data.dep = v-dep no-error.
				      if not avail t-data then do:
					 create t-data.
				         t-data.dep = v-dep.
				      end.
			              t-data.tam-gr-n = t-data.tam-gr-n + 1.
			              t-data.tam-gr-s = t-data.tam-gr-s + clrdog.amt.
                                   end. 
		             when "000904786" then do:
				      find t-data where t-data.dep = v-dep no-error.
				      if not avail t-data then do:
					 create t-data.
				         t-data.dep = v-dep.
				      end.
			              t-data.als-gr-n = t-data.als-gr-n + 1.
			              t-data.als-gr-s = t-data.als-gr-s + clrdog.amt.
                                   end. 
		             when "000904883" then do:
				      find t-data where t-data.dep = v-dep no-error.
				      if not avail t-data then do:
					 create t-data.
				         t-data.dep = v-dep.
				      end.
			              t-data.ivs-gr-n = t-data.ivs-gr-n + 1.
			              t-data.ivs-gr-s = t-data.ivs-gr-s + clrdog.amt.
                                   end. 
		             otherwise do:
				      find t-data where t-data.dep = v-dep no-error.
				      if not avail t-data then do:
					 create t-data.
				         t-data.dep = v-dep.
				      end.
			              t-data.pro-gr-n = t-data.pro-gr-n + 1.
			              t-data.pro-gr-s = t-data.pro-gr-s + clrdog.amt.
		             end.
		        end case.
	        
		  end.  
		  else v-dep = 900.
	   end.
           else do:
                find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
	        if not avail ofchis then do:
	           displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
	        end.
	        else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
           end.
      end.
    end. /* otherwise */
  end. /* case */

  find t-data where t-data.dep = v-dep no-error.
  if not avail t-data then do:
    create t-data.
    t-data.dep = v-dep.
  end.
  t-data.gro-n = t-data.gro-n + 1.
  t-data.gro-s = t-data.gro-s + clrdog.amt.

end.

for each clrdoc where clrdoc.rdt >= v-dtb and clrdoc.rdt <= v-dte no-lock:
  find remtrz where remtrz.remtrz = clrdoc.rem no-lock no-error.

  if not avail remtrz then do:
    /*displ clrdoc.rem clrdoc.amt.*/
    next.
  end.


  case remtrz.source :
    when "IBH" then do:
      find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
      find cif where cif.cif = aaa.cif no-lock no-error.
      v-dep = integer(cif.jame) mod 1000.
      find t-data where t-data.dep = v-dep no-error.
      if not avail t-data then do:
         create t-data.
         t-data.dep = v-dep.
      end.
      t-data.ibh-cl-n = t-data.ibh-cl-n + 1.
      t-data.ibh-cl-s = t-data.ibh-cl-s + clrdoc.amt.
    end.
    when "SCN" then do:
       /* Платежи со штрих-кодами */
      find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
      if not avail ofchis then do:
         displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
      end.
      else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
      find t-data where t-data.dep = v-dep no-error.
      if not avail t-data then do:
         create t-data.
         t-data.dep = v-dep.
      end.
      t-data.scn-cl-n = t-data.scn-cl-n + 1.
      t-data.scn-cl-s = t-data.scn-cl-s + clrdoc.amt.
    end.
    otherwise do:
      if remtrz.source = "A" then v-dep = 1000 + integer(substr(remtrz.sbank, 4, 2)).
      else do:
           if remtrz.source = "PRR" then do: 

              /* Коммунальные платежи */

              if lookup(remtrz.dracc,v-com-arp) > 0 then do:
                    v-dep = 1.
                    case remtrz.dracc :
                         when "000076261" then do:
            				      find t-data where t-data.dep = v-dep no-error.
            				      if not avail t-data then do:
            					 create t-data.
            				         t-data.dep = v-dep.
            				      end.
            			              t-data.tam-cl-n = t-data.tam-cl-n + 1.
            			              t-data.tam-cl-s = t-data.tam-cl-s + clrdoc.amt.
                                               end. 
                         when "000904786" then do:
            				      find t-data where t-data.dep = v-dep no-error.
            				      if not avail t-data then do:
            					 create t-data.
            				         t-data.dep = v-dep.
            				      end.
            			              t-data.als-cl-n = t-data.als-cl-n + 1.
            			              t-data.als-cl-s = t-data.als-cl-s + clrdoc.amt.
                                               end. 
                         when "000904883" then do:
            				      find t-data where t-data.dep = v-dep no-error.
            				      if not avail t-data then do:
            					 create t-data.
            				         t-data.dep = v-dep.
            				      end.
            			              t-data.ivs-cl-n = t-data.ivs-cl-n + 1.
            			              t-data.ivs-cl-s = t-data.ivs-cl-s + clrdoc.amt.
                                               end. 
                         otherwise do:
            		      find t-data where t-data.dep = v-dep no-error.
            		      if not avail t-data then do:
            			 create t-data.
            		         t-data.dep = v-dep.
            		      end.
            	              t-data.pro-cl-n = t-data.pro-cl-n + 1.
            	              t-data.pro-cl-s = t-data.pro-cl-s + clrdoc.amt.
                         end.
                    end case.
                    
              end.  
              else v-dep = 900.
           end.
           else do:
                find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
	        if not avail ofchis then do:
	           displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
	        end.
	        else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
           end.
      end.
    end.
  end.


  find t-data where t-data.dep = v-dep no-error.
  if not avail t-data then do:
    create t-data.
    t-data.dep = v-dep.
  end.
  t-data.clr-n = t-data.clr-n + 1.
  t-data.clr-s = t-data.clr-s + clrdoc.amt.

end.

for each clrdir where clrdir.rdt >= v-dtb and clrdir.rdt <= v-dte no-lock:
  find remtrz where remtrz.remtrz = clrdir.rem no-lock no-error.

  if not avail remtrz then next.


  if remtrz.cover = 1 then do:
     /* CLIRING */

     case remtrz.source :
       when "IBH" then do:
         find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
         find cif where cif.cif = aaa.cif no-lock no-error.
         v-dep = integer(cif.jame) mod 1000.
         find t-data where t-data.dep = v-dep no-error.
         if not avail t-data then do:
            create t-data.
            t-data.dep = v-dep.
         end.
         t-data.ibh-cl-n = t-data.ibh-cl-n + 1.
         t-data.ibh-cl-s = t-data.ibh-cl-s + clrdir.amt.
       end.
       when "SCN" then do:
          /* Платежи со штрих-кодами */
         find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
         if not avail ofchis then do:
            displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
         end.
         else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
         find t-data where t-data.dep = v-dep no-error.
         if not avail t-data then do:
            create t-data.
            t-data.dep = v-dep.
         end.
         t-data.scn-cl-n = t-data.scn-cl-n + 1.
         t-data.scn-cl-s = t-data.scn-cl-s + clrdir.amt.
       end.
       otherwise do:
         if remtrz.source = "A" then v-dep = 1000 + integer(substr(remtrz.sbank, 4, 2)).
         else do:
              if remtrz.source = "PRR" then do: 

                 /* Коммунальные платежи */

                 if lookup(remtrz.dracc,v-com-arp) > 0 then do:
                       v-dep = 1.
                       case remtrz.dracc :
                            when "000076261" then do:
               				      find t-data where t-data.dep = v-dep no-error.
               				      if not avail t-data then do:
               					 create t-data.
               				         t-data.dep = v-dep.
               				      end.
               			              t-data.tam-cl-n = t-data.tam-cl-n + 1.
               			              t-data.tam-cl-s = t-data.tam-cl-s + clrdir.amt.
                                                  end. 
                            when "000904786" then do:
               				      find t-data where t-data.dep = v-dep no-error.
               				      if not avail t-data then do:
               					 create t-data.
               				         t-data.dep = v-dep.
               				      end.
               			              t-data.als-cl-n = t-data.als-cl-n + 1.
               			              t-data.als-cl-s = t-data.als-cl-s + clrdir.amt.
                                                  end. 
                            when "000904883" then do:
               				      find t-data where t-data.dep = v-dep no-error.
               				      if not avail t-data then do:
               					 create t-data.
               				         t-data.dep = v-dep.
               				      end.
               			              t-data.ivs-cl-n = t-data.ivs-cl-n + 1.
               			              t-data.ivs-cl-s = t-data.ivs-cl-s + clrdir.amt.
                                                  end. 
                            otherwise do:
               		      find t-data where t-data.dep = v-dep no-error.
               		      if not avail t-data then do:
               			 create t-data.
               		         t-data.dep = v-dep.
               		      end.
               	              t-data.pro-cl-n = t-data.pro-cl-n + 1.
               	              t-data.pro-cl-s = t-data.pro-cl-s + clrdir.amt.
                            end.
                       end case.
                       
                 end.  
                 else v-dep = 900.
              end.
              else do:
                   find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
   	        if not avail ofchis then do:
   	           displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
   	        end.
   	        else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
              end.
         end.
       end.
     end.


     find t-data where t-data.dep = v-dep no-error.
     if not avail t-data then do:
       create t-data.
       t-data.dep = v-dep.
     end.
     t-data.clr-n = t-data.clr-n + 1.
     t-data.clr-s = t-data.clr-s + clrdir.amt.

  end.
  else if remtrz.cover = 2 then do:
    /* GROSS */
  
    case remtrz.source :
      when "IBH" then do:
        find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
        find cif where cif.cif = aaa.cif no-lock no-error.
        v-dep = integer(cif.jame) mod 1000.
        find t-data where t-data.dep = v-dep no-error.
        if not avail t-data then do:
           create t-data.
           t-data.dep = v-dep.
        end.
        t-data.ibh-gr-n = t-data.ibh-gr-n + 1.
        t-data.ibh-gr-s = t-data.ibh-gr-s + clrdir.amt.
      end.
      when "SCN" then do:
         /* Платежи со штрих-кодами */
        find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
        if not avail ofchis then do:
           displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
        end.
        else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
        find t-data where t-data.dep = v-dep no-error.
        if not avail t-data then do:
           create t-data.
           t-data.dep = v-dep.
        end.
        t-data.scn-gr-n = t-data.scn-gr-n + 1.
        t-data.scn-gr-s = t-data.scn-gr-s + clrdir.amt.
      end.
      otherwise do:
        if remtrz.source = "A" then v-dep = 1000 + integer(substr(remtrz.sbank, 4, 2)).
        else do:
             if remtrz.source = "PRR" then do:
  		  if lookup(remtrz.dracc,v-com-arp) > 0 then do:
  		        v-dep = 1.
  		        case remtrz.dracc :
  		             when "000076261" then do:
  				      find t-data where t-data.dep = v-dep no-error.
  				      if not avail t-data then do:
  					 create t-data.
  				         t-data.dep = v-dep.
  				      end.
  			              t-data.tam-gr-n = t-data.tam-gr-n + 1.
  			              t-data.tam-gr-s = t-data.tam-gr-s + clrdir.amt.
                                     end. 
  		             when "000904786" then do:
  				      find t-data where t-data.dep = v-dep no-error.
  				      if not avail t-data then do:
  					 create t-data.
  				         t-data.dep = v-dep.
  				      end.
  			              t-data.als-gr-n = t-data.als-gr-n + 1.
  			              t-data.als-gr-s = t-data.als-gr-s + clrdir.amt.
                                     end. 
  		             when "000904883" then do:
  				      find t-data where t-data.dep = v-dep no-error.
  				      if not avail t-data then do:
  					 create t-data.
  				         t-data.dep = v-dep.
  				      end.
  			              t-data.ivs-gr-n = t-data.ivs-gr-n + 1.
  			              t-data.ivs-gr-s = t-data.ivs-gr-s + clrdir.amt.
                                     end. 
  		             otherwise do:
  				      find t-data where t-data.dep = v-dep no-error.
  				      if not avail t-data then do:
  					 create t-data.
  				         t-data.dep = v-dep.
  				      end.
  			              t-data.pro-gr-n = t-data.pro-gr-n + 1.
  			              t-data.pro-gr-s = t-data.pro-gr-s + clrdir.amt.
  		             end.
  		        end case.
  	        
  		  end.  
  		  else v-dep = 900.
  	   end.
             else do:
                  find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
  	        if not avail ofchis then do:
  	           displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
  	        end.
  	        else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
             end.
        end.
      end. /* otherwise */
    end. /* case */

    find t-data where t-data.dep = v-dep no-error.
    if not avail t-data then do:
      create t-data.
      t-data.dep = v-dep.
    end.
    t-data.gro-n = t-data.gro-n + 1.
    t-data.gro-s = t-data.gro-s + clrdir.amt.

  end.


end.


for each remtrz where remtrz.rdt >= v-dtb and remtrz.rdt <= v-dte and remtrz.jh2 <> ? no-lock:
  find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
/*  if avail aaa then do:*/
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "eknp" and ccode = "eknp" no-lock no-error.
    if avail sub-cod and num-entries(sub-cod.rcode) = 3 then do:
      i = integer(entry(3, sub-cod.rcode)) no-error.

      
      if not error-status:error and (i = 10 or i = 19 or i = 13 or i = 20 or i = 12 or i = 17) then do:
        case remtrz.source :
          when "A" then v-dep = 1000 + integer(substr(remtrz.sbank, 4, 2)).
          when "IBH" then do:
            find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
            find cif where cif.cif = aaa.cif no-lock no-error.
            v-dep = integer(cif.jame) mod 1000.
          end.
          when "SCN" then do:
            find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
            if not avail ofchis then do:
              displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
            end.
            else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
          end.
          otherwise do:
            if remtrz.source = "PRR" then v-dep = 900.
            else do:
              find last ofchis where ofchis.ofc = remtrz.rwho and ofchis.regdt <= remtrz.rdt no-lock no-error.
              if not avail ofchis then do:
                displ remtrz.remtrz remtrz.source remtrz.sbank remtrz.rwho.
              end.
              else v-dep = get-dep(remtrz.rwho, remtrz.rdt).
            end.
          end.
        end.

        find t-data where t-data.dep = v-dep no-error.
        if not avail t-data then do:
          create t-data.
          t-data.dep = v-dep.
        end.
         
        if i <> 12 and i <> 17 then do:
        
	        t-data.pens-n = t-data.pens-n + 1.
	        t-data.pens-s = t-data.pens-s + remtrz.amt.

    	    if v-dep = 1 then do:
/*                         lookup (remtrz.dracc, v-076 ) > 0  */
	           if not avail aaa  then do:
	               t-data.pens-fiz-n = t-data.pens-fiz-n + 1. 
	               t-data.pens-fiz-s = t-data.pens-fiz-s + remtrz.amt.
	           end. else do:
	               t-data.pens-ur-n = t-data.pens-ur-n + 1.
	               t-data.pens-ur-s = t-data.pens-ur-s + remtrz.amt.
	           end.
    	    end.
        end.
        else do:
            t-data.sos-n = t-data.sos-n + 1.
	        t-data.sos-s = t-data.sos-s + remtrz.amt.
	         if v-dep = 1 then do:
	           if not avail aaa  then do:
	               t-data.sos-fiz-n = t-data.sos-fiz-n + 1. 
	               t-data.sos-fiz-s = t-data.sos-fiz-s + remtrz.amt.
	           end. else do:
	               t-data.sos-ur-n = t-data.sos-ur-n + 1.
	               t-data.sos-ur-s = t-data.sos-ur-s + remtrz.amt.
	           end.
    	    end.
    	end.


      end.
    end.
/*  end. */

end.


find t-data   where t-data.dep = 1 no-error.
find b-t-data where b-t-data.dep = 900 no-error.

if avail t-data and avail b-t-data then do:

      t-data.tax-gr-n  = b-t-data.gro-n.
      t-data.tax-gr-s  = b-t-data.gro-s.
      t-data.tax-cl-n  = b-t-data.clr-n.
      t-data.tax-cl-s  = b-t-data.clr-s.

      t-data.clr-n = t-data.clr-n + t-data.tax-cl-n.
      t-data.clr-s = t-data.clr-s + t-data.tax-cl-s.
end.


for each p_f_payment where txb = seltxb and date >= v-dtb and date <= v-dte and p_f_payment.deluid = ? and
                           (p_f_payment.cod = 100 or p_f_payment.cod = 200 or p_f_payment.cod = 300) no-lock:

   v_to_076_n = v_to_076_n + 1.
   v_to_076_s = v_to_076_s + p_f_payment.amt.

end.

/* Социальные платежи */
for each commonpl where commonpl.txb = 0 and commonpl.grp = 15 and commonpl.date >= (v-dtb - 1) and commonpl.date <= (v-dte - 1) and commonpl.deluid = ? no-lock.
    create tcommonpl.
    buffer-copy commonpl to tcommonpl.
    assign tcommonpl.dep = get-dep(commonpl.uid, commonpl.date)
           tcommonpl.account = deparp_pmp(tcommonpl.dep). 
end.

for each tcommonpl no-lock:
   find first commonls where commonls.txb = seltxb and commonls.grp = 15 and visible = no 
                         and commonls.type = tcommonpl.type and lookup(commonls.knp,v-knp) > 0 no-lock no-error.
   if avail commonls then do:
      v_to_076s_n = v_to_076s_n + 1.
      v_to_076s_s = v_to_076s_s + tcommonpl.sum.
   end.
end.

/* Интернет платежи на филиалах */
for each comm.txb where comm.txb.consolid and comm.txb.bank ne 'TXB00' no-lock.
         if avail comm.txb then do:
            if connected ("txb") then disconnect "txb". 
            connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run plateg_txb(v-dtb,v-dte, output v-ibhkol_cl, output v-ibhsum_cl, output v-ibhkol_gr, output v-ibhsum_gr).
            if connected ("txb") then disconnect "txb". 
         end.
   
         v-dep = 1000 + integer(substr(comm.txb.bank, 4, 2)).
         find t-data where t-data.dep = v-dep no-error.
         if not avail t-data then do:
            create t-data.
            t-data.dep = v-dep.
         end.
         t-data.ibh-cl-n = t-data.ibh-cl-n + v-ibhkol_cl.
         t-data.ibh-cl-s = t-data.ibh-cl-s + v-ibhsum_cl.
         t-data.ibh-gr-n = t-data.ibh-gr-n + v-ibhkol_gr.
         t-data.ibh-gr-s = t-data.ibh-gr-s + v-ibhsum_gr.
end.        

def var v-str as char.

output to plateg.txt.

put stream v-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Отчет по внешним платежам</h2>" skip. 
put stream v-out unformatted  "<br> С " v-dtb "&nbsp;&nbsp;ПО " v-dte skip. 
put stream v-out unformatted  "<br> в тыс. тенге "  skip. 


put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                    style=""border-collapse: collapse"" style=""font-size:10px"">" skip. 

       put stream v-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>Подразделение </td>"
                         "<td>Количество</td>"
                         "<td>Сумма</td>"
                         "</tr>"
                          skip.



for each t-data :

/*  accumulate t-data.clr-n (TOTAL).
  accumulate t-data.clr-s (TOTAL).
*/
  find ppoint where ppoint.depart = t-data.dep no-lock no-error.
  if avail ppoint then v-str = ppoint.name.
  else do:
    if t-data.dep = 900 then next.
    else do :
       v-str = " Филиал " .
       case t-data.dep :
           when 1001 then v-str = v-str + "г. Астана"  .
           when 1002 then v-str = v-str + "г. Уральск" .
           when 1003 then v-str = v-str + "г. Атырау"  .
           otherwise v-str =  v-str + string (t-data.dep).
      end.

    end.
  end.


  if t-data.dep = 1 then do:

              put stream v-out unformatted "<tr>"
                                "<td><b>" v-str "</b></td>"
                                "<td></td>"
                                "<td></td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские обычные платежи"  "</td>"
                                "<td>" t-data.clr-n - (v_to_076_n + t-data.pens-ur-n + v_to_076s_n + t-data.sos-ur-n + t-data.tax-cl-n + t-data.ibh-cl-n + t-data.scn-cl-n + t-data.tam-cl-n + t-data.als-cl-n + t-data.ivs-cl-n + t-data.pro-cl-n) format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.clr-s / 1000 - (v_to_076_s + t-data.pens-ur-s + v_to_076s_s + t-data.sos-ur-s + t-data.tax-cl-s + t-data.ibh-cl-s + t-data.scn-cl-s + t-data.tam-cl-s + t-data.als-cl-s + t-data.ivs-cl-s + t-data.pro-cl-s) / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские интернет платежи"  "</td>"
                                "<td>" t-data.ibh-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ibh-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские сканированные платежи"  "</td>"
                                "<td>" t-data.scn-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.scn-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Пенсионные 076 физ. лиц"  "</td>"
                                "<td>" v_to_076_n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((v_to_076_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Пенсионные платежи юр.лиц </td>"
                                "<td>" t-data.pens-ur-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.pens-ur-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 v_to_pens_s = v_to_pens_s + t-data.pens-ur-s.
                                 v_to_pens_n = v_to_pens_n + t-data.pens-ur-n.

              put stream v-out unformatted "<tr>"
                                "<td>Социальные платежи физ. лиц"  "</td>"
                                "<td>" v_to_076s_n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((v_to_076s_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.
                                  
              put stream v-out unformatted "<tr>"
                                "<td>Социальные платежи юр.лиц </td>"
                                "<td>" t-data.sos-ur-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.sos-ur-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 v_to_sos_s = v_to_sos_s + t-data.sos-ur-s.
                                 v_to_sos_n = v_to_sos_n + t-data.sos-ur-n.
                                 
              put stream v-out unformatted "<tr>"
                                "<td>Налоговые платежи </td>"
                                "<td>" t-data.tax-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.tax-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

/*              put stream v-out unformatted "<tr>"
                                "<td>Клиринг"  "</td>"
                                "<td>" t-data.clr-n - (v_to_076_n + t-data.tax-cl-n + t-data.pens-ur-n) "</td>"
                                "<td>" (t-data.clr-s - (v_to_076_s + t-data.tax-cl-s + t-data.pens-ur-s)) / 1000 format "-zzz,zzz,zzz,zz9.99" "</td>"
                                "</tr>"
                                skip.
*/
                                 
              put stream v-out unformatted "<tr>"
                                "<td>Таможенные платежи"  "</td>"
                                "<td>" t-data.tam-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.tam-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Платежи АЛСЕКО"  "</td>"
                                "<td>" t-data.als-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.als-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Платежи ИВЦ"  "</td>"
                                "<td>" t-data.ivs-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ivs-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Прочие платежи"  "</td>"
                                "<td>" t-data.pro-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.pro-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Итого Клиринг"  "</td>"
                                "<td>" (t-data.clr-n /*+ t-data.pens-ur-n + v_to_076_n*/) format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string(((t-data.clr-s /*+ t-data.pens-ur-s + v_to_076_s*/) / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.

                                v_to_cl_s = v_to_cl_s + t-data.clr-s /*+ t-data.pens-ur-s + v_to_076_s*/.
                                v_to_cl_n = v_to_cl_n + t-data.clr-n /*+ t-data.pens-ur-n + v_to_076_n*/. /* t-data.pens-ur-n.*/
                                

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские обычные платежи"  "</td>"
                                "<td>" t-data.gro-n - (t-data.ibh-gr-n + t-data.scn-gr-n + t-data.tam-gr-n + t-data.als-gr-n + t-data.ivs-gr-n + t-data.pro-gr-n) format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string(((t-data.gro-s - t-data.ibh-gr-s + t-data.scn-gr-s + t-data.tam-gr-s + t-data.als-gr-s + t-data.ivs-gr-s + t-data.pro-gr-s) / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip. 

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские интернет платежи"  "</td>"
                                "<td>" t-data.ibh-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ibh-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские сканированные платежи"  "</td>"
                                "<td>" t-data.scn-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.scn-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Налоговые платежи </td>"
                                "<td>" t-data.tax-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.tax-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Таможенные платежи"  "</td>"
                                "<td>" t-data.tam-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.tam-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Платежи АЛСЕКО"  "</td>"
                                "<td>" t-data.als-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.als-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Платежи ИВЦ"  "</td>"
                                "<td>" t-data.ivs-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ivs-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Прочие платежи"  "</td>"
                                "<td>" t-data.pro-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.pro-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 
/*              put stream v-out unformatted "<tr>"
                                "<td>Гросс</td>"
                                "<td>" t-data.gro-n    "</td>"
                                "<td>" t-data.gro-s  / 1000 format "zzz,zzz,zzz,zz9.99" "</td>"
                                "</tr>"
                                 skip.
*/
                                 
              put stream v-out unformatted "<tr>"
                                "<td>Итого гросс"  "</td>"
                                "<td>" (t-data.gro-n + t-data.tax-gr-n) format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string(((t-data.gro-s + t-data.tax-gr-s) / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 v_to_gr_s = v_to_gr_s + t-data.gro-s + t-data.tax-gr-s .
                                 v_to_gr_n = v_to_gr_n + t-data.gro-n + t-data.tax-gr-n .

  end. else do:
              put stream v-out unformatted "<tr>"
                                "<td><b>" v-str "</b></td>"
                                "<td></td>"
                                "<td></td>"
                                "</tr>"
                                 skip.
              put stream v-out unformatted "<tr>"
                                "<td>Пенсионные платежи"  "</td>"
                                "<td>" t-data.pens-n format "-zzzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.pens-s / 1000),"->>>>>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 v_to_pens_s = v_to_pens_s + t-data.pens-s.
                                 v_to_pens_n = v_to_pens_n + t-data.pens-n.

              put stream v-out unformatted "<tr>"
                                "<td>Социальные платежи"  "</td>"
                                "<td>" t-data.sos-n format "-zzzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.sos-s / 1000),"->>>>>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

                                 v_to_sos_s = v_to_sos_s + t-data.sos-s.
                                 v_to_sos_n = v_to_sos_n + t-data.sos-n.
                                 
              put stream v-out unformatted "<tr>"
                                "<td>Клиентские обычные платежи"  "</td>"
                                "<td>" t-data.clr-n - t-data.ibh-cl-n - t-data.scn-cl-n - t-data.pens-n - t-data.sos-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string(((t-data.clr-s / 1000) - ((t-data.ibh-cl-s) / 1000)),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские интернет платежи"  "</td>"
                                "<td>" t-data.ibh-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ibh-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские сканированные платежи"  "</td>"
                                "<td>" t-data.scn-cl-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.scn-cl-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.
                                 
              put stream v-out unformatted "<tr>"
                                "<td>Итого Клиринг"  "</td>"
                                "<td>" t-data.clr-n "</td>"
                                "<td>" replace(string(((t-data.clr-s / 1000) + (t-data.pens-s / 1000)),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.
   
                                 v_to_cl_s = v_to_cl_s + t-data.clr-s.
                                 v_to_cl_n = v_to_cl_n + t-data.clr-n.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские обычные платежи"  "</td>"
                                "<td>" t-data.gro-n - t-data.ibh-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string(((t-data.gro-s / 1000) - (t-data.ibh-gr-s / 1000)),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Клиентские интернет платежи"  "</td>"
                                "<td>" t-data.ibh-gr-n format "-zzzzzzzzzzz9" "</td>"
                                "<td>" replace(string((t-data.ibh-gr-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.

              put stream v-out unformatted "<tr>"
                                "<td>Итого гросс"  "</td>"
                                "<td>" t-data.gro-n  "</td>"
                                "<td>" replace(string((t-data.gro-s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                 skip.
   
                                 v_to_gr_s = v_to_gr_s + t-data.gro-s.
                                 v_to_gr_n = v_to_gr_n + t-data.gro-n.

   end.
end.

              put stream v-out unformatted "<tr>"
                                "<td><b>Всего по подразделениям </b></td>"
                                "<td></td>"
                                "<td></td>"
                                "</tr>".


              put stream v-out unformatted "<tr>"
                                "<td>Пенсионные"  "</td>"
                                "<td>" v_to_pens_n  "</td>"
                                "<td>" replace(string((v_to_pens_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.

			  put stream v-out unformatted "<tr>"
                                "<td>Социальные"  "</td>"
                                "<td>" v_to_sos_n  "</td>"
                                "<td>" replace(string((v_to_sos_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.
                                
              put stream v-out unformatted "<tr>"
                                "<td>Всего Клиринг"  "</td>"
                                "<td>" v_to_cl_n  "</td>"
                                "<td>" replace(string((v_to_cl_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.

              put stream v-out unformatted "<tr>"
                                "<td>Всего Гросс"  "</td>"
                                "<td>"  v_to_gr_n  "</td>"
                                "<td>"  replace(string((v_to_gr_s / 1000),"->>>>>>>>>>>9.99"),'.',',') "</td>"
                                "</tr>"
                                skip.

output close.
output stream v-out close.
unix silent value("cptwin plateg.html excel").







