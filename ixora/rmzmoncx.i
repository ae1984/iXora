/* rmzmoncx.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Монитор очередей ПКО
        Разгребание платежей для показывания по источникам
 * RUN
        
 * CALLER
        rmzmon1.p -> rmzmon.i
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-13, 5-3-5-10
 * AUTHOR
        16/06/05 kanat
 * CHANGES
*/

find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
if avail remtrz and remtrz.fcrc = 1 then do:
  if remtrz.source = "IBH" then do:
    /* Интернет-платежи разбираем по департаменту, обслуживающему клиента */
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
  end.  /* end-of do*/
  else if remtrz.source = "SCN" then do:
    /* Интернет-платежи разбираем по департаменту, обслуживающему клиента */
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
    /* платежи по источнику, которые есть в справочнике - отдельными строками */
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

  find first rep where rep.cdep = deptmp no-error.
  if avail rep then do:

    if {&drlb} then assign
        drlb-cnt = drlb-cnt + 1
        drlb-sum = drlb-sum + remtrz.amt.

    if {&drpr} then assign
        drpr-cnt = drpr-cnt + 1
        drpr-sum = drpr-sum + remtrz.amt.

    if {&drlbg} then assign
        drlbg-cnt = drlbg-cnt + 1
        drlbg-sum = drlbg-sum + remtrz.amt. 

  end.

end.


