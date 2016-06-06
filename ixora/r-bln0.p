/* r-bln0.p
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
        01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
        23.11.2004 saltanat - добавила вывод признака КИК только для 67 группы
*/

/* Ostatki po kreditam - Juris Omuls */
/* изменения от 10.05.2000 */

{mainhead.i}
{r-bln.f}.

define variable kopa1    as decimal.
define variable kopa11   as decimal.
define variable kopa2    as decimal.
define variable kopa3    as decimal.
define variable npk      as integer.
define variable ligums   as character.
define variable v-ligums as character.
define variable cifs     as character.
define variable v-cif    like cif.cif.
define variable n-cif    as integer.
define variable cifi     as character format "x(6)".
define variable ligumi   as character format "x(10)".
define variable krediti  as character format "x(10)".
define variable n        as integer.
define variable summa    as decimal.
define variable bilance  as decimal.
define variable proc     as decimal.
define variable i        as integer.
define variable jljdt    as date.
define variable lonis    like lon.lon.
define variable v-dt     as date format "99/99/9999".
define variable v-name   as character.
define variable v-name1  as character.
def var v-rate like crchis.rate[1].
define stream s1.
define stream s2.
def var v-lntreb as char init ''.

grupa = 10.
valuta = 1.
v-dt = g-today.

update v-dt label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .
if v-dt = g-today then run tb('Внимание!','День не закрыт.','Данные на текущий момент',string(v-dt)).

unix silent rm -f rpt.img.

