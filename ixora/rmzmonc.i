/* rmzmonc.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Монитор очередей
        Разгребание платежей для показывания по источникам
 * RUN
        
 * CALLER
        rmzmon1.p -> rmzmon.i
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-13, 5-3-5-10
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        04.11.2003 nadejda  - добавила новую строчку для Департамента регионального развития, источник PRR
        05.11.2003 nadejda  - сделала обработку любых очередей-источников из справочника depsibh
        12.11.2003 nadejda  - на всякий случай добавила условие по валюте = 1 на remtrz, а то на V1/V2 валютные платежи мешаются
        12.02.2004 nadejda  - условие avail rep, потому что при просмотре сотрудниками РКО теперь может не оказаться записи
        27.04.2005 suchkov  - добавил разбивку по сканированым платежам
        14.06.2005 - kanat - добавил информацию по сканированным платежам (по департаментам)
        08.08.2005 dpuchkov - добавил разбивку по инкассовым платежам
        05/10/2005 rundoll - добавил срочные платежи
*/


find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if avail remtrz and remtrz.fcrc = 1 then do:
  if remtrz.source = "IBH" then do:
    /* Интернет-платежи разбираем по департаменту, обслуживающему клиента */
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz  and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
    if avail sub-cod then deptmp = sub-cod.ccode.
    else do:
    find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
    find first cif where cif.cif = aaa.cif no-lock no-error.

    if cif.fname = "" then do:
      if cif.jame <> "" then
        v-dep = integer(cif.jame) mod 1000.
      else 
        v-dep = get-dep("superman", remtrz.rdt).
    end.
    else do:
      v-name = trim(substr(trim(cif.fname),1,8)).
      v-dep = get-dep(v-name, remtrz.rdt).
    end.
  
    deptmp = "I" + string(v-dep).
  end.
  end.  /* end-of do*/
  else if remtrz.source = "SCN" then do:
    /* Интернет-платежи разбираем по департаменту, обслуживающему клиента */
    find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz     and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
    if avail sub-cod then deptmp = sub-cod.ccode.
    else do:
  
    find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if avail aaa and avail cif then do:

    if cif.fname = "" then do:
      if cif.jame <> "" then
        v-dep = integer(cif.jame) mod 1000.
      else 
        v-dep = get-dep("superman", remtrz.rdt).
    end.
    else do:
      v-name = trim(substr(trim(cif.fname),1,8)).
      v-dep = get-dep(v-name, remtrz.rdt).
    end.
    end.
    deptmp = "S" + string(v-dep).
  end.
  end.  /* end-of do*/
  else if remtrz.source = "INK" then do:
    /* Инкассовые распоряжения */
    find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
    find first cif where cif.cif = aaa.cif no-lock no-error.
    if avail aaa and avail cif then do:

    if cif.fname = "" then do:
      if cif.jame <> "" then
        v-dep = integer(cif.jame) mod 1000.
      else 
        v-dep = get-dep("superman", remtrz.rdt).
    end.
    else do:
      v-name = trim(substr(trim(cif.fname),1,8)).
      v-dep = get-dep(v-name, remtrz.rdt).
    end.
    end.
    deptmp = string(v-dep).
  end.  /* end-of do*/
  else do:
    
         find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz     and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
         if avail sub-cod then deptmp = sub-cod.ccode.
     else do:   
 
    find first codfr where codfr.codfr = "depsibh" and codfr.code = remtrz.source no-lock no-error.
    if avail codfr then do:
      deptmp = remtrz.source.
    end.
    else do:
      /* филиальные - по банку-отправителю */
      if remtrz.sbank begins "TXB" and remtrz.sbank <> "TXB00" then 
        deptmp = remtrz.sbank.
      else do:

        /* все остальные платежи - по департаменту офицера */
        v-dep = get-dep(remtrz.rwho, remtrz.rdt).
        find first ppoint where ppoint.depart = v-dep no-lock no-error.
        if avail ppoint then deptmp = string(ppoint.depart).
                        else displ remtrz.remtrz remtrz.rwho get-dep(remtrz.rwho, remtrz.rdt).
  end.
  end.
  end.
  end.



  find first rep where rep.cdep = deptmp no-error.
  if avail rep then do:
    if {&lb} then assign
        lb-cnt = lb-cnt + 1
        lb-sum = lb-sum + remtrz.amt.    
    if {&lbg} then assign
        lbg-cnt = lbg-cnt + 1
        lbg-sum = lbg-sum + remtrz.amt.

  end.
end.


