/* comm-arp2.i
 * MODULE

 * DESCRIPTION

 * RUN
        включаемый фаил
 * CALLER
        comm-arp1.p, kastiyn.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        02/06/2004 dpuchkov
 * CHANGES
        09/08/2005 suchkov - Переделал немного для возможности работы ЦО в выходные через кассу в пути.
        21/10/2005 sasco   - исправил проверку на 514 (кассу)
        12/06/2010 madiyar - при поиске транзитников проверяем признак закрытия счета
*/

    /* поискать кассу в пути свою для ЦО и каждого РКО */
    if s_account_b = "arp" then do:
      find sysc where sysc.sysc = "904kas" no-lock no-error.
      if not avail sysc then do:
        message skip " Не настроен счет кассы в пути по ГК 100200 (настройка 904kas)!"
                skip(1) view-as alert-box title " ОШИБКА ! ".
        return.
      end.

      find ofc where ofc.ofc = g-ofc no-lock no-error .
      if not available ofc then do:
         message "Вы не наш оффицер!!!" view-as alert-box.
         quit .
      end.

      if i_temp_dep = 1 and ofc.titcd <> "514" then do:
        s_account_b = sysc.chval.
      end.
      else do:
        for each arp where arp.gl = sysc.inval no-lock:
          if arp.crc <> 1 then next.

          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                             sub-cod.acc = arp.arp no-lock no-error.
          if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.

/*  ----- СТАРАЯ ПРОВЕРКА
          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                             sub-cod.acc = arp.arp no-lock no-error.
          if not avail sub-cod or (substr(sub-cod.ccode, 2, 2) <> string(i_temp_dep, "99") and sub-cod.ccode <> "514") then next.
*/
          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                             sub-cod.acc = arp.arp no-lock no-error.
          if not avail sub-cod then next.
          if ofc.titcd = "514" then
          do:
               if sub-cod.ccode <> "514" then next.  /* наша каса? */
          end.
          else do:
               if substr(sub-cod.ccode, 2, 2) <> string(i_temp_dep, "99") then next. /* РКО? */
          end.

          find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
          if avail sub-cod and sub-cod.ccode <> "msc" then next.

          s_account_b = arp.arp.
          leave.
        end.

        if s_account_b = "arp" then do:
          message skip " Не настроен счет кассы в пути 100200 для департамента данного офицера!"
                  skip(1) view-as alert-box title " ОШИБКА ! ".
          undo, return.
        end.
      end.
    end.  /* поиск АРП-счета кассы в пути */