repeat:
    display grupa valuta  with down centered frame grupa.
    set grupa valuta  go-on("PF3") with frame
           grupa.   
    display grupa valuta  gaidiet no-label with frame grupa.
        find longrp where longrp.longrp = grupa no-lock.
    output stream s2 to rpt.img append.
    kopa1 = 0.
    kopa11 = 0.
    kopa2 = 0.
    kopa3 = 0.
    npk = 0.
    put stream s2 skip(3).
    put stream s2 head0 + longrp.des format "x(51)" at 36
        gr-nos grupa format 'zz9' '  '
        val-nos valuta format 'z9' '  '
        'За ' v-dt.  
        if valuta = 1
        then put stream s2 ' (тыс.тенге)' skip.
        else do:
        put stream s2 ' Курс:'.
        find last crchis where crchis.crc = valuta and crchis.rdt le v-dt
                   no-lock .  
        v-rate = crchis.rate[1].
        put stream s2 v-rate  format "zzz.99" skip.
        end.
    run head-gr.
    put stream s2 unformatted head[1]
        skip
        head[2]
        skip.
    put stream s2 unformatted head[3]
        skip.
    n = 0.
    output stream s1 to drb.1.
    for each lon where lon.grp = grupa and lon.crc = valuta no-lock:
        if lon.dam[1] = 0 and lon.gua <> "OD"
        then next.
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= v-dt
             no-lock no-error.
        if not available ln%his
        then next.
        if lon.gua = "OD"
        then do:
             find aaa where aaa.aaa = lon.lcr no-lock.
             if aaa.crc <> valuta
             then next.
        end.
        n = n + 1.
        cifi = lon.cif.
        ligumi = '?         '.
        krediti = lon.lon.
        ligumi = ln%his.lcnt.
        export stream s1 
               cifi
               ligumi
               krediti.
    end.
    output stream s1 close.
    unix silent sort -f drb.1 > drb.2.
    v-ligums = 'S'.
    npk = 0.
    ligums = ' '.
    v-cif = "".
    n-cif = 0.
    input stream s1 from drb.2.
    repeat on endkey undo,leave:
        import stream s1 cifi ligumi krediti.
        find lon where lon.lon = krediti no-lock.
        find cif where cif.cif = lon.cif no-lock no-error.
        if lon.gua = "OD"
        then find aaa where aaa.aaa = lon.lcr no-lock.
        ligums = ligumi.
        if v-cif <> cif.cif
        then do:
             if v-cif <> "" and n-cif > 0 
             then do:
                  repeat while v-name1 <> "":
                     run rin-dal(input-output v-name1,output v-name,30).
                     put stream s2 v-name format "x(30)" at 42 skip.
                  end.
                  if n-cif > 1 and kopa1 + kopa11 > 0
                  then put stream s2 
                       space (75)
                       if valuta = 1
                       then kopa1 / 1000 
                       else kopa1 
                       format 'z,zzz,zzz,zzz,zz9.99'
                       if valuta = 1
                       then kopa11 / 1000 
                       else kopa11 format 'zzz,zzz,zz9.99'
                       ' ***'
                       skip.
             end.
             kopa1 = 0.
             kopa11 = 0.
             v-cif = cif.cif.
             v-name1 = trim(trim(cif.prefix) + " " + trim(cif.name)).
             n-cif = 0.
        end.
        if lon.gua = "OD"
        then lonis = aaa.aaa.
        else lonis = lon.lon.
        find last ln%his where ln%his.lon = lon.lon and ln%his.stdat <= v-dt
             no-lock.
        summa = ln%his.opnamt.
        proc = ln%his.intrate.

        /* Признак LNTREB */
        if grupa = 67 then do:
	find sub-cod where sub-cod.sub   = 'lon'
                       and sub-cod.d-cod = 'lntreb'
	               and sub-cod.acc   = lon.lon no-lock no-error.
	if avail sub-cod then
	     v-lntreb = sub-cod.ccode.
	else v-lntreb = ''.
	end.

        run atl-dat(lon.lon,v-dt,output bilance).
        if bilance > 0
        then do:
             n-cif = n-cif + 1.
             find last lnscg where lnscg.lng = lonis and
                  lnscg.f0 > - 1 and lnscg.flp > 0 no-lock no-error.
             find last lnsch where lnsch.lnn  = lonis and lnsch.f0 > - 1
                  and lnsch.flp > 0 and lnsch.fpn = 0 no-lock no-error.
             if not available lnscg
             then do:
                  if not available lnsch
                  then jljdt = ?.
                  else jljdt = lnsch.stdat.
             end.
             else do:
                  if not available lnsch
                  then jljdt = lnscg.stdat.
                  else jljdt = maximum(lnscg.stdat,lnsch.stdat).
             end.
             kopa11 = kopa11 + bilance.
             kopa1 = kopa1 + summa.
             kopa2 = kopa2 + summa.
             kopa3 = kopa3 + bilance.
             npk = npk + 1.
             run rin-dal(input-output v-name1,output v-name,30).
             if v-ligums <> ligums or ligums = '?'
             then put stream s2
                      npk format 'zz9' ' '
                      ligums format 'x(17)'
                      jljdt format '99/99/9999' '   '
                      lon.cif ' '
                      v-name format 'x(30)' ' '
                      lon.lon
                      if valuta = 1
                      then summa / 1000 
                      else summa 
                      format 'zz,zzz,zz9.99' ' '
                      if valuta = 1
                      then bilance / 1000 
                      else bilance 
                      format 'zz,zzz,zz9.99' ' '
                      ln%his.rdt ' '
                      ln%his.duedt ' '
                      proc format 'zz9.9999' '     '
                      if grupa = 67 then v-lntreb else '' skip.
             else put stream s2 
                      npk format 'zz9' ' '
                      '                 '
                      jljdt format '99/99/9999' '   '
                      '       '
                      v-name format 'x(31)'
                      lon.lon
                      if valuta = 1
                      then summa / 1000 
                      else summa
                      format 'zz,zzz,zz9.99' ' '
                      if valuta = 1
                      then bilance / 1000 
                      else bilance
                      format 'zz,zzz,zz9.99' ' '
                      ln%his.rdt ' '
                      ln%his.duedt ' '
                      proc format 'zz9.9999'
                      if grupa = 67 then v-lntreb else '' skip.
             v-ligums = ligums.
        end.
    end.
    if kopa1 + kopa11 > 0 and n-cif > 1
    then put stream s2 
            space (75)
            if valuta = 1
            then kopa1 / 1000
            else kopa1
            format 'z,zzz,zzz,zzz,zz9.99'
            if valuta = 1
            then kopa11 / 1000 
            else kopa11
            format 'zzz,zzz,zz9.99'
            ' ***' skip.
    put stream s2 unformatted head[1]
        skip.
    put stream s2
        space (60)
        'Итого:      '
        npk   format 'zz9' 
        if valuta = 1
        then kopa2 / 1000 
        else kopa2
        format 'z,zzz,zzz,zzz,zz9.99'
        if valuta = 1    
        then kopa3 / 1000 
        else kopa3 
        format 'z,zzz,zzz,zzz,zz9.99' skip.
    if valuta <> 1 then 
    put stream s2
    space (60)
    'в тенге        ' 
    kopa2 * v-rate format 'z,zzz,zzz,zzz,zz9.99'
    kopa3 * v-rate format 'z,zzz,zzz,zzz,zz9.99' skip.
    output stream s2 close.
    input stream s1 close.
    pause 0.
end.
if  not g-batch then do:
    pause 0.
    run menu-prt( 'rpt.img' ).
end.

procedure head-gr.
if grupa = 67 then do:
head[1] =
    '-------------------------------------------------------------------------' +
    '-------------------------------------------------------------------------------'.
head[2] =
    'Нпп:     Договор    :Посл.транз. : CIF  :    Н а и м е н о в а н и е   :' +
    '  Кредит  :   Сумма    :   Остаток   :Дата рег. :  Срок    :% ставка:Признак КИК' .

head[3] =
    '---:----------------:------------:------:------------------------------:' +
    '----------:------------:-------------:----------:----------:--------:-----------'.
end.

else do:

head[1] =
    '----------------------------------------------------------------------' +
    '----------------------------------------------------------------------'.
head[2] =
    'Нпп:     Договор    :Посл.транз. : CIF  :    Н а и м е н о в а н и е   :' +
    '  Кредит  :   Сумма    :   Остаток   :Дата рег. :  Срок    :% ставка' .
head[3] =
    '---:----------------:------------:------:------------------------------:' +
    '----------:------------:-------------:----------:----------:--------'.
end.
end procedure.
