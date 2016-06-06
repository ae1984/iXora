/* addtocurctrl.i
 * MODULE
        ГЕНРАТОР ТРАНЗАКЦИЙ
 * DESCRIPTION
        вставка записей в таблицу curctrl
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        trxgen0.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        25.09.2006 Natalya D. 
 * CHANGES        
        11/12/08 marinav - add if avail

*/
for each tmpl where tmpl.amt > 0 
                and tmpl.crgl = 220310
                and tmpl.crc <> 1 
                and lookup(substring(tmpl.cracc,4,3),'070,160') > 0 no-lock:    /*только для валютных счетов*/                                  
     
   create curctrl.
          curctrl.aaa     = tmpl.cracc.
          curctrl.gl      = tmpl.drgl.
          curctrl.crc     = tmpl.crc.
          curctrl.pamt    = tmpl.amt.
          curctrl.jh      = vjh.
          curctrl.jdt     = g-today.
          curctrl.pdocnum = vhref.  
/*Находим код назначения платежа*/
find first trxcods where trxcods.trxh = vjh and trxcods.codfr = 'spnpl' no-lock no-error.
/*в обычном зачислении на счёт*/
  if avail trxcods then v-cod = trxcods.code.
  else do:
/*в платежах*/
    find first jh where jh.jh = vjh no-lock no-error.
    if avail jh then do:
       find sub-cod where sub-cod.acc = jh.ref and sub-cod.d-cod = 'eknp' no-lock no-error.
       if avail sub-cod then v-cod = entry(3,sub-cod.rcode).
    end.
  end.

          curctrl.kpn     = v-cod.
    if tmpl.drgl = 287044 then 
          curctrl.sts     = 2.
    else do:
      if lookup(string(tmpl.drgl),'223730,255110') > 0 and lookup(v-cod,'780,880') > 0 then
          curctrl.sts     = 1.
      else   curctrl.sts  = 3.
    end.      
end.
/*от суммы зачисления отнимаем комиссии, находим чистую сумму*/
 for each tmpl where tmpl.amt > 0 
                and tmpl.crgl = 460410
                and tmpl.crc <> 1 no-lock.
        find last curctrl where curctrl.jh = vjh no-error. 
        if avail curctrl then curctrl.pamt = curctrl.pamt - tmpl.amt.
 end.